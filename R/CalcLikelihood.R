#' @name CalcLikelihood
#' @title Calculate the log likelihood of a document term matrix given a topic model
#' @param dtm The document term matrix of class \code{dgCMatrix}.
#' @param phi The phi matrix whose rows index topics and columns index words. 
#' The i, j entries are P(word_i | topic_j)  
#' @param theta The theta matrix whose rows index documents and columns index topics. 
#' The i, j entries are P(topic_i | document_j)
#' @description
#'     This function takes a DTM, phi matrix (P(word|topic)), and a theta matrix 
#'     (P(topic|document)) and returns a single value for the likelihood of the 
#'     data given the model.     
#' @return
#' Returns an object of class \code{numeric} corresponding to the log likelihood. 
#' @examples
#' # Load a pre-formatted dtm and topic model
#' data(acq2) 
#' 
#' # Get the likelihood of the data given the fitted model parameters
#' ll <- CalcLikelihood(dtm = dtm, phi = model$phi, theta = model$theta)
#' 
#' ll
#' @export
CalcLikelihood <- function(dtm, phi, theta){
  # ensure that all inputs are sorted correctly
  phi <- phi[ colnames(theta) , colnames(dtm) ]
  
  theta <- theta[ rownames(dtm) , ]
  
  # do in parallel in batches of about 3000 if we have more than 3000 docs
  if(nrow(dtm) > 3000){
    
    batches <- seq(1, nrow(dtm), by = 3000)
    
    data_divided <- lapply(batches, function(j){
      
      dtm_divided <- dtm[ j:min(j + 2999, nrow(dtm)) , ]
      
      theta_divided <- theta[ j:min(j + 2999, nrow(dtm)) , ]
      
      list(dtm_divided=dtm_divided, theta_divided=theta_divided)
    })
    
    result <-TmParallelApply(X = data_divided, FUN = function(x){
      CalcLikelihoodC(dtm=x$dtm_divided, 
                      phi=phi, 
                      theta=x$theta_divided)
    }, export=c("phi"))
    
    result <- sum(unlist(result))
    
    # do sequentially otherwise
  }else{
    result <- CalcLikelihoodC(dtm=dtm, phi=phi, theta=theta)
  }
  
  result  
}
