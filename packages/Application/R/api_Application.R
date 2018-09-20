#'
#' run the app on selected port
#'
#' @param ui layout of the page
#' @param server server logic function
#' @param port port on localhost to run the app
#'
#' @export
#' 
runApplication <- function(ui, server, port) {
  app <- shinyApp(ui = ui, server = server)
  runApp(app, port = port)
}

#'
#' convert to a tensor 1 x 28 x 28 x 1 (to be compatible with model)
#'
#' @param img_mtrx a single image pixel intensity "matrix" (in fact a tensor 28 x 28 x 1 that is the result of loadAndPrepareImage)
#'
#' @return a single image pixel intensity tensor (1 x 28 x 28 x 1)
#' 
#' @export
#'
createTensor <- function(img_mtrx) {
  img_tensor <- array(dim = c(1, 28, 28, 1))
  img_tensor[1, , , ] <- img_mtrx

  return(img_tensor)
}

#'
#' use the model to predict class on a new example
#'
#' @param model Keras model
#' @param data_tensor a single pixel intenstity tensor 1 x 28 x 28 x 1
#'
#' @return a class label (digit 0-9 as character)
#'
#' @export
#'
predictClass <- function(model, data_tensor) {
  class <- predict_classes(model, data_tensor)

  return(as.character(class))
}

#'
#' calculates class probabilities (the output of the softmax layer) and convert them into a data frame
#'
#' @param model Keras model
#' @param data_tensor a single pixel intenstity tensor 1 x 28 x 28 x 1
#'
#' @return a data frame with class probabilities
#'  
#' @export
#' 
predictProbabilities <- function(model, data_tensor) {
    prob <- predict_proba(model, data_tensor)
    prob_df <- data.frame(class = as.character(0:9),
                          probability = round(as.vector(prob), 5))

    return(prob_df)
}
