# Custom Layers and Models

This guide demonstrates how to create custom layers and models in Keras3 using R, providing full control over layer behavior and model architecture.

## Custom Layer Basics

Create a simple custom layer with `Layer()` base class.

```r
library(keras3)

# Define a simple dense layer from scratch
CustomDenseLayer <- Layer(
  "CustomDenseLayer",

  # Initialize layer with hyperparameters
  initialize = function(units, activation = NULL, ...) {
    super$initialize(...)
    self$units <- as.integer(units)
    self$activation <- activation
  },

  # Create weights when layer is built
  build = function(input_shape) {
    # Weight matrix
    self$kernel <- self$add_weight(
      name = "kernel",
      shape = list(input_shape[[2]], self$units),
      initializer = "glorot_uniform",
      trainable = TRUE
    )

    # Bias vector
    self$bias <- self$add_weight(
      name = "bias",
      shape = list(self$units),
      initializer = "zeros",
      trainable = TRUE
    )
  },

  # Forward pass computation
  call = function(inputs, ...) {
    # Matrix multiplication + bias
    output <- keras3::k_dot(inputs, self$kernel) + self$bias

    # Apply activation if specified
    if (!is.null(self$activation)) {
      output <- keras3::activation_get(self$activation)(output)
    }

    return(output)
  }
)

# Usage
input <- keras_input(shape = 10)
output <- input |>
  CustomDenseLayer(units = 32, activation = "relu") |>
  layer_dense(units = 1)

model <- keras_model(inputs = input, outputs = output)
model |> compile(optimizer = "adam", loss = "mse")
```

## Deferred Weight Creation with build()

Use `build()` method for weight creation based on input shape.

```r
# Custom layer that adapts to input dimensions
AdaptiveNormalizationLayer <- Layer(
  "AdaptiveNormalizationLayer",

  initialize = function(epsilon = 1e-5, ...) {
    super$initialize(...)
    self$epsilon <- epsilon
  },

  # Deferred weight creation
  build = function(input_shape) {
    # Create scale and shift parameters matching input features
    feature_dim <- input_shape[[length(input_shape)]]

    self$scale <- self$add_weight(
      name = "scale",
      shape = list(feature_dim),
      initializer = "ones",
      trainable = TRUE
    )

    self$shift <- self$add_weight(
      name = "shift",
      shape = list(feature_dim),
      initializer = "zeros",
      trainable = TRUE
    )
  },

  call = function(inputs, training = NULL, ...) {
    # Compute mean and variance
    mean <- keras3::k_mean(inputs, axis = -1L, keepdims = TRUE)
    variance <- keras3::k_var(inputs, axis = -1L, keepdims = TRUE)

    # Normalize
    normalized <- (inputs - mean) / keras3::k_sqrt(variance + self$epsilon)

    # Scale and shift
    output <- self$scale * normalized + self$shift

    return(output)
  }
)

# Example: Use with different input dimensions
model1 <- keras_model_sequential() |>
  layer_input(shape = 64) |>
  AdaptiveNormalizationLayer() |>
  layer_dense(units = 10)

model2 <- keras_model_sequential() |>
  layer_input(shape = 128) |>
  AdaptiveNormalizationLayer() |>  # Automatically adapts to 128 features
  layer_dense(units = 5)
```

## Layer with Configuration

Implement `get_config()` and `from_config()` for serialization.

```r
# Custom layer with proper configuration support
DropoutDenseLayer <- Layer(
  "DropoutDenseLayer",

  initialize = function(units, dropout_rate = 0.5, activation = NULL, ...) {
    super$initialize(...)
    self$units <- as.integer(units)
    self$dropout_rate <- dropout_rate
    self$activation <- activation

    # Create sublayers
    self$dense <- layer_dense(units = units, activation = activation)
    self$dropout <- layer_dropout(rate = dropout_rate)
  },

  build = function(input_shape) {
    # Build sublayers
    self$dense$build(input_shape)
  },

  call = function(inputs, training = NULL, ...) {
    x <- self$dense(inputs)
    x <- self$dropout(x, training = training)
    return(x)
  },

  # Serialization: Save configuration
  get_config = function() {
    config <- super$get_config()
    config$units <- self$units
    config$dropout_rate <- self$dropout_rate
    config$activation <- self$activation
    return(config)
  }
)

# Create and save model
model <- keras_model_sequential() |>
  layer_input(shape = 20) |>
  DropoutDenseLayer(units = 64, dropout_rate = 0.3, activation = "relu") |>
  layer_dense(units = 1)

model |> compile(optimizer = "adam", loss = "mse")

# Save and reload (configuration preserved)
save_model(model, "model_with_custom.keras")
loaded_model <- load_model("model_with_custom.keras",
                           custom_objects = list(DropoutDenseLayer = DropoutDenseLayer))
```

