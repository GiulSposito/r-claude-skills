# Framework Comparison: TensorFlow vs torch vs keras3 in R

Comprehensive comparison to help choose the right deep learning framework for your R project.

## Quick Decision Matrix

| Aspect | torch | keras3 | tensorflow (R interface) |
|--------|-------|--------|--------------------------|
| **Abstraction Level** | Low-level, explicit | High-level, concise | Infrastructure layer |
| **Control** | Maximum flexibility | Moderate | Limited (through keras3) |
| **Learning Curve** | Steeper | Gentler | Medium |
| **Training API** | Manual loops or luz | Built-in `fit()` | Via keras3 |
| **Backend** | Pure PyTorch | TensorFlow/JAX/torch | TensorFlow/libtorch |
| **Best for** | Research, custom architectures | Production, standard models | Deployment, infrastructure |
| **Community** | Growing in R | Established | Mature |
| **Pretrained Models** | torchvision, torchaudio | TensorFlow Hub, Keras Apps | TensorFlow Hub |
| **Deployment** | ONNX, TorchScript | SavedModel, ONNX | SavedModel, TF Serving |
| **GPU Support** | Excellent | Excellent | Excellent |
| **Multi-backend** | No | Yes (TF/JAX/torch) | No |

---

## When to Use Each Framework

### Use **torch** When:

✅ **Research and Experimentation**
- Implementing novel architectures from papers
- Custom loss functions with complex logic
- Need full control over training loop
- Experimenting with cutting-edge techniques

✅ **Custom Training Procedures**
- Non-standard optimization strategies
- Multi-task learning with custom schedulers
- Advanced gradient manipulation
- Custom backward passes

✅ **State-of-the-Art Models**
- PyTorch-based pretrained models (Hugging Face)
- Research code primarily in PyTorch
- Audio processing with torchaudio
- Computer vision with torchvision

✅ **Educational Purposes**
- Learning deep learning fundamentals
- Understanding backpropagation mechanics
- Building models from scratch

**Example Use Cases:**
- Implementing transformer variants (GPT, BERT)
- Custom audio classification with spectrograms
- Multi-modal learning (text + image + audio)
- Research in few-shot learning or meta-learning

---

### Use **keras3** When:

✅ **Standard Architectures**
- ResNet, VGG, Inception, MobileNet
- LSTM, GRU, transformers (standard)
- U-Net, autoencoders
- Standard GANs, VAEs

✅ **Rapid Prototyping**
- Need quick results
- Standard training workflow with `fit()`
- Built-in callbacks and metrics
- High-level API preferred

✅ **Production Ready**
- Standard deployment pipelines
- Need built-in training features
- Prefer stable, well-tested API
- Multi-backend flexibility (TF/JAX/torch)

✅ **Transfer Learning**
- Using Keras Applications (ResNet50, VGG16, etc.)
- TensorFlow Hub models
- Fine-tuning pretrained models
- Standard image classification

**Example Use Cases:**
- Image classification (standard datasets)
- Text classification with embeddings
- Time series forecasting (standard architectures)
- Sentiment analysis
- Standard recommendation systems

---

### Use **tensorflow** (R interface) When:

✅ **Existing TensorFlow Infrastructure**
- Integrating with Python TensorFlow pipelines
- Company already using TensorFlow
- Existing TF models to maintain
- TensorFlow Serving deployment

✅ **Deployment Requirements**
- Need SavedModel format
- TensorFlow Serving infrastructure
- TensorFlow Lite (mobile deployment)
- TensorFlow.js (web deployment)

✅ **Cross-Platform Models**
- Deploy to web browsers
- Mobile apps (iOS/Android)
- Edge devices with TFLite
- Embedded systems

✅ **Graph Optimization**
- Need `tf_function()` compilation
- Complex computational graphs
- Performance-critical production code
- Custom TensorFlow operations

✅ **Python Interoperability**
- Working with Python data scientists
- Existing Python TF codebase
- Need to call Python TF code from R
- Sharing models between Python and R

**Example Use Cases:**
- Deploying models to TensorFlow Serving
- Converting Python TF models to R
- Production pipelines with TF infrastructure
- Multi-platform deployment (web + mobile + server)

---

## Performance Comparison

### Training Speed

**torch**:
- Fast with manual loops
- luz provides high-level interface with good performance
- Excellent GPU utilization
- DataLoader with num_workers for parallel loading

**keras3**:
- Fast with built-in `fit()`
- Automatic optimization
- Good GPU utilization
- Backend-dependent (TensorFlow backend is mature)

**tensorflow**:
- Fast with keras3 interface
- `tf_function()` compilation for additional speedup
- Excellent for graph-optimized operations
- Mixed precision training support

**Verdict**: All three are performant. torch gives more control for optimization, keras3 is fastest to implement, tensorflow excels at graph optimization.

---

### Memory Efficiency

**torch**:
- Manual memory management
- `with_no_grad()` for inference
- `torch_empty_cache()` to free GPU memory
- Gradient accumulation for large batches

**keras3**:
- Automatic memory management
- Efficient built-in batching
- Handles memory well with `fit()`

