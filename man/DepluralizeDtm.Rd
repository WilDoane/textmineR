% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DepluralizeDtm.R
\name{DepluralizeDtm}
\alias{DepluralizeDtm}
\title{Run the CorrectS function on columns of a document term matrix.}
\usage{
DepluralizeDtm(dtm)
}
\arguments{
\item{dtm}{A document term matrix of class \code{dgCMatrix} whose colnames are tokens}
}
\value{
Returns a document term matrix of class \code{dgCMatrix}. The columns index
the de-pluralized tokens of the input document term matrix. In other words,
there will generally be fewer columns in the returned matrix than the
input matrix
}
\description{
Turns pluralizations of words in the columns of a document term 
matrix to their singular form. Then aggregates all columns that now have the 
same token. See example below.
}
\examples{
\dontrun{
myvec <- c("the quick brown fox eats chickens", 
           "the slow gray fox eats the slow chicken", 
           "look at my horse", "my horses are amazing")
           
names(myvec) <- paste("doc", 1:length(myvec), sep="_")

dtm <- Vec2Dtm(vec = myvec, min.n.gram = 1, max.n.gram = 1)

dtm_new <- DepluralizeDtm(dtm = dtm)
#' }
}

