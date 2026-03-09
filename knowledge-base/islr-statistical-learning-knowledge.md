# Statistical Learning Knowledge Base

*Reference framework for statistical learning methods in R*
*Based on established statistical learning principles*

---

## Chapter 2: Statistical Learning Fundamentals

### Core Concepts

**Statistical Learning**: Methods for understanding relationships between variables and making predictions.

- **Supervised Learning**: Predict output Y from inputs X (regression, classification)
- **Unsupervised Learning**: Find patterns in X without output Y (clustering, PCA)
- **Prediction vs Inference**: Focus on accuracy vs understanding relationships

**Key Framework**:
```
Y = f(X) + ε
```
- Y: response/output variable
- X: predictors/features
- f: unknown function we want to estimate
- ε: irreducible error

### Bias-Variance Tradeoff

**Fundamental principle**: Total error = Bias² + Variance + Irreducible Error

- **High Bias**: Model too simple (underfitting) → systematic errors
- **High Variance**: Model too complex (overfitting) → sensitivity to training data
- **Goal**: Find balance that minimizes test error

### Model Assessment Methods

**Training vs Test Error**:
```r
# Split data
set.seed(123)
train_idx <- sample(1:nrow(data), 0.7 * nrow(data))
train_data <- data[train_idx, ]
test_data <- data[-train_idx, ]

# Evaluate on test set
predictions <- predict(model, newdata = test_data)
test_mse <- mean((test_data$y - predictions)^2)
```

**Cross-Validation** (k-fold):
```r
library(caret)
ctrl <- trainControl(method = "cv", number = 10)
cv_model <- train(y ~ ., data = train_data,
                  method = "lm",
                  trControl = ctrl)
```

### When to Use What

| Problem Type | Method | Use When |
|--------------|--------|----------|
| Quantitative Y | Regression | Predicting continuous values |
| Categorical Y | Classification | Predicting discrete categories |
| No Y | Clustering | Finding groups/patterns |
| Dimension reduction | PCA | Too many features, visualization |

---

## Chapter 3: Linear Regression

### Core Concept
Model linear relationship: Y = β₀ + β₁X₁ + ... + βₚXₚ + ε

### Basic Linear Regression in R

```r
# Simple linear regression
lm_model <- lm(y ~ x, data = train_data)
summary(lm_model)

# Multiple regression
lm_multi <- lm(y ~ x1 + x2 + x3, data = train_data)

# Predictions
predictions <- predict(lm_model, newdata = test_data)

# Model diagnostics
par(mfrow = c(2, 2))
plot(lm_model)  # Residual plots
```

### Key Metrics

**R-squared**: Proportion of variance explained (0 to 1)
```r
summary(lm_model)$r.squared
```

**RSE (Residual Standard Error)**: Average deviation from regression line
```r
summary(lm_model)$sigma
```

**F-statistic**: Tests if ANY predictor is useful
```r
summary(lm_model)$fstatistic
```

### Variable Selection

```r
# Stepwise selection (forward/backward)
library(MASS)
full_model <- lm(y ~ ., data = train_data)
step_model <- stepAIC(full_model, direction = "both")

# All subsets
library(leaps)
regfit <- regsubsets(y ~ ., data = train_data, nvmax = 10)
summary(regfit)
```

### Interaction Terms

```r
# Include interaction
lm_interact <- lm(y ~ x1 + x2 + x1:x2, data = train_data)
# Or use shorthand
lm_interact <- lm(y ~ x1 * x2, data = train_data)
```

### Polynomial Regression

```r
# Polynomial terms
lm_poly <- lm(y ~ poly(x, degree = 3), data = train_data)
```

### When to Use Linear Regression

✅ **Use when:**
- Relationship appears linear
- Interpretability is important
- Quick baseline model needed
- Assumptions reasonably met (linearity, normality, homoscedasticity)

❌ **Avoid when:**
- Clear non-linear patterns
- Many irrelevant predictors (use regularization instead)
- Heavy multicollinearity (use PCA or regularization)

---

## Chapter 4: Classification

### Logistic Regression

**For binary outcomes** (Y = 0 or 1)

