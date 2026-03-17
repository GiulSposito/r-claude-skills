# keras3 Skill

High-level deep learning API for R with multi-backend support (TensorFlow, JAX, PyTorch).

## Overview

This skill provides comprehensive guidance for **keras3** - the R interface to Keras 3, a powerful and intuitive deep learning API. Keras3 gives you the flexibility to choose your backend (TensorFlow, JAX, or PyTorch) while maintaining the same high-level API for rapid prototyping and production deployment.

**What makes this skill unique:**
- **Keras3-first perspective**: Guidance centered on keras3 as the primary API, not a secondary interface to TensorFlow
- **Multi-backend patterns**: Switch between TensorFlow, JAX, and PyTorch backends seamlessly
- **Complete preprocessing ecosystem**: Audio, image, and text preprocessing with keras3-native layers
- **30+ pretrained applications**: ResNet, EfficientNet, BERT, and more with transfer learning patterns
- **Production deployment**: Multiple export formats (SavedModel, .keras, ONNX) with deployment strategies
- **R-specific optimizations**: Idiomatic R patterns, pipe operators, and integration with tidyverse workflows

**Version compatibility:**
- keras3 package: 1.5.1+
- R: 4.0+
- Backends: TensorFlow 2.15+, JAX 0.4.13+, PyTorch 2.1.0+

## Features

### Core API Paradigms
- **Sequential API**: Simple layer stacking for straightforward architectures
- **Functional API**: Multi-input/output models, complex DAGs, residual connections
- **Model Subclassing**: Full control with custom forward passes and training logic

### Comprehensive Preprocessing
- **Audio**: Spectrogram generation, mel-scale conversion, audio augmentation
- **Image**: Rescaling, augmentation, resizing, center crop, random crop/flip
- **Text**: TextVectorization, embedding layers, sequence preprocessing

### Pretrained Models (30+ Applications)
- **Computer Vision**: ResNet, EfficientNet, DenseNet, MobileNet, Vision Transformer
- **NLP**: BERT, DistilBERT, RoBERTa, GPT-2
- **Audio**: Audio spectrogram transformer models
- **Transfer Learning**: Fine-tuning and feature extraction patterns

### Multi-Backend Support
- **TensorFlow**: Production-ready, SavedModel export, TensorFlow Serving
- **JAX**: High-performance, functional programming, XLA compilation
- **PyTorch**: Research-friendly, dynamic computation graphs

### Custom Components
- **Custom Layers**: Build reusable layer components with state
- **Custom Models**: Subclass Model for full control
- **Custom Losses**: Domain-specific loss functions
- **Custom Metrics**: Specialized evaluation metrics
- **Custom Callbacks**: Training monitoring and control

### Training & Optimization
- **Built-in fit()**: High-level training with callbacks, validation, metrics
- **Custom Training Loops**: GradientTape for full control
- **Callbacks**: Early stopping, learning rate scheduling, checkpointing, TensorBoard
- **Mixed Precision**: FP16 training for faster computation
- **Distributed Training**: Multi-GPU and TPU support

### Production Deployment
- **SavedModel**: TensorFlow Serving compatible format
- **.keras**: Portable keras3 format (cross-backend)
- **ONNX**: Cross-platform export
- **TFLite**: Mobile and edge deployment
- **Model Versioning**: Production deployment patterns

### R-Specific Optimizations
- **Pipe-friendly**: Full support for R pipe operators (`|>`)
- **Functional programming**: Map/reduce patterns for data pipelines
- **Tidyverse integration**: Work seamlessly with dplyr, tidyr, purrr
- **RMarkdown/Quarto**: Reproducible research and reporting

## When to Use This Skill

