# Keras 3 Applications Reference

Complete catalog of 30+ pretrained models with transfer learning patterns.

## Overview

Keras Applications provides pretrained models for computer vision tasks, all trained on ImageNet. These models can be used for:
- Transfer learning
- Feature extraction
- Fine-tuning
- Benchmarking

All models are available through `application_*()` functions and support multiple backends (TensorFlow, JAX, PyTorch).

## ResNet Family

Residual Networks with skip connections for training very deep networks.

### application_resnet50()
### application_resnet101()
### application_resnet152()

Original ResNet architecture (He et al., 2015).

**Parameters:**
- `include_top` - Include final classification layer (default: TRUE)
- `weights` - "imagenet" or NULL for random initialization
- `input_tensor` - Optional input tensor
- `input_shape` - Shape tuple (only if include_top = FALSE)
- `pooling` - "avg" or "max" pooling (if include_top = FALSE)
- `classes` - Number of classes (only if weights = NULL)
- `classifier_activation` - Activation for final layer

**Architecture:**
- **ResNet50**: 50 layers, 25.6M parameters
- **ResNet101**: 101 layers, 44.6M parameters
- **ResNet152**: 152 layers, 60.3M parameters

**Use Cases:**
- General purpose image classification
- Feature extraction for medium-sized datasets
- Baseline for custom architectures

**Example:**
```r
library(keras3)

# Load pretrained model
resnet <- application_resnet50(weights = "imagenet")

# Predict on image
img <- image_load("elephant.jpg", target_size = c(224, 224))
x <- image_to_array(img)
x <- array_reshape(x, c(1, dim(x)))
x <- imagenet_preprocess_input(x, mode = "caffe")
preds <- predict(resnet, x)
imagenet_decode_predictions(preds, top = 3)

# Feature extraction
base_model <- application_resnet50(
  include_top = FALSE,
  weights = "imagenet",
  input_shape = c(224, 224, 3),
  pooling = "avg"
)
```

### application_resnet50_v2()
### application_resnet101_v2()
### application_resnet152_v2()

ResNet V2 with improved residual blocks (batch normalization before convolution).

**Key Differences:**
- Batch normalization precedes convolutions
- Slightly better accuracy
- More stable training

**Example:**
```r
resnet_v2 <- application_resnet50_v2(
  weights = "imagenet",
  include_top = FALSE,
  pooling = "avg"
)
```

## EfficientNet Family

Compound scaling architecture optimizing depth, width, and resolution.

### application_efficientnet_b0() through application_efficientnet_b7()

EfficientNet B0-B7 variants with increasing capacity and accuracy.

**Parameters:** Same as ResNet family

**Variants:**
- **B0**: 5.3M params, 224x224, baseline
- **B1**: 7.8M params, 240x240
- **B2**: 9.2M params, 260x260
- **B3**: 12M params, 300x300
- **B4**: 19M params, 380x380
- **B5**: 30M params, 456x456
- **B6**: 43M params, 528x528
- **B7**: 66M params, 600x600

**Characteristics:**
- State-of-the-art accuracy/efficiency tradeoff
- Compound scaling (depth + width + resolution)
- Mobile deployment friendly (B0-B3)

**Use Cases:**
- High accuracy requirements (B4-B7)
- Mobile/edge deployment (B0-B2)
- Resource-constrained environments

**Example:**
```r
# Lightweight model
efficient_b0 <- application_efficientnet_b0(
  weights = "imagenet",
  include_top = FALSE,
  input_shape = c(224, 224, 3),
  pooling = "avg"
)

# High accuracy model
efficient_b7 <- application_efficientnet_b7(
  weights = "imagenet",
  include_top = FALSE,
  input_shape = c(600, 600, 3),
  pooling = "avg"
)
```

### application_efficientnet_v2_s()
### application_efficientnet_v2_m()
### application_efficientnet_v2_l()

EfficientNet V2 with improved training speed and parameter efficiency.

**Variants:**
- **V2-S**: 21.5M params, 384x384, small
- **V2-M**: 54M params, 480x480, medium
- **V2-L**: 119M params, 480x480, large

**Improvements:**
- Fused-MBConv layers
- Progressive learning
- Faster training
- Better accuracy

**Example:**
```r
efficientnet_v2 <- application_efficientnet_v2_s(
  weights = "imagenet",
  include_top = FALSE,
  pooling = "avg"
)
```