**tensorflow**:
- Memory growth configuration
- `tf$config$experimental$set_memory_growth()`
- Automatic graph optimization
- Good memory management with tfdatasets

**Verdict**: All handle memory well. torch requires more manual management but offers more control.

---

## API Comparison

### Model Definition

**torch** (most explicit):
```r
model <- nn_module(
  initialize = function() {
    self$conv1 <- nn_conv2d(3, 32, kernel_size = 3)
    self$fc1 <- nn_linear(32 * 30 * 30, 128)
    self$fc2 <- nn_linear(128, 10)
  },
  forward = function(x) {
    x <- self$conv1(x)
    x <- nnf_relu(x)
    x <- nnf_max_pool2d(x, 2)
    x <- torch_flatten(x, start_dim = 2)
    x <- self$fc1(x)
    x <- nnf_relu(x)
    self$fc2(x)
  }
)
```

**keras3** (most concise):
```r
model <- keras_model_sequential() |>
  layer_conv_2d(32, 3, activation = "relu", input_shape = c(32, 32, 3)) |>
  layer_max_pooling_2d(2) |>
  layer_flatten() |>
  layer_dense(128, activation = "relu") |>
  layer_dense(10, activation = "softmax")
```

**tensorflow** (through keras3):
Same as keras3, but can access low-level TF ops:
```r
# Keras3 for model, TF for custom ops
model <- keras_model_sequential() |>
  layer_lambda(function(x) tf$nn$softmax(x, axis = -1L))
```

---

### Training Loop

**torch** (manual control):
```r
for (epoch in 1:epochs) {
  coro::loop(for (batch in train_dl) {
    optimizer$zero_grad()
    output <- model(batch$x)
    loss <- nnf_cross_entropy(output, batch$y)
    loss$backward()
    optimizer$step()
  })
}
```

**keras3** (automatic):
```r
model |> fit(
  x_train, y_train,
  epochs = 10,
  validation_split = 0.2,
  callbacks = list(callback_early_stopping(patience = 3))
)
```

**tensorflow** (through keras3 or custom):
```r
# High-level
model |> fit(dataset, epochs = 10)

# Custom with GradientTape
with(tf$GradientTape() %as% tape, {
  loss <- loss_fn(model(x), y)
})
grads <- tape$gradient(loss, model$trainable_weights)
optimizer$apply_gradients(zip_lists(grads, model$trainable_weights))
```

---

## Ecosystem Integration

### R Ecosystem

**torch**:
- `luz`: High-level training (similar to keras)
- `torchvision`: Image models and datasets
- `torchaudio`: Audio processing
- Growing tidyverse integration

**keras3**:
- Native pipe (`|>`) support
- Works with tidymodels for feature engineering
- Good R integration patterns
- Mature R community

**tensorflow**:
- `tfdatasets`: Data pipelines
- `tfhub`: Pretrained models
- `tfruns`: Experiment tracking
- `reticulate` bridge to Python

---

### Pretrained Models

**torch**:
- torchvision models (ResNet, VGG, etc.)
- Hugging Face transformers (via Python)
- Growing collection in torch ecosystem

**keras3**:
- Keras Applications (20+ architectures)
- TensorFlow Hub (thousands of models)
- Easy fine-tuning with `application_*()` functions

**tensorflow**:
- TensorFlow Hub (largest collection)
- Keras Applications
- Easy integration with Python TF models

**Verdict**: keras3/tensorflow have the largest pretrained model ecosystem.

---

## Code Examples: Same Task in Each Framework

### Task: Binary Image Classification

**torch**:
```r
library(torch)

# Define model
model <- nn_module(
  initialize = function() {
    self$conv1 <- nn_conv2d(3, 16, 3, padding = 1)
    self$conv2 <- nn_conv2d(16, 32, 3, padding = 1)
    self$fc1 <- nn_linear(32 * 8 * 8, 128)
    self$fc2 <- nn_linear(128, 1)
  },
  forward = function(x) {
    x <- self$conv1(x) |> nnf_relu() |> nnf_max_pool2d(2)
    x <- self$conv2(x) |> nnf_relu() |> nnf_max_pool2d(2)
    x <- torch_flatten(x, start_dim = 2)
    x <- self$fc1(x) |> nnf_relu()
    self$fc2(x)
  }
)

# Training loop
optimizer <- optim_adam(model$parameters, lr = 0.001)

for (epoch in 1:10) {
  coro::loop(for (batch in train_dl) {
    optimizer$zero_grad()
    output <- model(batch$x)
    loss <- nnf_binary_cross_entropy_with_logits(output, batch$y)
    loss$backward()
    optimizer$step()
  })
}
```

**keras3**:
```r
library(keras3)

# Define model
model <- keras_model_sequential() |>
  layer_conv_2d(16, 3, activation = "relu", padding = "same", input_shape = c(32, 32, 3)) |>
  layer_max_pooling_2d(2) |>
  layer_conv_2d(32, 3, activation = "relu", padding = "same") |>
  layer_max_pooling_2d(2) |>
  layer_flatten() |>
  layer_dense(128, activation = "relu") |>
  layer_dense(1, activation = "sigmoid")

# Compile and train
model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = loss_binary_crossentropy(),
  metrics = c("accuracy")
)

model |> fit(x_train, y_train, epochs = 10, validation_split = 0.2)
```

