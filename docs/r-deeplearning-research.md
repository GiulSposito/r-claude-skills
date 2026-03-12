# Deep Learning in R: Comprehensive Research for Claude Code Skill

This document consolidates comprehensive information about deep learning in R, focusing on torch, keras3, and torchaudio packages. This research supports building a comprehensive r-deeplearning skill for Claude Code.

**Last Updated:** 2026-03-11
**Primary Sources:**
- torch.mlverse.org
- keras3.posit.co
- Posit AI Blog (blogs.rstudio.com/ai)
- Official package documentation

---

## Core Concepts

### Torch Fundamentals

#### Tensors
Tensors are the fundamental data structure in torch, similar to multi-dimensional arrays with automatic differentiation support.

**Creation from R objects:**
```r
torch_tensor(c(1, 2, 3))
torch_tensor(matrix(1:10, ncol = 5, nrow = 2, byrow = TRUE))
torch_tensor(array(runif(12), dim = c(2, 2, 3)))
```

**Factory functions:**
- `torch_randn(5, 3)` - Normal distribution (mean 0, SD 1)
- `torch_ones()`, `torch_zeros()` - Filled tensors
- `torch_rand()` - Uniform [0, 1)
- `torch_randint()` - Random integers
- `torch_arange()`, `torch_linspace()`, `torch_logspace()` - Sequences
- `torch_eye()` - Identity matrix
- `torch_empty()` - Uninitialized tensor
- `torch_full()` - Single-value filled
- `torch_randperm()` - Random permutation

**Key parameters:**
- `dtype` - Data type (torch_long(), torch_float64(), etc.)
- `device` - "cpu" or "cuda" for GPU
- `requires_grad` - Enable automatic differentiation
- `pin_memory` - Allocate pinned memory for CPU tensors

**Device management:**
```r
y <- x$to(dtype = torch_int32())
y <- x$cuda()  # Move to GPU
```

#### Autograd
Automatic differentiation tracks operations to compute gradients automatically.

**Basic workflow:**
```r
x <- torch_tensor(3, requires_grad = TRUE)
o <- x^2
o$backward()  # Compute gradients
x$grad  # Access gradient: d/dx(x²) = 2x = 6 at x=3
```

**Gradient control:**
- `with_no_grad()` - Disable gradient tracking
- `autograd_backward()` - Compute gradients
- `autograd_function()` - Custom operations with autograd

#### Neural Network Modules

**Basic nn_module pattern:**
```r
dense <- nn_module(
  classname = "dense",
  initialize = function(in_features, out_features) {
    self$w <- nn_parameter(torch_randn(in_features, out_features))
    self$b <- nn_parameter(torch_zeros(out_features))
  },
  forward = function(x) {
    torch_mm(x, self$w) + self$b
  }
)

model <- dense(3, 1)
model$parameters  # Access all parameters
y_pred <- model(x)  # Forward pass
```

**Key concepts:**
- `initialize()` - Constructor called once during instantiation
- `forward()` - Execution logic called when model is invoked
- `nn_parameter()` - Mark tensors as trainable
- Parameters automatically tracked by nn_module

### Keras3 Fundamentals

#### Models and APIs

**Sequential API** - For linear layer stacks:
```r
model <- keras_model_sequential(input_shape = c(784))
model |>
  layer_dense(units = 256, activation = 'relu') |>
  layer_dropout(rate = 0.4) |>
  layer_dense(units = 128, activation = 'relu') |>
  layer_dropout(rate = 0.3) |>
  layer_dense(units = 10, activation = 'softmax')
```

**Functional API** - For complex topologies:
```r
inputs <- keras_input(shape = c(784))
outputs <- inputs |>
  layer_dense(units = 64, activation = "relu") |>
  layer_dense(units = 10)
model <- keras_model(inputs = inputs, outputs = outputs)
```

**When to use:**
- Sequential: Plain stack, one input/output, no sharing, no residuals
- Functional: Multiple inputs/outputs, residual connections, shared layers, DAG topologies

#### Training Workflow

**Compilation:**
```r
model |> compile(
  loss = 'categorical_crossentropy',
  optimizer = optimizer_rmsprop(learning_rate = 1e-3),
  metrics = c('accuracy')
)
```

**Training:**
```r
history <- model |> fit(
  x_train, y_train,
  epochs = 30,
  batch_size = 128,
  validation_split = 0.2,
  callbacks = list(
    callback_early_stopping(monitor = "val_loss", patience = 2),
    callback_model_checkpoint(filepath = "model_{epoch}.keras")
  )
)

plot(history)
```

**Evaluation and Prediction:**
```r
results <- model |> evaluate(x_test, y_test, batch_size = 128)
predictions <- model |> predict(x_test)
```

---

## Model Architecture Patterns

### Torch Architectures

#### Manual Training Loop Pattern

```r
# Setup
optimizer <- optim_adam(model$parameters, lr = 0.001)
loss_fn <- nn_cross_entropy_loss()

# Training loop
for (epoch in 1:num_epochs) {
  model$train()

  coro::loop(for (batch in train_dl) {
    # Forward pass
    optimizer$zero_grad()
    predictions <- model(batch[[1]])
    loss <- loss_fn(predictions, batch[[2]])

    # Backward pass
    loss$backward()
    optimizer$step()
  })

  # Validation
  model$eval()
  with_no_grad({
    # Compute validation metrics
  })
}
```

#### Custom Dataset

```r
custom_dataset <- dataset(
  name = "custom_dataset",
  initialize = function() {
    self$data <- self$prepare_data()
  },
  .getitem = function(index) {
    x <- self$data[index, 2:-1]
    y <- self$data[index, 1]$to(torch_long())
    list(x, y)
  },
  .length = function() {
    self$data$size()[[1]]
  },
  prepare_data = function() {
    # Data preparation logic
    torch_tensor(as.matrix(input))
  }
)

# Usage
ds <- custom_dataset()
dl <- ds %>% dataloader(batch_size = 32, shuffle = TRUE)
```

### Keras3 Architectures

#### Sequential for Simple CNNs

```r
model <- keras_model_sequential(input_shape = c(28, 28, 1))
model |>
  layer_conv_2d(filters = 32, kernel_size = c(3, 3), activation = 'relu') |>
  layer_max_pooling_2d(pool_size = c(2, 2)) |>
  layer_conv_2d(filters = 64, kernel_size = c(3, 3), activation = 'relu') |>
  layer_max_pooling_2d(pool_size = c(2, 2)) |>
  layer_flatten() |>
  layer_dropout(rate = 0.5) |>
  layer_dense(units = 10, activation = 'softmax')
```