### Choose keras3 When:
- **High-level API preferred**: Focus on architecture, not low-level implementation
- **Rapid prototyping**: Quick iteration on model architectures
- **Multi-backend flexibility**: Want to experiment with different backends or switch later
- **Standard architectures**: ResNets, LSTMs, Transformers with pretrained weights
- **Production deployment**: Need SavedModel, ONNX, or TFLite export
- **Built-in training**: Prefer `fit()` API with callbacks over manual loops
- **Preprocessing layers**: Want data augmentation/preprocessing as part of model graph
- **Transfer learning**: Using pretrained models for fine-tuning or feature extraction

### Choose r-tensorflow When:
- **TensorFlow infrastructure**: Working with existing TensorFlow deployments
- **GPU setup and configuration**: Need detailed CUDA and device management
- **SavedModel deployment**: TensorFlow Serving integration
- **Low-level TensorFlow**: Custom tf_function, GradientTape, advanced graph optimization
- **TensorFlow ecosystem**: TFX, TF Extended, TensorBoard advanced features

### Choose r-deeplearning When:
- **Framework comparison**: Deciding between torch and keras3
- **General deep learning**: Need guidance across multiple frameworks
- **Architecture patterns**: Understanding general DL concepts (not framework-specific)

### Choose torch When:
- **Research and experimentation**: Maximum flexibility for novel architectures
- **Custom operators**: Need to write custom C++/CUDA kernels
- **Dynamic computation**: Architectures with dynamic control flow
- **PyTorch ecosystem**: Integration with PyTorch-specific tools
- **Low-level control**: Prefer manual optimization and gradient handling

## Installation

### Basic Installation

```r
# Install keras3 from CRAN
install.packages("keras3")

# Load the package
library(keras3)

# Install default backend (TensorFlow)
install_keras(backend = "tensorflow")

# Verify installation
keras3_version()
```

### Backend Options

```r
# TensorFlow backend (default, production-ready)
install_keras(backend = "tensorflow")

# JAX backend (high-performance, functional)
install_keras(backend = "jax")

# PyTorch backend (research-friendly)
install_keras(backend = "torch")
```

### Switching Backends

```r
# Set backend for current session
Sys.setenv(KERAS_BACKEND = "jax")

# Or set in .Renviron for persistence
# KERAS_BACKEND=tensorflow
```

### GPU Support

```r
# TensorFlow automatically includes GPU support
install_keras(backend = "tensorflow")

# Verify GPU availability
library(tensorflow)
tf$config$list_physical_devices("GPU")
```

See the r-tensorflow skill for detailed GPU configuration and troubleshooting.

## Quick Start

### Simple Image Classification

```r
library(keras3)

# Load MNIST data
mnist <- dataset_mnist()
c(c(x_train, y_train), c(x_test, y_test)) %<-% mnist

# Preprocess
x_train <- x_train / 255
x_test <- x_test / 255

# Create Sequential model
model <- keras_model_sequential(input_shape = c(28, 28)) |>
  layer_flatten() |>
  layer_dense(128, activation = "relu") |>
  layer_dropout(0.2) |>
  layer_dense(10, activation = "softmax")

# Compile
model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = loss_sparse_categorical_crossentropy(),
  metrics = c("accuracy")
)

# Train
history <- model |> fit(
  x_train, y_train,
  epochs = 10,
  validation_split = 0.2,
  verbose = 2
)

# Evaluate
results <- model |> evaluate(x_test, y_test, verbose = 0)
cat(sprintf("Test accuracy: %.2f%%\n", results["accuracy"] * 100))

# Predict
predictions <- model |> predict(x_test[1:5, , ])
```

## Skill Invocation

### Automatic Activation

The skill automatically activates when Claude detects:

**Explicit mentions:**
- "keras3"
- "Keras 3"
- "keras_model_sequential"
- "Functional API"
- "custom keras layer"
- "keras applications"

**Code patterns:**
- `keras_model_sequential()`
- `keras_model()`
- `layer_*()`
- `optimizer_*()`
- `loss_*()`
- `application_*()`

**Concepts:**
- "Sequential API"
- "Functional API"
- "model subclassing"
- "keras preprocessing layers"
- "transfer learning with keras3"
- "keras callbacks"

