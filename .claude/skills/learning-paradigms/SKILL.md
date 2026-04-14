---
name: learning-paradigms
description: Machine learning paradigm selection guide covering self-supervised, few-shot, weak supervision, transfer learning and meta-learning. Use when mentions "self-supervised learning", "SSL", "few-shot learning", "FSL", "few shot", "weak supervision", "weakly supervised", "limited labeled data", "limited labels", "learning paradigms", "paradigmas de aprendizado", "meta-learning", "transfer learning", "quando usar SSL", "quando usar few-shot", "which learning approach", "escolher paradigma", "choose learning paradigm", "data scarcity", "escassez de dados", "unlabeled data", "dados não rotulados", or asks about learning strategy selection for data-limited scenarios.
version: 1.0.0
allowed-tools: Read, Grep, Glob
---

# Learning Paradigms - ML Strategy Selection Guide

Strategic guide for selecting machine learning paradigms when dealing with data constraints: self-supervised learning, few-shot learning, weak supervision, transfer learning, and meta-learning.

## Overview

Modern machine learning extends beyond traditional supervised learning. This skill helps you choose the right learning paradigm based on your data characteristics, labeling resources, and deployment constraints.

**Key covered paradigms:**
- **Self-Supervised Learning (SSL)**: Learn from abundant unlabeled data
- **Few-Shot Learning (FSL)**: Classify with 1-10 labeled examples per class
- **Weak Supervision**: Leverage imperfect, incomplete, or noisy labels
- **Transfer Learning**: Adapt pretrained models to new domains
- **Meta-Learning**: Learn to learn across tasks

This skill synthesizes insights from recent research in audio classification, computer vision, and NLP to provide domain-agnostic guidance applicable to R, Python, or Julia implementations.

## When This Skill Activates

Use this skill when:
- Starting a project with limited labeled data
- Facing annotation bottlenecks or high labeling costs
- Working with rare classes or long-tailed distributions
- Building systems for understudied domains (e.g., bioacoustics, medical imaging)
- Deciding between SSL pretraining vs direct supervised learning
- Combining multiple learning paradigms (e.g., SSL + FSL)
- Evaluating if weak supervision can replace full annotation

## The Five Paradigms

### 1. Self-Supervised Learning (SSL)

**What it is:**
Pretraining on unlabeled data by solving pretext tasks (contrastive learning, masked prediction, reconstruction) to learn useful representations.