## Stateful Layers

Maintain state across calls, useful for RNNs or running statistics.

```r
# Custom layer with internal state
RunningMeanLayer <- Layer(
  "RunningMeanLayer",

  initialize = function(momentum = 0.99, ...) {
    super$initialize(...)
    self$momentum <- momentum
  },

  build = function(input_shape) {
    # Non-trainable state variable
    self$running_mean <- self$add_weight(
      name = "running_mean",
      shape = input_shape[-1],  # Exclude batch dimension
      initializer = "zeros",
      trainable = FALSE  # State, not learned parameter
    )
  },

  call = function(inputs, training = NULL, ...) {
    if (training) {
      # Update running mean during training
      batch_mean <- keras3::k_mean(inputs, axis = 1L)

      # Exponential moving average
      new_mean <- self$momentum * self$running_mean + (1 - self$momentum) * batch_mean

      # Update state
      self$running_mean$assign(new_mean)
    }

    # Subtract running mean
    output <- inputs - self$running_mean

    return(output)
  },

  get_config = function() {
    config <- super$get_config()
    config$momentum <- self$momentum
    return(config)
  }
)

# Usage
model <- keras_model_sequential() |>
  layer_input(shape = c(100, 10)) |>
  RunningMeanLayer(momentum = 0.95) |>
  layer_lstm(units = 32) |>
  layer_dense(units = 1)

model |> compile(optimizer = "adam", loss = "mse")

# State persists across training batches
history <- model |> fit(
  x = train_x,
  y = train_y,
  epochs = 10,
  batch_size = 32
)
```

## Model Subclassing

Create custom models with full control over forward pass.

```r
# Custom model with residual connections
ResidualBlock <- Model(
  "ResidualBlock",

  initialize = function(filters, kernel_size = 3, ...) {
    super$initialize(...)
    self$filters <- filters
    self$kernel_size <- kernel_size

    # Define layers
    self$conv1 <- layer_conv_2d(filters = filters, kernel_size = kernel_size, padding = "same")
    self$bn1 <- layer_batch_normalization()
    self$conv2 <- layer_conv_2d(filters = filters, kernel_size = kernel_size, padding = "same")
    self$bn2 <- layer_batch_normalization()
    self$activation <- layer_activation("relu")
    self$add <- layer_add()
  },

  call = function(inputs, training = NULL, ...) {
    # Residual path
    x <- self$conv1(inputs)
    x <- self$bn1(x, training = training)
    x <- self$activation(x)
    x <- self$conv2(x)
    x <- self$bn2(x, training = training)

    # Skip connection
    x <- self$add(list(x, inputs))
    x <- self$activation(x)

    return(x)
  }
)

# Custom classifier using residual blocks
ResidualClassifier <- Model(
  "ResidualClassifier",

  initialize = function(num_classes, num_blocks = 3, ...) {
    super$initialize(...)
    self$num_classes <- num_classes
    self$num_blocks <- num_blocks

    # Initial convolution
    self$conv_in <- layer_conv_2d(filters = 64, kernel_size = 7, strides = 2, padding = "same")
    self$bn_in <- layer_batch_normalization()
    self$activation <- layer_activation("relu")
    self$pool <- layer_max_pooling_2d(pool_size = 3, strides = 2, padding = "same")

    # Residual blocks
    self$res_blocks <- lapply(seq_len(num_blocks), function(i) {
      ResidualBlock(filters = 64)
    })

    # Classification head
    self$global_pool <- layer_global_average_pooling_2d()
    self$classifier <- layer_dense(units = num_classes, activation = "softmax")
  },

  call = function(inputs, training = NULL, ...) {
    # Initial processing
    x <- self$conv_in(inputs)
    x <- self$bn_in(x, training = training)
    x <- self$activation(x)
    x <- self$pool(x)

    # Apply residual blocks
    for (block in self$res_blocks) {
      x <- block(x, training = training)
    }

    # Classification
    x <- self$global_pool(x)
    output <- self$classifier(x)

    return(output)
  },

  get_config = function() {
    config <- super$get_config()
    config$num_classes <- self$num_classes
    config$num_blocks <- self$num_blocks
    return(config)
  }
)

# Usage
model <- ResidualClassifier(num_classes = 10, num_blocks = 4)

# Build model by calling it once
dummy_input <- keras3::k_random_uniform(c(1, 224, 224, 3))
dummy_output <- model(dummy_input)

model |> compile(
  optimizer = optimizer_adam(),
  loss = "categorical_crossentropy",
  metrics = c("accuracy")
)
```