```r
# Fit logistic regression
logit_model <- glm(y ~ x1 + x2, data = train_data, family = binomial)

# Predict probabilities
prob_pred <- predict(logit_model, newdata = test_data, type = "response")

# Convert to class predictions (threshold = 0.5)
class_pred <- ifelse(prob_pred > 0.5, 1, 0)

# Confusion matrix
table(Predicted = class_pred, Actual = test_data$y)
```

### Classification Metrics

```r
# Accuracy
accuracy <- mean(class_pred == test_data$y)

# Confusion matrix metrics
library(caret)
confusionMatrix(factor(class_pred), factor(test_data$y))

# ROC curve and AUC
library(pROC)
roc_obj <- roc(test_data$y, prob_pred)
auc(roc_obj)
plot(roc_obj)
```

### Linear Discriminant Analysis (LDA)

**Assumes**: Each class has multivariate normal distribution with common covariance

```r
library(MASS)
lda_model <- lda(y ~ x1 + x2, data = train_data)
lda_pred <- predict(lda_model, newdata = test_data)

# Predictions
class_pred <- lda_pred$class
posteriors <- lda_pred$posterior
```

### Quadratic Discriminant Analysis (QDA)

**Less restrictive**: Allows different covariance matrices per class

```r
library(MASS)
qda_model <- qda(y ~ x1 + x2, data = train_data)
qda_pred <- predict(qda_model, newdata = test_data)
```

### K-Nearest Neighbors (KNN)

**Non-parametric**: Classifies based on K closest training observations

```r
library(class)
train_X <- train_data[, c("x1", "x2")]
test_X <- test_data[, c("x1", "x2")]
train_y <- train_data$y

knn_pred <- knn(train = train_X, test = test_X, cl = train_y, k = 5)

# Choose K via cross-validation
library(caret)
ctrl <- trainControl(method = "cv", number = 10)
knn_cv <- train(y ~ ., data = train_data, method = "knn",
                trControl = ctrl,
                tuneGrid = data.frame(k = 1:20))
```

### Classification Method Selection

| Method | Use When | Advantages | Limitations |
|--------|----------|------------|-------------|
| Logistic | Binary outcome, linear boundaries | Interpretable, probabilities | Assumes linearity |
| LDA | Multiple classes, normal data | Fast, stable | Assumes normality, equal covariance |
| QDA | Non-linear boundaries, unequal variance | More flexible than LDA | Needs more data |
| KNN | Complex boundaries, no assumptions | Very flexible | Slow, needs feature scaling |

---

## Chapter 5: Resampling Methods

### Cross-Validation

**K-Fold CV** (Standard approach):
```r
library(caret)
set.seed(123)
ctrl <- trainControl(method = "cv", number = 10)

# For any model
cv_results <- train(y ~ ., data = data,
                    method = "lm",  # or "glm", "knn", etc.
                    trControl = ctrl)

# Extract CV error
cv_results$results
```

**Leave-One-Out CV (LOOCV)**:
```r
ctrl_loocv <- trainControl(method = "LOOCV")
loocv_results <- train(y ~ ., data = data,
                       method = "lm",
                       trControl = ctrl_loocv)
```

### Bootstrap

**For estimating uncertainty**:
```r
library(boot)

# Define statistic function
stat_function <- function(data, indices) {
  d <- data[indices, ]
  model <- lm(y ~ x, data = d)
  return(coef(model))
}

# Bootstrap
boot_results <- boot(data, stat_function, R = 1000)

# Confidence intervals
boot.ci(boot_results, type = "bca")
```

### When to Use Resampling

- **Small datasets**: Use LOOCV or bootstrap
- **Medium-large datasets**: Use 5-10 fold CV
- **Tuning hyperparameters**: Always use CV
- **Assessing uncertainty**: Use bootstrap
- **Model comparison**: Use repeated CV

---

## Chapter 6: Linear Model Selection & Regularization

### Ridge Regression (L2 Regularization)

**Shrinks coefficients** toward zero (but not exactly zero)

```r
library(glmnet)

# Prepare data
x <- model.matrix(y ~ ., data = train_data)[, -1]
y <- train_data$y

# Fit ridge (alpha = 0)
ridge_model <- glmnet(x, y, alpha = 0)

# Cross-validation to choose lambda
cv_ridge <- cv.glmnet(x, y, alpha = 0)
best_lambda <- cv_ridge$lambda.min

# Predict with best lambda
x_test <- model.matrix(y ~ ., data = test_data)[, -1]
ridge_pred <- predict(ridge_model, s = best_lambda, newx = x_test)
```

