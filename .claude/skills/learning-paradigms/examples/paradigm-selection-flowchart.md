# Paradigm Selection Flowchart

Visual decision flowchart for selecting machine learning paradigms based on data characteristics.

## Quick Decision Flowchart

```
┌─────────────────────────────────────────┐
│  Start: Analyze Your Data Constraints  │
└─────────────┬───────────────────────────┘
              │
              ▼
   ┌──────────────────────────┐
   │ How many labeled samples │
   │    do you have total?    │
   └──┬───────────────────┬───┘
      │                   │
   < 100             100-10k              > 10k
      │                   │                  │
      ▼                   ▼                  ▼
┌──────────┐      ┌─────────────┐    ┌────────────┐
│Few-Shot  │      │Transfer     │    │Supervised  │
│Learning  │      │Learning     │    │Learning    │
└────┬─────┘      └──────┬──────┘    └─────┬──────┘
     │                   │                  │
     └───────────────────┴──────────────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │ Do you have abundant│
              │  unlabeled data?    │
              └──┬──────────────┬───┘
                 │              │
               Yes             No
                 │              │
                 ▼              ▼
         ┌───────────────┐  Use chosen
         │ Add SSL       │  paradigm as-is
         │ Pretraining   │
         └───────┬───────┘
                 │
                 ▼
        ┌─────────────────┐
        │ Are labels noisy│
        │ or incomplete?  │
        └──┬──────────┬───┘
           │          │
         Yes         No
           │          │
           ▼          ▼
    ┌──────────┐  Fine-tune
    │Add Weak  │  directly
    │Superv.   │
    └──────────┘
```

## Detailed Decision Tree

### Step 1: Data Volume Assessment

```
Total Labeled Examples:
├─ < 100 examples
│  └─ → Few-Shot Learning (FSL)
│     └─ Have related tasks for meta-training?
│        ├─ Yes → Meta-Learning (MAML, Prototypical Networks)
│        └─ No  → Transfer Learning + FSL
│
├─ 100-1,000 examples
│  └─ → Transfer Learning
│     └─ Good pretrained model exists?
│        ├─ Yes → Fine-tune pretrained model
│        └─ No  → SSL pretraining + supervised
│
├─ 1,000-10,000 examples
│  └─ → Supervised Learning or Transfer Learning
│     └─ Domain-specific data available unlabeled?
│        ├─ Yes → SSL pretraining + supervised
│        └─ No  → Standard supervised learning
│
└─ > 10,000 examples
   └─ → Supervised Learning (sufficient data)
      └─ Classes heavily imbalanced?
         ├─ Yes → Add class balancing techniques
         └─ No  → Standard supervised workflow
```

### Step 2: Unlabeled Data Assessment

```
Unlabeled Data Volume:
├─ > 10x labeled data
│  └─ → Consider SSL Pretraining
│     └─ Can define meaningful augmentations?
│        ├─ Yes → SSL (SimCLR, MoCo, Barlow Twins)
│        └─ No  → Skip SSL, use supervised only
│
├─ 1x-10x labeled data
│  └─ → Maybe SSL (marginal gains)
│     └─ Worth the implementation cost?
│        ├─ Yes → Try SSL
│        └─ No  → Skip, use supervised
│
└─ < 1x labeled data
   └─ → Skip SSL (insufficient unlabeled data)
```

### Step 3: Label Quality Assessment

```
Label Quality:
├─ Clean, complete labels
│  └─ → Use standard training
│
├─ Noisy labels (20-40% error rate)
│  └─ → Weak Supervision
│     └─ Technique:
│        ├─ Symmetric cross-entropy
│        ├─ Bootstrapping loss
│        └─ Co-teaching (train two networks)
│
├─ Incomplete labels (clip-level, not frame-level)
│  └─ → Multiple Instance Learning (MIL)
│     └─ Technique:
│        ├─ Attention pooling
│        ├─ Max pooling over instances
│        └─ Mean pooling with gates
│
└─ Multiple annotators with disagreements
   └─ → Label Aggregation + Uncertainty
      └─ Technique:
         ├─ Majority vote (simple)
         ├─ STAPLE (statistical fusion)
         └─ Probabilistic aggregation (Dawid-Skene)
```

## Example Decision Paths

### Path 1: Medical Imaging with Limited Data

```
START
  │
  ├─ Labeled: 200 X-rays (50 positive, 150 negative)
  ├─ Unlabeled: 50,000 X-rays
  └─ Pretrained: ImageNet models available
      │
      ▼
STEP 1: 200 examples → Transfer Learning or SSL
      │
      ▼
STEP 2: 50k unlabeled (250x labeled) → Add SSL Pretraining
      │
      ▼
STEP 3: Labels are clean → No weak supervision needed
      │
      ▼
DECISION: Transfer Learning → SSL Pretraining → Fine-tuning
      │
      └─ Implementation:
         1. Load ImageNet pretrained model
         2. SSL pretrain on 50k unlabeled medical X-rays
         3. Fine-tune on 200 labeled examples
         4. Handle class imbalance (50 vs 150)
```

### Path 2: Bioacoustics with Weak Labels

```
START
  │
  ├─ Labeled: 500 audio clips (clip-level species labels)
  ├─ Unlabeled: 10,000 hours continuous audio
  └─ Pretrained: No domain-specific models
      │
      ▼
STEP 1: 500 examples → Transfer Learning or SSL
      │
      ▼
STEP 2: 10k hours unlabeled → Add SSL Pretraining
      │
      ▼
STEP 3: Clip-level labels (need frame-level) → Weak Supervision
      │
      ▼
DECISION: SSL Pretraining → MIL (Weak Supervision)
      │
      └─ Implementation:
         1. SSL pretrain on 10k hours unlabeled audio
         2. Train MIL model with attention pooling
         3. Clip-level supervision, frame-level predictions
         4. Validate on small set of frame-labeled data
```