## MobileNet Family

Lightweight architectures optimized for mobile and embedded devices.

### application_mobilenet()

Original MobileNet V1 with depthwise separable convolutions.

**Parameters:**
- Standard parameters plus:
- `alpha` - Width multiplier (0.25, 0.50, 0.75, 1.0)
- `depth_multiplier` - Depth multiplier for depthwise convolution

**Characteristics:**
- 4.2M params (α=1.0)
- Depthwise separable convolutions
- Very fast inference
- Lower accuracy than larger models

**Example:**
```r
mobilenet <- application_mobilenet(
  alpha = 1.0,
  weights = "imagenet",
  include_top = FALSE,
  pooling = "avg"
)

# Smaller variant
mobilenet_small <- application_mobilenet(
  alpha = 0.25,  # 25% width
  weights = "imagenet"
)
```

### application_mobilenet_v2()

MobileNet V2 with inverted residuals and linear bottlenecks.

**Parameters:**
- Standard parameters plus:
- `alpha` - Width multiplier

**Improvements:**
- Inverted residual structure
- Linear bottlenecks
- Better accuracy than V1
- Similar speed

**Example:**
```r
mobilenet_v2 <- application_mobilenet_v2(
  alpha = 1.0,
  weights = "imagenet",
  include_top = FALSE,
  pooling = "avg"
)
```

### application_mobilenet_v3_small()
### application_mobilenet_v3_large()

MobileNet V3 with neural architecture search and hard swish activation.

**Improvements:**
- NAS-optimized architecture
- h-swish and h-sigmoid activations
- Squeeze-and-excitation blocks
- Best mobile accuracy/speed tradeoff

**Example:**
```r
mobilenet_v3_large <- application_mobilenet_v3_large(
  weights = "imagenet",
  include_top = FALSE,
  pooling = "avg"
)

mobilenet_v3_small <- application_mobilenet_v3_small(
  weights = "imagenet",
  minimalistic = FALSE  # Use full model
)
```

## ConvNeXt Family

Modern pure convolutional architecture (2022).

### application_convnext_tiny()
### application_convnext_small()
### application_convnext_base()
### application_convnext_large()
### application_convnext_xlarge()

**Parameters:** Standard application parameters

**Variants:**
- **Tiny**: 28M params
- **Small**: 50M params
- **Base**: 89M params
- **Large**: 198M params
- **XLarge**: 350M params

**Characteristics:**
- Modern design inspired by Vision Transformers
- Pure convolutional architecture
- State-of-the-art accuracy
- No attention mechanisms

**Use Cases:**
- Replacing Vision Transformers with convolutions
- Transfer learning with modern architecture
- Research baselines

**Example:**
```r
convnext <- application_convnext_base(
  weights = "imagenet",
  include_top = FALSE,
  input_shape = c(224, 224, 3),
  pooling = "avg"
)
```

## DenseNet Family

Dense connectivity between layers.

### application_densenet121()
### application_densenet169()
### application_densenet201()

**Characteristics:**
- Dense connections (each layer connects to all previous layers)
- Parameter efficient
- Strong gradient flow
- Good for feature reuse

**Variants:**
- **DenseNet121**: 8.0M params
- **DenseNet169**: 14.3M params
- **DenseNet201**: 20.2M params

**Example:**
```r
densenet <- application_densenet121(
  weights = "imagenet",
  include_top = FALSE,
  pooling = "avg"
)
```

## VGG Family

Classic deep convolutional architecture.

### application_vgg16()
### application_vgg19()

**Characteristics:**
- Simple architecture (3x3 convolutions only)
- Large model size (138M params for VGG16)
- Good for visualization and interpretation
- Older architecture, but still useful

**Example:**
```r
vgg16 <- application_vgg16(
  weights = "imagenet",
  include_top = FALSE,
  pooling = "avg"
)
```

## Inception Family

Multi-scale feature extraction with inception modules.

### application_inception_v3()

**Characteristics:**
- 23.9M params
- Inception modules (parallel convolutions)
- Auxiliary classifiers during training
- Good accuracy/efficiency tradeoff

### application_inception_resnet_v2()

Hybrid architecture combining Inception and ResNet.