### Lasso Regression (L1 Regularization)

**Performs feature selection** (sets some coefficients exactly to zero)

```r
# Fit lasso (alpha = 1)
lasso_model <- glmnet(x, y, alpha = 1)

# Cross-validation
cv_lasso <- cv.glmnet(x, y, alpha = 1)
best_lambda <- cv_lasso$lambda.min

# Get non-zero coefficients
coef(cv_lasso, s = "lambda.min")

# Predict
lasso_pred <- predict(lasso_model, s = best_lambda, newx = x_test)
```

### Elastic Net

**Combines Ridge and Lasso**:
```r
# alpha between 0 and 1
elastic_model <- cv.glmnet(x, y, alpha = 0.5)
```

### Principal Components Regression (PCR)

**Use PCA first, then regress**:
```r
library(pls)

pcr_model <- pcr(y ~ ., data = train_data, scale = TRUE, validation = "CV")

# Choose number of components
validationplot(pcr_model, val.type = "MSEP")

# Predict
pcr_pred <- predict(pcr_model, newdata = test_data, ncomp = 5)
```

### Method Selection Guide

| Method | Use When | Benefit |
|--------|----------|---------|
| Ridge | Many predictors, multicollinearity | Stabilizes estimates |
| Lasso | Want feature selection, sparse model | Automatic variable selection |
| Elastic Net | Mix of correlated/uncorrelated predictors | Balance ridge/lasso |
| PCR | High correlation among predictors | Reduces dimensionality |

**Rule of thumb**: Start with Lasso for interpretability, use Ridge if all features matter, use Elastic Net when unsure.

---

## Chapter 7: Beyond Linearity

### Polynomial Regression

```r
# Degree-d polynomial
poly_model <- lm(y ~ poly(x, degree = 4), data = train_data)
```

### Step Functions

```r
# Cut variable into bins
breaks <- c(min(data$x), 25, 50, 75, max(data$x))
data$x_cut <- cut(data$x, breaks = breaks)
step_model <- lm(y ~ x_cut, data = data)
```

### Regression Splines

```r
library(splines)

# Cubic spline with specified knots
knots <- quantile(train_data$x, probs = c(0.25, 0.5, 0.75))
spline_model <- lm(y ~ bs(x, knots = knots), data = train_data)

# Natural spline (linear at boundaries)
ns_model <- lm(y ~ ns(x, df = 4), data = train_data)
```

### Smoothing Splines

```r
# Choose smoothing via cross-validation
smooth_model <- smooth.spline(train_data$x, train_data$y, cv = TRUE)

# Predict
smooth_pred <- predict(smooth_model, x = test_data$x)
```

### Local Regression (LOESS)

```r
# Fit locally weighted regression
loess_model <- loess(y ~ x, data = train_data, span = 0.5)

# Predict
loess_pred <- predict(loess_model, newdata = test_data)
```

### Generalized Additive Models (GAMs)

```r
library(gam)

# Smoothing splines for each predictor
gam_model <- gam(y ~ s(x1, df = 4) + s(x2, df = 4) + x3, data = train_data)

# Or with automatic smoothing selection
library(mgcv)
gam_auto <- gam(y ~ s(x1) + s(x2) + x3, data = train_data)

# Plot effects
plot(gam_model, se = TRUE)
```

### When to Use Non-Linear Methods

✅ **Use when:**
- Residual plots show non-linearity
- Relationship clearly curved
- Want flexibility while maintaining interpretability
- GAMs work well for additive non-linear effects

**Method choice:**
- **Polynomials**: Simple curves, be careful of high degrees
- **Splines**: More flexible, better for complex curves
- **GAMs**: Multiple predictors with different non-linear relationships
- **LOESS**: Exploratory analysis, small-medium datasets

---

## Chapter 8: Tree-Based Methods

### Decision Trees

