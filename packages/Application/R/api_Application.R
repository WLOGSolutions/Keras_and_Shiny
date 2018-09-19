#' @export
runApplication <- function(ui, server, port) {
  # INPUT: layout of the page, server logic function, port on localhost to run the app
  # OPERATIONS: run the app on selected port
  # OUTPUT: none

  app <- shinyApp(ui = ui, server = server)
  runApp(app, port = port)
}

#' @export
createTensor <- function(img_mtrx) {
  # INPUT: a single image pixel intensity "matrix" (in fact a tensor 28 x 28 x 1 that is the result of loadAndPrepareImage)
  # OPERATIONS: convert to a tensor 1 x 28 x 28 x 1 (to be compatible with model)
  # OUTPUT: a single image pixel intensity tensor (1 x 28 x 28 x 1)

  img_tensor <- array(dim = c(1, 28, 28, 1))
  img_tensor[1, , , ] <- img_mtrx

  return(img_tensor)
}

#' @export
predictClass <- function(model, data_tensor) {
  # INPUT: Keras model, a single pixel intenstity tensor 1 x 28 x 28 x 1
  # OPERATIONS: use the model to predict class on a new example
  # OUTPUT: a class label (digit 0-9 as character)

  class <- predict_classes(model, data_tensor)

  return(as.character(class))
}

#' @export
predictProbabilities <- function(model, data_tensor) {
  # INPUT: Keras model, a single pixel intenstity tensor 1 x 28 x 28 x 1
  # OPERATIONS: calculates class probabilities (the output of the softmax layer) and convert them into a data frame
  # OUTPUT: a data frame with class probabilities

  prob <- predict_proba(model, data_tensor)
  prob_df <- data.frame(class = as.character(0:9), probability = round(as.vector(prob), 5))

  return(prob_df)
}

# Re-exports:

#' @export
Modeling::loadModel

#' @export
DataPreparation::loadAndPrepareImage

#' @export
DataPreparation::normalizePixelIntensities
