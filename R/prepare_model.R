# Detect proper script_path (you cannot use args yet as they are build with tools in set_env.r)
script_path <- (function() {
  args <- commandArgs(trailingOnly = FALSE)
  script_path <- dirname(sub("--file=", "", args[grep("--file=", args)]))
  if (!length(script_path)) {
    return("R")
  }
  if (grepl("darwin", R.version$os)) {
    base <- gsub("~\\+~", " ", base) # on MacOS ~+~ in path denotes whitespace
  }
  return(normalizePath(script_path))
})()

# Setting .libPaths() to point to libs folder
source(file.path(script_path, "set_env.R"), chdir = T)

config <- load_config()
args <- args_parser()

###############################################################################

# Force using local Python environment
reticulate::use_python(python = file.path(script_path, "..", "conda"), require = TRUE)
loginfo("Python initialized.")

library(DataPreparation)
library(Modeling)

### 1. DATA PREPARATION

# Read the path to data (image files) and training subset fraction from the config
data_path <- normalizePath(config$data_path, winslash = "/")
train_fraction <- as.numeric(config$train_fraction)

# Read all images from "training" subfolder (a subset for training and validation) and convert them into a single pixel intensity matrix; append labels
subfolder <- "training"
loginfo("Started image processing (%s)...", subfolder)

trainvalid_data <- getAllImages(data_path, subfolder)

loginfo("Image processing complete.")

# Normalize pixel intensities
trainvalid_data$data_tensor <- normalizePixelIntensities(trainvalid_data$data_tensor)

# Convert vector of labels in to a one-hot encoded label matrix (a requirement for keras)
trainvalid_data$labels <- convertLabels(trainvalid_data$labels)

# Split data randomly into training and validation subsets
set.seed(1)
trainvalid_data <- splitDataset(trainvalid_data, training_fraction = train_fraction)

# Record the number of observations in training and validation subsets
nobs_train <- nrow(trainvalid_data$labels$train)
nobs_valid <- nrow(trainvalid_data$labels$valid)

### 2. MODEL TRAINING

# Neural network layer architecture
model <- defineModelArchitecture()

# Compile the model
model <- compileModel(model)

# Train the model
loginfo("Model training started...")
tic <- Sys.time()

model <- trainModel(model, trainvalid_data, epochs = 30, batch_size = 256)

toc <- Sys.time()
model_created <- toc
ltime <- difftime(toc, tic, "CET", "secs")

loginfo("Model training complete. Training time: %.1f secs", ltime)

# Calculate training and validation accuracy
acc_train <- calculateAccuracy(model, trainvalid_data$data_tensor$train, trainvalid_data$labels$train)
acc_valid <- calculateAccuracy(model, trainvalid_data$data_tensor$valid, trainvalid_data$labels$valid)

### 3. MODEL TESTING
# Read all images from "testing" subfolder (a subset for training and validation) and convert them into a single pixel intensity matrix; append labels
subfolder <- "testing"
loginfo("Started image processing (%s)...", subfolder)

test_data <- getAllImages(data_path, subfolder)

loginfo("Image processing complete.")

# Normalize pixel intensities
test_data$data_tensor <- normalizePixelIntensities(test_data$data_tensor)

# Convert vector of labels in to a one-hot encoded label matrix
test_data$labels <- convertLabels(test_data$labels)

# Record the number of observations in test set
nobs_test <- nrow(test_data$labels)

# Calculate testing accuracy
acc_test <- calculateAccuracy(model, test_data$data_tensor, test_data$labels)

### 4. MODEL SAVING
save_path <- file.path(script_path, "..", "models")

saveModel(model, model_created, save_path)

loginfo("Number of observations used to build the model: train=%s; valid=%s; test=%s;", nobs_train, nobs_valid, nobs_test)
loginfo("Model accuracy: train=%.4f; valid=%.4f; test=%.4f;", acc_train, acc_valid, acc_test)