#### Functional for Multi-Input Models

```r
# Text input
title_input <- keras_input(shape = c(100), name = "title")
title_features <- title_input |>
  layer_embedding(input_dim = 10000, output_dim = 64) |>
  layer_lstm(units = 32)

# Numeric input
body_input <- keras_input(shape = c(500), name = "body")
body_features <- body_input |>
  layer_embedding(input_dim = 10000, output_dim = 64) |>
  layer_lstm(units = 32)

# Combine
main <- layer_concatenate(list(title_features, body_features))
output <- main |>
  layer_dense(units = 64, activation = "relu") |>
  layer_dense(units = 1, activation = "sigmoid")

model <- keras_model(
  inputs = list(title_input, body_input),
  outputs = output
)
```

#### Residual Connections

```r
inputs <- keras_input(shape = c(32, 32, 3))

# Residual block
x <- inputs |>
  layer_conv_2d(32, 3, activation = "relu", padding = "same")

residual <- x

x <- x |>
  layer_conv_2d(32, 3, activation = "relu", padding = "same") |>
  layer_conv_2d(32, 3, padding = "same")

# Skip connection
x <- layer_add(list(x, residual)) |>
  layer_activation("relu")
```

---

## Training Workflows

### Torch Training Patterns

#### Basic Training Loop

```r
model <- my_net()
optimizer <- optim_adam(model$parameters, lr = 0.001)
criterion <- nn_mse_loss()

for (epoch in 1:epochs) {
  model$train()
  train_loss <- 0

  coro::loop(for (batch in train_dl) {
    # Zero gradients
    optimizer$zero_grad()

    # Forward pass
    output <- model(batch$x)
    loss <- criterion(output, batch$y)

    # Backward pass
    loss$backward()

    # Update weights
    optimizer$step()

    train_loss <- train_loss + loss$item()
  })

  # Validation phase
  model$eval()
  val_loss <- 0

  with_no_grad({
    coro::loop(for (batch in val_dl) {
      output <- model(batch$x)
      loss <- criterion(output, batch$y)
      val_loss <- val_loss + loss$item()
    })
  })

  cat(sprintf("Epoch %d - Train: %.4f, Val: %.4f\n",
              epoch, train_loss, val_loss))
}
```

#### GPU Training

```r
device <- if (cuda_is_available()) "cuda" else "cpu"

model <- my_net()$to(device = device)

coro::loop(for (batch in train_dl) {
  x <- batch$x$to(device = device)
  y <- batch$y$to(device = device)

  output <- model(x)
  loss <- criterion(output, y)
  # ... rest of training
})
```

#### Learning Rate Scheduling

```r
scheduler <- lr_step(optimizer, step_size = 10, gamma = 0.1)
# or
scheduler <- lr_cosine_annealing(optimizer, T_max = 50)
# or
scheduler <- lr_one_cycle(optimizer, max_lr = 0.1,
                          epochs = epochs, steps_per_epoch = steps)

# In training loop after optimizer$step()
scheduler$step()
```

### Keras3 Training Patterns

#### Custom Callbacks

```r
callback_loss_history <- Callback(
  classname = "LossHistory",
  on_train_begin = function(logs = NULL) {
    private$losses <- list()
  },
  on_epoch_end = function(epoch, logs = NULL) {
    private$losses <- c(private$losses, logs$loss)
    cat(sprintf("Epoch %d: loss = %.4f\n", epoch, logs$loss))
  }
)

history <- model |> fit(
  x_train, y_train,
  callbacks = list(callback_loss_history())
)
```

#### Custom Training Step

```r
CustomModel <- new_model_class(
  classname = "CustomModel",
  initialize = function(...) {
    super$initialize(...)
    # Build layers
  },
  train_step = function(data) {
    c(x, y) %<-% data

    # Compute loss with GradientTape
    with(tf$GradientTape() %as% tape, {
      y_pred <- self(x, training = TRUE)
      loss <- self$compute_loss(y = y, y_pred = y_pred)
    })

    # Compute gradients
    gradients <- tape$gradient(loss, self$trainable_variables)

    # Update weights
    self$optimizer$apply_gradients(
      zip_lists(gradients, self$trainable_variables)
    )

    # Update metrics
    for (metric in self$metrics) {
      if (metric$name == "loss") {
        metric$update_state(loss)
      } else {
        metric$update_state(y, y_pred)
      }
    }

    # Return metrics
    metric_results <- list()
    for (metric in self$metrics) {
      metric_results[[metric$name]] <- metric$result()
    }
    metric_results
  }
)
```

#### Custom Loss Functions

**Function-based:**
```r
custom_mse <- function(y_true, y_pred) {
  op_mean(op_square(y_true - y_pred), axis = -1)
}

model |> compile(
  loss = custom_mse,
  optimizer = optimizer_adam()
)
```

**Class-based with parameters:**
```r
loss_custom_mse <- Loss(
  classname = "CustomMSE",
  initialize = function(regularization_factor = 0.1, name = "custom_mse") {
    super$initialize(name = name)
    self$regularization_factor <- regularization_factor
  },
  call = function(y_true, y_pred) {
    mse <- op_mean(op_square(y_true - y_pred), axis = -1)
    reg <- op_mean(op_square(0.5 - y_pred), axis = -1)
    mse + reg * self$regularization_factor
  }
)

model |> compile(
  loss = loss_custom_mse(regularization_factor = 0.2)
)
```

#### Custom Metrics

```r
metric_categorical_true_positives <- Metric(
  "CategoricalTruePositives",
  initialize = function(name = "categorical_true_positives", ...) {
    super$initialize(name = name, ...)
    self$true_positives <- self$add_variable(
      shape = shape(),
      name = "ctp",
      initializer = "zeros"
    )
  },
  update_state = function(y_true, y_pred, sample_weight = NULL) {
    y_pred <- op_argmax(y_pred, axis = -1)
    y_true <- op_argmax(y_true, axis = -1)
    matches <- op_cast(op_equal(y_true, y_pred), "float32")
    self$true_positives$assign_add(op_sum(matches))
  },
  result = function() {
    self$true_positives$value
  },
  reset_state = function() {
    self$true_positives$assign(0.0)
  }
)
```

---

## Domain-Specific Patterns

### Computer Vision

#### CNN for Image Classification (Keras3)

