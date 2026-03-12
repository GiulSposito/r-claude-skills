# Learning Paradigms Taxonomy

Comprehensive taxonomy of modern machine learning paradigms beyond standard supervised learning, with decision criteria and implementation guidance.

## Paradigm Classification

```
Machine Learning Paradigms
│
├─ Standard Paradigms
│  ├─ Supervised Learning (full labels)
│  ├─ Unsupervised Learning (no labels)
│  └─ Reinforcement Learning (reward signals)
│
└─ Data-Efficient Paradigms (this skill's focus)
   ├─ Transfer Learning (leverage pretrained knowledge)
   ├─ Self-Supervised Learning (learn from unlabeled data structure)
   ├─ Few-Shot Learning (classify with 1-10 examples)
   ├─ Weak Supervision (learn from imperfect labels)
   └─ Meta-Learning (learn to learn across tasks)
```

---

## Paradigm Comparison Matrix

| Paradigm | Data Requirement | Label Requirement | Computational Cost | R Support | Primary Use Case |
|----------|------------------|-------------------|-------------------|-----------|------------------|
| **Supervised** | 1000+ per class | Clean, complete | Low-Medium | ⭐⭐⭐⭐⭐ | Standard classification/regression |
| **Transfer** | 100+ per class | Clean | Low | ⭐⭐⭐⭐ | New task similar to source |
| **SSL** | 10k+ unlabeled | None (pretraining) | High | ⭐⭐⭐ | Abundant unlabeled data |
| **FSL** | 1-10 per class | Clean | Medium | ⭐⭐ | Rare classes, new classes emerging |
| **Weak Supervision** | 100+ per class | Noisy/incomplete | Medium | ⭐⭐ | Expensive to get clean labels |
| **Meta-Learning** | Many tasks | Clean (per task) | Very High | ⭐ | Distribution of related tasks |

---

## Self-Supervised Learning (SSL) Deep Dive

### Taxonomy of SSL Methods

```
Self-Supervised Learning
│
├─ Contrastive Learning
│  ├─ Instance Discrimination
│  │  ├─ SimCLR (simple, requires large batches)
│  │  ├─ MoCo (momentum encoder, memory bank)
│  │  └─ SwAV (clustering-based)
│  └─ Avoiding Negatives
│     ├─ BYOL (momentum + predictor)
│     ├─ SimSiam (stop-gradient trick)
│     └─ Barlow Twins (decorrelation)
│
├─ Masked Prediction
│  ├─ MAE (Masked Autoencoder for images)
│  ├─ BERT (Masked Language Model for text)
│  └─ Wav2Vec (Masked prediction for audio)
│
├─ Predictive Learning
│  ├─ Autoencoding (reconstruct input)
│  ├─ Denoising (remove added noise)
│  └─ Rotation prediction (predict image rotation)
│
└─ Generative Models
   ├─ VAE (variational autoencoder)
   ├─ GANs (adversarial generation)
   └─ Diffusion models
```

### SSL Method Selection Guide

| Method | Data Type | Batch Size | GPU Memory | Ease of Implementation | Performance |
|--------|-----------|------------|------------|----------------------|-------------|
| **SimCLR** | Images, Audio | Large (256+) | High | Medium | ⭐⭐⭐⭐ |
| **MoCo** | Images, Audio | Medium (64+) | Medium | Medium-High | ⭐⭐⭐⭐⭐ |
| **Barlow Twins** | Images | Medium | Medium | Medium | ⭐⭐⭐⭐ |
| **BYOL** | Images | Medium | Medium | High (complex) | ⭐⭐⭐⭐⭐ |
| **MAE** | Images | Large | High | Medium-High | ⭐⭐⭐⭐⭐ |
| **Wav2Vec** | Audio | Large | High | High | ⭐⭐⭐⭐⭐ (audio) |

**Recommendation for R users:** Start with **SimCLR** or **Barlow Twins** (simpler, well-documented).

### SSL Augmentation Guidelines