## Custom Training Loop

Full control over training with custom model and loss.

```r
# Custom model with custom training logic
VariationalAutoencoder <- Model(
  "VariationalAutoencoder",

  initialize = function(latent_dim, ...) {
    super$initialize(...)
    self$latent_dim <- latent_dim

    # Encoder
    self$encoder_conv1 <- layer_conv_2d(filters = 32, kernel_size = 3, strides = 2, padding = "same", activation = "relu")
    self$encoder_conv2 <- layer_conv_2d(filters = 64, kernel_size = 3, strides = 2, padding = "same", activation = "relu")
    self$encoder_flatten <- layer_flatten()

    # Latent space
    self$z_mean_layer <- layer_dense(units = latent_dim)
    self$z_log_var_layer <- layer_dense(units = latent_dim)

    # Decoder
    self$decoder_dense <- layer_dense(units = 7 * 7 * 64, activation = "relu")
    self$decoder_reshape <- layer_reshape(target_shape = c(7, 7, 64))
    self$decoder_conv1 <- layer_conv_2d_transpose(filters = 64, kernel_size = 3, strides = 2, padding = "same", activation = "relu")
    self$decoder_conv2 <- layer_conv_2d_transpose(filters = 32, kernel_size = 3, strides = 2, padding = "same", activation = "relu")
    self$decoder_out <- layer_conv_2d(filters = 1, kernel_size = 3, padding = "same", activation = "sigmoid")

    # Metrics
    self$total_loss_tracker <- metric_mean(name = "total_loss")
    self$reconstruction_loss_tracker <- metric_mean(name = "reconstruction_loss")
    self$kl_loss_tracker <- metric_mean(name = "kl_loss")
  },

  # Encoder
  encode = function(inputs) {
    x <- self$encoder_conv1(inputs)
    x <- self$encoder_conv2(x)
    x <- self$encoder_flatten(x)

    z_mean <- self$z_mean_layer(x)
    z_log_var <- self$z_log_var_layer(x)

    return(list(z_mean = z_mean, z_log_var = z_log_var))
  },

  # Sampling
  sample_latent = function(z_mean, z_log_var) {
    batch_size <- keras3::k_shape(z_mean)[1]
    latent_dim <- keras3::k_shape(z_mean)[2]

    epsilon <- keras3::k_random_normal(shape = list(batch_size, latent_dim))
    z <- z_mean + keras3::k_exp(0.5 * z_log_var) * epsilon

    return(z)
  },

  # Decoder
  decode = function(z) {
    x <- self$decoder_dense(z)
    x <- self$decoder_reshape(x)
    x <- self$decoder_conv1(x)
    x <- self$decoder_conv2(x)
    reconstruction <- self$decoder_out(x)

    return(reconstruction)
  },

  # Forward pass
  call = function(inputs, training = NULL, ...) {
    # Encode
    encoding <- self$encode(inputs)
    z_mean <- encoding$z_mean
    z_log_var <- encoding$z_log_var

    # Sample
    z <- self$sample_latent(z_mean, z_log_var)

    # Decode
    reconstruction <- self$decode(z)

    if (training) {
      # Compute losses
      reconstruction_loss <- keras3::k_mean(
        keras3::k_square(inputs - reconstruction),
        axis = c(2L, 3L, 4L)
      )

      kl_loss <- -0.5 * keras3::k_mean(
        1 + z_log_var - keras3::k_square(z_mean) - keras3::k_exp(z_log_var),
        axis = -1L
      )

      total_loss <- reconstruction_loss + kl_loss

      # Track metrics
      self$add_loss(total_loss)
      self$total_loss_tracker$update_state(total_loss)
      self$reconstruction_loss_tracker$update_state(reconstruction_loss)
      self$kl_loss_tracker$update_state(kl_loss)
    }

    return(reconstruction)
  },

  get_config = function() {
    config <- super$get_config()
    config$latent_dim <- self$latent_dim
    return(config)
  }
)

# Usage
vae <- VariationalAutoencoder(latent_dim = 16)

# Compile (optimizer only, loss is computed internally)
vae |> compile(optimizer = optimizer_adam())

# Train
history <- vae |> fit(
  x = train_images,
  y = train_images,  # Autoencoder: output = input
  epochs = 30,
  batch_size = 128,
  validation_split = 0.2
)

# Generate new images
latent_samples <- keras3::k_random_normal(shape = c(10, 16))
generated_images <- vae$decode(latent_samples)
```