**Regression tree**:
```r
library(tree)

# Fit tree
tree_model <- tree(y ~ ., data = train_data)

# Plot
plot(tree_model)
text(tree_model, pretty = 0)

# Predict
tree_pred <- predict(tree_model, newdata = test_data)
```

**Classification tree**:
```r
class_tree <- tree(factor(y) ~ ., data = train_data)
```

### Pruning Trees

```r
# Cross-validation to find optimal size
cv_tree <- cv.tree(tree_model)
plot(cv_tree$size, cv_tree$dev, type = "b")

# Prune to optimal size
pruned_tree <- prune.tree(tree_model, best = 5)
```

### Better Approach: Use rpart

```r
library(rpart)
library(rpart.plot)

# Fit tree with cp (complexity parameter)
rpart_model <- rpart(y ~ ., data = train_data,
                     control = rpart.control(cp = 0.01))

# Visualize
rpart.plot(rpart_model)

# Find optimal cp via CV
printcp(rpart_model)
plotcp(rpart_model)

# Prune
optimal_cp <- rpart_model$cptable[which.min(rpart_model$cptable[,"xerror"]), "CP"]
pruned_rpart <- prune(rpart_model, cp = optimal_cp)
```

### Bagging (Bootstrap Aggregating)

```r
library(randomForest)

# Bagging = Random Forest with mtry = p (all variables)
bag_model <- randomForest(y ~ ., data = train_data,
                          mtry = ncol(train_data) - 1,
                          ntree = 500,
                          importance = TRUE)

# Predict
bag_pred <- predict(bag_model, newdata = test_data)

# Variable importance
importance(bag_model)
varImpPlot(bag_model)
```

### Random Forests

```r
library(randomForest)

# Random Forest (mtry = sqrt(p) for classification, p/3 for regression)
rf_model <- randomForest(y ~ ., data = train_data,
                         ntree = 500,
                         importance = TRUE)

# Tune mtry
library(caret)
ctrl <- trainControl(method = "cv", number = 5)
rf_tuned <- train(y ~ ., data = train_data,
                  method = "rf",
                  trControl = ctrl,
                  tuneGrid = data.frame(mtry = c(2, 4, 6, 8)))

# Variable importance
varImpPlot(rf_model)
```

### Boosting

```r
library(gbm)

# Gradient boosting for regression
boost_model <- gbm(y ~ ., data = train_data,
                   distribution = "gaussian",
                   n.trees = 5000,
                   interaction.depth = 4,
                   shrinkage = 0.01,
                   cv.folds = 5)

# Find optimal number of trees
best_iter <- gbm.perf(boost_model, method = "cv")

# Predict
boost_pred <- predict(boost_model, newdata = test_data, n.trees = best_iter)

# Variable importance
summary(boost_model)
```

**XGBoost** (usually better performance):
```r
library(xgboost)

# Prepare data
dtrain <- xgb.DMatrix(data = as.matrix(train_data[, -1]),
                      label = train_data$y)
dtest <- xgb.DMatrix(data = as.matrix(test_data[, -1]))

# Train with cross-validation
xgb_cv <- xgb.cv(data = dtrain,
                 nrounds = 1000,
                 nfold = 5,
                 objective = "reg:squarederror",
                 eta = 0.1,
                 max_depth = 6,
                 early_stopping_rounds = 50,
                 verbose = 0)

# Train final model
xgb_model <- xgboost(data = dtrain,
                     nrounds = xgb_cv$best_iteration,
                     objective = "reg:squarederror",
                     eta = 0.1,
                     max_depth = 6,
                     verbose = 0)

# Predict
xgb_pred <- predict(xgb_model, dtest)

# Importance
xgb.importance(model = xgb_model)
```

### Tree Method Comparison

| Method | Accuracy | Interpretability | Speed | Use When |
|--------|----------|------------------|-------|----------|
| Single Tree | Low | High | Fast | Need interpretability |
| Bagging | Medium | Low | Medium | Reduce variance |
| Random Forest | High | Low | Medium | General purpose, robust |
| Boosting | Very High | Low | Slow | Maximum accuracy |

**Default recommendation**: Start with Random Forest, try XGBoost if you need more accuracy.

---

## Chapter 9: Support Vector Machines

### Support Vector Classifier (Linear)

