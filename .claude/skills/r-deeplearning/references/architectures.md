# Neural Network Architectures Reference

Comprehensive guide to neural network architectures for deep learning in R.

---

## CNN Architectures

### Simple CNN

Basic convolutional network for image/spectrogram classification.

```r
simple_cnn <- nn_module(
  "SimpleCNN",

  initialize = function(input_channels = 1, n_classes = 10) {
    # Conv blocks: Conv -> BN -> ReLU -> MaxPool

    self$conv1 <- nn_conv2d(input_channels, 32, c(3, 3), padding = "same")
    self$bn1 <- nn_batch_norm2d(32)
    self$pool1 <- nn_max_pool2d(c(2, 2))

    self$conv2 <- nn_conv2d(32, 64, c(3, 3), padding = "same")
    self$bn2 <- nn_batch_norm2d(64)
    self$pool2 <- nn_max_pool2d(c(2, 2))

    self$conv3 <- nn_conv2d(64, 128, c(3, 3), padding = "same")
    self$bn3 <- nn_batch_norm2d(128)
    self$pool3 <- nn_max_pool2d(c(2, 2))

    # Global average pooling + classifier
    self$gap <- nn_adaptive_avg_pool2d(c(1, 1))
    self$dropout <- nn_dropout(0.5)
    self$fc <- nn_linear(128, n_classes)
  },

  forward = function(x) {
    x <- x |>
      self$conv1() |> self$bn1() |> nnf_relu() |> self$pool1() |>
      self$conv2() |> self$bn2() |> nnf_relu() |> self$pool2() |>
      self$conv3() |> self$bn3() |> nnf_relu() |> self$pool3()

    x <- self$gap(x) |> torch_flatten(start_dim = 2)
    x <- self$dropout(x) |> self$fc()

    return(x)
  }
)
```

**When to use**:
- Image classification
- Audio spectrogram classification
- Simple pattern recognition
- Baseline model

**Pros**: Fast, simple, works well for basic tasks
**Cons**: Limited capacity for complex patterns

---

### ResNet-Style CNN

Residual connections for deeper networks.

```r
# Residual block
residual_block <- nn_module(
  "ResidualBlock",

  initialize = function(in_channels, out_channels, stride = 1) {
    self$conv1 <- nn_conv2d(in_channels, out_channels, c(3, 3),
                           stride = stride, padding = 1)
    self$bn1 <- nn_batch_norm2d(out_channels)

    self$conv2 <- nn_conv2d(out_channels, out_channels, c(3, 3),
                           stride = 1, padding = 1)
    self$bn2 <- nn_batch_norm2d(out_channels)

    # Shortcut connection
    if (stride != 1 || in_channels != out_channels) {
      self$shortcut <- nn_sequential(
        nn_conv2d(in_channels, out_channels, c(1, 1), stride = stride),
        nn_batch_norm2d(out_channels)
      )
    } else {
      self$shortcut <- nn_identity()
    }
  },

  forward = function(x) {
    identity <- self$shortcut(x)

    out <- x |>
      self$conv1() |> self$bn1() |> nnf_relu() |>
      self$conv2() |> self$bn2()

    out <- out + identity
    out <- nnf_relu(out)

    return(out)
  }
)

# ResNet model
resnet_classifier <- nn_module(
  "ResNetClassifier",

  initialize = function(n_classes, n_blocks = c(2, 2, 2, 2)) {
    self$conv1 <- nn_conv2d(1, 64, c(7, 7), stride = 2, padding = 3)
    self$bn1 <- nn_batch_norm2d(64)
    self$pool1 <- nn_max_pool2d(c(3, 3), stride = 2, padding = 1)

    # Residual layers
    self$layer1 <- self$make_layer(64, 64, n_blocks[1], stride = 1)
    self$layer2 <- self$make_layer(64, 128, n_blocks[2], stride = 2)
    self$layer3 <- self$make_layer(128, 256, n_blocks[3], stride = 2)
    self$layer4 <- self$make_layer(256, 512, n_blocks[4], stride = 2)

    self$gap <- nn_adaptive_avg_pool2d(c(1, 1))
    self$fc <- nn_linear(512, n_classes)
  },

  make_layer = function(in_channels, out_channels, n_blocks, stride) {
    layers <- nn_module_list()
    layers$append(residual_block(in_channels, out_channels, stride))

    for (i in 2:n_blocks) {
      layers$append(residual_block(out_channels, out_channels, 1))
    }

    return(nn_sequential(!!!layers))
  },

  forward = function(x) {
    x <- x |>
      self$conv1() |> self$bn1() |> nnf_relu() |> self$pool1() |>
      self$layer1() |> self$layer2() |>
      self$layer3() |> self$layer4()

    x <- self$gap(x) |> torch_flatten(start_dim = 2) |> self$fc()

    return(x)
  }
)
```

