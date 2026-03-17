# Keras3 Workflows with TensorFlow Backend

Common workflows for building, training, and evaluating models using keras3 with TensorFlow backend in R.

## Image Classification

### Standard CNN

```r
library(keras3)

# Load data
c(c(x_train, y_train), c(x_test, y_test)) %<-% dataset_fashion_mnist()
x_train <- x_train / 255
x_test <- x_test / 255

# Model
model <- keras_model_sequential(input_shape = c(28, 28)) |>
  layer_conv_2d(32, 3, activation = "relu") |>
  layer_max_pooling_2d(2) |>
  layer_conv_2d(64, 3, activation = "relu") |>
  layer_max_pooling_2d(2) |>
  layer_flatten() |>
  layer_dropout(0.5) |>
  layer_dense(10, activation = "softmax")

# Compile and train
model |> compile(
  optimizer = optimizer_adam(),
  loss = loss_sparse_categorical_crossentropy(),
  metrics = c("accuracy")
)

history <- model |> fit(
  x_train, y_train,
  epochs = 10,
  validation_split = 0.2,
  callbacks = list(callback_early_stopping(patience = 3))
)

# Evaluate
model |> evaluate(x_test, y_test)
```

---

## Text Classification

### With Embedding Layer

```r
library(keras3)

# Preprocessing
max_features <- 10000
maxlen <- 200

# Load IMDB
c(c(x_train, y_train), c(x_test, y_test)) %<-% dataset_imdb(num_words = max_features)

# Pad sequences
x_train <- pad_sequences(x_train, maxlen = maxlen)
x_test <- pad_sequences(x_test, maxlen = maxlen)

# Model
model <- keras_model_sequential() |>
  layer_embedding(max_features, 128, input_length = maxlen) |>
  layer_lstm(64, dropout = 0.2, recurrent_dropout = 0.2) |>
  layer_dense(1, activation = "sigmoid")

model |> compile(
  optimizer = optimizer_adam(),
  loss = loss_binary_crossentropy(),
  metrics = c("accuracy")
)

model |> fit(x_train, y_train, epochs = 5, batch_size = 32,
             validation_split = 0.2)
```

### With TextVectorization Layer

```r
library(keras3)

# Sample text data
texts <- c("The movie was great!", "Terrible film", ...)
labels <- c(1, 0, ...)

# Text vectorization
text_vectorizer <- layer_text_vectorization(
  max_tokens = 10000,
  output_sequence_length = 100
)

# Adapt to vocabulary
text_vectorizer |> adapt(texts)

# End-to-end model
model <- keras_model_sequential() |>
  text_vectorizer |>
  layer_embedding(10000, 128) |>
  layer_global_average_pooling_1d() |>
  layer_dense(16, activation = "relu") |>
  layer_dropout(0.5) |>
  layer_dense(1, activation = "sigmoid")

model |> compile(
  optimizer = optimizer_adam(),
  loss = loss_binary_crossentropy(),
  metrics = c("accuracy")
)

# Train on raw text
model |> fit(texts, labels, epochs = 10, validation_split = 0.2)
```

---

## Time Series Forecasting

### LSTM for Univariate Forecasting

