# Functional API Advanced Patterns

This guide demonstrates advanced Keras3 Functional API patterns for building complex neural network architectures in R.

## Multi-Input Models

Combine multiple data sources into a single model. Common for systems requiring heterogeneous inputs.

```r
library(keras3)

# Example: Movie recommendation with text and metadata
# Input 1: Movie description (text)
text_input <- keras_input(shape = NULL, dtype = "string", name = "description")
text_features <- text_input |>
  layer_text_vectorization(max_tokens = 10000, output_sequence_length = 100) |>
  layer_embedding(input_dim = 10000, output_dim = 64) |>
  layer_global_average_pooling_1d()

# Input 2: Metadata (year, budget, runtime)
meta_input <- keras_input(shape = 3, name = "metadata")
meta_features <- meta_input |>
  layer_dense(units = 32, activation = "relu") |>
  layer_dropout(rate = 0.3)

# Merge inputs
merged <- layer_concatenate(list(text_features, meta_features))

# Output layers
output <- merged |>
  layer_dense(units = 64, activation = "relu") |>
  layer_dropout(rate = 0.3) |>
  layer_dense(units = 1, activation = "sigmoid", name = "rating")

# Build model
model <- keras_model(
  inputs = list(text_input, meta_input),
  outputs = output
)

model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = "binary_crossentropy",
  metrics = c("accuracy")
)

# Training with named inputs
history <- model |> fit(
  x = list(
    description = train_text,
    metadata = train_meta
  ),
  y = train_labels,
  validation_split = 0.2,
  epochs = 10,
  batch_size = 32
)
```

### Multi-Input with Different Processing Paths

```r
# Example: Image + Sensor Data Fusion
# Input 1: Image data
image_input <- keras_input(shape = c(224, 224, 3), name = "image")
image_features <- image_input |>
  layer_conv_2d(filters = 32, kernel_size = 3, activation = "relu") |>
  layer_max_pooling_2d(pool_size = 2) |>
  layer_conv_2d(filters = 64, kernel_size = 3, activation = "relu") |>
  layer_max_pooling_2d(pool_size = 2) |>
  layer_flatten()

# Input 2: Time-series sensor data
sensor_input <- keras_input(shape = c(100, 10), name = "sensors")
sensor_features <- sensor_input |>
  layer_lstm(units = 64, return_sequences = FALSE) |>
  layer_dropout(rate = 0.3)

# Combine with attention to sensor data
merged <- layer_concatenate(list(image_features, sensor_features))

output <- merged |>
  layer_dense(units = 128, activation = "relu") |>
  layer_dropout(rate = 0.4) |>
  layer_dense(units = 5, activation = "softmax")

model <- keras_model(
  inputs = list(image_input, sensor_input),
  outputs = output
)
```

## Multi-Output Models

Single input generating multiple predictions with separate loss functions.