**Important**: This skill is for **R only**. It will NOT activate for Python Keras code.

### Manual Invocation

```bash
/keras3
```

Use manual invocation when:
- Starting a new keras3 project
- Need comprehensive guidance on API choices
- Want to see all available preprocessing layers
- Comparing Sequential vs Functional vs Subclassing APIs

### Skill Type

**Background Knowledge Skill** (`user-invocable: false`)

Claude uses this skill automatically when relevant. While users can invoke it manually with `/keras3`, it's primarily designed to activate automatically based on context.

## File Structure

```
.claude/skills/keras3/
├── SKILL.md                              # Main skill guidance
├── README.md                             # This file
├── templates/
│   ├── sequential-template.R            # Sequential API starter
│   ├── functional-template.R            # Functional API starter
│   ├── subclass-template.R              # Model subclassing starter
│   └── custom-layer-template.R          # Custom layer template
├── examples/
│   ├── functional-api-advanced.md       # Multi-input/output patterns
│   ├── custom-layers-models.md          # Custom components
│   ├── audio-classification.md          # Audio with keras3 preprocessing
│   ├── nlp-patterns.md                  # Text classification & generation
│   └── deployment-comparison.md         # Export format comparison
└── references/
    ├── preprocessing-layers.md          # Complete preprocessing catalog
    ├── keras-applications.md            # Pretrained models guide
    ├── backend-guide.md                 # Backend switching & optimization
    ├── callbacks-reference.md           # All built-in callbacks
    └── advanced-patterns.md             # Custom training, mixed precision
```

## Key Examples

### Functional API - Advanced Patterns
**File**: [examples/functional-api-advanced.md](examples/functional-api-advanced.md)

Complete examples of:
- Multi-input models (image + metadata)
- Multi-output models (auxiliary losses)
- Residual connections (ResNet-style)
- Inception modules
- Attention mechanisms
- Shared layers and weight sharing
- Complex DAG architectures

### Custom Layers & Models
**File**: [examples/custom-layers-models.md](examples/custom-layers-models.md)

Build custom components:
- Custom layers with trainable parameters
- Stateful layers (RNN-style)
- Custom models via subclassing
- Custom loss functions
- Custom metrics
- Custom callbacks
- Full training loop examples

### Audio Classification (keras3-native)
**File**: [examples/audio-classification.md](examples/audio-classification.md)

End-to-end audio pipeline using keras3 preprocessing:
- Audio loading and preprocessing
- Spectrogram generation with `layer_mel_spectrogram()`
- Mel-scale conversion
- Audio augmentation layers
- CNN architecture for spectrograms
- Training with callbacks
- Deployment patterns

**Why keras3 for audio?**
- Preprocessing as part of model graph
- Single-file model export includes audio preprocessing
- No external dependencies at inference time
- Backend flexibility (TensorFlow/JAX/PyTorch)

See r-bioacoustics skill for audio signal analysis and feature extraction.

### NLP Patterns
**File**: [examples/nlp-patterns.md](examples/nlp-patterns.md)

Text processing and modeling:
- Text vectorization with `layer_text_vectorization()`
- Embedding layers
- LSTM/GRU for sequence modeling
- Transformer architectures
- Pretrained BERT fine-tuning
- Text generation with temperature
- Sentiment analysis
- Multi-class text classification

### Deployment Comparison
**File**: [examples/deployment-comparison.md](examples/deployment-comparison.md)

Choose the right export format:
- **SavedModel**: TensorFlow Serving, Python/R inference
- **.keras**: Portable, cross-backend, versioned
- **ONNX**: Cross-platform, non-Python runtimes
- **TFLite**: Mobile and edge devices
- **Weights only**: Fine-tuning scenarios

Includes production deployment patterns and best practices.

## Key References

### Preprocessing Layers Catalog
**File**: [references/preprocessing-layers.md](references/preprocessing-layers.md)

Complete reference of all keras3 preprocessing layers:

