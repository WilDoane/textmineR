#' Function to calculate R-squared of a topic model.
#' @description Function to calculate R-squared for a topic model. 
#' This uses a geometric interpretation of R-squared as the proportion of total distance 
#' each document is from the center of all the documents that is explained by the model. 
#'
#' @param dtm A documents by terms dimensional document term matrix of class
#' \code{dgCMatrix} or of class \code{matrix}. 
#'   
#' @param phi A topics by terms dimensional matrix where each entry is p(term_i |topic_j)
#' @param theta A documents by topics dimensional matrix where each entry is p(topic_j|document_d)
#' 
#' @return
#' Returns an object of class \code{numeric} representing the proportion of variability
#' in the data that is explained by the topic model.
#' @note
#' Will *not* work on DTMs from the \code{tm} package or simple triplet matrices from 
#' the \code{slam} package.     
#' @export
#' @examples
#' # Load a pre-formatted dtm and topic model
#' data(acq2) 
#' 
#' # Get the R-squared of the model
#' r2 <- CalcTopicModelR2(dtm = dtm, phi = model$phi, theta = model$theta)
#' 
#' r2



CalcTopicModelR2 <- function(dtm, phi, theta){
    
    # ensure that all inputs are sorted correctly
    phi <- phi[ colnames(theta) , colnames(dtm) ]
    
    theta <- theta[ rownames(dtm) , ]
    
    
    # get ybar, the "center" of the documents
    ybar <- Matrix::colMeans(dtm)
    
    # do in parallel in batches of about 3000 if we have more than 3000 docs
    if(nrow(dtm) > 3000){
      
      batches <- seq(1, nrow(dtm), by = 3000)
      
      data_divided <- lapply(batches, function(j){
        
        dtm_divided <- dtm[ j:min(j + 2999, nrow(dtm)) , ]
        
        theta_divided <- theta[ j:min(j + 2999, nrow(dtm)) , ]
        
        list(dtm_divided=dtm_divided, theta_divided=theta_divided)
      })
      
      result <-TmParallelApply(X = data_divided, FUN = function(x){
        CalcSumSquares(dtm = x$dtm_divided, 
                       phi = phi, 
                       theta = x$theta_divided, 
                       ybar=ybar)
      }, export=c("phi", "ybar"))
      
      result <- do.call(rbind, result)
      
      result <- 1 - sum(result[ , 1 ]) / sum(result[ , 2 ])
    
    # do sequentially otherwise
    }else{
      sum_squares <- CalcSumSquares(dtm = dtm,  phi = phi, theta = theta, ybar=ybar)
      
      result <- 1 - sum_squares[ 1 ] / sum_squares[ 2 ]
      
    }
    
    result
}