```r
# Example: Document classification with auxiliary tasks
# Main input
text_input <- keras_input(shape = NULL, dtype = "string", name = "text")

# Shared embedding layer
shared_embedding <- text_input |>
  layer_text_vectorization(max_tokens = 20000, output_sequence_length = 200) |>
  layer_embedding(input_dim = 20000, output_dim = 128)

# Shared LSTM processing
shared_lstm <- shared_embedding |>
  layer_lstm(units = 128, return_sequences = TRUE)

# Output 1: Main topic classification
topic_branch <- shared_lstm |>
  layer_global_average_pooling_1d() |>
  layer_dense(units = 64, activation = "relu") |>
  layer_dropout(rate = 0.3) |>
  layer_dense(units = 10, activation = "softmax", name = "topic")

# Output 2: Sentiment analysis
sentiment_branch <- shared_lstm |>
  layer_global_max_pooling_1d() |>
  layer_dense(units = 32, activation = "relu") |>
  layer_dropout(rate = 0.3) |>
  layer_dense(units = 3, activation = "softmax", name = "sentiment")

# Output 3: Language detection (auxiliary task)
language_branch <- shared_embedding |>
  layer_global_average_pooling_1d() |>
  layer_dense(units = 5, activation = "softmax", name = "language")

# Build multi-output model
model <- keras_model(
  inputs = text_input,
  outputs = list(
    topic = topic_branch,
    sentiment = sentiment_branch,
    language = language_branch
  )
)

# Compile with different losses and weights
model |> compile(
  optimizer = optimizer_adam(),
  loss = list(
    topic = "categorical_crossentropy",
    sentiment = "categorical_crossentropy",
    language = "categorical_crossentropy"
  ),
  loss_weights = list(
    topic = 1.0,      # Main task
    sentiment = 0.5,   # Secondary task
    language = 0.2     # Auxiliary task
  ),
  metrics = list(
    topic = "accuracy",
    sentiment = "accuracy",
    language = "accuracy"
  )
)

# Training with multiple outputs
history <- model |> fit(
  x = train_texts,
  y = list(
    topic = train_topics,
    sentiment = train_sentiments,
    language = train_languages
  ),
  validation_split = 0.2,
  epochs = 20,
  batch_size = 32
)
```

## Skip Connections (ResNet-style)

Residual connections that help gradient flow in deep networks.

```r
# Example: ResNet-style block
build_resnet_block <- function(x, filters, kernel_size = 3, stride = 1) {
  # Main path
  shortcut <- x

  # Residual path
  out <- x |>
    layer_conv_2d(filters = filters, kernel_size = kernel_size,
                  strides = stride, padding = "same") |>
    layer_batch_normalization() |>
    layer_activation("relu") |>
    layer_conv_2d(filters = filters, kernel_size = kernel_size,
                  padding = "same") |>
    layer_batch_normalization()

  # Adjust shortcut dimensions if needed
  if (stride != 1 || dim(x)[4] != filters) {
    shortcut <- x |>
      layer_conv_2d(filters = filters, kernel_size = 1,
                    strides = stride, padding = "same") |>
      layer_batch_normalization()
  }

  # Add skip connection
  out <- layer_add(list(out, shortcut))
  out <- out |> layer_activation("relu")

  return(out)
}

# Build complete ResNet-style model
input <- keras_input(shape = c(32, 32, 3))

output <- input |>
  # Initial convolution
  layer_conv_2d(filters = 64, kernel_size = 7, strides = 2, padding = "same") |>
  layer_batch_normalization() |>
  layer_activation("relu") |>
  layer_max_pooling_2d(pool_size = 3, strides = 2, padding = "same") |>

  # ResNet blocks
  build_resnet_block(filters = 64) |>
  build_resnet_block(filters = 64) |>
  build_resnet_block(filters = 128, stride = 2) |>
  build_resnet_block(filters = 128) |>
  build_resnet_block(filters = 256, stride = 2) |>
  build_resnet_block(filters = 256) |>

  # Classification head
  layer_global_average_pooling_2d() |>
  layer_dense(units = 10, activation = "softmax")

model <- keras_model(inputs = input, outputs = output)
```

## Branching Architectures

Split processing into parallel paths with different operations.