```r
library(keras3)

# Prepare sequences
create_sequences <- function(data, lookback = 60) {
  X <- list()
  y <- list()

  for (i in 1:(length(data) - lookback)) {
    X[[i]] <- data[i:(i + lookback - 1)]
    y[[i]] <- data[i + lookback]
  }

  list(
    X = array(unlist(X), dim = c(length(X), lookback, 1)),
    y = unlist(y)
  )
}

# Load and prepare data
data <- as.numeric(datasets::AirPassengers)
data_normalized <- (data - min(data)) / (max(data) - min(data))

sequences <- create_sequences(data_normalized, lookback = 12)

# Split
train_size <- floor(0.8 * nrow(sequences$X))
x_train <- sequences$X[1:train_size, , ]
y_train <- sequences$y[1:train_size]
x_test <- sequences$X[(train_size + 1):nrow(sequences$X), , ]
y_test <- sequences$y[(train_size + 1):length(sequences$y)]

# Model
model <- keras_model_sequential() |>
  layer_lstm(50, return_sequences = TRUE, input_shape = c(12, 1)) |>
  layer_dropout(0.2) |>
  layer_lstm(50, return_sequences = FALSE) |>
  layer_dropout(0.2) |>
  layer_dense(1)

model |> compile(
  optimizer = optimizer_adam(),
  loss = loss_mean_squared_error()
)

history <- model |> fit(
  x_train, y_train,
  epochs = 50,
  batch_size = 32,
  validation_data = list(x_test, y_test),
  callbacks = list(callback_early_stopping(patience = 10))
)

# Predict
predictions <- model |> predict(x_test)
```

---

## Transfer Learning

### Using Pretrained Model

```r
library(keras3)

# Load pretrained model
base_model <- application_resnet50(
  weights = "imagenet",
  include_top = FALSE,
  input_shape = c(224, 224, 3)
)

# Freeze base layers
base_model$trainable <- FALSE

# Add custom head
inputs <- keras_input(shape = c(224, 224, 3))
x <- base_model(inputs, training = FALSE)
x <- layer_global_average_pooling_2d()(x)
x <- layer_dropout(0.2)(x)
outputs <- layer_dense(x, 10, activation = "softmax")

model <- keras_model(inputs, outputs)

# Compile
model |> compile(
  optimizer = optimizer_adam(),
  loss = loss_categorical_crossentropy(),
  metrics = c("accuracy")
)

# Train
model |> fit(train_data, train_labels, epochs = 10)

# Fine-tune
base_model$trainable <- TRUE
model |> compile(
  optimizer = optimizer_adam(learning_rate = 1e-5),
  loss = loss_categorical_crossentropy()
)

model |> fit(train_data, train_labels, epochs = 5)
```

---

## Multi-Input Model (Functional API)

```r
library(keras3)

# Define inputs
text_input <- keras_input(shape = c(100), name = "text")
numeric_input <- keras_input(shape = c(10), name = "numeric")

# Text branch
text_features <- text_input |>
  layer_embedding(10000, 64) |>
  layer_lstm(32)

# Numeric branch
numeric_features <- numeric_input |>
  layer_dense(32, activation = "relu")

# Merge
merged <- layer_concatenate(c(text_features, numeric_features))

# Output
output <- merged |>
  layer_dense(64, activation = "relu") |>
  layer_dropout(0.5) |>
  layer_dense(1, activation = "sigmoid")

# Create model
model <- keras_model(
  inputs = list(text_input, numeric_input),
  outputs = output
)

model |> compile(
  optimizer = optimizer_adam(),
  loss = loss_binary_crossentropy(),
  metrics = c("accuracy")
)

# Train with multiple inputs
model |> fit(
  list(text_data, numeric_data),
  labels,
  epochs = 10
)
```

---

## Multi-Output Model

```r
library(keras3)

# Input
input <- keras_input(shape = c(100))

# Shared layers
shared <- input |>
  layer_dense(64, activation = "relu") |>
  layer_dropout(0.5)

# Output 1: Classification
output1 <- shared |>
  layer_dense(32, activation = "relu") |>
  layer_dense(10, activation = "softmax", name = "class_output")

# Output 2: Regression
output2 <- shared |>
  layer_dense(32, activation = "relu") |>
  layer_dense(1, name = "reg_output")

# Model
model <- keras_model(
  inputs = input,
  outputs = list(output1, output2)
)

model |> compile(
  optimizer = optimizer_adam(),
  loss = list(
    class_output = loss_categorical_crossentropy(),
    reg_output = loss_mean_squared_error()
  ),
  loss_weights = list(class_output = 1.0, reg_output = 0.5),
  metrics = list(
    class_output = c("accuracy"),
    reg_output = c("mae")
  )
)

# Train
model |> fit(
  x_train,
  list(y_class_train, y_reg_train),
  epochs = 10
)
```