```r
library(e1071)

# Linear SVM
svm_linear <- svm(factor(y) ~ ., data = train_data,
                  kernel = "linear",
                  cost = 1,
                  scale = TRUE)

# Predict
svm_pred <- predict(svm_linear, newdata = test_data)

# Tune cost parameter
tune_svm <- tune(svm, factor(y) ~ ., data = train_data,
                 kernel = "linear",
                 ranges = list(cost = c(0.001, 0.01, 0.1, 1, 10, 100)))

best_svm <- tune_svm$best.model
```

### SVM with Non-Linear Kernels

**Polynomial kernel**:
```r
svm_poly <- svm(factor(y) ~ ., data = train_data,
                kernel = "polynomial",
                degree = 3,
                cost = 1)
```

**Radial (RBF) kernel** (most common):
```r
svm_radial <- svm(factor(y) ~ ., data = train_data,
                  kernel = "radial",
                  gamma = 1,
                  cost = 1)

# Tune both cost and gamma
tune_radial <- tune(svm, factor(y) ~ ., data = train_data,
                    kernel = "radial",
                    ranges = list(cost = c(0.1, 1, 10, 100),
                                  gamma = c(0.5, 1, 2, 3, 4)))
```

### SVM for Regression (SVR)

```r
svr_model <- svm(y ~ ., data = train_data,
                 kernel = "radial",
                 epsilon = 0.1,
                 cost = 1)
```

### When to Use SVM

✅ **Use when:**
- High-dimensional data (many features)
- Clear margin of separation
- Non-linear boundaries (with kernels)
- Want robust classifier

❌ **Avoid when:**
- Very large datasets (slow to train)
- Need probability estimates (requires extra computation)
- Need interpretability

**Practical tips**:
- Always scale features
- Start with linear kernel, then try RBF
- Tune cost (and gamma for RBF) via cross-validation
- For large datasets, consider Random Forest or XGBoost instead

---

## Chapter 10: Deep Learning

*Note: Deep learning typically requires specialized libraries like keras/tensorflow*

### Neural Networks in R

```r
library(keras)

# Simple neural network
model <- keras_model_sequential() %>%
  layer_dense(units = 128, activation = "relu", input_shape = ncol(train_x)) %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 1, activation = "sigmoid")

# Compile
model %>% compile(
  loss = "binary_crossentropy",
  optimizer = optimizer_adam(learning_rate = 0.001),
  metrics = c("accuracy")
)

# Train
history <- model %>% fit(
  x = as.matrix(train_x),
  y = train_y,
  epochs = 50,
  batch_size = 32,
  validation_split = 0.2,
  callbacks = list(callback_early_stopping(patience = 5))
)

# Predict
predictions <- model %>% predict(as.matrix(test_x))
```

### Convolutional Neural Networks (CNN)

```r
# For image data
cnn_model <- keras_model_sequential() %>%
  layer_conv_2d(filters = 32, kernel_size = c(3, 3), activation = "relu",
                input_shape = c(28, 28, 1)) %>%
  layer_max_pooling_2d(pool_size = c(2, 2)) %>%
  layer_conv_2d(filters = 64, kernel_size = c(3, 3), activation = "relu") %>%
  layer_max_pooling_2d(pool_size = c(2, 2)) %>%
  layer_flatten() %>%
  layer_dense(units = 128, activation = "relu") %>%
  layer_dropout(rate = 0.5) %>%
  layer_dense(units = 10, activation = "softmax")
```

### Recurrent Neural Networks (RNN/LSTM)

```r
# For sequential/time series data
lstm_model <- keras_model_sequential() %>%
  layer_lstm(units = 50, input_shape = c(timesteps, features)) %>%
  layer_dense(units = 1)
```

### When to Use Deep Learning

✅ **Use when:**
- Very large datasets (>10k observations)
- Complex patterns (images, text, sequences)
- High-dimensional unstructured data
- Have computational resources (GPU)

❌ **Avoid when:**
- Small datasets (<1k observations) - will overfit
- Need interpretability
- Limited computational resources
- Simpler methods work well

**Practical advice**:
- For tabular data: Try Random Forest/XGBoost first
- For images: Use CNNs (or transfer learning)
- For sequences/text: Use RNNs/LSTMs or transformers
- Always use regularization (dropout, early stopping)