```r
# Example: Inception-style module
inception_module <- function(x, filters_1x1, filters_3x3_reduce, filters_3x3,
                             filters_5x5_reduce, filters_5x5, filters_pool) {
  # Branch 1: 1x1 convolution
  branch1 <- x |>
    layer_conv_2d(filters = filters_1x1, kernel_size = 1, activation = "relu")

  # Branch 2: 1x1 -> 3x3 convolution
  branch2 <- x |>
    layer_conv_2d(filters = filters_3x3_reduce, kernel_size = 1, activation = "relu") |>
    layer_conv_2d(filters = filters_3x3, kernel_size = 3, padding = "same", activation = "relu")

  # Branch 3: 1x1 -> 5x5 convolution
  branch3 <- x |>
    layer_conv_2d(filters = filters_5x5_reduce, kernel_size = 1, activation = "relu") |>
    layer_conv_2d(filters = filters_5x5, kernel_size = 5, padding = "same", activation = "relu")

  # Branch 4: MaxPool -> 1x1 convolution
  branch4 <- x |>
    layer_max_pooling_2d(pool_size = 3, strides = 1, padding = "same") |>
    layer_conv_2d(filters = filters_pool, kernel_size = 1, activation = "relu")

  # Concatenate all branches
  output <- layer_concatenate(list(branch1, branch2, branch3, branch4))

  return(output)
}

# Build Inception-style network
input <- keras_input(shape = c(224, 224, 3))

output <- input |>
  layer_conv_2d(filters = 64, kernel_size = 7, strides = 2, padding = "same", activation = "relu") |>
  layer_max_pooling_2d(pool_size = 3, strides = 2, padding = "same") |>

  # Inception modules
  inception_module(64, 64, 96, 128, 16, 32, 32) |>
  inception_module(128, 128, 128, 192, 32, 96, 64) |>
  layer_max_pooling_2d(pool_size = 3, strides = 2, padding = "same") |>

  # More inception modules
  inception_module(192, 192, 96, 208, 16, 48, 64) |>
  inception_module(160, 160, 112, 224, 24, 64, 64) |>

  # Classification
  layer_global_average_pooling_2d() |>
  layer_dropout(rate = 0.4) |>
  layer_dense(units = 1000, activation = "softmax")

model <- keras_model(inputs = input, outputs = output)
```

## Shared Layers (Siamese Networks)

Reuse the same layer instance across different branches for weight sharing.

```r
# Example: Siamese network for similarity learning
# Shared embedding network
create_embedding_network <- function() {
  input <- keras_input(shape = c(28, 28, 1))

  output <- input |>
    layer_conv_2d(filters = 32, kernel_size = 3, activation = "relu") |>
    layer_max_pooling_2d(pool_size = 2) |>
    layer_conv_2d(filters = 64, kernel_size = 3, activation = "relu") |>
    layer_max_pooling_2d(pool_size = 2) |>
    layer_flatten() |>
    layer_dense(units = 128, activation = "relu")

  keras_model(inputs = input, outputs = output)
}

# Create shared embedding model
embedding_model <- create_embedding_network()

# Define two inputs for comparison
input_a <- keras_input(shape = c(28, 28, 1), name = "input_a")
input_b <- keras_input(shape = c(28, 28, 1), name = "input_b")

# Process both inputs through SHARED embedding network
embedding_a <- embedding_model(input_a)
embedding_b <- embedding_model(input_b)

# Compute similarity
distance <- layer_lambda(
  f = function(tensors) {
    keras3::k_sqrt(keras3::k_sum(keras3::k_square(tensors[[1]] - tensors[[2]]), axis = -1L, keepdims = TRUE))
  },
  output_shape = function(shapes) list(shapes[[1]][1], 1L)
)(list(embedding_a, embedding_b))

# Convert distance to similarity
output <- distance |>
  layer_dense(units = 1, activation = "sigmoid", name = "similarity")

# Build Siamese model
siamese_model <- keras_model(
  inputs = list(input_a, input_b),
  outputs = output
)

siamese_model |> compile(
  optimizer = optimizer_adam(),
  loss = "binary_crossentropy",
  metrics = c("accuracy")
)

# Training with pairs
history <- siamese_model |> fit(
  x = list(input_a = train_pairs_a, input_b = train_pairs_b),
  y = train_labels,  # 1 for similar, 0 for dissimilar
  validation_split = 0.2,
  epochs = 20,
  batch_size = 32
)

# Extract embedding model for inference
# Use the shared embedding_model directly
embeddings <- embedding_model |> predict(test_images)
```

## Complex DAG (Directed Acyclic Graph)