---

## Autoencoder

```r
library(keras3)

# Encoder
encoder_input <- keras_input(shape = c(784))
encoded <- encoder_input |>
  layer_dense(128, activation = "relu") |>
  layer_dense(64, activation = "relu") |>
  layer_dense(32, activation = "relu")

encoder <- keras_model(encoder_input, encoded)

# Decoder
decoder_input <- keras_input(shape = c(32))
decoded <- decoder_input |>
  layer_dense(64, activation = "relu") |>
  layer_dense(128, activation = "relu") |>
  layer_dense(784, activation = "sigmoid")

decoder <- keras_model(decoder_input, decoded)

# Autoencoder
autoencoder_input <- keras_input(shape = c(784))
encoded_repr <- encoder(autoencoder_input)
reconstructed <- decoder(encoded_repr)

autoencoder <- keras_model(autoencoder_input, reconstructed)

autoencoder |> compile(
  optimizer = optimizer_adam(),
  loss = loss_binary_crossentropy()
)

# Train
autoencoder |> fit(
  x_train, x_train,  # Reconstruct input
  epochs = 50,
  batch_size = 256,
  validation_data = list(x_test, x_test)
)

# Extract features
encoded_data <- encoder |> predict(x_train)
```

---

## Callbacks

### Common Callbacks

```r
callbacks <- list(
  # Early stopping
  callback_early_stopping(
    monitor = "val_loss",
    patience = 10,
    restore_best_weights = TRUE
  ),

  # Model checkpoint
  callback_model_checkpoint(
    filepath = "best_model.keras",
    monitor = "val_accuracy",
    save_best_only = TRUE
  ),

  # Learning rate reduction
  callback_reduce_lr_on_plateau(
    monitor = "val_loss",
    factor = 0.5,
    patience = 5,
    min_lr = 1e-7
  ),

  # TensorBoard
  callback_tensorboard(log_dir = "logs"),

  # CSV logger
  callback_csv_logger("training.csv"),

  # Lambda (custom)
  callback_lambda(
    on_epoch_end = function(epoch, logs) {
      cat(sprintf("Epoch %d: loss=%.4f, val_loss=%.4f\n",
                  epoch, logs$loss, logs$val_loss))
    }
  )
)

model |> fit(x_train, y_train, epochs = 100, callbacks = callbacks)
```

### Custom Callback

```r
callback_custom <- new_keras_callback(
  "CustomCallback",

  initialize = function(threshold = 0.95) {
    self$threshold <- threshold
  },

  on_epoch_end = function(epoch, logs = NULL) {
    if (logs$val_accuracy >= self$threshold) {
      cat(sprintf("\nReached %.2f%% accuracy, stopping training!\n",
                  self$threshold * 100))
      self$model$stop_training <- TRUE
    }
  }
)

model |> fit(
  x_train, y_train,
  epochs = 100,
  callbacks = list(callback_custom(threshold = 0.95))
)
```

---

## Data Augmentation

### Image Augmentation

```r
# Define augmentation layers
data_augmentation <- keras_model_sequential() |>
  layer_random_flip("horizontal") |>
  layer_random_rotation(0.2) |>
  layer_random_zoom(0.2) |>
  layer_random_translation(height_factor = 0.2, width_factor = 0.2)

# Use in model
model <- keras_model_sequential(input_shape = c(224, 224, 3)) |>
  data_augmentation |>  # Only active during training
  layer_conv_2d(32, 3, activation = "relu") |>
  # ... rest of model
```

### Using image_dataset_from_directory