```r
# MNIST ConvNet - 99% accuracy
model <- keras_model_sequential(input_shape = c(28, 28, 1))
model |>
  layer_conv_2d(filters = 32, kernel_size = c(3, 3), activation = 'relu') |>
  layer_max_pooling_2d(pool_size = c(2, 2)) |>
  layer_conv_2d(filters = 64, kernel_size = c(3, 3), activation = 'relu') |>
  layer_max_pooling_2d(pool_size = c(2, 2)) |>
  layer_flatten() |>
  layer_dropout(rate = 0.5) |>
  layer_dense(units = 10, activation = 'softmax')

model |> compile(
  loss = 'categorical_crossentropy',
  optimizer = optimizer_adam(),
  metrics = c('accuracy')
)

# Data preprocessing
x_train <- array_reshape(x_train, c(nrow(x_train), 28, 28, 1))
x_train <- x_train / 255
y_train <- to_categorical(y_train, 10)

history <- model |> fit(
  x_train, y_train,
  epochs = 15,
  batch_size = 128,
  validation_split = 0.1
)
```

#### Transfer Learning

```r
# Load pretrained model
base_model <- application_xception(
  weights = "imagenet",
  include_top = FALSE,
  input_shape = c(150, 150, 3)
)

# Freeze base layers
base_model$trainable <- FALSE

# Add custom head
inputs <- keras_input(shape = c(150, 150, 3))
x <- base_model(inputs, training = FALSE)
x <- x |>
  layer_global_average_pooling_2d() |>
  layer_dropout(0.2) |>
  layer_dense(units = 128, activation = "relu") |>
  layer_dense(units = num_classes, activation = "softmax")

model <- keras_model(inputs, x)

# Train top layers
model |> compile(
  optimizer = optimizer_adam(),
  loss = "categorical_crossentropy",
  metrics = c("accuracy")
)

model |> fit(train_data, epochs = 10)

# Fine-tuning: Unfreeze some layers
base_model$trainable <- TRUE
# Freeze first N layers
for (layer in base_model$layers[1:100]) {
  layer$trainable <- FALSE
}

# Recompile with low learning rate
model |> compile(
  optimizer = optimizer_adam(learning_rate = 1e-5),
  loss = "categorical_crossentropy",
  metrics = c("accuracy")
)

model |> fit(train_data, epochs = 10)
```

#### Data Augmentation

```r
# Keras3 augmentation layers
data_augmentation <- keras_model_sequential() |>
  layer_random_flip("horizontal") |>
  layer_random_rotation(0.2) |>
  layer_random_zoom(0.2) |>
  layer_random_brightness(0.2) |>
  layer_random_contrast(0.2)

# Include in model
inputs <- keras_input(shape = c(150, 150, 3))
x <- data_augmentation(inputs)
x <- base_model(x, training = FALSE)
outputs <- x |> layer_dense(units = num_classes, activation = "softmax")
model <- keras_model(inputs, outputs)
```

### Natural Language Processing

#### Text Classification

```r
# Text vectorization
max_tokens <- 20000
sequence_length <- 500

vectorize_layer <- layer_text_vectorization(
  max_tokens = max_tokens,
  output_sequence_length = sequence_length
)

# Adapt to training data
vectorize_layer |> adapt(text_train)

# Model with embeddings
model <- keras_model_sequential()
model |>
  layer_embedding(
    input_dim = max_tokens,
    output_dim = 128,
    input_length = sequence_length
  ) |>
  layer_conv_1d(filters = 128, kernel_size = 7, activation = "relu") |>
  layer_global_max_pooling_1d() |>
  layer_dense(units = 128, activation = "relu") |>
  layer_dropout(0.5) |>
  layer_dense(units = 1, activation = "sigmoid")

model |> compile(
  loss = "binary_crossentropy",
  optimizer = optimizer_adam(),
  metrics = c("accuracy")
)
```

#### LSTM for Sequences (Torch)

```r
lstm_model <- nn_module(
  classname = "lstm_classifier",
  initialize = function(vocab_size, embedding_dim, hidden_dim, output_dim) {
    self$embedding <- nn_embedding(vocab_size, embedding_dim)
    self$lstm <- nn_lstm(embedding_dim, hidden_dim, batch_first = TRUE)
    self$fc <- nn_linear(hidden_dim, output_dim)
  },
  forward = function(x) {
    # x: (batch, seq_len)
    embedded <- self$embedding(x)  # (batch, seq_len, emb_dim)
    lstm_out <- self$lstm(embedded)
    # Get last hidden state
    last_hidden <- lstm_out[[1]][, -1, ]  # (batch, hidden_dim)
    self$fc(last_hidden)
  }
)
```

#### Bidirectional LSTM (Keras3)

```r
model <- keras_model_sequential()
model |>
  layer_embedding(input_dim = vocab_size, output_dim = 128) |>
  layer_bidirectional(layer_lstm(units = 64)) |>
  layer_dropout(0.5) |>
  layer_dense(units = num_classes, activation = "softmax")
```

### Time Series and Recurrent Patterns

#### GRU/LSTM for Forecasting (Torch)

```r
rnn_model <- nn_module(
  classname = "rnn_forecaster",
  initialize = function(input_dim, hidden_dim, num_layers = 2) {
    self$gru <- nn_gru(
      input_size = input_dim,
      hidden_size = hidden_dim,
      num_layers = num_layers,
      batch_first = TRUE
    )
    self$fc <- nn_linear(hidden_dim, 1)
  },
  forward = function(x) {
    # x: (batch, seq_len, input_dim)
    gru_out <- self$gru(x)
    # Get output from last time step
    last_out <- gru_out[[1]][, -1, ]  # (batch, hidden_dim)
    self$fc(last_out)  # (batch, 1)
  }
)

# Training for time series
for (epoch in 1:epochs) {
  model$train()
  coro::loop(for (batch in train_dl) {
    optimizer$zero_grad()
    predictions <- model(batch$x)
    loss <- nn_mse_loss()(predictions, batch$y)
    loss$backward()
    optimizer$step()
  })
}
```

#### Convolutional LSTM