**When to use**:
- Deeper networks (10+ layers)
- Complex image classification
- When simple CNN underfits
- Transfer learning backbone

**Pros**: Can train very deep networks, better accuracy
**Cons**: More parameters, slower training

---

### 1D CNN for Audio/Time Series

Convolutional network for 1D sequences.

```r
cnn_1d <- nn_module(
  "CNN1D",

  initialize = function(input_channels = 1, n_classes = 10) {
    # 1D convolutions operate on time axis

    self$conv1 <- nn_conv1d(input_channels, 64, kernel_size = 3, padding = "same")
    self$bn1 <- nn_batch_norm1d(64)
    self$pool1 <- nn_max_pool1d(2)

    self$conv2 <- nn_conv1d(64, 128, kernel_size = 3, padding = "same")
    self$bn2 <- nn_batch_norm1d(128)
    self$pool2 <- nn_max_pool1d(2)

    self$conv3 <- nn_conv1d(128, 256, kernel_size = 3, padding = "same")
    self$bn3 <- nn_batch_norm1d(256)
    self$pool3 <- nn_max_pool1d(2)

    self$gap <- nn_adaptive_avg_pool1d(1)
    self$dropout <- nn_dropout(0.5)
    self$fc <- nn_linear(256, n_classes)
  },

  forward = function(x) {
    # x: (batch, channels, time_steps)

    x <- x |>
      self$conv1() |> self$bn1() |> nnf_relu() |> self$pool1() |>
      self$conv2() |> self$bn2() |> nnf_relu() |> self$pool2() |>
      self$conv3() |> self$bn3() |> nnf_relu() |> self$pool3()

    x <- self$gap(x) |> torch_flatten(start_dim = 2)
    x <- self$dropout(x) |> self$fc()

    return(x)
  }
)
```

**When to use**:
- Raw audio waveforms
- Time series with local patterns
- Sensor data
- When RNN is too slow

**Pros**: Fast, parallelizable, good for local patterns
**Cons**: Limited long-range dependencies

---

## RNN/LSTM/GRU Architectures

### Basic LSTM

```r
lstm_model <- nn_module(
  "LSTMModel",

  initialize = function(input_size, hidden_size = 128,
                       n_layers = 2, n_classes = 10,
                       dropout = 0.3, bidirectional = TRUE) {

    self$lstm <- nn_lstm(
      input_size = input_size,
      hidden_size = hidden_size,
      num_layers = n_layers,
      batch_first = TRUE,
      dropout = dropout,
      bidirectional = bidirectional
    )

    self$dir_mult <- if (bidirectional) 2 else 1

    self$dropout <- nn_dropout(dropout)
    self$fc <- nn_linear(hidden_size * self$dir_mult, n_classes)
  },

  forward = function(x) {
    # x: (batch, seq_len, input_size)

    lstm_out <- self$lstm(x)[[1]]  # (batch, seq_len, hidden*dir)

    # Take last time step
    last_hidden <- lstm_out[, -1, ]

    out <- self$dropout(last_hidden) |> self$fc()

    return(out)
  }
)
```

**When to use**:
- Sequential data (text, time series)
- Long-term dependencies
- Variable-length sequences
- When order matters

**Pros**: Captures temporal dependencies, flexible sequence length
**Cons**: Slow (sequential), prone to overfitting

---

### GRU (Faster Alternative to LSTM)

```r
gru_model <- nn_module(
  "GRUModel",

  initialize = function(input_size, hidden_size = 128,
                       n_layers = 2, n_classes = 10,
                       dropout = 0.3, bidirectional = TRUE) {

    self$gru <- nn_gru(
      input_size = input_size,
      hidden_size = hidden_size,
      num_layers = n_layers,
      batch_first = TRUE,
      dropout = dropout,
      bidirectional = bidirectional
    )

    self$dir_mult <- if (bidirectional) 2 else 1
    self$dropout <- nn_dropout(dropout)
    self$fc <- nn_linear(hidden_size * self$dir_mult, n_classes)
  },

  forward = function(x) {
    gru_out <- self$gru(x)[[1]]
    last_hidden <- gru_out[, -1, ]
    out <- self$dropout(last_hidden) |> self$fc()
    return(out)
  }
)
```

