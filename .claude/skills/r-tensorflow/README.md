# r-tensorflow Skill

Expert guidance for TensorFlow in R using the `tensorflow` package and keras3 integration.

## Overview

This skill provides comprehensive support for:
- **Installation and setup** (`install_tensorflow()`, GPU configuration, troubleshooting)
- **Core concepts** (tensors, graphs, tf_function, automatic differentiation)
- **Keras3 integration** (Sequential, Functional, Subclassing APIs)
- **Model training** (fit(), custom loops, callbacks, optimization)
- **Deployment** (SavedModel, TensorFlow Serving, ONNX export)
- **Framework comparison** (TensorFlow vs torch vs keras3 - when to use each)
- **Best practices** (GPU optimization, mixed precision, distributed training)

## When This Skill Activates

The skill automatically activates when Claude detects:
- TensorFlow-specific mentions: "tensorflow em R", "tensorflow for R", "install_tensorflow"
- Infrastructure needs: "SavedModel", "TensorFlow deployment", "tf_function"
- Keras3 backend: "keras3 backend", "TensorFlow graph"
- Integration: "Python TensorFlow code", "TensorFlow infrastructure"

**Important**: This skill is for **R only**. It will NOT activate for Python TensorFlow code.

## Skill Type

**Background Knowledge Skill** (`user-invocable: false`)

Claude uses this skill automatically when relevant. Users cannot invoke it directly with `/r-tensorflow`.

## File Structure

```
.claude/skills/r-tensorflow/
├── SKILL.md                                    # Main skill (core concepts, workflows)
├── README.md                                   # This file
├── examples/
│   ├── cifar10-complete.md                    # Complete end-to-end example
│   └── keras-workflows.md                     # Common workflow patterns
└── references/
    ├── framework-comparison.md                # TensorFlow vs torch vs keras3
    └── installation-troubleshooting.md        # Comprehensive troubleshooting guide
```

## Key Topics Covered

### Installation & Setup
- `install_tensorflow()` variants (CPU, GPU, specific versions)
- GPU configuration and memory management
- Environment management (virtualenv, conda)
- Platform-specific installation (Ubuntu, Windows, macOS M1/M2)
- Common issues and fixes

### Core TensorFlow
- Tensors and operations
- Automatic differentiation with GradientTape
- Graph compilation with `tf_function()`
- Python-R bridge via reticulate

### Keras3 Integration
- Sequential API (simple stacking)
- Functional API (multi-input/output, DAG architectures)
- Model subclassing (custom models)
- Training with `fit()` and custom loops

### Model Training
- Compiling models (optimizers, losses, metrics)
- Callbacks (early stopping, checkpoints, LR scheduling)
- Data augmentation (image, text)
- Transfer learning and fine-tuning

### Deployment
- SavedModel format (TensorFlow Serving compatible)
- Keras format (.keras files)
- Weight checkpoints
- ONNX export (cross-platform)
- TensorFlow Hub integration

### GPU & Performance
- GPU detection and configuration
- Memory growth settings
- Mixed precision training (FP16)
- Multi-GPU training (MirroredStrategy)
- tf_function optimization

### Data Pipelines
- tfdatasets package
- Preprocessing layers (TextVectorization, Normalization)
- Dataset transformations (map, batch, shuffle, prefetch, cache)

### Advanced Topics
- Custom layers and models
- Custom training loops with GradientTape
- Multi-input/multi-output models
- Autoencoders and GANs
- Distributed training strategies

## Framework Comparison

### Quick Decision Guide

**Use TensorFlow when:**
- Existing TensorFlow infrastructure
- Need SavedModel/TensorFlow Serving
- Cross-platform deployment (TFLite, TF.js)
- Integration with Python TensorFlow code

**Use torch when:**
- Research and experimentation
- Custom training loops required
- Novel architectures from papers
- Need maximum flexibility

**Use keras3 when:**
- Standard architectures (ResNet, LSTM)
- Rapid prototyping
- Multi-backend flexibility (TF/JAX/torch)
- Production with built-in `fit()`

See `references/framework-comparison.md` for detailed comparison.

## Installation Quick Start