```r
# For spatiotemporal data (batch, time, channels, height, width)
convlstm_cell <- nn_module(
  classname = "convlstm_cell",
  initialize = function(input_dim, hidden_dim, kernel_size) {
    self$input_dim <- input_dim
    self$hidden_dim <- hidden_dim

    padding <- (kernel_size - 1) %/% 2

    # Gates: input, forget, output, cell
    self$conv <- nn_conv2d(
      in_channels = input_dim + hidden_dim,
      out_channels = 4 * hidden_dim,
      kernel_size = kernel_size,
      padding = padding
    )
  },
  forward = function(input, state) {
    h_cur <- state[[1]]
    c_cur <- state[[2]]

    # Concatenate input and hidden state
    combined <- torch_cat(list(input, h_cur), dim = 2)

    # Convolve and split into gates
    gates <- self$conv(combined)
    gates_split <- torch_split(gates, self$hidden_dim, dim = 2)

    i <- torch_sigmoid(gates_split[[1]])  # Input gate
    f <- torch_sigmoid(gates_split[[2]])  # Forget gate
    o <- torch_sigmoid(gates_split[[3]])  # Output gate
    g <- torch_tanh(gates_split[[4]])     # Cell gate

    # Update cell and hidden states
    c_next <- f * c_cur + i * g
    h_next <- o * torch_tanh(c_next)

    list(h_next, c_next)
  }
)
```

### Tabular Data

#### Deep Learning for Tabular (Keras3)

```r
# Entity embeddings for categorical variables
inputs <- list()
encoded <- list()

# Categorical inputs with embeddings
for (cat_col in categorical_columns) {
  input <- keras_input(shape = 1, name = cat_col)
  inputs[[cat_col]] <- input

  embedding <- input |>
    layer_embedding(
      input_dim = num_categories[[cat_col]],
      output_dim = embedding_dims[[cat_col]]
    ) |>
    layer_flatten()

  encoded[[cat_col]] <- embedding
}

# Numeric inputs
numeric_input <- keras_input(shape = length(numeric_columns), name = "numeric")
inputs[["numeric"]] <- numeric_input
encoded[["numeric"]] <- numeric_input

# Concatenate all features
all_features <- layer_concatenate(encoded)

# Dense layers
x <- all_features |>
  layer_dense(256, activation = "relu") |>
  layer_batch_normalization() |>
  layer_dropout(0.3) |>
  layer_dense(128, activation = "relu") |>
  layer_batch_normalization() |>
  layer_dropout(0.3) |>
  layer_dense(64, activation = "relu") |>
  layer_dense(1)

model <- keras_model(inputs = inputs, outputs = x)
```

---

## Audio Deep Learning Specifics

### Audio Classification with Torch and Torchaudio

Based on the Posit AI blog tutorial "Simple Audio Classification with torch" (2021-02-04), here's the complete workflow:

#### Data Loading

```r
library(torch)
library(torchaudio)

# Speech Commands dataset
train_ds <- speechcommand_dataset(
  root = "data",
  url = "speech_commands_v0.01",
  download = TRUE
)

test_ds <- speechcommand_dataset(
  root = "data",
  url = "speech_commands_v0.01",
  download = TRUE,
  subset = "testing"
)
```

#### Custom Collate Function for Variable-Length Audio

```r
# Pad sequences to consistent length
collate_fn <- function(batch) {
  # Extract waveforms and labels
  waveforms <- lapply(batch, function(x) x$waveform)
  labels <- sapply(batch, function(x) x$label_index)

  # Pad to max length (16001 samples)
  max_len <- 16001
  padded <- lapply(waveforms, function(w) {
    if (w$size(2) < max_len) {
      # Pad with zeros
      padding <- torch_zeros(1, max_len - w$size(2))
      torch_cat(list(w, padding), dim = 2)
    } else {
      w[, 1:max_len]
    }
  })

  # Stack into batch
  tensors <- torch_stack(padded)
  targets <- torch_tensor(labels)

  list(tensors = tensors, targets = targets)
}

# DataLoader with custom collate
train_dl <- dataloader(
  train_ds,
  batch_size = 128,
  shuffle = TRUE,
  collate_fn = collate_fn,
  num_workers = 16
)
```

#### Audio CNN Model with Spectrogram

```r
audio_cnn <- nn_module(
  classname = "AudioCNN",
  initialize = function(num_classes = 30) {
    # Spectrogram transformation (integrated in forward pass)
    # FFT: 30ms windows, 10ms stride -> 257x101 spectrogram
    self$spectrogram <- transform_spectrogram(
      n_fft = 480,
      win_length = 480,
      hop_length = 160,
      power = 2
    )

    # Conv block 1
    self$conv1 <- nn_conv2d(1, 32, kernel_size = c(3, 3))
    self$bn1 <- nn_batch_norm2d(32)
    self$pool1 <- nn_max_pool2d(c(2, 2))
    self$dropout1 <- nn_dropout2d(0.25)

    # Conv block 2
    self$conv2 <- nn_conv2d(32, 64, kernel_size = c(3, 3))
    self$bn2 <- nn_batch_norm2d(64)
    self$pool2 <- nn_max_pool2d(c(2, 2))
    self$dropout2 <- nn_dropout2d(0.25)

    # Conv block 3
    self$conv3 <- nn_conv2d(64, 128, kernel_size = c(3, 3))
    self$bn3 <- nn_batch_norm2d(128)
    self$pool3 <- nn_max_pool2d(c(2, 2))
    self$dropout3 <- nn_dropout2d(0.25)

    # Conv block 4
    self$conv4 <- nn_conv2d(128, 256, kernel_size = c(3, 3))
    self$bn4 <- nn_batch_norm2d(256)
    self$pool4 <- nn_max_pool2d(c(2, 2))
    self$dropout4 <- nn_dropout2d(0.25)

    # Dense layers (adjust size based on spectrogram dimensions)
    self$flatten <- nn_flatten()
    self$fc1 <- nn_linear(256 * 13 * 4, 128)  # Calculated from output shape
    self$fc_dropout <- nn_dropout(0.5)
    self$fc2 <- nn_linear(128, num_classes)
  },

  forward = function(x) {
    # x: (batch, 1, 16001) - raw waveform

    # Generate spectrogram
    x <- self$spectrogram(x)  # (batch, 1, 257, 101)

    # Add small constant and log scale
    x <- torch_log(x + 1e-9)

    # Conv blocks
    x <- self$conv1(x) %>%
      nnf_relu() %>%
      self$bn1() %>%
      self$pool1() %>%
      self$dropout1()

    x <- self$conv2(x) %>%
      nnf_relu() %>%
      self$bn2() %>%
      self$pool2() %>%
      self$dropout2()

    x <- self$conv3(x) %>%
      nnf_relu() %>%
      self$bn3() %>%
      self$pool3() %>%
      self$dropout3()

    x <- self$conv4(x) %>%
      nnf_relu() %>%
      self$bn4() %>%
      self$pool4() %>%
      self$dropout4()

    # Dense layers
    x <- self$flatten(x)
    x <- self$fc1(x) %>%
      nnf_relu() %>%
      self$fc_dropout()

    self$fc2(x)  # (batch, num_classes)
  }
)
```