---

## Chapter 12: Unsupervised Learning

### Principal Component Analysis (PCA)

```r
# Perform PCA (scale = TRUE standardizes variables)
pca_result <- prcomp(data[, -1], scale = TRUE)

# Summary
summary(pca_result)

# Scree plot (variance explained)
plot(pca_result)
screeplot(pca_result, type = "lines")

# Biplot
biplot(pca_result, scale = 0)

# Extract principal components
pc_scores <- pca_result$x[, 1:3]  # First 3 PCs

# Variance explained
var_explained <- pca_result$sdev^2 / sum(pca_result$sdev^2)
plot(cumsum(var_explained), type = "b",
     xlab = "Principal Component",
     ylab = "Cumulative Proportion of Variance Explained")
```

### K-Means Clustering

```r
# Perform K-means
set.seed(123)
kmeans_result <- kmeans(scaled_data, centers = 3, nstart = 25)

# Cluster assignments
clusters <- kmeans_result$cluster

# Cluster centers
kmeans_result$centers

# Within-cluster sum of squares
kmeans_result$tot.withinss

# Choose K using elbow method
wss <- numeric(10)
for (k in 1:10) {
  kmeans_temp <- kmeans(scaled_data, centers = k, nstart = 25)
  wss[k] <- kmeans_temp$tot.withinss
}
plot(1:10, wss, type = "b", xlab = "Number of Clusters", ylab = "Within-cluster SS")

# Visualize clusters (first 2 PCs)
library(factoextra)
fviz_cluster(kmeans_result, data = scaled_data)
```

### Hierarchical Clustering

```r
# Compute distance matrix
dist_matrix <- dist(scaled_data, method = "euclidean")

# Hierarchical clustering
hc_complete <- hclust(dist_matrix, method = "complete")
hc_average <- hclust(dist_matrix, method = "average")
hc_single <- hclust(dist_matrix, method = "single")

# Dendrogram
plot(hc_complete, main = "Complete Linkage")

# Cut tree to get K clusters
clusters <- cutree(hc_complete, k = 3)

# Or cut at specific height
clusters <- cutree(hc_complete, h = 5)

# Visualize
library(factoextra)
fviz_dend(hc_complete, k = 3, rect = TRUE)
```

### Linkage Methods

- **Complete**: Maximum distance between clusters (tight clusters)
- **Average**: Average distance (balanced)
- **Single**: Minimum distance (can create long chains)
- **Ward**: Minimize within-cluster variance (similar to K-means)

```r
hc_ward <- hclust(dist_matrix, method = "ward.D2")
```

### Determining Optimal Number of Clusters

**Gap statistic**:
```r
library(cluster)
gap_stat <- clusGap(scaled_data, FUN = kmeans, nstart = 25, K.max = 10, B = 50)
plot(gap_stat)
```

**Silhouette method**:
```r
library(cluster)
silhouette_score <- numeric(10)
for (k in 2:10) {
  kmeans_temp <- kmeans(scaled_data, centers = k, nstart = 25)
  ss <- silhouette(kmeans_temp$cluster, dist(scaled_data))
  silhouette_score[k] <- mean(ss[, 3])
}
plot(2:10, silhouette_score[2:10], type = "b")
```

### Clustering Method Selection

| Method | Use When | Advantages | Limitations |
|--------|----------|------------|-------------|
| K-Means | Know # clusters, spherical clusters | Fast, simple | Assumes spherical, needs K |
| Hierarchical | Don't know K, want dendrogram | Flexible, visual | Slow for large data |
| DBSCAN | Arbitrary shapes, noise | Handles outliers | Sensitive to parameters |

### PCA Use Cases

✅ **Use PCA when:**
- Too many correlated variables
- Need visualization (use first 2-3 PCs)
- Reduce dimensionality before modeling
- Data exploration

**How many components to keep?**
- Variance explained > 80-90%
- Elbow in scree plot
- Eigenvalue > 1 (Kaiser rule)

---

## Model Selection Decision Framework

### 1. What's your goal?

```
┌─ Prediction → Focus on test error, use CV
│
├─ Inference → Focus on interpretability, p-values
│
└─ Exploration → Use visualization, unsupervised methods
```

