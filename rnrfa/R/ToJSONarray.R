#' Transforms a data.frame into a JSON array in a format compatible with D3.js and Protovis
#' (source by: http://theweiluo.wordpress.com/2011/09/30/r-to-json-for-d3-js-and-protovis/)
#' 
#' @author Claudia Vitolo
#'
#' @description This function transforms a R data frame into a JSON array such that each row in R becomes an JSON object in the array. 
#' 
#' @details The rjson/RJSONIO packages convert a data frame into a JSON hashmap, in which each column of the data frame becomes a named array.
#'
#' @param dtf this is a data.frame
#'
#' @return JSON array in a format compatible with D3.js and Protovis
#' 
#' @export
#'
#' @examples
#' # ToJSONarray(dtf)
#'

ToJSONarray <- function(dtf){
  
  clnms <- colnames(dtf)
  
  name.value <- function(i){
    quote <- '';
    # if(class(dtf[, i])!='numeric'){
    if(class(dtf[, i])!='numeric' && class(dtf[, i])!= 'integer'){ # I modified this line so integers are also not enclosed in quotes
      quote <- '"';
    }
    
    paste('"', i, '" : ', quote, dtf[,i], quote, sep='')
  }
  
  objs <- apply(sapply(clnms, name.value), 1, function(x){paste(x, collapse=', ')})
  objs <- paste('{', objs, '}')
  
  # res <- paste('[', paste(objs, collapse=', '), ']')
  res <- paste('[', paste(objs, collapse=',\n'), ']') # added newline for formatting output
  
  return(res)
}