**Image preprocessing:**
- Rescaling, Normalization, Resizing
- CenterCrop, RandomCrop, RandomFlip, RandomRotation
- RandomContrast, RandomBrightness, RandomZoom

**Audio preprocessing:**
- MelSpectrogram, Spectrogram
- Audio augmentation layers

**Text preprocessing:**
- TextVectorization, StringLookup, IntegerLookup
- Hashing, CategoryEncoding

**Structured data:**
- Discretization, CategoryEncoding, Hashing
- Normalization

Each with usage examples and best practices.

### Keras Applications Guide
**File**: [references/keras-applications.md](references/keras-applications.md)

Comprehensive guide to 30+ pretrained models:

**Computer vision:**
- ResNet family (50, 101, 152, V2)
- EfficientNet (B0-B7)
- DenseNet (121, 169, 201)
- MobileNet (V1, V2, V3)
- Vision Transformer (ViT)
- ConvNeXt

**NLP:**
- BERT and variants
- DistilBERT
- RoBERTa

**Usage patterns:**
- Feature extraction (frozen base)
- Fine-tuning (unfreezing layers)
- Custom top layers
- Input preprocessing requirements
- Memory and compute considerations

### Backend Switching Guide
**File**: [references/backend-guide.md](references/backend-guide.md)

Deep dive into multi-backend support:

**Backend characteristics:**
- **TensorFlow**: Production deployment, SavedModel, TensorFlow Serving
- **JAX**: Functional programming, XLA compilation, high performance
- **PyTorch**: Dynamic graphs, research flexibility, PyTorch ecosystem

**Switching backends:**
- Environment configuration
- API compatibility notes
- Performance implications
- Deployment considerations

**Optimization per backend:**
- TensorFlow: tf_function, mixed precision, distribution strategies
- JAX: jit, vmap, pmap for parallelization
- PyTorch: torch.compile, dynamic batching

### Callbacks Reference
**File**: [references/callbacks-reference.md](references/callbacks-reference.md)

All built-in callbacks with usage examples:

**Training control:**
- EarlyStopping: Stop when validation metric stops improving
- ReduceLROnPlateau: Adaptive learning rate
- LearningRateScheduler: Custom schedules
- TerminateOnNaN: Stop on numerical instability

**Monitoring:**
- TensorBoard: Visualization and logging
- CSVLogger: Training history to CSV
- RemoteMonitor: Send events to server

**Checkpointing:**
- ModelCheckpoint: Save best models
- BackupAndRestore: Fault tolerance

**Custom callbacks:**
- Base class structure
- Available hooks (on_epoch_begin, on_batch_end, etc.)
- Example implementations

### Advanced Patterns
**File**: [references/advanced-patterns.md](references/advanced-patterns.md)

Advanced techniques:

**Custom training loops:**
- GradientTape for manual optimization
- Custom metrics accumulation
- Multi-optimizer training (GANs)
- Gradient clipping and manipulation

**Mixed precision training:**
- FP16 computation with FP32 master weights
- Loss scaling for numerical stability
- Memory savings and speed improvements

**Distributed training:**
- Multi-GPU strategies (MirroredStrategy)
- TPU strategies
- Data parallelism patterns

**Model interpretation:**
- Grad-CAM visualization
- Attention weight visualization
- Feature map analysis

## Integration with Other Skills

### r-tensorflow - Infrastructure & Deployment
**Relationship**: Complementary infrastructure layer

**Use r-tensorflow for:**
- TensorFlow installation and GPU setup
- SavedModel deployment with TensorFlow Serving
- Low-level TensorFlow operations (tf_function, GradientTape)
- TensorFlow-specific troubleshooting
- Integration with Python TensorFlow code

**Use keras3 for:**
- High-level model definition and training
- Multi-backend flexibility (not locked to TensorFlow)
- Preprocessing layers as part of model
- Transfer learning with pretrained models

**Typical workflow**: Use keras3 for model development, use r-tensorflow for deployment infrastructure.