```r
train_ds <- image_dataset_from_directory(
  "data/train",
  validation_split = 0.2,
  subset = "training",
  seed = 123,
  image_size = c(224, 224),
  batch_size = 32
)

val_ds <- image_dataset_from_directory(
  "data/train",
  validation_split = 0.2,
  subset = "validation",
  seed = 123,
  image_size = c(224, 224),
  batch_size = 32
)

# Model with augmentation
model <- keras_model_sequential() |>
  layer_rescaling(1/255) |>
  data_augmentation |>
  layer_conv_2d(32, 3, activation = "relu") |>
  # ... rest of model

model |> fit(train_ds, validation_data = val_ds, epochs = 10)
```

---

## Mixed Precision Training

```r
# Enable mixed precision
policy <- tf$keras$mixed_precision$Policy("mixed_float16")
tf$keras$mixed_precision$set_global_policy(policy)

# Model automatically uses FP16
model <- keras_model_sequential() |>
  layer_dense(128, activation = "relu") |>
  layer_dense(10, activation = "softmax", dtype = "float32")  # Keep output FP32

model |> compile(
  optimizer = optimizer_adam(),
  loss = loss_sparse_categorical_crossentropy()
)

# ~2x speedup on compatible GPUs
model |> fit(x_train, y_train, epochs = 10)
```

---

## Distributed Training

```r
# MirroredStrategy for single-machine multi-GPU
strategy <- tf$distribute$MirroredStrategy()

cat("Number of devices:", strategy$num_replicas_in_sync, "\n")

# Create model within strategy scope
with(strategy$scope(), {
  model <- keras_model_sequential() |>
    layer_dense(128, activation = "relu") |>
    layer_dense(10, activation = "softmax")

  model |> compile(
    optimizer = optimizer_adam(),
    loss = loss_sparse_categorical_crossentropy(),
    metrics = c("accuracy")
  )
})

# Adjust batch size for all replicas
global_batch_size <- 32 * strategy$num_replicas_in_sync

# Train normally
model |> fit(x_train, y_train, batch_size = global_batch_size, epochs = 10)
```

---

## Model Serialization

```r
# Save complete model
save_model(model, "my_model.keras")

# Load model
loaded_model <- load_model("my_model.keras")

# Save weights only
model |> save_model_weights("weights.h5")
model |> load_model_weights("weights.h5")

# SavedModel format (for TF Serving)
save_model(model, "saved_model/1")

# Load SavedModel
model <- load_model("saved_model/1")

# Get/set config
config <- get_config(model)
new_model <- from_config(config)

# Clone model
cloned_model <- clone_model(model)
```

---

## Hyperparameter Tuning with keras_tuner

```r
# Not yet available in R keras3
# Use tfruns or manual grid search instead

library(tfruns)

# Define FLAGS in training script
FLAGS <- flags(
  flag_numeric("learning_rate", 0.001),
  flag_integer("units", 128),
  flag_numeric("dropout", 0.5)
)

# Training script uses FLAGS
model <- keras_model_sequential() |>
  layer_dense(FLAGS$units, activation = "relu") |>
  layer_dropout(FLAGS$dropout) |>
  layer_dense(10, activation = "softmax")

# Run grid search
runs <- tuning_run(
  "train.R",
  flags = list(
    learning_rate = c(0.001, 0.01),
    units = c(64, 128, 256),
    dropout = c(0.3, 0.5, 0.7)
  )
)

# Compare runs
compare_runs(runs)
```

---

## Summary

These workflows cover most common deep learning tasks in R using keras3 with TensorFlow backend:

- ✅ Image classification (CNN)
- ✅ Text classification (LSTM, embeddings, TextVectorization)
- ✅ Time series forecasting (LSTM)
- ✅ Transfer learning (pretrained models)
- ✅ Multi-input/multi-output models (Functional API)
- ✅ Autoencoders
- ✅ Callbacks (built-in and custom)
- ✅ Data augmentation
- ✅ Mixed precision training
- ✅ Distributed training
- ✅ Model serialization

For more advanced patterns, see SKILL.md main documentation.