## Advanced: Multi-Input Custom Model

Custom model with complex input handling.

```r
# Custom model with multiple inputs and auxiliary losses
MultiTaskModel <- Model(
  "MultiTaskModel",

  initialize = function(num_main_classes, num_aux_classes, ...) {
    super$initialize(...)
    self$num_main_classes <- num_main_classes
    self$num_aux_classes <- num_aux_classes

    # Shared backbone
    self$conv1 <- layer_conv_2d(filters = 32, kernel_size = 3, activation = "relu")
    self$pool1 <- layer_max_pooling_2d(pool_size = 2)
    self$conv2 <- layer_conv_2d(filters = 64, kernel_size = 3, activation = "relu")
    self$pool2 <- layer_max_pooling_2d(pool_size = 2)
    self$flatten <- layer_flatten()

    # Main task head
    self$main_dense <- layer_dense(units = 128, activation = "relu")
    self$main_out <- layer_dense(units = num_main_classes, activation = "softmax")

    # Auxiliary task head
    self$aux_dense <- layer_dense(units = 64, activation = "relu")
    self$aux_out <- layer_dense(units = num_aux_classes, activation = "softmax")

    # Metrics
    self$main_loss_tracker <- metric_mean(name = "main_loss")
    self$aux_loss_tracker <- metric_mean(name = "aux_loss")
    self$main_accuracy <- metric_categorical_accuracy(name = "main_accuracy")
    self$aux_accuracy <- metric_categorical_accuracy(name = "aux_accuracy")
  },

  call = function(inputs, training = NULL, ...) {
    # Shared feature extraction
    x <- self$conv1(inputs)
    x <- self$pool1(x)
    x <- self$conv2(x)
    x <- self$pool2(x)
    features <- self$flatten(x)

    # Main task
    main_x <- self$main_dense(features)
    main_output <- self$main_out(main_x)

    # Auxiliary task
    aux_x <- self$aux_dense(features)
    aux_output <- self$aux_out(aux_x)

    return(list(main = main_output, aux = aux_output))
  },

  train_step = function(data) {
    # Unpack data
    x <- data[[1]]
    y_main <- data[[2]]$main
    y_aux <- data[[2]]$aux

    # Forward pass with gradient tape
    with(tensorflow::tf$GradientTape() %as% tape, {
      predictions <- self(x, training = TRUE)

      # Compute losses
      main_loss <- keras3::loss_categorical_crossentropy(y_main, predictions$main)
      aux_loss <- keras3::loss_categorical_crossentropy(y_aux, predictions$aux)

      total_loss <- main_loss + 0.5 * aux_loss
    })

    # Compute gradients
    gradients <- tape$gradient(total_loss, self$trainable_variables)

    # Update weights
    self$optimizer$apply_gradients(zip(gradients, self$trainable_variables))

    # Update metrics
    self$main_loss_tracker$update_state(main_loss)
    self$aux_loss_tracker$update_state(aux_loss)
    self$main_accuracy$update_state(y_main, predictions$main)
    self$aux_accuracy$update_state(y_aux, predictions$aux)

    return(list(
      main_loss = self$main_loss_tracker$result(),
      aux_loss = self$aux_loss_tracker$result(),
      main_accuracy = self$main_accuracy$result(),
      aux_accuracy = self$aux_accuracy$result()
    ))
  }
)
```

## Best Practices

1. **Use build()**: Defer weight creation until input shape is known
2. **Implement get_config()**: Enable model serialization
3. **Handle training flag**: Different behavior for training vs inference
4. **Add metrics**: Track custom metrics for monitoring
5. **Document parameters**: Clear documentation for initialization arguments
6. **Test thoroughly**: Validate custom logic with simple examples
7. **Memory management**: Be careful with state in stateful layers

## Related Resources

- See functional-api-advanced.md for combining custom layers in complex architectures
- Reference main SKILL.md for basic layer usage
- Check deployment-comparison.md for serializing custom components