### r-deeplearning - Framework Comparison
**Relationship**: Framework-agnostic guidance

**Use r-deeplearning for:**
- Deciding between torch and keras3
- General deep learning concepts (architectures, training strategies)
- Framework-agnostic best practices
- Understanding when to use which framework

**Use keras3 for:**
- Keras3-specific implementation details
- API usage and patterns
- Preprocessing layers
- Pretrained models catalog

**Typical workflow**: Consult r-deeplearning to choose framework, then use keras3 skill for implementation.

### r-bioacoustics - Audio Signal Analysis
**Relationship**: Domain expertise + preprocessing

**Use r-bioacoustics for:**
- Bioacoustic signal analysis (tuneR, seewave, warbleR)
- Traditional acoustic features (MFCCs, spectral features)
- Ecological audio analysis patterns
- Audio format handling and conversion

**Use keras3 for:**
- Deep learning on audio spectrograms
- End-to-end audio classification models
- Audio preprocessing as part of model graph (layer_mel_spectrogram)
- Transfer learning for audio tasks

**Integration pattern**: Use r-bioacoustics for exploratory audio analysis and feature engineering, then use keras3 for deep learning models with built-in preprocessing.

### learning-paradigms - Transfer Learning Context
**Relationship**: Theoretical foundation

**Use learning-paradigms for:**
- Transfer learning theory and strategies
- When to freeze/unfreeze layers
- Domain adaptation concepts
- Few-shot learning patterns

**Use keras3 for:**
- Implementation of transfer learning with keras3 applications
- Fine-tuning mechanics (trainable flags, layer freezing)
- Pretrained model catalog

**Typical workflow**: Understand transfer learning strategy with learning-paradigms, implement with keras3.

## Differentiation

### What Makes This Skill Unique

#### 1. Keras3-First Perspective
Unlike r-tensorflow (which treats keras3 as part of TensorFlow), this skill centers keras3 as the primary API:
- Keras3 as the entry point, not "TensorFlow with keras3"
- Multi-backend approach (TensorFlow is one option, not the only one)
- Emphasis on keras3-native patterns and best practices

#### 2. Comprehensive Preprocessing Focus
Deep coverage of keras3's preprocessing ecosystem:
- Audio preprocessing with keras3 layers (not torchaudio)
- Image augmentation as part of model graph
- Text vectorization and embedding patterns
- Structured data preprocessing

**Advantage**: Preprocessing becomes part of the model, exported together for deployment.

#### 3. Multi-Backend Patterns
Guidance on switching between TensorFlow, JAX, and PyTorch backends:
- When to use each backend
- API compatibility across backends
- Performance optimization per backend
- Migration patterns

**Advantage**: Not locked into TensorFlow ecosystem; can switch backends based on deployment needs.

#### 4. Pretrained Models Catalog
Comprehensive guide to 30+ keras3 applications:
- Computer vision models with ImageNet weights
- NLP models (BERT, DistilBERT)
- Transfer learning patterns (feature extraction vs fine-tuning)
- Custom top layer patterns

**Advantage**: Production-ready pretrained models with one-line loading.

#### 5. Production Deployment Focus
Multiple export formats with deployment guidance:
- SavedModel for TensorFlow Serving
- .keras for cross-backend portability
- ONNX for cross-platform inference
- TFLite for mobile and edge

**Advantage**: Clear path from prototype to production.

#### 6. R-Specific Optimizations
Idiomatic R patterns:
- Pipe operator integration (`|>`)
- Functional programming patterns
- Tidyverse data pipeline integration
- RMarkdown/Quarto reproducible research

**Advantage**: Feels natural in R workflows, not just Python translated to R.

### Comparison with Related Skills

