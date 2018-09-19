#' @export
defineModelArchitecture <- function() {
  # INPUT: none
  # OPERATIONS: define model architecture
  # OUTPUT: Keras sequential model object with defined layers

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

#' @export
compileModel <- function(model) {
  # INPUT: Keras sequential model object with defined layers
  # OPERATIONS: compile the model
  # OUTPUT: compiled Keras model

  model %>% compile(
    optimizer = optimizer_sgd(lr = 0.01),
    loss = "categorical_crossentropy",
    metrics = "accuracy")

  return(model)
}

#' @export
trainModel <- function(model, data, epochs = 30, batch_size = 256) {
  # INPUT: compiled Keras model, training and validation data (output of splitDataset function), number of epochs and mini-batch size
  # OPERATIONS: train the model
  # OUTPUT: Keras model with calculated weigths

  model %>% fit(data$data_tensor$train,
    data$labels$train,
    epochs = epochs,
    batch_size = batch_size,
    validation_data = list(data$data_tensor$valid, data$labels$valid))

  return(model)
}

#' @export
calculateAccuracy <- function(model, data, labels) {
  # INPUT: Keras model, data tensor N x 28 x 28 x 1, label one-hot encoded matrix
  # OPERATIONS: calculate classification accuracy
  # OUTPUT: accuracy

  acc <- evaluate(model, data, labels)$acc

  return(acc)
}

#' @export
saveModel <- function(model, model_created, save_path = file.path(script_path, "..", "models")) {
  # INPUT: Keras model, timestamp when the model was created, a path to the folder where model should be saved
  # OPERATIONS: give model a name in the format "model_YYYYMMDD_HHMMSS" and save it to a given directory in HDF5 format
  # OUTPUT: none

  dir.create(save_path, showWarnings = FALSE)

  model_name <- paste0("model_", gsub(" ", "_", gsub("-|:", "", as.character(model_created))))
  model_fpath <- file.path(save_path, model_name)
  keras::save_model_hdf5(model, model_fpath)

  pkg_loginfo("Model '%s' saved.", model_name)
}

#' @export
loadModel <- function(fpath) {
  # INPUT: path to the HDF5 file containing the model
  # OPERATIONS: load the model
  # OUTPUT: Keras model

  model <- load_model_hdf5(fpath)

  return(model)
}