**General principles:**
- Augmentations must preserve class semantics
- Two views of same sample should be "similar"
- Augmentation strength matters (too weak = no learning, too strong = collapse)

**Domain-specific augmentations:**

#### Images
✅ Good:
- Random crop + resize
- Color jitter (hue, saturation, brightness)
- Gaussian blur
- Horizontal flip (if semantics preserved)
- Random rotation (±15°)

❌ Bad:
- Vertical flip (for most objects)
- Extreme crops (removes too much context)
- Over-saturation (destroys color information)

#### Audio (spectrograms)
✅ Good:
- Time masking (SpecAugment)
- Frequency masking
- Time stretching (±10-20%)
- Pitch shifting (±2 semitones)
- Gaussian noise

❌ Bad:
- Frequency inversion (changes fundamental meaning)
- Extreme time warping (destroys rhythm)
- Over-aggressive masking (> 40% masked)

#### Text
✅ Good:
- Random word masking
- Synonym replacement
- Back-translation
- Random insertion/deletion

❌ Bad:
- Character-level perturbations (breaks words)
- Extreme masking (> 30%)
- Sentiment-changing replacements

---

## Few-Shot Learning (FSL) Deep Dive

### Taxonomy of FSL Methods

```
Few-Shot Learning
│
├─ Metric Learning
│  ├─ Siamese Networks (learn similarity function)
│  ├─ Prototypical Networks (classify by prototype distance)
│  ├─ Matching Networks (attention-based)
│  └─ Relation Networks (learn non-linear relation)
│
├─ Meta-Learning (Learn to Learn)
│  ├─ Optimization-Based
│  │  ├─ MAML (learn good initialization)
│  │  └─ Reptile (simpler than MAML)
│  ├─ Metric-Based (see above)
│  └─ Model-Based
│     ├─ Memory Networks
│     └─ Neural Turing Machines
│
├─ Transfer Learning + Fine-Tuning
│  ├─ Fine-tune pretrained model with few shots
│  ├─ Freeze features, train classifier
│  └─ Adapter modules
│
└─ Data Augmentation
   ├─ Mixup in feature space
   ├─ Meta-learning augmentation policies
   └─ Synthetic sample generation
```

### FSL Method Selection Guide

| Method | Ease of Implementation | Sample Efficiency | Requires Meta-Training | Performance | R Support |
|--------|------------------------|-------------------|------------------------|-------------|-----------|
| **Prototypical Networks** | ⭐⭐⭐⭐⭐ Easy | ⭐⭐⭐⭐ Good | Optional | ⭐⭐⭐⭐ Good | ⭐⭐⭐ Moderate |
| **Matching Networks** | ⭐⭐⭐⭐ Medium | ⭐⭐⭐ Moderate | Yes | ⭐⭐⭐ Moderate | ⭐⭐ Limited |
| **Relation Networks** | ⭐⭐⭐ Medium | ⭐⭐⭐⭐ Good | Yes | ⭐⭐⭐⭐ Good | ⭐⭐ Limited |
| **MAML** | ⭐⭐ Hard | ⭐⭐⭐⭐⭐ Excellent | Yes | ⭐⭐⭐⭐⭐ Excellent | ⭐ Very Limited |
| **Transfer + Fine-Tune** | ⭐⭐⭐⭐⭐ Easy | ⭐⭐⭐ Moderate | No | ⭐⭐⭐⭐ Good | ⭐⭐⭐⭐ Good |

**Recommendation for R users:** Start with **Prototypical Networks** (simple, effective) or **Transfer + Fine-Tune** (easiest).

### Episodic Training Protocol

**Standard N-way K-shot setup:**
- **N-way:** Number of classes in an episode (typically 5-20)
- **K-shot:** Number of labeled examples per class (typically 1, 5, or 10)
- **Q-query:** Number of test examples per class (typically 15)

**Example: 5-way 5-shot episode**
- Sample 5 random classes from dataset
- Sample 5 support examples per class (25 total support)
- Sample 15 query examples per class (75 total query)
- Train to classify queries using only support examples
- Repeat for 10k-100k episodes