| Feature | keras3 | r-tensorflow | r-deeplearning | torch |
|---------|--------|--------------|----------------|-------|
| **Primary focus** | High-level API | TensorFlow infrastructure | Framework comparison | Research flexibility |
| **Backend options** | TF, JAX, PyTorch | TensorFlow only | torch + keras3 | PyTorch only |
| **Preprocessing layers** | ✅ Comprehensive | ⚠️ Via keras3 | ⚠️ Via framework skills | ✅ torchaudio/torchvision |
| **Pretrained models** | ✅ 30+ applications | ⚠️ Via keras3 | ⚠️ Via framework skills | ✅ torchvision.models |
| **Deployment formats** | Multiple (SavedModel, .keras, ONNX) | SavedModel focus | Framework-dependent | .pt, ONNX |
| **Custom training loops** | ⚠️ Supported, but fit() preferred | ✅ GradientTape focus | ✅ Both frameworks | ✅ Manual optimization |
| **Production readiness** | ✅ Built-in | ✅ TensorFlow Serving | Framework-dependent | ⚠️ More manual |
| **Learning curve** | Low (high-level) | Medium (infrastructure) | Medium (concepts) | Medium-High (low-level) |

## Resources

### Official Documentation
- **Keras3 for R**: https://keras3.posit.co/
  - Complete API reference
  - Getting started guides
  - Migration from Keras 2

- **Keras.io**: https://keras.io/
  - Keras 3 official documentation
  - Code examples (Python, translatable to R)
  - API reference

### Package Resources
- **CRAN**: https://cran.r-project.org/package=keras3
  - Package documentation
  - Version history
  - Installation instructions

- **GitHub**: https://github.com/rstudio/keras3
  - Source code
  - Issue tracker
  - Development version

### Books
- **Deep Learning with R (2nd Edition)** by François Chollet and Tomasz Kalinowski
  - Comprehensive keras3 coverage
  - R-specific examples
  - Covers keras3 migration
  - Available from Manning Publications

### Tutorials & Learning
- **Posit AI Blog**: https://blogs.rstudio.com/ai/
  - keras3 tutorials and examples
  - Deep learning best practices
  - Model deployment guides

- **RStudio Community**: https://community.rstudio.com/
  - Q&A for keras3
  - Example implementations
  - Troubleshooting help

### Related Packages
- **tensorflow**: TensorFlow backend support
- **torch**: Alternative deep learning framework
- **tfdatasets**: TensorFlow data pipelines
- **tfhub**: TensorFlow Hub pretrained models
- **luz**: High-level torch wrapper (torch equivalent of keras3)

### Research Papers
- **Keras 3**: "Keras 3: A Universal API for Deep Learning" (2023)
- **Transfer Learning**: "A Survey on Transfer Learning" (IEEE Transactions)
- **Mixed Precision**: "Mixed Precision Training" (ICLR 2018)

## Contributing

To improve this skill:

1. **Update core content**: Edit `SKILL.md` for main guidance
2. **Add examples**: Create new files in `examples/` for complete working examples
3. **Extend references**: Add detailed references to `references/` (callbacks, layers, etc.)
4. **Add templates**: Create starter templates in `templates/` for common patterns
5. **Keep main skill concise**: Move detailed content to supporting files

### Content Guidelines
- Keep `SKILL.md` under 500 lines (move details to references)
- Examples should be complete and runnable
- Include error handling in code examples
- Test code on multiple backends when relevant
- Use R-idiomatic patterns (pipes, functional programming)
- Cite official documentation for API details

### Testing Changes
- Test manual invocation: `/keras3`
- Test automatic activation with trigger phrases
- Verify all file references work
- Run example code to ensure it executes
- Check for YAML frontmatter validity

## License

MIT License - Part of the claudeSkiller project.

## Skill Metadata

- **Version**: 1.0.0
- **Created**: 2026-03-16
- **Type**: Reference/Background Knowledge
- **Invocation**: Automatic (Claude-only) + Manual capable
- **Language**: R only
- **Dependencies**: keras3, reticulate, backend (tensorflow/jax/torch)
- **Maintained by**: Claude Code Skills Project

---

**Need help?** Invoke the skill with `/keras3` or mention "keras3" in your conversation for automatic guidance.
