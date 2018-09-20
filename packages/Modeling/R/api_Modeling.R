#'
#' Prepare model architecture.
#'
#' @return Keras sequential model object with defined layers
#'
#' @export
#'
defineModelArchitecture <- function() {

  model_architecture <- keras_model_sequential() %>%
    layer_conv_2d(filters = 20, kernel_size = c(5, 5), strides = c(1, 1), input_shape = c(28, 28, 1)) %>%
    layer_max_pooling_2d(pool_size = c(2,2), strides = c(2, 2)) %>%
    layer_conv_2d(filters = 50, kernel_size = c(5, 5), strides = c(1, 1)) %>%
    layer_max_pooling_2d(pool_size = c(2,2), strides = c(2, 2)) %>%
    layer_flatten() %>%
    layer_dense(units = 120, activation = "relu") %>%
    layer_dense(units = 10, activation = "softmax")

  return (model_architecture)
}

#'
#' Compile keras model.
#'
#' @param model Keras sequential model object with defined layers
#'
#' @return compiled Keras model
#'
#' @export
#'
compileModel <- function(model) {

  model %>% compile(
    optimizer = optimizer_sgd(lr = 0.01),
    loss = "categorical_crossentropy",
    metrics = "accuracy")

  return(model)
}


#'
#' Fit model parameters.
#'
#' @param model compiled keras model
#' @param data training and validation data (output of splitDataset function)
#' @param epochs number of epochs
#' @param batch_size mini-batch size
#'
#' @return fitted keras model
#'
#' @export
#'
trainModel <- function(model, data, epochs = 30, batch_size = 256) {

  model %>% fit(data$data_tensor$train,
    data$labels$train,
    epochs = epochs,
    batch_size = batch_size,
    validation_data = list(data$data_tensor$valid, data$labels$valid))

  return(model)
}

#'
#' Calculate model accuracy.
#'
#' @param model fitted keras model
#' @param data data tensor N x 28 x 28 x 1
#' @param labels label one-hot encoded matrix
#'
#' @return Accuracy as percentage of properly classified examples
#'
#' @export
#'
calculateAccuracy <- function(model, data, labels) {
  acc <- evaluate(model, data, labels)$acc

  return(acc)
}

#'
#' Give model a name in the format "model_YYYYMMDD_HHMMSS" and save it to a given directory in HDF5 format.
#'
#' @param model keras model
#' @param model_created timestamp when the model was created
#' @param save_path a path to the folder where model should be saved
#'
#' @export
#'
saveModel <- function(model, model_created, save_path) {
  dir.create(save_path, showWarnings = FALSE)

  model_name <- paste0("model_", gsub(" ", "_", gsub("-|:", "", as.character(model_created))))
  model_fpath <- file.path(save_path, model_name)
  keras::save_model_hdf5(model, model_fpath)

  pkg_loginfo("Model '%s' saved.", model_name)
}

#'
#' Load model from the disk.
#'
#' @param fpath path to the HDF5 file containing the model
#'
#' @return loaded Keras model
#'
#' @export
#'
loadModel <- function(fpath) {
  model <- load_model_hdf5(fpath)

  return(model)
}