#### Training Loop for Audio Classification

```r
device <- if (cuda_is_available()) "cuda" else "cpu"
model <- audio_cnn(num_classes = 30)$to(device = device)

optimizer <- optim_adadelta(model$parameters, rho = 0.95, eps = 1e-7)
criterion <- nn_cross_entropy_loss()

num_epochs <- 20

for (epoch in 1:num_epochs) {
  model$train()
  train_loss <- 0
  train_acc <- 0
  num_batches <- 0

  coro::loop(for (batch in train_dl) {
    # Move to device
    x <- batch$tensors$to(device = device)
    y <- batch$targets$to(device = device)

    # Forward pass
    optimizer$zero_grad()
    predictions <- model(x)
    loss <- criterion(predictions, y)

    # Backward pass
    loss$backward()
    optimizer$step()

    # Metrics
    train_loss <- train_loss + loss$item()
    pred_classes <- torch_argmax(predictions, dim = 2)
    train_acc <- train_acc + (pred_classes == y)$sum()$item() / y$size(1)
    num_batches <- num_batches + 1
  })

  # Validation
  model$eval()
  val_loss <- 0
  val_acc <- 0
  num_val_batches <- 0

  with_no_grad({
    coro::loop(for (batch in val_dl) {
      x <- batch$tensors$to(device = device)
      y <- batch$targets$to(device = device)

      predictions <- model(x)
      loss <- criterion(predictions, y)

      val_loss <- val_loss + loss$item()
      pred_classes <- torch_argmax(predictions, dim = 2)
      val_acc <- val_acc + (pred_classes == y)$sum()$item() / y$size(1)
      num_val_batches <- num_val_batches + 1
    })
  })

  cat(sprintf(
    "Epoch %d/%d - Train Loss: %.4f, Train Acc: %.2f%%, Val Loss: %.4f, Val Acc: %.2f%%\n",
    epoch, num_epochs,
    train_loss / num_batches,
    100 * train_acc / num_batches,
    val_loss / num_val_batches,
    100 * val_acc / num_val_batches
  ))
}

# Results: ~87.7% validation accuracy on Speech Commands
```

### Torchaudio Transformations

Key audio transformations available in torchaudio:

```r
# Spectrogram (STFT power)
spec_transform <- transform_spectrogram(
  n_fft = 512,           # FFT size
  win_length = 400,      # Window length
  hop_length = 160,      # Hop between windows
  power = 2              # Power spectrogram (magnitude squared)
)

# Mel-spectrogram
mel_transform <- transform_mel_spectrogram(
  sample_rate = 16000,
  n_fft = 512,
  win_length = 400,
  hop_length = 160,
  n_mels = 64,           # Number of mel bands
  f_min = 0,
  f_max = 8000
)

# MFCC (Mel-Frequency Cepstral Coefficients)
mfcc_transform <- transform_mfcc(
  sample_rate = 16000,
  n_mfcc = 13,           # Number of coefficients
  melkwargs = list(
    n_fft = 512,
    n_mels = 64,
    hop_length = 160
  )
)

# Apply transformations
waveform <- torchaudio_load("audio.wav")
spectrogram <- spec_transform(waveform$tensor)
mel_spec <- mel_transform(waveform$tensor)
mfcc <- mfcc_transform(waveform$tensor)

# Log scaling for better visualization
log_mel_spec <- torch_log(mel_spec + 1e-9)
```

### CRNN for Audio (Convolutional-Recurrent)

```r
audio_crnn <- nn_module(
  classname = "AudioCRNN",
  initialize = function(num_classes, n_mels = 64) {
    # Mel-spectrogram transformation
    self$mel_transform <- transform_mel_spectrogram(
      sample_rate = 16000,
      n_mels = n_mels,
      n_fft = 512,
      hop_length = 160
    )

    # CNN for frequency patterns
    self$conv1 <- nn_conv2d(1, 32, kernel_size = c(3, 3), padding = 1)
    self$bn1 <- nn_batch_norm2d(32)
    self$pool1 <- nn_max_pool2d(c(2, 2))

    self$conv2 <- nn_conv2d(32, 64, kernel_size = c(3, 3), padding = 1)
    self$bn2 <- nn_batch_norm2d(64)
    self$pool2 <- nn_max_pool2d(c(2, 2))

    self$conv3 <- nn_conv2d(64, 128, kernel_size = c(3, 3), padding = 1)
    self$bn3 <- nn_batch_norm2d(128)
    self$pool3 <- nn_max_pool2d(c(2, 2))

    # RNN for temporal patterns
    # Input after CNN: (batch, 128, n_mels/8, time/8)
    # Reshape to (batch, time/8, 128*n_mels/8) for RNN
    self$lstm <- nn_lstm(
      input_size = 128 * (n_mels %/% 8),
      hidden_size = 128,
      num_layers = 2,
      batch_first = TRUE,
      bidirectional = TRUE
    )

    # Output layer
    self$fc <- nn_linear(128 * 2, num_classes)  # *2 for bidirectional
    self$dropout <- nn_dropout(0.5)
  },

  forward = function(x) {
    # x: (batch, 1, samples)

    # Mel-spectrogram
    x <- self$mel_transform(x)  # (batch, 1, n_mels, time)
    x <- torch_log(x + 1e-9)

    # CNN layers
    x <- self$conv1(x) %>% nnf_relu() %>% self$bn1() %>% self$pool1()
    x <- self$conv2(x) %>% nnf_relu() %>% self$bn2() %>% self$pool2()
    x <- self$conv3(x) %>% nnf_relu() %>% self$bn3() %>% self$pool3()

    # Reshape for RNN: (batch, channels, freq, time) -> (batch, time, channels*freq)
    batch_size <- x$size(1)
    time_steps <- x$size(4)
    x <- x$permute(c(1, 4, 2, 3))  # (batch, time, channels, freq)
    x <- x$reshape(c(batch_size, time_steps, -1))

    # LSTM
    lstm_out <- self$lstm(x)
    # Use output from all time steps or just last
    x <- lstm_out[[1]]  # (batch, time, hidden*2)

    # Global average pooling over time
    x <- x$mean(dim = 2)  # (batch, hidden*2)

    # Classification
    x <- self$dropout(x)
    self$fc(x)
  }
)
```