**tensorflow** (via keras3):
Same as keras3, with option to add TF-specific features:
```r
library(tensorflow)
library(keras3)

# Same model as keras3
model <- keras_model_sequential() |>
  layer_conv_2d(16, 3, activation = "relu", padding = "same") |>
  layer_max_pooling_2d(2) |>
  layer_conv_2d(32, 3, activation = "relu", padding = "same") |>
  layer_max_pooling_2d(2) |>
  layer_flatten() |>
  layer_dense(128, activation = "relu") |>
  layer_dense(1, activation = "sigmoid")

# Use tf_function for optimization
train_step <- tf_function(function(x, y) {
  with(tf$GradientTape() %as% tape, {
    predictions <- model(x, training = TRUE)
    loss <- loss_fn(y, predictions)
  })

  gradients <- tape$gradient(loss, model$trainable_weights)
  optimizer$apply_gradients(zip_lists(gradients, model$trainable_weights))
})
```

---

## Migration Paths

### torch → keras3
**Difficulty**: Medium
**Considerations**: Rewrite training loops to use `fit()`, adjust model definition syntax

### keras3 → torch
**Difficulty**: Medium-Hard
**Considerations**: Implement manual training loop, adjust data loading to DataLoader

### tensorflow → torch
**Difficulty**: Hard
**Considerations**: Different backend, rewrite everything

### torch → tensorflow
**Difficulty**: Medium
**Considerations**: Use keras3 interface, leverage similar concepts

### keras3 ↔ tensorflow
**Difficulty**: Easy
**Considerations**: keras3 uses TensorFlow backend by default, minimal changes

---

## Community and Support

### torch
- Active mlverse community
- Growing documentation
- R-specific resources increasing
- PyTorch tutorials often applicable

### keras3
- Mature R community
- Excellent documentation
- Large number of examples
- Strong Posit/RStudio support

### tensorflow
- Mature but Python-focused community
- Good R documentation
- Some examples outdated (TF 1.x)
- Strong enterprise support

---

## Recommended Learning Path

### Phase 1: Start with keras3 (2-4 weeks)
- Learn deep learning fundamentals
- Build standard models (image classification, text classification)
- Use built-in `fit()` and callbacks
- Work with Keras Applications for transfer learning

**Why**: Gentle learning curve, focus on concepts not implementation details

---

### Phase 2: Explore torch (4-6 weeks)
- Learn manual training loops
- Understand gradients and backpropagation
- Implement custom architectures
- Work with DataLoader and datasets

**Why**: Deeper understanding, more control, research-oriented

---

### Phase 3: TensorFlow for Infrastructure (2-3 weeks)
- Learn SavedModel format
- Explore TensorFlow Serving
- Understand graph compilation with `tf_function()`
- Deploy models to production

**Why**: Production deployment, cross-platform models

---

## Decision Flowchart

```
Do you need custom training loops or novel architectures?
├─ Yes → torch
└─ No → Continue

Is this for research or implementing cutting-edge papers?
├─ Yes → torch
└─ No → Continue

Do you have existing TensorFlow infrastructure or need TF Serving?
├─ Yes → tensorflow (via keras3)
└─ No → Continue

Do you need multi-backend flexibility (TF/JAX/torch)?
├─ Yes → keras3
└─ No → Continue

Are you building standard models for production?
├─ Yes → keras3
└─ No → Continue

Default recommendation: keras3 (best balance of ease and power)
```

---

## Summary

### torch: The Research Framework
**Strengths**: Maximum control, explicit, great for custom architectures
**Weaknesses**: More verbose, steeper learning curve
**Best for**: Research, experimentation, state-of-the-art models

### keras3: The Pragmatic Choice
**Strengths**: Concise, easy to learn, great for standard models
**Weaknesses**: Less control over training details
**Best for**: Production, rapid prototyping, standard architectures

### tensorflow: The Infrastructure Layer
**Strengths**: Deployment ecosystem, graph optimization, cross-platform
**Weaknesses**: Primarily accessed via keras3 in R
**Best for**: Deployment, existing TF infrastructure, Python interop

---

## Hybrid Approach

You can use multiple frameworks in the same project:

1. **Prototype with keras3** → Fast iteration
2. **Implement novel components in torch** → Custom modules
3. **Deploy with tensorflow** → Production infrastructure

Example:
```r
# Experiment with keras3
model_keras <- keras_model_sequential() |> ...
model_keras |> fit(...)

# Implement custom loss in torch
custom_loss <- nn_module(...)

# Export to ONNX for deployment
# Both keras3 and torch support ONNX export
```

---

## Conclusion

**No single "best" framework** - choose based on your needs:

- **Starting out?** → keras3
- **Doing research?** → torch
- **Need deployment?** → tensorflow (via keras3)
- **Want flexibility?** → keras3 (multi-backend)

**Most common path**: Start with keras3, learn torch for research, use tensorflow for deployment.