**When to use**:
- Same as LSTM but faster
- When training time is critical
- Smaller datasets (fewer parameters)

**Pros**: Faster than LSTM, fewer parameters, often similar performance
**Cons**: Slightly less powerful than LSTM on complex sequences

---

## CRNN (CNN + RNN) Architectures

### CRNN for Audio

Combine CNN for local features and RNN for temporal modeling.

```r
crnn_audio <- nn_module(
  "CRNNAudio",

  initialize = function(n_classes, n_mels = 128, rnn_hidden = 128) {

    # CNN frontend: extract features from spectrogram
    self$conv1 <- nn_conv2d(1, 64, c(3, 3), padding = "same")
    self$bn1 <- nn_batch_norm2d(64)
    self$pool1 <- nn_max_pool2d(c(2, 2))

    self$conv2 <- nn_conv2d(64, 128, c(3, 3), padding = "same")
    self$bn2 <- nn_batch_norm2d(128)
    self$pool2 <- nn_max_pool2d(c(2, 2))

    self$conv3 <- nn_conv2d(128, 256, c(3, 3), padding = "same")
    self$bn3 <- nn_batch_norm2d(256)
    self$pool3 <- nn_max_pool2d(c(2, 2))

    # RNN: model temporal evolution
    freq_dim <- n_mels / 8  # After 3 pooling layers
    self$gru <- nn_gru(
      input_size = 256 * freq_dim,
      hidden_size = rnn_hidden,
      num_layers = 2,
      batch_first = TRUE,
      bidirectional = TRUE,
      dropout = 0.3
    )

    # Classifier
    self$dropout <- nn_dropout(0.5)
    self$fc <- nn_linear(rnn_hidden * 2, n_classes)
  },

  forward = function(x) {
    batch_size <- x$shape[1]

    # CNN: extract features
    x <- x |>
      self$conv1() |> self$bn1() |> nnf_relu() |> self$pool1() |>
      self$conv2() |> self$bn2() |> nnf_relu() |> self$pool2() |>
      self$conv3() |> self$bn3() |> nnf_relu() |> self$pool3()

    # x: (batch, 256, freq/8, time/8)

    # Reshape for RNN: (batch, time, features)
    x <- x$permute(c(1, 4, 2, 3))  # (batch, time, channels, freq)
    x <- torch_flatten(x, start_dim = 3)  # (batch, time, channels*freq)

    # RNN: temporal modeling
    gru_out <- self$gru(x)[[1]]
    last_hidden <- gru_out[, -1, ]

    # Classify
    out <- self$dropout(last_hidden) |> self$fc()

    return(out)
  }
)
```

**When to use**:
- Audio event detection
- Speech recognition
- Music classification
- When both local and temporal features matter

**Pros**: Best of both worlds (local patterns + temporal context)
**Cons**: More complex, more parameters, slower

---

### CRNN with Attention

Add attention mechanism to focus on important time steps.

```r
crnn_attention <- nn_module(
  "CRNNAttention",

  initialize = function(n_classes, n_mels = 128, rnn_hidden = 128) {

    # CNN frontend (same as above)
    self$conv1 <- nn_conv2d(1, 64, c(3, 3), padding = "same")
    self$bn1 <- nn_batch_norm2d(64)
    self$pool1 <- nn_max_pool2d(c(2, 2))

    self$conv2 <- nn_conv2d(64, 128, c(3, 3), padding = "same")
    self$bn2 <- nn_batch_norm2d(128)
    self$pool2 <- nn_max_pool2d(c(2, 2))

    self$conv3 <- nn_conv2d(128, 256, c(3, 3), padding = "same")
    self$bn3 <- nn_batch_norm2d(256)
    self$pool3 <- nn_max_pool2d(c(2, 2))

    # RNN
    freq_dim <- n_mels / 8
    self$gru <- nn_gru(
      input_size = 256 * freq_dim,
      hidden_size = rnn_hidden,
      num_layers = 2,
      batch_first = TRUE,
      bidirectional = TRUE,
      dropout = 0.3
    )

    # Attention mechanism
    self$attention_fc <- nn_linear(rnn_hidden * 2, 1)

    # Classifier
    self$dropout <- nn_dropout(0.5)
    self$fc <- nn_linear(rnn_hidden * 2, n_classes)
  },

  forward = function(x) {
    # CNN
    x <- x |>
      self$conv1() |> self$bn1() |> nnf_relu() |> self$pool1() |>
      self$conv2() |> self$bn2() |> nnf_relu() |> self$pool2() |>
      self$conv3() |> self$bn3() |> nnf_relu() |> self$pool3()

    # Reshape for RNN
    x <- x$permute(c(1, 4, 2, 3))
    x <- torch_flatten(x, start_dim = 3)

    # RNN
    gru_out <- self$gru(x)[[1]]  # (batch, time, hidden*2)

    # Attention weights
    attn_weights <- self$attention_fc(gru_out)  # (batch, time, 1)
    attn_weights <- torch_softmax(attn_weights, dim = 2)

    # Weighted sum (attention pooling)
    attended <- (gru_out * attn_weights)$sum(dim = 2)  # (batch, hidden*2)

    # Classify
    out <- self$dropout(attended) |> self$fc()

    return(out)
  }
)
```