**Example:**
```r
inception <- application_inception_v3(
  weights = "imagenet",
  include_top = FALSE,
  pooling = "avg"
)

inception_resnet <- application_inception_resnet_v2(
  weights = "imagenet",
  include_top = FALSE,
  pooling = "avg"
)
```

## Xception

Extreme Inception with depthwise separable convolutions.

### application_xception()

**Characteristics:**
- 22.9M params
- Depthwise separable convolutions throughout
- Linear residual connections
- Strong performance on many tasks

**Example:**
```r
xception <- application_xception(
  weights = "imagenet",
  include_top = FALSE,
  pooling = "avg"
)
```

## NASNet Family

Neural Architecture Search discovered models.

### application_nasnet_mobile()
### application_nasnet_large()

**Characteristics:**
- Automatically designed architecture
- Strong performance
- Complex architecture

**Example:**
```r
nasnet <- application_nasnet_mobile(
  weights = "imagenet",
  include_top = FALSE,
  pooling = "avg"
)
```

## Transfer Learning Patterns

### Pattern 1: Feature Extraction (Freeze Base)

Use pretrained model as fixed feature extractor.

```r
library(keras3)

# Load base model without top
base_model <- application_resnet50(
  include_top = FALSE,
  weights = "imagenet",
  input_shape = c(224, 224, 3),
  pooling = "avg"
)

# Freeze base model
freeze_weights(base_model)

# Add custom classifier
inputs <- layer_input(shape = c(224, 224, 3))
features <- base_model(inputs)
outputs <- features |>
  layer_dense(256, activation = "relu") |>
  layer_dropout(0.5) |>
  layer_dense(num_classes, activation = "softmax")

model <- keras_model(inputs, outputs)

# Compile with higher learning rate (only training head)
model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = "categorical_crossentropy",
  metrics = "accuracy"
)
```

### Pattern 2: Fine-tuning (Unfreeze and Train)

Train entire model with low learning rate.

```r
# Start with frozen base (pattern 1)
# ... train classifier head first ...

# Then unfreeze base model
unfreeze_weights(base_model)

# Recompile with lower learning rate
model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.0001),  # 10x lower
  loss = "categorical_crossentropy",
  metrics = "accuracy"
)

# Continue training
model |> fit(
  train_data,
  epochs = 20,
  validation_data = val_data
)
```

### Pattern 3: Gradual Unfreezing

Progressively unfreeze layers from top to bottom.

```r
# Unfreeze only last N layers
unfreeze_layers <- function(model, num_layers) {
  total_layers <- length(model$layers)
  for (i in seq_len(total_layers - num_layers)) {
    freeze_weights(model$layers[[i]])
  }
  for (i in (total_layers - num_layers + 1):total_layers) {
    unfreeze_weights(model$layers[[i]])
  }
}

# Train head first
# ... (pattern 1) ...

# Unfreeze top 20 layers
unfreeze_layers(base_model, 20)
model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.0001),
  loss = "categorical_crossentropy",
  metrics = "accuracy"
)

# Train some more
# ...

# Unfreeze all layers
unfreeze_weights(base_model)
model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.00001),  # Even lower
  loss = "categorical_crossentropy",
  metrics = "accuracy"
)
```

### Pattern 4: Learning Rate Scheduling

Use learning rate schedules for fine-tuning.

```r
# Exponential decay
lr_schedule <- learning_rate_schedule_exponential_decay(
  initial_learning_rate = 0.001,
  decay_steps = 1000,
  decay_rate = 0.96
)

model |> compile(
  optimizer = optimizer_adam(learning_rate = lr_schedule),
  loss = "categorical_crossentropy",
  metrics = "accuracy"
)

# Or use callbacks
model |> fit(
  train_data,
  epochs = 50,
  callbacks = list(
    callback_reduce_lr_on_plateau(
      monitor = "val_loss",
      factor = 0.5,
      patience = 5,
      min_lr = 0.00001
    )
  )
)
```

### Pattern 5: Multi-stage Training

Structured training pipeline.