**When to use:**
- ✅ Abundant unlabeled data available (1000s-millions of samples)
- ✅ Expensive or slow to label data
- ✅ Need domain-specific representations (pretrained models don't transfer well)
- ✅ Can define meaningful augmentations or pretext tasks

**When NOT to use:**
- ❌ Very small datasets (< 1000 samples) - not enough for SSL pretraining
- ❌ Task is fundamentally different from pretext task
- ❌ Strong pretrained models already exist and transfer well

**Common techniques:**
- Contrastive learning: SimCLR, MoCo, Barlow Twins
- Masked prediction: MAE (images), BERT (text)
- Consistency regularization: FixMatch, UDA

**R ecosystem support:**
- `{torch}` + `{luz}`: Custom SSL implementation
- `{keras3}`: Contrastive learning with Keras
- Limited native packages - often requires Python interop via `{reticulate}`

**Expected gain:** 5-20% accuracy improvement on downstream tasks with limited labels.

---

### 2. Few-Shot Learning (FSL)

**What it is:**
Learning to classify new classes from 1-10 labeled examples per class (N-way K-shot), typically via metric learning or meta-learning.

**When to use:**
- ✅ New classes emerge frequently (e.g., new species, products)
- ✅ Cannot collect many labeled examples per class
- ✅ Need rapid adaptation to new categories
- ✅ Have related tasks for meta-training

**When NOT to use:**
- ❌ Can collect 50+ labeled examples per class - standard supervised learning works better
- ❌ Classes are very similar (inter-class similarity high) - hard to discriminate with few shots
- ❌ No related tasks for meta-training

**Common techniques:**
- Metric learning: Prototypical Networks, Matching Networks, Siamese Networks
- Meta-learning: MAML, Reptile
- Data augmentation: Mixup, CutMix in feature space

**R ecosystem support:**
- `{torch}`: Manual implementation of prototypical networks
- No native meta-learning frameworks - Python (learn2learn, torchmeta) dominates

**Expected performance:** 40-70% accuracy on 5-way 5-shot tasks (domain-dependent).

---

### 3. Weak Supervision

**What it is:**
Training with imperfect labels: noisy labels, incomplete labels (only clip-level, not frame-level), or labels from multiple annotators with disagreements.

**When to use:**
- ✅ Labels exist but are imperfect (crowdsourced, automatically generated)
- ✅ Fine-grained labels too expensive (e.g., temporal boundaries in audio)
- ✅ Multiple overlapping events (e.g., bird chorus - know species present, not when)
- ✅ Can use rule-based heuristics or domain knowledge as weak labels

**When NOT to use:**
- ❌ Can afford clean labels - clean data always better
- ❌ Noise rate > 40% - model may memorize noise
- ❌ No validation set with clean labels - can't evaluate properly

**Common techniques:**
- Multiple Instance Learning (MIL): Treat recordings as bags
- Attention pooling: Learn which frames are relevant
- Noise-robust losses: Symmetric cross-entropy, bootstrapping
- Label smoothing: Reduce overconfidence

**R ecosystem support:**
- `{milr}`: Multiple instance learning (basic support)
- `{torch}`: Custom attention mechanisms
- Better supported in Python (snorkel, weakly)

**Expected robustness:** Tolerates 20-30% label noise with proper techniques.

---

### 4. Transfer Learning

**What it is:**
Reusing knowledge from a pretrained model (trained on large source task) and adapting to target task via fine-tuning or feature extraction.

**When to use:**
- ✅ Limited target data (< 1000 labeled examples)
- ✅ Good pretrained model exists for related domain
- ✅ Target task shares structure with source task
- ✅ Computational budget allows fine-tuning

**When NOT to use:**
- ❌ Source and target domains are very different (e.g., ImageNet → medical histology)
- ❌ Target data is abundant (10k+ labeled examples) - train from scratch often better
- ❌ Pretrained model is too large for deployment

**Common techniques:**
- Feature extraction: Freeze pretrained layers, train only classifier
- Fine-tuning: Update all or top layers with small learning rate
- Domain adaptation: Align distributions between source and target

**R ecosystem support:**
- `{keras3}`: Excellent - direct access to pretrained models (ResNet, EfficientNet, BERT)
- `{torch}`: Good - torchvision models, easy fine-tuning
- `{tidymodels}`: Integrates with pretrained embeddings

**Expected gain:** 10-30% accuracy improvement over training from scratch.

---

### 5. Meta-Learning

**What it is:**
Learning to learn: training on multiple related tasks to acquire a learning algorithm that adapts quickly to new tasks.

**When to use:**
- ✅ Have many related tasks (e.g., multiple datasets, multiple domains)
- ✅ Need fast adaptation to new tasks at test time
- ✅ Tasks share structure but differ in specifics
- ✅ Sufficient compute for meta-training

**When NOT to use:**
- ❌ Only one task available - no distribution of tasks to meta-learn from
- ❌ Tasks are unrelated (no shared structure)
- ❌ Limited compute - meta-learning is expensive

**Common techniques:**
- Optimization-based: MAML, Reptile (learn initialization)
- Metric-based: Prototypical Networks (learn embedding space)
- Model-based: Neural Turing Machines, Memory Networks

**R ecosystem support:**
- Very limited - requires manual implementation in `{torch}`
- Python (PyTorch) strongly recommended for meta-learning

**Expected benefit:** 2-3× sample efficiency on new tasks after meta-training.

---

## Decision Framework

### Primary Decision Tree

```
START: What data constraints do you have?

├─ Abundant unlabeled data (1000s+) but few labels?
│  ├─ Yes → Consider SSL pretraining
│  │         ├─ Then fine-tune with few labels (SSL → Supervised)
│  │         └─ Or combine with FSL (SSL → FSL)
│  └─ No → Continue
│
├─ Very few labeled examples per class (< 10)?
│  ├─ Yes → Consider Few-Shot Learning
│  │         ├─ Have related tasks? → Meta-learning FSL
│  │         └─ No related tasks? → Transfer learning + FSL
│  └─ No → Continue
│
├─ Labels exist but are noisy/incomplete?
│  ├─ Yes → Consider Weak Supervision
│  │         ├─ Clip-level only? → Multiple Instance Learning
│  │         ├─ Noisy labels? → Noise-robust training
│  │         └─ Multiple annotators? → Aggregation + uncertainty
│  └─ No → Continue
│
├─ Pretrained model available for similar domain?
│  ├─ Yes → Transfer Learning (fine-tune or extract features)
│  └─ No → Train from scratch or SSL pretraining
│
└─ Multiple related tasks to leverage?
   ├─ Yes → Meta-learning
   └─ No → Standard supervised learning
```

### Combination Strategies

Paradigms often work better together:

| Combination | Use Case | Example |
|-------------|----------|---------|
| **SSL → Supervised** | Unlabeled abundant, moderate labels | Pretrain on 100k unlabeled, fine-tune on 1k labeled |
| **SSL → FSL** | Unlabeled abundant, very few labels | Pretrain on 50k unlabeled, 5-shot classify new classes |
| **Transfer → FSL** | Pretrained model exists, few target labels | Fine-tune ImageNet model with 10 shots per class |
| **Weak → SSL** | Weak labels + unlabeled data | Use weak labels as pretext task, refine with SSL |
| **Meta-learning → FSL** | Many related FSL tasks | Meta-train on 20 datasets, fast adapt to new dataset |

**Implementation tip:** Start simple (transfer learning), then add complexity (SSL, FSL) only if needed.

---

## Paradigm Selection Cheat Sheet

| Scenario | Recommended Paradigm | R Support |
|----------|---------------------|-----------|
| 10k+ clean labels, standard task | **Supervised learning** | ⭐⭐⭐⭐⭐ Excellent (`tidymodels`, `mlr3`) |
| 1k labels, pretrained model exists | **Transfer learning** | ⭐⭐⭐⭐ Good (`keras3`, `torch`) |
| 100k unlabeled, 500 labeled | **SSL + supervised** | ⭐⭐⭐ Moderate (`torch` custom) |
| 5-10 examples per class, new classes | **Few-shot learning** | ⭐⭐ Limited (manual `torch`) |
| Clip-level labels, need frame-level | **Weak supervision (MIL)** | ⭐⭐ Limited (`milr`, `torch`) |
| Noisy crowdsourced labels | **Weak supervision (robust)** | ⭐⭐ Limited (`torch` custom) |
| Many related tasks, need adaptation | **Meta-learning** | ⭐ Very limited (Python better) |

**Legend:**
- ⭐⭐⭐⭐⭐ Native R packages, production-ready
- ⭐⭐⭐⭐ Good support, may need some custom code
- ⭐⭐⭐ Moderate, requires `torch`/`keras3` + custom layers
- ⭐⭐ Limited, manual implementation required
- ⭐ Use Python via `{reticulate}` or switch languages

---

## Practical Examples

### Example 1: Bioacoustics with Limited Labels

**Scenario:** Classify 50 frog species from 3-hour recordings. Have 10 labeled clips per species, 500 hours unlabeled.

**Solution:**
1. **SSL pretraining** on 500 hours unlabeled (contrastive learning on mel-spectrograms)
2. **Weak supervision** on 10 clips per species (clip-level labels, learn frame-level via attention)
3. **Few-shot evaluation** for rare species (5-shot prototypical networks)

**R implementation path:**
- `{tuneR}` + `{torch}` for audio preprocessing
- Custom SSL implementation with `{luz}`
- Attention pooling for weak supervision
- Prototypical networks for FSL

**Reference:** See SSL+FSL combination pattern in [examples/ssl-fsl-combination-pattern.md](examples/ssl-fsl-combination-pattern.md)

---

### Example 2: Medical Image Classification

**Scenario:** Detect rare disease from X-rays. 50 positive cases, 1000 negative cases, 100k unlabeled X-rays.

**Solution:**
1. **Transfer learning** from ImageNet pretrained model (anatomy structure preserved)
2. **SSL pretraining** on 100k unlabeled X-rays (adapt to medical domain)
3. **Class imbalance handling** (focal loss, oversampling rare class)

**R implementation path:**
- `{keras3}`: Load pretrained DenseNet/EfficientNet
- Fine-tune with frozen early layers, train classifier
- Use `{themis}` for imbalance handling in `{tidymodels}`

---

### Example 3: NLP with Crowdsourced Labels

**Scenario:** Sentiment classification with 5 annotators per text. 30% annotator disagreement.

**Solution:**
1. **Weak supervision** with label aggregation (majority vote or probabilistic)
2. **Transfer learning** from BERT pretrained model
3. **Uncertainty estimation** to detect unreliable annotations

**R implementation path:**
- `{text}` package for BERT embeddings
- Custom aggregation (weighted by annotator reliability)
- `{tidymodels}` for classifier training

---

## Guidelines for R Practitioners

### When R is Sufficient
- Transfer learning with pretrained models (`{keras3}`, `{torch}`)
- Standard supervised learning with feature engineering
- Moderate-scale SSL (< 100k samples)
- Simple metric learning (prototypical networks)

### When to Use Python Interop
- Advanced SSL techniques (MoCo, BYOL, VICReg)
- Meta-learning frameworks (MAML, Reptile)
- Complex weak supervision (Snorkel, data programming)
- Production-scale FSL (learn2learn, torchmeta)

**Interop pattern:**
```r
library(reticulate)
use_condaenv("ml-paradigms")

# Python SSL/FSL training
py_run_file("train_ssl.py")

# Load embeddings back to R
embeddings <- py$load_embeddings()

# Continue in R with tidymodels
model <- logistic_reg() |>
  fit(label ~ ., data = embeddings)
```

### Recommended Workflow
1. **Prototype in R** (if possible) to validate approach
2. **Switch to Python** for paradigms with weak R support (meta-learning, advanced SSL)
3. **Return to R** for downstream tasks (analysis, reporting, integration)

---

## Common Pitfalls

### SSL
- ❌ **Insufficient data**: SSL needs 10k+ samples to learn useful representations
- ❌ **Poor augmentations**: Augmentations must preserve semantics (e.g., don't flip bird calls vertically)
- ❌ **No downstream evaluation**: Always validate SSL embeddings on downstream task

### FSL
- ❌ **Not enough meta-training tasks**: Need 20+ related tasks for effective meta-learning
- ❌ **Overfitting to support set**: Use episodic training to prevent memorization
- ❌ **Ignoring class imbalance**: FSL assumes balanced classes - preprocess accordingly

### Weak Supervision
- ❌ **No clean validation set**: Need clean labels to evaluate and tune noise handling
- ❌ **Trusting weak labels too much**: Always treat as noisy, never as ground truth
- ❌ **Ignoring label dependencies**: Multi-label weak supervision harder than single-label

### Transfer Learning
- ❌ **Unfreezing too early**: Let classifier train first before fine-tuning backbone
- ❌ **Learning rate too high**: Use 10-100× smaller LR for fine-tuning than training from scratch
- ❌ **Domain mismatch ignored**: If source ≠ target, consider domain adaptation techniques

### Meta-Learning
- ❌ **Single task meta-learning**: Meaningless - need multiple related tasks
- ❌ **Insufficient compute**: Meta-learning is 10-100× more expensive than standard training
- ❌ **Overengineering**: Often transfer learning + fine-tuning works just as well

---

## Evaluation Metrics by Paradigm

### SSL
- **Downstream accuracy**: Classification accuracy after fine-tuning
- **Linear probe accuracy**: Train only linear classifier on frozen embeddings
- **kNN accuracy**: k-nearest neighbors in learned embedding space
- **Embedding quality**: t-SNE/UMAP visualization of class separation

### FSL
- **N-way K-shot accuracy**: Standard FSL benchmark (e.g., 5-way 5-shot)
- **Cross-domain generalization**: Test on unseen domains
- **Sample efficiency curve**: Accuracy vs number of shots (1, 5, 10, 50)

### Weak Supervision
- **Clean test accuracy**: Performance on fully labeled test set
- **Label noise robustness**: Accuracy vs noise rate (10%, 20%, 30%)
- **Calibration**: Expected Calibration Error (ECE) to check confidence

### Transfer Learning
- **Fine-tuning gain**: Improvement over random initialization
- **Convergence speed**: Epochs to reach target accuracy
- **Forgetting**: Performance on source task after fine-tuning

---

## Supporting Resources

### Detailed References
- Complete paradigm taxonomy: [references/learning-paradigms-taxonomy.md](references/learning-paradigms-taxonomy.md)
- SSL+FSL combination pattern: [examples/ssl-fsl-combination-pattern.md](examples/ssl-fsl-combination-pattern.md)
- Paradigm selection flowchart: [examples/paradigm-selection-flowchart.md](examples/paradigm-selection-flowchart.md)

### Key Papers by Paradigm
- **SSL**: "SimCLR: A Simple Framework for Contrastive Learning" (Chen et al., 2020)
- **FSL**: "Prototypical Networks for Few-shot Learning" (Snell et al., 2017)
- **Weak Supervision**: "Weakly Supervised Learning" (Zhou, 2018)
- **Transfer Learning**: "A Survey on Transfer Learning" (Pan & Yang, 2010)
- **Meta-Learning**: "Model-Agnostic Meta-Learning" (Finn et al., 2017)

### R Packages by Paradigm
- SSL/FSL: `{torch}`, `{luz}`, `{keras3}`
- Transfer: `{keras3}`, `{torch}`, `{tidymodels}`
- Weak supervision: `{milr}` (basic), custom `{torch}` implementations

---

## Quick Reference Card

**I have abundant unlabeled data + few labels**
→ Self-Supervised Learning (SSL pretraining + fine-tuning)

**I have 1-10 labeled examples per class**
→ Few-Shot Learning (prototypical networks, meta-learning)

**I have noisy or incomplete labels**
→ Weak Supervision (MIL, attention pooling, noise-robust losses)

**I have a pretrained model for a related task**
→ Transfer Learning (fine-tune or extract features)

**I have many related tasks to leverage**
→ Meta-Learning (MAML, task-aware models)

**I can combine multiple paradigms**
→ Hybrid: SSL → FSL, Transfer → FSL, Weak → SSL

**R support is limited for my paradigm**
→ Use `{reticulate}` to call Python libraries, return to R for downstream work

---

## When to Use This Skill

Invoke this skill when:
- Designing a new ML project with data constraints
- Stuck deciding between SSL, FSL, transfer learning
- Evaluating if weak supervision can reduce annotation costs
- Combining paradigms (e.g., "Should I do SSL before FSL?")
- Unsure if R ecosystem supports your chosen paradigm
- Need decision trees or cheat sheets for paradigm selection

This skill does NOT:
- Implement specific algorithms (that's for framework-specific skills)
- Provide detailed hyperparameter tuning (see `r-tidymodels` or `r-performance`)
- Cover standard supervised learning (see `r-datascience`, `r-tidymodels`)