**When to use**:
- When different time regions have different importance
- Long sequences where simple max pooling loses information
- Interpretability (attention weights show what model focuses on)

**Pros**: Better than simple pooling, interpretable
**Cons**: More computation, slightly more complex

---

## Attention Mechanisms

### Self-Attention Layer

```r
self_attention <- nn_module(
  "SelfAttention",

  initialize = function(embed_dim, num_heads = 8, dropout = 0.1) {
    self$attention <- nn_multihead_attention(
      embed_dim = embed_dim,
      num_heads = num_heads,
      dropout = dropout,
      batch_first = TRUE
    )

    self$norm <- nn_layer_norm(embed_dim)
    self$dropout <- nn_dropout(dropout)
  },

  forward = function(x) {
    # x: (batch, seq_len, embed_dim)

    # Self-attention with residual connection
    attn_out <- self$attention(x, x, x)[[1]]
    x <- x + self$dropout(attn_out)
    x <- self$norm(x)

    return(x)
  }
)
```

---

## Architecture Selection Guide

### By Task

| Task | Recommended Architecture | Alternative |
|------|-------------------------|-------------|
| Image classification | Simple CNN, ResNet | EfficientNet, Vision Transformer |
| Audio classification (spectrogram) | CNN, CRNN | ResNet, Attention CNN |
| Audio classification (raw waveform) | 1D CNN, CRNN | Wav2Vec-style |
| Text classification | LSTM, GRU | 1D CNN, Transformer |
| Time series forecasting | GRU, 1D CNN | LSTM, Temporal CNN |
| Speech recognition | CRNN with Attention | Transformer |
| Object detection | - | (requires external packages) |
| Semantic segmentation | - | (requires U-Net-style architecture) |

### By Data Characteristics

**Short sequences (< 50 steps)**:
- 1D CNN: Fast, effective
- GRU: Good temporal modeling

**Long sequences (> 50 steps)**:
- LSTM with attention: Handles long dependencies
- Transformer: Best for very long sequences (needs implementation)

**2D spatial data (images, spectrograms)**:
- CNN: Standard choice
- ResNet: When depth matters
- CRNN: When time axis is important

**Variable-length sequences**:
- LSTM/GRU: Natural handling
- Pack/pad sequences for batching

**Multivariate time series**:
- 1D CNN: Each channel = variable
- LSTM/GRU: Handle channels as input_size

### By Dataset Size

**Small (< 1k samples)**:
- Simple models (3-4 layers)
- Strong regularization (dropout 0.5+)
- Data augmentation essential
- Consider transfer learning

**Medium (1k-100k samples)**:
- Standard architectures work well
- Moderate regularization (dropout 0.3-0.5)
- Data augmentation helpful

**Large (> 100k samples)**:
- Deeper models (ResNet, etc.)
- Less regularization needed
- Can train from scratch

---

## Design Guidelines

### General Principles

1. **Start simple**: Begin with basic architecture, add complexity only if needed
2. **Batch normalization**: Use after conv/linear layers, before activation
3. **Dropout**: Add before classifier layers (0.3-0.5 typical)
4. **Activation**: ReLU is standard, Leaky ReLU for negative values
5. **Pooling**: MaxPool for features, AvgPool for classification
6. **Global pooling**: Use adaptive pooling instead of flatten when possible