Non-linear topology combining multiple patterns.

```r
# Example: Multi-scale feature pyramid for object detection
input <- keras_input(shape = c(256, 256, 3), name = "image")

# Encoder: Progressive downsampling
conv1 <- input |>
  layer_conv_2d(filters = 64, kernel_size = 3, padding = "same", activation = "relu") |>
  layer_conv_2d(filters = 64, kernel_size = 3, padding = "same", activation = "relu")

pool1 <- conv1 |> layer_max_pooling_2d(pool_size = 2)  # 128x128

conv2 <- pool1 |>
  layer_conv_2d(filters = 128, kernel_size = 3, padding = "same", activation = "relu") |>
  layer_conv_2d(filters = 128, kernel_size = 3, padding = "same", activation = "relu")

pool2 <- conv2 |> layer_max_pooling_2d(pool_size = 2)  # 64x64

conv3 <- pool2 |>
  layer_conv_2d(filters = 256, kernel_size = 3, padding = "same", activation = "relu") |>
  layer_conv_2d(filters = 256, kernel_size = 3, padding = "same", activation = "relu")

pool3 <- conv3 |> layer_max_pooling_2d(pool_size = 2)  # 32x32

# Bottom: Deepest features
conv4 <- pool3 |>
  layer_conv_2d(filters = 512, kernel_size = 3, padding = "same", activation = "relu") |>
  layer_conv_2d(filters = 512, kernel_size = 3, padding = "same", activation = "relu")

# Decoder with skip connections: Progressive upsampling
up1 <- conv4 |>
  layer_upsampling_2d(size = 2) |>  # 64x64
  layer_conv_2d(filters = 256, kernel_size = 3, padding = "same", activation = "relu")

merge1 <- layer_concatenate(list(up1, conv3))  # Merge with conv3

conv5 <- merge1 |>
  layer_conv_2d(filters = 256, kernel_size = 3, padding = "same", activation = "relu") |>
  layer_conv_2d(filters = 256, kernel_size = 3, padding = "same", activation = "relu")

up2 <- conv5 |>
  layer_upsampling_2d(size = 2) |>  # 128x128
  layer_conv_2d(filters = 128, kernel_size = 3, padding = "same", activation = "relu")

merge2 <- layer_concatenate(list(up2, conv2))  # Merge with conv2

conv6 <- merge2 |>
  layer_conv_2d(filters = 128, kernel_size = 3, padding = "same", activation = "relu") |>
  layer_conv_2d(filters = 128, kernel_size = 3, padding = "same", activation = "relu")

up3 <- conv6 |>
  layer_upsampling_2d(size = 2) |>  # 256x256
  layer_conv_2d(filters = 64, kernel_size = 3, padding = "same", activation = "relu")

merge3 <- layer_concatenate(list(up3, conv1))  # Merge with conv1

# Final output
output <- merge3 |>
  layer_conv_2d(filters = 64, kernel_size = 3, padding = "same", activation = "relu") |>
  layer_conv_2d(filters = 1, kernel_size = 1, activation = "sigmoid")

# Build U-Net style model
model <- keras_model(inputs = input, outputs = output)

model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.0001),
  loss = "binary_crossentropy",
  metrics = c("accuracy")
)
```

## Best Practices

1. **Name Your Layers**: Use `name` parameter for debugging and visualization
2. **Match Dimensions**: Ensure concatenated/added layers have compatible shapes
3. **Use Batch Normalization**: Helps with training deep networks
4. **Regularization**: Add dropout between dense layers
5. **Learning Rate**: Start with smaller rates for complex architectures
6. **Validation**: Monitor multiple metrics for multi-output models
7. **Memory**: Complex DAGs consume more memory - adjust batch size accordingly

## Related Resources

- See main SKILL.md for basic Functional API usage
- Reference custom-layers-models.md for building reusable components
- Check deployment-comparison.md for serializing complex architectures