**Training vs Testing:**
- **Training:** Meta-train on *seen* classes (e.g., 60 base classes)
- **Testing:** Evaluate on *unseen* classes (e.g., 20 novel classes)
- Goal: Generalize to new classes not seen during training

---

## Weak Supervision Deep Dive

### Taxonomy of Weak Supervision

```
Weak Supervision
│
├─ Incomplete Supervision
│  ├─ Multiple Instance Learning (MIL)
│  │  ├─ Standard MIL (bag-level labels)
│  │  ├─ Attention-based MIL
│  │  └─ Embedded-space MIL
│  └─ Partial Labels
│     ├─ Some instances labeled, others not
│     └─ Some classes labeled, others not
│
├─ Inexact Supervision
│  ├─ Coarse labels (clip-level instead of frame-level)
│  ├─ Crowdsourced labels (multiple annotators, disagreements)
│  └─ Weak bounding boxes (loose, not tight)
│
├─ Noisy Supervision
│  ├─ Label Noise
│  │  ├─ Symmetric noise (random flips)
│  │  ├─ Asymmetric noise (class-dependent flips)
│  │  └─ Instance-dependent noise
│  └─ Noise-Robust Training
│     ├─ Loss correction (estimate noise transition matrix)
│     ├─ Sample reweighting (down-weight noisy samples)
│     └─ Co-teaching (two networks teach each other)
│
└─ Programmatic Supervision
   ├─ Labeling functions (heuristics)
   ├─ Snorkel (combine multiple weak sources)
   └─ Data programming (probabilistic labels)
```

### Weak Supervision Method Selection

| Supervision Type | Method | When to Use | R Support |
|------------------|--------|-------------|-----------|
| **Clip-level labels** | MIL with attention pooling | Audio/video with temporal structure | ⭐⭐ Custom |
| **Noisy labels (20-30%)** | Symmetric cross-entropy | Random label noise | ⭐⭐⭐ Custom loss |
| **Noisy labels (> 30%)** | Co-teaching, MentorNet | High noise rate | ⭐ Python better |
| **Crowdsourced labels** | Dawid-Skene aggregation | Multiple annotators | ⭐⭐⭐ Custom |
| **Heuristic labels** | Snorkel | Many weak labeling functions | ⭐ Python only |

### Multiple Instance Learning (MIL) Details

**Core idea:** Bag-level label, predict instance-level labels.

**Example (audio):**
- **Bag:** 5-second audio clip
- **Instances:** 50 frames (100ms each)
- **Bag label:** "Frog species X present somewhere in clip"
- **Goal:** Identify *which frames* contain frog species X

**MIL assumptions:**
- **Positive bag:** At least one instance is positive
- **Negative bag:** All instances are negative

**MIL pooling strategies:**

| Pooling | Formula | When to Use |
|---------|---------|-------------|
| **Max** | `max(instance_scores)` | At least one positive is enough |
| **Mean** | `mean(instance_scores)` | Most instances should be positive |
| **Attention** | `sum(attention_weights * instance_scores)` | Learn which instances matter |
| **Top-K** | `mean(top_k(instance_scores, k))` | K strongest instances |

**Recommendation:** Use **attention pooling** (most flexible, best performance).

---

## Transfer Learning Deep Dive

### Transfer Learning Strategies

| Strategy | When to Use | Freezing | Fine-Tuning | Computational Cost |
|----------|-------------|----------|-------------|--------------------|
| **Feature Extraction** | Target data scarce (< 100), source ≈ target | All layers | None | Low |
| **Fine-Tuning (top layers)** | Moderate data (100-1k), source ≈ target | Early layers | Top layers | Medium |
| **Fine-Tuning (all layers)** | Sufficient data (> 1k), source ≠ target | None | All layers | High |
| **Discriminative Fine-Tuning** | Varied layer relevance | Layer-dependent | Different LRs | Medium |

**Layer-wise learning rates:**
```r
# Example: Discriminate fine-tuning
lr_base <- 1e-5    # Early layers (general features)
lr_mid <- 1e-4     # Middle layers (mid-level features)
lr_top <- 1e-3     # Top layers (task-specific)
```