### Audio Data Augmentation

```r
# Time stretching
time_stretch <- transform_time_stretch(n_freq = 257, fixed_rate = 1.2)

# Pitch shifting
pitch_shift <- function(waveform, sample_rate, n_steps) {
  # Shift by n_steps semitones
  rate <- 2^(n_steps / 12)
  torchaudio_functional_resample(
    waveform,
    orig_freq = sample_rate,
    new_freq = as.integer(sample_rate * rate)
  )
}

# Add noise
add_noise <- function(waveform, noise_level = 0.005) {
  noise <- torch_randn_like(waveform) * noise_level
  waveform + noise
}

# Time masking (SpecAugment)
time_mask <- function(spectrogram, mask_param = 20) {
  time_dim <- spectrogram$size(-1)
  mask_length <- sample(1:mask_param, 1)
  mask_start <- sample(1:(time_dim - mask_length), 1)

  spectrogram[.., mask_start:(mask_start + mask_length)] <- 0
  spectrogram
}

# Frequency masking (SpecAugment)
freq_mask <- function(spectrogram, mask_param = 10) {
  freq_dim <- spectrogram$size(-2)
  mask_length <- sample(1:mask_param, 1)
  mask_start <- sample(1:(freq_dim - mask_length), 1)

  spectrogram[.., mask_start:(mask_start + mask_length), ] <- 0
  spectrogram
}

# Augmentation pipeline
augment_audio <- function(waveform, sample_rate) {
  # Random time stretch
  if (runif(1) > 0.5) {
    rate <- runif(1, 0.8, 1.2)
    waveform <- torchaudio_functional_time_stretch(waveform, rate)
  }

  # Random pitch shift
  if (runif(1) > 0.5) {
    n_steps <- sample(-2:2, 1)
    waveform <- pitch_shift(waveform, sample_rate, n_steps)
  }

  # Add noise
  if (runif(1) > 0.5) {
    waveform <- add_noise(waveform, noise_level = runif(1, 0.001, 0.01))
  }

  waveform
}

# Use in dataset
augmented_dataset <- dataset(
  name = "augmented_audio_dataset",
  initialize = function(audio_files) {
    self$audio_files <- audio_files
  },
  .getitem = function(index) {
    audio <- torchaudio_load(self$audio_files[index])
    waveform <- audio$tensor

    # Apply augmentation during training
    waveform <- augment_audio(waveform, audio$sample_rate)

    list(waveform = waveform, label = self$labels[index])
  },
  .length = function() {
    length(self$audio_files)
  }
)
```

---

## Best Practices

### General Deep Learning Practices

#### Data Handling

1. **Train/Val/Test Split**: Always use separate validation and test sets
   ```r
   # Stratified split
   indices <- 1:nrow(data)
   train_idx <- sample(indices, 0.7 * length(indices))
   remaining <- setdiff(indices, train_idx)
   val_idx <- sample(remaining, 0.5 * length(remaining))
   test_idx <- setdiff(remaining, val_idx)
   ```

2. **Data Normalization**: Normalize inputs for faster convergence
   ```r
   # Keras3
   x_train <- (x_train - mean(x_train)) / sd(x_train)

   # Torch - use running statistics
   normalizer <- transform_normalize(
     mean = c(0.485, 0.456, 0.406),
     std = c(0.229, 0.224, 0.225)
   )
   ```

3. **Data Loading**: Use efficient data loaders
   ```r
   # Torch with parallel workers
   dl <- dataloader(
     dataset,
     batch_size = 32,
     shuffle = TRUE,
     num_workers = 4,
     pin_memory = TRUE  # For GPU
   )
   ```

#### Regularization

1. **Dropout**: Prevent overfitting
   ```r
   # Keras3
   layer_dropout(rate = 0.5)

   # Torch
   self$dropout <- nn_dropout(p = 0.5)
   ```

2. **Batch Normalization**: Stabilize training
   ```r
   # Keras3
   layer_batch_normalization()

   # Torch
   self$bn <- nn_batch_norm2d(num_features)
   ```

3. **Weight Decay/L2 Regularization**:
   ```r
   # Keras3
   layer_dense(
     units = 128,
     kernel_regularizer = regularizer_l2(0.01)
   )

   # Torch optimizer
   optimizer <- optim_adam(model$parameters, lr = 0.001, weight_decay = 1e-5)
   ```

4. **Early Stopping**:
   ```r
   # Keras3
   callback_early_stopping(
     monitor = "val_loss",
     patience = 5,
     restore_best_weights = TRUE
   )
   ```

#### Optimization

1. **Learning Rate Scheduling**:
   ```r
   # Keras3
   lr_schedule <- learning_rate_schedule_exponential_decay(
     initial_learning_rate = 0.1,
     decay_steps = 10000,
     decay_rate = 0.96
   )
   optimizer <- optimizer_adam(learning_rate = lr_schedule)

   # Torch
   scheduler <- lr_cosine_annealing(optimizer, T_max = 50)
   scheduler$step()  # Call after optimizer$step()
   ```

2. **Gradient Clipping**:
   ```r
   # Torch
   nn_utils_clip_grad_norm_(model$parameters, max_norm = 1.0)
   ```

3. **Mixed Precision Training** (Torch):
   ```r
   # For faster training on modern GPUs
   scaler <- cuda_amp_grad_scaler()

   for (epoch in 1:epochs) {
     coro::loop(for (batch in train_dl) {
       optimizer$zero_grad()

       with_cuda_amp_autocast({
         output <- model(batch$x)
         loss <- criterion(output, batch$y)
       })

       scaler$scale(loss)$backward()
       scaler$step(optimizer)
       scaler$update()
     })
   }
   ```

#### Model Checkpointing

```r
# Keras3
callback_model_checkpoint(
  filepath = "model_{epoch:02d}_{val_loss:.4f}.keras",
  save_best_only = TRUE,
  monitor = "val_loss"
)

# Torch
if (val_loss < best_loss) {
  best_loss <- val_loss
  torch_save(model$state_dict(), "best_model.pt")
}

# Load model
model$load_state_dict(torch_load("best_model.pt"))
```

### Domain-Specific Best Practices

#### Computer Vision