### Path 3: Few-Shot with Meta-Learning

```
START
  │
  ├─ Labeled: 5 examples per class, 100 classes
  ├─ Unlabeled: None
  └─ Related tasks: 20 similar datasets available
      │
      ▼
STEP 1: 5 examples/class → Few-Shot Learning
      │
      ▼
STEP 2: No unlabeled data → Skip SSL
      │
      ▼
STEP 3: Have 20 related datasets → Meta-Learning
      │
      ▼
DECISION: Meta-Learning (MAML or Prototypical Networks)
      │
      └─ Implementation:
         1. Meta-train on 20 related datasets
         2. Learn initialization that adapts quickly
         3. Fine-tune on target task (5-shot per class)
         4. Evaluate with episodic testing
```

## Paradigm Combination Matrix

| Labeled Data | Unlabeled Data | Label Quality | Pretrained Model | Recommended Paradigm |
|--------------|----------------|---------------|------------------|---------------------|
| < 100        | None           | Clean         | Yes              | Transfer → FSL |
| < 100        | None           | Clean         | No               | FSL (meta-learning) |
| < 100        | Abundant       | Clean         | Yes/No           | SSL → FSL |
| 100-1k       | None           | Clean         | Yes              | Transfer Learning |
| 100-1k       | None           | Noisy         | Yes              | Transfer → Weak Supervision |
| 100-1k       | Abundant       | Clean         | No               | SSL → Supervised |
| 100-1k       | Abundant       | Incomplete    | No               | SSL → MIL |
| 1k-10k       | None           | Clean         | No               | Supervised Learning |
| 1k-10k       | Abundant       | Clean         | No               | SSL → Supervised |
| > 10k        | Any            | Clean         | No               | Supervised Learning |
| > 10k        | Any            | Noisy/Incom.  | No               | Weak Supervision |

## R Ecosystem Decision Matrix

| Paradigm | Native R Support | Recommended Path |
|----------|------------------|------------------|
| **Supervised Learning** | ⭐⭐⭐⭐⭐ Excellent | `{tidymodels}`, `{mlr3}` |
| **Transfer Learning** | ⭐⭐⭐⭐ Good | `{keras3}`, `{torch}` |
| **SSL (Simple)** | ⭐⭐⭐ Moderate | Custom `{torch}` + `{luz}` |
| **SSL (Advanced)** | ⭐⭐ Limited | Python via `{reticulate}` |
| **FSL (Basic)** | ⭐⭐ Limited | Custom prototypical nets in `{torch}` |
| **FSL (Meta-learning)** | ⭐ Very Limited | Python (learn2learn, torchmeta) |
| **Weak Supervision (MIL)** | ⭐⭐ Limited | `{milr}` or custom `{torch}` |
| **Weak Supervision (Advanced)** | ⭐ Very Limited | Python (snorkel, cleanlab) |
| **Meta-Learning** | ⭐ Very Limited | Python (MAML, Reptile) |

**Legend:**
- ⭐⭐⭐⭐⭐ = Production-ready, well-maintained packages
- ⭐⭐⭐⭐ = Good support, minor custom code needed
- ⭐⭐⭐ = Moderate, requires `{torch}`/`{keras3}` + custom implementations
- ⭐⭐ = Limited, significant manual implementation
- ⭐ = Use Python via `{reticulate}` or switch languages

## Common Mistakes to Avoid

### ❌ Over-Engineering
```
Mistake: Using meta-learning FSL when you have 500 labeled examples
Better:  Use transfer learning + standard supervised learning
Reason:  500 examples is sufficient for supervised learning
```

### ❌ Under-Engineering
```
Mistake: Training from scratch with 50 labeled examples
Better:  Use transfer learning or few-shot learning
Reason:  50 examples far too few for training from scratch
```

### ❌ Ignoring Unlabeled Data
```
Mistake: Using only 1k labeled when 100k unlabeled available
Better:  SSL pretrain on 100k, fine-tune on 1k
Reason:  Wasting valuable signal from unlabeled data
```

### ❌ Trusting Weak Labels Too Much
```
Mistake: Treating noisy crowdsourced labels as ground truth
Better:  Apply noise-robust losses or label cleaning
Reason:  Noisy labels lead to overfitting and poor generalization
```

### ❌ Wrong Paradigm for R
```
Mistake: Implementing advanced meta-learning from scratch in R
Better:  Use Python for meta-learning, return to R for analysis
Reason:  R ecosystem lacks mature meta-learning frameworks
```

## Summary: When to Use What

**Your situation:** → **Recommended paradigm**

- 🔵 **Abundant unlabeled, few labeled** → SSL Pretraining
- 🟢 **1-10 examples per class** → Few-Shot Learning
- 🟡 **Noisy or incomplete labels** → Weak Supervision
- 🟠 **Pretrained model exists** → Transfer Learning
- 🔴 **Many related tasks** → Meta-Learning
- ⚪ **10k+ clean labels** → Supervised Learning

**Hybrid strategies:**
- SSL + FSL: Best of both worlds for very limited labeled data
- Transfer + FSL: Leverage pretrained models for few-shot scenarios
- SSL + Weak Supervision: Handle both unlabeled data and label noise

**R implementation priority:**
1. Start with Transfer Learning (easiest in R)
2. Add SSL if unlabeled data abundant (moderate difficulty)
3. Try FSL if < 100 examples (requires custom code)
4. Use Weak Supervision if labels noisy (manual implementation)
5. Switch to Python for advanced meta-learning