### Domain Adaptation

**When source and target distributions differ:**

| Technique | Method | Use Case |
|-----------|--------|----------|
| **Discrepancy-based** | MMD, CORAL | Align feature distributions |
| **Adversarial** | DANN, ADDA | Learn domain-invariant features |
| **Reconstruction-based** | Domain autoencoders | Reconstruct across domains |
| **Self-training** | Pseudo-labeling | Iterative refinement |

---

## Meta-Learning Deep Dive

### Meta-Learning Approaches

```
Meta-Learning
│
├─ Black-Box Adaptation
│  ├─ RNNs (memory across tasks)
│  └─ Hypernetworks (generate weights)
│
├─ Optimization-Based
│  ├─ MAML (gradient-based meta-learning)
│  ├─ Reptile (first-order MAML)
│  └─ Meta-SGD (learn LR per parameter)
│
├─ Metric-Based
│  ├─ Prototypical Networks
│  ├─ Matching Networks
│  └─ Relation Networks
│
└─ Non-Parametric
   ├─ Memory-augmented networks
   └─ External memory systems
```

### MAML Algorithm (Simplified)

**Intuition:** Find initialization θ such that one gradient step on new task yields good performance.

**Algorithm:**
```
For each meta-training iteration:
  1. Sample batch of tasks {T₁, T₂, ..., Tₙ}
  2. For each task Tᵢ:
     a. Sample K support examples (train)
     b. Sample Q query examples (test)
     c. Compute adapted parameters: θᵢ' = θ - α ∇θ L(θ, support)
     d. Compute meta-loss: L(θᵢ', query)
  3. Update θ: θ ← θ - β ∇θ Σᵢ L(θᵢ', query)
```

**Why MAML is powerful:** One gradient step on new task is enough to adapt.

**Why MAML is expensive:** Requires second-order derivatives (grad of grad).

---

## Paradigm Synergies

### Combinations That Work Well

| Paradigm 1 | Paradigm 2 | Synergy Reason | Example |
|------------|------------|----------------|---------|
| **SSL** | **FSL** | SSL learns representations, FSL classifies with few labels | Bioacoustics with unlabeled + few labeled |
| **Transfer** | **FSL** | Pretrained features + few-shot adaptation | Medical imaging with ImageNet |
| **SSL** | **Weak Supervision** | SSL from unlabeled, weak labels guide | Soundscapes with clip-level labels |
| **Meta-Learning** | **FSL** | Meta-learn across tasks, few-shot per task | Multi-domain classification |
| **Transfer** | **Domain Adaptation** | Pretrained + align distributions | Medical imaging from natural images |

### Combinations to Avoid

| Paradigm 1 | Paradigm 2 | Why Avoid |
|------------|------------|-----------|
| **FSL** | **Standard Supervised** | If you have enough data for supervised, don't use FSL |
| **SSL** | **Transfer** (same task) | If good pretrained model exists, SSL is redundant |
| **Meta-Learning** | **Single Task** | Meta-learning requires multiple tasks |

---

## Implementation Difficulty by Paradigm (R)

### Difficulty Ranking

1. ⭐⭐⭐⭐⭐ **Transfer Learning** - Easiest, `{keras3}` + `{torch}` pretrained models
2. ⭐⭐⭐⭐ **Supervised Learning** - Well-supported, `{tidymodels}`, `{mlr3}`
3. ⭐⭐⭐ **SSL (Simple)** - Custom `{torch}`, SimCLR or Barlow Twins
4. ⭐⭐ **FSL (Prototypical)** - Manual implementation in `{torch}`
5. ⭐⭐ **Weak Supervision (MIL)** - `{milr}` or custom attention pooling
6. ⭐ **SSL (Advanced)** - MoCo, BYOL, MAE - Python better
7. ⭐ **FSL (Meta-Learning)** - MAML, Reptile - Python strongly recommended
8. ⭐ **Weak Supervision (Advanced)** - Snorkel, co-teaching - Python only