### Layer Sizing

**Convolutional layers**:
- Start with 32-64 filters in first layer
- Double filters after each pooling: 32 → 64 → 128 → 256
- Kernel size 3×3 most common, 5×5 for larger receptive field
- Use "same" padding to maintain spatial dimensions

**Recurrent layers**:
- Hidden size 128-512 typical
- 1-3 layers sufficient for most tasks
- Bidirectional when full sequence available
- Dropout between layers if > 1 layer

**Fully connected layers**:
- Fewer is better (1-2 layers)
- Use global pooling to reduce dimensionality first
- Hidden size 128-512
- Add dropout (0.3-0.5)

### Common Mistakes

❌ **Too deep without residual connections**: Gradient vanishing
✅ Use ResNet-style blocks for > 10 layers

❌ **Overfitting on small data**: Model too large
✅ Reduce model size, increase dropout, add augmentation

❌ **Underfitting**: Model too simple
✅ Add layers, increase width, reduce regularization

❌ **Slow RNN training**: LSTM on very long sequences
✅ Use GRU, or 1D CNN, or truncate sequences

❌ **Exploding gradients**: Deep RNN
✅ Use gradient clipping, lower learning rate

---

## Advanced Patterns

### Multi-Scale CNN

Process input at multiple scales.

```r
multiscale_cnn <- nn_module(
  "MultiScaleCNN",

  initialize = function(n_classes) {
    # Small receptive field
    self$branch1 <- nn_sequential(
      nn_conv2d(1, 32, c(3, 3), padding = "same"),
      nn_batch_norm2d(32),
      nn_relu()
    )

    # Medium receptive field
    self$branch2 <- nn_sequential(
      nn_conv2d(1, 32, c(5, 5), padding = "same"),
      nn_batch_norm2d(32),
      nn_relu()
    )

    # Large receptive field
    self$branch3 <- nn_sequential(
      nn_conv2d(1, 32, c(7, 7), padding = "same"),
      nn_batch_norm2d(32),
      nn_relu()
    )

    # Combine and classify
    self$conv_combined <- nn_conv2d(96, 128, c(1, 1))
    self$gap <- nn_adaptive_avg_pool2d(c(1, 1))
    self$fc <- nn_linear(128, n_classes)
  },

  forward = function(x) {
    # Parallel branches
    x1 <- self$branch1(x)
    x2 <- self$branch2(x)
    x3 <- self$branch3(x)

    # Concatenate
    x <- torch_cat(list(x1, x2, x3), dim = 2)

    # Combine and classify
    x <- self$conv_combined(x)
    x <- self$gap(x) |> torch_flatten(start_dim = 2)
    x <- self$fc(x)

    return(x)
  }
)
```

### Temporal Convolutional Network (TCN)

Dilated convolutions for long-range dependencies.

```r
tcn_block <- nn_module(
  "TCNBlock",

  initialize = function(in_channels, out_channels, kernel_size, dilation) {
    padding <- (kernel_size - 1) * dilation / 2

    self$conv1 <- nn_conv1d(in_channels, out_channels,
                           kernel_size, padding = padding,
                           dilation = dilation)
    self$bn1 <- nn_batch_norm1d(out_channels)

    self$conv2 <- nn_conv1d(out_channels, out_channels,
                           kernel_size, padding = padding,
                           dilation = dilation)
    self$bn2 <- nn_batch_norm1d(out_channels)

    # Residual
    if (in_channels != out_channels) {
      self$residual <- nn_conv1d(in_channels, out_channels, 1)
    } else {
      self$residual <- nn_identity()
    }

    self$dropout <- nn_dropout(0.3)
  },

  forward = function(x) {
    residual <- self$residual(x)

    out <- x |>
      self$conv1() |> self$bn1() |> nnf_relu() |> self$dropout() |>
      self$conv2() |> self$bn2() |> nnf_relu() |> self$dropout()

    out <- out + residual
    out <- nnf_relu(out)

    return(out)
  }
)
```

---

## See Also

- [examples/audio-classification.md](../examples/audio-classification.md) - Complete audio classification example
- [examples/computer-vision.md](../examples/computer-vision.md) - Image classification with transfer learning
- [examples/nlp.md](../examples/nlp.md) - Text classification with LSTM
- [audio-dl-best-practices.md](audio-dl-best-practices.md) - Audio-specific architecture guidelines