### 2. What's your Y variable?

```
┌─ Quantitative → Regression methods
│   ├─ Linear relationship → Linear regression
│   ├─ Non-linear → GAM, splines, trees
│   └─ Complex → Random Forest, XGBoost
│
├─ Binary → Classification methods
│   ├─ Linear boundary → Logistic regression, LDA
│   ├─ Non-linear → QDA, SVM, trees
│   └─ Complex → Random Forest, XGBoost
│
├─ Multi-class → LDA, QDA, multinomial logistic, trees
│
└─ None (no Y) → Unsupervised methods
    ├─ Find groups → K-means, hierarchical
    └─ Reduce dimensions → PCA
```

### 3. How many observations (n) vs features (p)?

```
┌─ n >> p (lots of data, few features)
│   → Can use flexible methods (trees, SVM, neural nets)
│
├─ n ≈ p (similar)
│   → Use regularization (ridge, lasso)
│   → Or reduce dimensions (PCA)
│
└─ n << p (more features than observations)
    → Lasso for feature selection
    → Ridge for prediction
    → PCA to reduce p
```

### 4. Data characteristics?

```
┌─ Linear relationships → Linear models, GAMs
├─ Non-linear → Trees, SVM with kernels, neural nets
├─ High correlation among predictors → Ridge, PCA, Random Forest
├─ Many irrelevant features → Lasso, trees
├─ Mixed linear/non-linear → GAMs, Random Forest
└─ Complex interactions → Trees, Random Forest, XGBoost
```

### 5. Practical constraints?

```
┌─ Need interpretability → Linear regression, logistic, single tree, GAM
├─ Need fast predictions → Linear models, naive Bayes
├─ Can tolerate slow training → SVM, XGBoost, neural nets
├─ Limited computational resources → Linear models, simple trees
└─ Need probability estimates → Logistic, LDA, calibrated models
```

---

## Standard Workflow Template

### Complete Analysis Pipeline

```r
# 1. LOAD AND EXPLORE DATA
library(tidyverse)
data <- read_csv("data.csv")
summary(data)
str(data)

# Check for missing values
colSums(is.na(data))

# Visualize
ggplot(data, aes(x = x, y = y)) + geom_point()

# 2. SPLIT DATA
set.seed(123)
train_idx <- sample(1:nrow(data), 0.7 * nrow(data))
train_data <- data[train_idx, ]
test_data <- data[-train_idx, ]

# 3. PREPROCESSING
# Scale numeric variables
library(caret)
preproc <- preProcess(train_data[, -1], method = c("center", "scale"))
train_scaled <- predict(preproc, train_data)
test_scaled <- predict(preproc, test_data)

# Handle categorical variables
# Use model.matrix() or factor encoding

# 4. FIT MULTIPLE MODELS
# Linear model
lm_fit <- lm(y ~ ., data = train_scaled)

# Regularized model
library(glmnet)
x_train <- model.matrix(y ~ ., train_scaled)[, -1]
y_train <- train_scaled$y
cv_lasso <- cv.glmnet(x_train, y_train, alpha = 1)

# Tree-based model
library(randomForest)
rf_fit <- randomForest(y ~ ., data = train_scaled, ntree = 500)

# 5. EVALUATE ON TEST SET
# Linear model
lm_pred <- predict(lm_fit, newdata = test_scaled)
lm_rmse <- sqrt(mean((test_scaled$y - lm_pred)^2))

# Lasso
x_test <- model.matrix(y ~ ., test_scaled)[, -1]
lasso_pred <- predict(cv_lasso, newx = x_test, s = "lambda.min")
lasso_rmse <- sqrt(mean((test_scaled$y - lasso_pred)^2))

# Random Forest
rf_pred <- predict(rf_fit, newdata = test_scaled)
rf_rmse <- sqrt(mean((test_scaled$y - rf_pred)^2))

# 6. COMPARE MODELS
results <- data.frame(
  Model = c("Linear", "Lasso", "Random Forest"),
  RMSE = c(lm_rmse, lasso_rmse, rf_rmse)
)
print(results)

# 7. SELECT BEST MODEL AND ANALYZE
# Coefficients/importance
summary(best_model)
varImpPlot(rf_fit)  # For RF

# Residual diagnostics
plot(best_model)

# 8. FINAL PREDICTIONS
final_predictions <- predict(best_model, newdata = new_data)
```