```r
# Stage 1: Train head only (frozen base)
freeze_weights(base_model)
model |> compile(
  optimizer = optimizer_adam(0.001),
  loss = "categorical_crossentropy",
  metrics = "accuracy"
)
model |> fit(train_data, epochs = 10, validation_data = val_data)

# Stage 2: Fine-tune top layers
unfreeze_layers(base_model, 30)
model |> compile(
  optimizer = optimizer_adam(0.0001),
  loss = "categorical_crossentropy",
  metrics = "accuracy"
)
model |> fit(train_data, epochs = 20, validation_data = val_data)

# Stage 3: Fine-tune all layers
unfreeze_weights(base_model)
model |> compile(
  optimizer = optimizer_adam(0.00001),
  loss = "categorical_crossentropy",
  metrics = "accuracy"
)
model |> fit(train_data, epochs = 30, validation_data = val_data)
```

## Model Comparison Table

| Model | Params | Top-1 Acc | Input Size | Use Case |
|-------|--------|-----------|------------|----------|
| **MobileNet V3 Small** | 2.5M | 67.5% | 224x224 | Mobile, edge devices |
| **MobileNet V3 Large** | 5.4M | 75.2% | 224x224 | Mobile, edge devices |
| **EfficientNet B0** | 5.3M | 77.1% | 224x224 | Balanced efficiency |
| **EfficientNet B1** | 7.8M | 79.1% | 240x240 | Balanced efficiency |
| **ResNet50** | 25.6M | 76.1% | 224x224 | General purpose |
| **ResNet50 V2** | 25.6M | 76.0% | 224x224 | General purpose |
| **ConvNeXt Tiny** | 28M | 82.1% | 224x224 | Modern baseline |
| **EfficientNet B3** | 12M | 81.6% | 300x300 | High accuracy |
| **ResNet101** | 44.6M | 77.3% | 224x224 | Deep networks |
| **EfficientNet V2-S** | 21.5M | 83.9% | 384x384 | Fast training |
| **ConvNeXt Base** | 89M | 85.8% | 224x224 | SOTA transfer learning |
| **EfficientNet B7** | 66M | 84.3% | 600x600 | Maximum accuracy |
| **ConvNeXt Large** | 198M | 86.6% | 224x224 | Research, competitions |

## Preprocessing Functions

Each model family requires specific preprocessing:

```r
# ResNet, VGG (Caffe mode)
x <- imagenet_preprocess_input(x, mode = "caffe")

# Inception, Xception, MobileNet (TensorFlow mode)
x <- imagenet_preprocess_input(x, mode = "tf")

# Or use model-specific preprocessing
x <- preprocess_input(x, model = "resnet50")
```

## Complete Transfer Learning Example

```r
library(keras3)

# Configuration
IMG_SIZE <- c(224, 224)
BATCH_SIZE <- 32
NUM_CLASSES <- 10

# Data preprocessing with augmentation
data_augmentation <- keras_model_sequential() |>
  layer_random_flip("horizontal") |>
  layer_random_rotation(0.2) |>
  layer_random_zoom(0.2)

# Load and preprocess data
train_ds <- image_dataset_from_directory(
  "data/train",
  image_size = IMG_SIZE,
  batch_size = BATCH_SIZE
)

# Build transfer learning model
base_model <- application_efficientnet_b0(
  include_top = FALSE,
  weights = "imagenet",
  input_shape = c(IMG_SIZE, 3),
  pooling = "avg"
)
freeze_weights(base_model)

inputs <- layer_input(shape = c(IMG_SIZE, 3))
x <- inputs |>
  layer_rescaling(scale = 1/255) |>
  data_augmentation()
x <- base_model(x, training = FALSE)  # Inference mode for BN
outputs <- x |>
  layer_dense(256, activation = "relu") |>
  layer_dropout(0.5) |>
  layer_dense(NUM_CLASSES, activation = "softmax")

model <- keras_model(inputs, outputs)

# Stage 1: Train head
model |> compile(
  optimizer = optimizer_adam(0.001),
  loss = "sparse_categorical_crossentropy",
  metrics = "accuracy"
)
model |> fit(train_ds, epochs = 10)

# Stage 2: Fine-tune
unfreeze_weights(base_model)
model |> compile(
  optimizer = optimizer_adam(0.0001),
  loss = "sparse_categorical_crossentropy",
  metrics = "accuracy"
)
model |> fit(train_ds, epochs = 20)
```

## See Also

- [preprocessing-layers.md](preprocessing-layers.md) - Image preprocessing layers
- [advanced-patterns.md](advanced-patterns.md) - Custom training loops
- [backend-guide.md](backend-guide.md) - Backend-specific optimizations