### When to Switch to Python

**Stay in R if:**
- Transfer learning with pretrained models
- Prototypical networks (simple metric learning)
- Basic SSL (SimCLR, Barlow Twins)
- Standard supervised with feature engineering

**Switch to Python if:**
- Advanced SSL (MoCo, BYOL, Wav2Vec)
- Meta-learning (MAML, Reptile)
- Programmatic weak supervision (Snorkel)
- Production-scale FSL pipelines

---

## Performance Expectations

### Typical Accuracy Ranges by Paradigm

| Task | Baseline (Random) | Supervised (Full) | Transfer | SSL → Supervised | FSL (5-shot) |
|------|-------------------|-------------------|----------|------------------|--------------|
| **Image classification (10 classes)** | 10% | 90-95% | 80-90% | 85-93% | 60-75% |
| **Audio classification (50 species)** | 2% | 75-85% | 60-70% | 70-80% | 40-60% |
| **Medical imaging (rare disease)** | 5% | 80-90% | 75-85% | 78-88% | 50-70% |
| **Fine-grained (100 bird species)** | 1% | 70-80% | 50-65% | 65-75% | 30-50% |

**Key insight:** Paradigm performance heavily depends on domain and data quality.

---

## Research Papers by Paradigm (Foundational)

### Self-Supervised Learning
- **SimCLR:** "A Simple Framework for Contrastive Learning" (Chen et al., 2020)
- **MoCo:** "Momentum Contrast for Unsupervised Visual Representation Learning" (He et al., 2020)
- **BYOL:** "Bootstrap Your Own Latent" (Grill et al., 2020)
- **MAE:** "Masked Autoencoders Are Scalable Vision Learners" (He et al., 2022)

### Few-Shot Learning
- **Prototypical Networks:** "Prototypical Networks for Few-shot Learning" (Snell et al., 2017)
- **Matching Networks:** "Matching Networks for One Shot Learning" (Vinyals et al., 2016)
- **MAML:** "Model-Agnostic Meta-Learning" (Finn et al., 2017)

### Weak Supervision
- **MIL Survey:** "A Survey on Multiple Instance Learning" (Amores, 2013)
- **Snorkel:** "Snorkel: Rapid Training Data Creation with Weak Supervision" (Ratner et al., 2017)
- **Co-teaching:** "Co-teaching: Robust Training of Deep Neural Networks" (Han et al., 2018)

### Transfer Learning
- **Survey:** "A Survey on Transfer Learning" (Pan & Yang, 2010)
- **Fine-tuning:** "How transferable are features in deep neural networks?" (Yosinski et al., 2014)

### Meta-Learning
- **MAML:** "Model-Agnostic Meta-Learning for Fast Adaptation" (Finn et al., 2017)
- **Reptile:** "On First-Order Meta-Learning Algorithms" (Nichol et al., 2018)

---

## Summary Decision Matrix

**I have...**

| Data Situation | Recommended Paradigm | Second Choice |
|----------------|---------------------|---------------|
| 10k+ clean labels | Supervised Learning | — |
| 1k labels, pretrained model | Transfer Learning | SSL + Supervised |
| 100k unlabeled, 500 labeled | SSL + Supervised | Transfer Learning |
| < 10 examples per class | Few-Shot Learning | Transfer + FSL |
| Noisy labels (20-30%) | Weak Supervision | Clean labels + supervised |
| Clip-level labels, need frame-level | MIL (Weak Supervision) | SSL + MIL |
| Many related tasks | Meta-Learning | Transfer across tasks |

**R ecosystem priority:**
1. Transfer Learning (excellent support)
2. Supervised Learning (excellent support)
3. SSL (moderate support, custom code)
4. FSL (limited support, manual implementation)
5. Weak Supervision (limited support)
6. Meta-Learning (switch to Python)

---

This taxonomy provides a comprehensive reference for choosing and implementing data-efficient ML paradigms. For practical implementation guidance, see the main SKILL.md file.