1. **Transfer Learning First**: Start with pretrained models (ImageNet)
2. **Data Augmentation**: Essential for small datasets
3. **Progressive Resizing**: Start with smaller images, increase size
4. **Test-Time Augmentation**: Average predictions over multiple augmented versions

#### NLP

1. **Pretrained Embeddings**: Use GloVe, Word2Vec, or contextual embeddings
2. **Padding/Truncation**: Consistent sequence lengths
3. **Vocabulary Management**: Limit vocab size, handle unknown tokens
4. **Attention Mechanisms**: Improve interpretability and performance

#### Audio

1. **Spectrogram Features**: Log-mel spectrograms work best for most tasks
2. **Normalization**: Per-sample or per-dataset normalization critical
3. **Window Length**: 25-30ms typical for speech, longer for music
4. **Augmentation**: Time/frequency masking (SpecAugment), noise, time stretch
5. **Context Windows**: Sufficient context (2-5 seconds typical)

#### Time Series

1. **Sequence Length**: Balance between context and computation
2. **Stationary Data**: Differencing or normalization
3. **Validation Strategy**: Time-based splits, no shuffle
4. **Multi-Step Forecasting**: Teacher forcing vs autoregressive

### Performance Optimization

#### GPU Utilization

```r
# Check CUDA availability
cuda_is_available()
cuda_device_count()

# Move model and data to GPU
device <- "cuda"
model <- model$to(device = device)
x <- x$to(device = device)

# Multiple GPUs (Torch)
if (cuda_device_count() > 1) {
  model <- nn_data_parallel(model)
}
```

#### Memory Management

```r
# Torch: Clear cache
if (cuda_is_available()) {
  cuda_empty_cache()
}

# Gradient accumulation for large effective batch sizes
accumulation_steps <- 4
optimizer$zero_grad()

for (i in 1:length(train_dl)) {
  batch <- train_dl[[i]]
  output <- model(batch$x)
  loss <- criterion(output, batch$y) / accumulation_steps
  loss$backward()

  if (i %% accumulation_steps == 0) {
    optimizer$step()
    optimizer$zero_grad()
  }
}
```

#### Efficient Data Loading

```r
# Pin memory for faster GPU transfer
dl <- dataloader(
  dataset,
  batch_size = 32,
  pin_memory = TRUE,
  num_workers = 4
)

# Prefetch data
dl <- dataloader(
  dataset,
  batch_size = 32,
  prefetch_factor = 2,
  persistent_workers = TRUE
)
```

---

## Common Code Patterns

### Torch Patterns

#### Complete Training Script Template

```r
library(torch)
library(coro)

# Hyperparameters
config <- list(
  batch_size = 32,
  learning_rate = 0.001,
  epochs = 50,
  device = if (cuda_is_available()) "cuda" else "cpu"
)

# Model
model <- my_model()$to(device = config$device)

# Optimizer and loss
optimizer <- optim_adam(model$parameters, lr = config$learning_rate)
criterion <- nn_cross_entropy_loss()
scheduler <- lr_cosine_annealing(optimizer, T_max = config$epochs)

# Data loaders
train_dl <- dataloader(train_ds, batch_size = config$batch_size, shuffle = TRUE)
val_dl <- dataloader(val_ds, batch_size = config$batch_size)

# Training loop
best_val_loss <- Inf

for (epoch in 1:config$epochs) {
  # Training phase
  model$train()
  train_loss <- 0
  train_correct <- 0
  train_total <- 0

  coro::loop(for (batch in train_dl) {
    x <- batch$x$to(device = config$device)
    y <- batch$y$to(device = config$device)

    optimizer$zero_grad()
    output <- model(x)
    loss <- criterion(output, y)
    loss$backward()

    # Gradient clipping
    nn_utils_clip_grad_norm_(model$parameters, max_norm = 1.0)

    optimizer$step()

    train_loss <- train_loss + loss$item()
    pred <- torch_argmax(output, dim = 2)
    train_correct <- train_correct + (pred == y)$sum()$item()
    train_total <- train_total + y$size(1)
  })

  # Validation phase
  model$eval()
  val_loss <- 0
  val_correct <- 0
  val_total <- 0

  with_no_grad({
    coro::loop(for (batch in val_dl) {
      x <- batch$x$to(device = config$device)
      y <- batch$y$to(device = config$device)

      output <- model(x)
      loss <- criterion(output, y)

      val_loss <- val_loss + loss$item()
      pred <- torch_argmax(output, dim = 2)
      val_correct <- val_correct + (pred == y)$sum()$item()
      val_total <- val_total + y$size(1)
    })
  })

  # Metrics
  train_loss <- train_loss / length(train_dl)
  train_acc <- train_correct / train_total
  val_loss <- val_loss / length(val_dl)
  val_acc <- val_correct / val_total

  cat(sprintf(
    "Epoch %d/%d - Train Loss: %.4f, Train Acc: %.4f, Val Loss: %.4f, Val Acc: %.4f\n",
    epoch, config$epochs, train_loss, train_acc, val_loss, val_acc
  ))

  # Save best model
  if (val_loss < best_val_loss) {
    best_val_loss <- val_loss
    torch_save(model$state_dict(), "best_model.pt")
  }

  # Learning rate scheduling
  scheduler$step()
}

# Load best model
model$load_state_dict(torch_load("best_model.pt"))
```

#### Custom Layer Pattern

```r
custom_layer <- nn_module(
  classname = "CustomLayer",
  initialize = function(input_dim, output_dim) {
    self$weight <- nn_parameter(torch_randn(input_dim, output_dim))
    self$bias <- nn_parameter(torch_zeros(output_dim))
    self$activation <- nn_relu()
  },
  forward = function(x) {
    linear <- torch_matmul(x, self$weight) + self$bias
    self$activation(linear)
  }
)
```

### Keras3 Patterns

#### Complete Training Script Template