---

## Quick Reference: Common Tasks

### Task: Build Predictive Model

**Quick start**:
```r
library(caret)
set.seed(123)

# Split data
trainIndex <- createDataPartition(data$y, p = 0.7, list = FALSE)
train <- data[trainIndex, ]
test <- data[-trainIndex, ]

# Train with CV
ctrl <- trainControl(method = "cv", number = 10)
model <- train(y ~ ., data = train,
               method = "rf",  # or "lm", "glm", "xgbTree"
               trControl = ctrl)

# Evaluate
predictions <- predict(model, newdata = test)
postResample(predictions, test$y)
```

### Task: Feature Selection

```r
# Lasso
library(glmnet)
cv_lasso <- cv.glmnet(x, y, alpha = 1)
coef(cv_lasso, s = "lambda.min")

# Random Forest importance
library(randomForest)
rf <- randomForest(y ~ ., data = data, importance = TRUE)
importance(rf)

# Recursive Feature Elimination
library(caret)
rfe_control <- rfeControl(functions = rfFuncs, method = "cv", number = 10)
rfe_results <- rfe(x, y, sizes = c(1:10), rfeControl = rfe_control)
```

### Task: Handle Imbalanced Classes

```r
# Downsample majority class
library(caret)
train_balanced <- downSample(x = train[, -target_col],
                             y = train$target)

# Or upsample minority class
train_balanced <- upSample(x = train[, -target_col],
                           y = train$target)

# SMOTE
library(DMwR)
train_smote <- SMOTE(target ~ ., data = train, perc.over = 200, perc.under = 100)

# Weighted classes in model
library(randomForest)
rf <- randomForest(target ~ ., data = train,
                   classwt = c(0.3, 0.7))  # Give more weight to minority class
```

### Task: Tune Hyperparameters

```r
library(caret)

# Define grid
tune_grid <- expand.grid(
  mtry = c(2, 4, 6, 8),
  splitrule = c("gini", "extratrees"),
  min.node.size = c(1, 5, 10)
)

# Train with tuning
ctrl <- trainControl(method = "cv", number = 5, search = "grid")
tuned_model <- train(y ~ ., data = train,
                     method = "ranger",
                     trControl = ctrl,
                     tuneGrid = tune_grid)

# Best parameters
tuned_model$bestTune
```

---

## Common Pitfalls & Best Practices

### ❌ Common Mistakes

1. **Not splitting data properly**
   - Fix: Always split BEFORE any preprocessing

2. **Data leakage**
   - Fix: Fit preprocessing (scaling, imputation) on train only, apply to test

3. **Not using CV for model selection**
   - Fix: Always use CV to choose between models

4. **Overfitting to test set**
   - Fix: Only look at test set once at the end

5. **Ignoring class imbalance**
   - Fix: Use balanced metrics, resampling, or weighted classes

6. **Not scaling features for distance-based methods**
   - Fix: Always scale for KNN, SVM, neural nets

### ✅ Best Practices

1. **Always split data** (train/validation/test or train/test with CV)

2. **Use cross-validation** for model selection and tuning

3. **Scale features** when using distance-based methods

4. **Check assumptions** (especially for linear models)

5. **Start simple** (linear model) then increase complexity

6. **Compare multiple models** (don't stop at first model)

7. **Look at residuals/errors** (not just metrics)

8. **Use appropriate metrics** (RMSE for regression, accuracy/AUC for classification)

9. **Handle missing data properly** (don't drop blindly)

10. **Document your process** (seeds, preprocessing, parameters)

---

## References

This knowledge base synthesizes established statistical learning principles and R programming practices for machine learning. For comprehensive theoretical foundations and mathematical details, consult:

- Hastie, T., Tibshirani, R., & Friedman, J. (2009). *The Elements of Statistical Learning*
- James, G., Witten, D., Hastie, T., & Tibshirani, R. (2021). *An Introduction to Statistical Learning with Applications in R* (2nd ed.)

All code examples follow standard R conventions and use widely-adopted packages from CRAN.

---

*Last updated: 2026-03-08*