```r
# Basic installation
install.packages("tensorflow")
library(tensorflow)
install_tensorflow()

# GPU-capable (latest version with auto CUDA setup)
install_tensorflow()

# Specific version
install_tensorflow(version = "2.14.0")

# CPU-only (smaller)
install_tensorflow(version = "cpu")

# Verify
tf$constant("Hello TensorFlow!")
```

## Common Workflows

### Image Classification (CNN)

```r
library(keras3)

model <- keras_model_sequential(input_shape = c(28, 28, 1)) |>
  layer_conv_2d(32, 3, activation = "relu") |>
  layer_max_pooling_2d(2) |>
  layer_flatten() |>
  layer_dense(10, activation = "softmax")

model |> compile(
  optimizer = optimizer_adam(),
  loss = loss_sparse_categorical_crossentropy(),
  metrics = c("accuracy")
)

model |> fit(x_train, y_train, epochs = 10, validation_split = 0.2)
```

### Transfer Learning

```r
base_model <- application_resnet50(weights = "imagenet", include_top = FALSE)
base_model$trainable <- FALSE

model <- keras_model_sequential() |>
  base_model |>
  layer_global_average_pooling_2d() |>
  layer_dense(10, activation = "softmax")

model |> compile(optimizer = optimizer_adam(),
                 loss = loss_categorical_crossentropy())
model |> fit(data, labels, epochs = 10)
```

### Model Deployment

```r
# Save for production
save_model(model, "production/model_v1")

# Load and serve
model <- load_model("production/model_v1")
predictions <- model |> predict(new_data)
```

See `examples/keras-workflows.md` for more patterns.

## Troubleshooting

### GPU Not Detected

```r
# Check GPUs
tf$config$list_physical_devices("GPU")

# Enable memory growth
gpus <- tf$config$list_physical_devices("GPU")
tf$config$experimental$set_memory_growth(gpus[[1]], TRUE)
```

### Installation Fails

```r
# Force reinstall
install_tensorflow(force = TRUE)

# Try conda method (Windows)
install_tensorflow(method = "conda")

# Clean slate
reticulate::virtualenv_remove("r-tensorflow")
install_tensorflow(envname = "r-tf-fresh")
```

See `references/installation-troubleshooting.md` for comprehensive solutions.

## Examples

### Complete CIFAR-10 Example

See `examples/cifar10-complete.md` for a full end-to-end example covering:
- Data loading and preprocessing
- CNN architecture with data augmentation
- Training with callbacks
- Evaluation and visualization
- Model saving and deployment
- Production inference patterns

### Keras Workflow Patterns

See `examples/keras-workflows.md` for common patterns:
- Image classification (CNN)
- Text classification (LSTM, TextVectorization)
- Time series forecasting (LSTM)
- Transfer learning
- Multi-input/multi-output models
- Autoencoders
- Callbacks (built-in and custom)
- Mixed precision training
- Distributed training

## Resources

### Documentation
- TensorFlow for R: https://tensorflow.rstudio.com
- Keras3: https://keras3.posit.co
- TensorFlow API: https://www.tensorflow.org/api_docs

### Books
- **Deep Learning with R** (2nd edition) - Comprehensive keras3 coverage

### Related Packages
- **keras3**: High-level neural networks API
- **tfdatasets**: Data input pipelines
- **tfhub**: Pretrained models
- **tfruns**: Experiment tracking
- **tfautograph**: Graph compilation
- **tfprobability**: Probabilistic programming

## Skill Metadata

- **Version**: 1.0.0
- **Created**: 2024-03-16
- **Type**: Reference/Background Knowledge
- **Invocation**: Automatic (Claude-only)
- **Languages**: R only
- **Dependencies**: tensorflow, keras3, reticulate

## Complementary Skills

This skill complements:
- **r-deeplearning**: torch and keras3 (covers torch primarily, this covers TensorFlow)
- **r-datascience**: Data preprocessing with tidyverse before modeling
- **r-tidymodels**: Traditional ML (use TensorFlow/keras3 for deep learning)

## Contributing

To improve this skill:
1. Update `SKILL.md` for core content
2. Add examples to `examples/`
3. Extend references in `references/`
4. Keep main SKILL.md under 500 lines (move details to supporting files)

## License

Part of the claudeSkiller project.