```r
library(keras3)

# Data preparation
c(c(x_train, y_train), c(x_val, y_val), c(x_test, y_test)) %<-%
  prepare_data()

# Build model
model <- build_model()

# Compile
model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = loss_categorical_crossentropy(),
  metrics = list(
    metric_categorical_accuracy(),
    metric_top_k_categorical_accuracy(k = 5)
  )
)

# Callbacks
callbacks <- list(
  callback_early_stopping(
    monitor = "val_loss",
    patience = 10,
    restore_best_weights = TRUE
  ),
  callback_model_checkpoint(
    filepath = "best_model.keras",
    monitor = "val_loss",
    save_best_only = TRUE
  ),
  callback_reduce_lr_on_plateau(
    monitor = "val_loss",
    factor = 0.5,
    patience = 5,
    min_lr = 1e-7
  ),
  callback_tensorboard(log_dir = "logs"),
  callback_csv_logger("training.csv")
)

# Train
history <- model |> fit(
  x_train, y_train,
  epochs = 100,
  batch_size = 32,
  validation_data = list(x_val, y_val),
  callbacks = callbacks,
  verbose = 1
)

# Evaluate
results <- model |> evaluate(x_test, y_test)
predictions <- model |> predict(x_test)

# Plot history
plot(history)
```

#### Custom Layer Pattern

```r
CustomLayer <- Layer(
  classname = "CustomLayer",
  initialize = function(units = 32, ...) {
    super$initialize(...)
    self$units <- units
  },
  build = function(input_shape) {
    self$w <- self$add_weight(
      shape = c(input_shape[[2]], self$units),
      initializer = "random_normal",
      trainable = TRUE,
      name = "kernel"
    )
    self$b <- self$add_weight(
      shape = c(self$units),
      initializer = "zeros",
      trainable = TRUE,
      name = "bias"
    )
  },
  call = function(inputs) {
    op_matmul(inputs, self$w) + self$b
  }
)

# Usage
model <- keras_model_sequential()
model |> CustomLayer(units = 64)
```

### Common Utilities

#### Model Summary and Inspection

```r
# Keras3
summary(model)
plot(model)  # Visualization
get_config(model)

# Torch
cat(as.character(model))  # Print architecture
length(model$parameters)  # Number of parameter tensors
sum(sapply(model$parameters, function(p) p$numel()))  # Total parameters
```

#### Reproducibility

```r
# Set seeds for reproducibility
set.seed(42)

# Torch
torch_manual_seed(42)
if (cuda_is_available()) {
  torch_cuda_manual_seed_all(42)
}

# Keras3
keras3::set_random_seed(42)
```

#### Model Serialization

```r
# Keras3 - complete model
save_model(model, "model.keras")
model <- load_model("model.keras")

# Keras3 - weights only
save_model_weights(model, "weights.h5")
load_model_weights(model, "weights.h5")

# Torch - state dict
torch_save(model$state_dict(), "model.pt")
model$load_state_dict(torch_load("model.pt"))

# Torch - entire model
torch_save(model, "complete_model.pt")
model <- torch_load("complete_model.pt")

# Torch - JIT compilation for deployment
scripted_model <- jit_trace(model, example_input)
jit_save(scripted_model, "model_scripted.pt")
```

---

## Integration with R Ecosystem

### Tidyverse Integration

```r
library(tidyverse)

# Data preparation pipeline
train_data <- raw_data |>
  filter(!is.na(label)) |>
  mutate(
    image_path = file.path("images", paste0(id, ".jpg")),
    label_encoded = as.integer(factor(label)) - 1
  ) |>
  select(image_path, label_encoded)

# Split using rsample
library(rsample)
split <- initial_split(train_data, prop = 0.8, strata = label_encoded)
train <- training(split)
val <- testing(split)
```

### Tidymodels Integration

```r
library(tidymodels)

# Feature engineering recipe
recipe <- recipe(label ~ ., data = train_data) |>
  step_normalize(all_numeric_predictors()) |>
  step_pca(all_numeric_predictors(), threshold = 0.95)

# Use features as input to deep learning model
prepped <- prep(recipe)
train_features <- bake(prepped, train_data)

# Convert to torch tensors
train_tensor <- torch_tensor(as.matrix(train_features[, -1]))
train_labels <- torch_tensor(train_features$label)
```

### Visualization

```r
# Training history
library(ggplot2)

history_df <- data.frame(
  epoch = 1:length(train_losses),
  train_loss = train_losses,
  val_loss = val_losses
)

ggplot(history_df, aes(x = epoch)) +
  geom_line(aes(y = train_loss, color = "Train")) +
  geom_line(aes(y = val_loss, color = "Validation")) +
  labs(title = "Training History", y = "Loss", color = "Dataset") +
  theme_minimal()

# Confusion matrix
library(caret)
cm <- confusionMatrix(
  factor(predictions, levels = classes),
  factor(true_labels, levels = classes)
)
print(cm)

# Visualize spectrograms
library(ggplot2)
library(reshape2)

spec_matrix <- as.matrix(spectrogram$cpu())
spec_df <- melt(spec_matrix)
names(spec_df) <- c("frequency", "time", "value")

ggplot(spec_df, aes(x = time, y = frequency, fill = value)) +
  geom_tile() +
  scale_fill_viridis_c() +
  labs(title = "Mel Spectrogram", x = "Time", y = "Frequency") +
  theme_minimal()
```

### R Markdown Integration

```r
# In R Markdown document
```{r setup}
library(torch)
library(keras3)
library(tidyverse)
```

```{r train-model, cache=TRUE}
# Training code here
# Results cached for reproducibility
model <- train_deep_learning_model(data)
```

```{r visualize}
plot_training_history(model)
```
```

---

## Summary

This research document provides comprehensive coverage of:

1. **Core Concepts**: Tensors, autograd, neural network modules in both torch and keras3
2. **Model Architectures**: Sequential, functional, custom models with complete code examples
3. **Training Workflows**: Complete training loops, callbacks, custom training steps, optimization
4. **Domain-Specific Patterns**: Computer vision (CNNs, transfer learning), NLP (LSTM, embeddings, text processing), time series (RNNs, ConvLSTM), tabular data (entity embeddings)
5. **Audio Deep Learning**: Complete audio classification pipeline with torchaudio, spectrogram transformations, audio CNNs, CRNNs, and augmentation
6. **Best Practices**: Regularization, optimization, memory management, GPU utilization, domain-specific tips
7. **Common Patterns**: Complete training script templates, custom layers, utilities, serialization
8. **R Integration**: Tidyverse, tidymodels, visualization, R Markdown workflows

**Key Packages Covered:**
- `torch` - R interface to PyTorch
- `torchaudio` - Audio processing with torch
- `keras3` - Multi-backend deep learning API
- `torchvision` - Computer vision utilities

**Primary Use Cases:**
- Image classification and computer vision
- Text classification and NLP
- Time series forecasting
- Audio classification and bioacoustics
- Tabular deep learning

This information is ready to be transformed into a comprehensive Claude Code skill for deep learning in R.
