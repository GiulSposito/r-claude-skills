# Statistical Modeling Guide

Complete reference for statistical inference and modeling in R.

## Linear Regression

### Simple Linear Regression

```r
# Fit model
model <- lm(y ~ x, data = data)

# Tidy output with broom
library(broom)
tidy(model, conf.int = TRUE)  # Coefficients with CIs
glance(model)                  # Model statistics
augment(model)                 # Fitted values and residuals

# Summary
summary(model)

# Confidence intervals
confint(model, level = 0.95)

# Predictions
predict(model, newdata = new_data, interval = "confidence")
predict(model, newdata = new_data, interval = "prediction")
```

### Multiple Regression

```r
# Multiple predictors
model <- lm(y ~ x1 + x2 + x3, data = data)

# With categorical predictors
model <- lm(price ~ bedrooms + factor(neighborhood), data = houses)

# Interactions
model <- lm(y ~ x1 * x2, data = data)  # x1 + x2 + x1:x2
model <- lm(y ~ x1 + x2 + x1:x2, data = data)  # Equivalent

# Polynomials
model <- lm(y ~ poly(x, 2), data = data)  # x + x^2
model <- lm(y ~ poly(x, 2, raw = TRUE), data = data)  # Raw polynomials

# All interactions
model <- lm(y ~ (x1 + x2 + x3)^2, data = data)  # All 2-way

# Transform response
model <- lm(log(y) ~ x1 + x2, data = data)
```

### Model Diagnostics

```r
# Diagnostic plots
par(mfrow = c(2, 2))
plot(model)

# 1. Residuals vs Fitted: Check linearity, homoscedasticity
# 2. Q-Q plot: Check normality of residuals
# 3. Scale-Location: Check homoscedasticity
# 4. Residuals vs Leverage: Identify influential points

# Individual checks
# Normality
shapiro.test(residuals(model))
ggplot(data.frame(resid = residuals(model)), aes(sample = resid)) +
  stat_qq() + stat_qq_line()

# Homoscedasticity
library(lmtest)
bptest(model)  # Breusch-Pagan test

# Autocorrelation
dwtest(model)  # Durbin-Watson test

# Multicollinearity
library(car)
vif(model)  # Variance Inflation Factor (< 5 good, < 10 acceptable)

# Influential observations
cooks_d <- cooks.distance(model)
plot(cooks_d, type = "h")
abline(h = 4/nrow(data), col = "red")  # Threshold

# Leverage
hatvalues(model)
```

### Model Comparison

```r
# Nested models
model1 <- lm(y ~ x1, data = data)
model2 <- lm(y ~ x1 + x2, data = data)
model3 <- lm(y ~ x1 + x2 + x3, data = data)

# F-test
anova(model1, model2, model3)

# Information criteria
AIC(model1, model2, model3)
BIC(model1, model2, model3)

# Cross-validation
library(caret)
train_control <- trainControl(method = "cv", number = 10)
cv_model <- train(y ~ ., data = data, method = "lm", trControl = train_control)
cv_model$results
```

## Generalized Linear Models (GLM)

### Logistic Regression

```r
# Binary outcome
model <- glm(outcome ~ x1 + x2, data = data, family = binomial)

# Coefficients (log-odds)
tidy(model)

# Odds ratios
tidy(model, exponentiate = TRUE, conf.int = TRUE)

# Predictions (probabilities)
predictions <- predict(model, newdata = test, type = "response")

# Classification
predicted_class <- ifelse(predictions > 0.5, 1, 0)

# Confusion matrix
table(Predicted = predicted_class, Actual = test$outcome)

# ROC curve
library(pROC)
roc_obj <- roc(test$outcome, predictions)
plot(roc_obj)
auc(roc_obj)

# Model comparison (deviance)
anova(model1, model2, test = "Chisq")
```

### Poisson Regression

```r
# Count data
model <- glm(count ~ x1 + x2, data = data, family = poisson)

# Check overdispersion
deviance(model) / df.residual(model)  # Should be ~1

# If overdispersed, use quasi-Poisson
model_quasi <- glm(count ~ x1 + x2, data = data, family = quasipoisson)

# Or negative binomial
library(MASS)
model_nb <- glm.nb(count ~ x1 + x2, data = data)
```

### Other GLM Families

```r
# Gamma (continuous positive, right-skewed)
glm(y ~ x, data = data, family = Gamma(link = "log"))

# Inverse Gaussian
glm(y ~ x, data = data, family = inverse.gaussian(link = "1/mu^2"))
```

## Hypothesis Testing

### T-Tests

```r
# One-sample t-test
t.test(x, mu = 0)

# Two-sample t-test
t.test(x, y)  # Independent samples
t.test(x, y, paired = TRUE)  # Paired samples

# Unequal variances (Welch's t-test)
t.test(x, y, var.equal = FALSE)

# One-sided tests
t.test(x, y, alternative = "greater")
t.test(x, y, alternative = "less")

# Extract components
result <- t.test(x, y)
result$p.value
result$conf.int
result$estimate
```

### ANOVA

```r
# One-way ANOVA
model <- aov(response ~ group, data = data)
summary(model)

# Check assumptions
plot(model)
shapiro.test(residuals(model))  # Normality
bartlett.test(response ~ group, data = data)  # Homogeneity of variance

# Post-hoc tests
TukeyHSD(model)
plot(TukeyHSD(model))

# Two-way ANOVA
model <- aov(response ~ factor1 * factor2, data = data)
summary(model)

# Type II/III sums of squares
library(car)
Anova(model, type = "II")
```

### Non-Parametric Tests

```r
# Mann-Whitney U (Wilcoxon rank-sum)
wilcox.test(x, y)

# Wilcoxon signed-rank (paired)
wilcox.test(x, y, paired = TRUE)

# Kruskal-Wallis (one-way ANOVA alternative)
kruskal.test(response ~ group, data = data)

# Post-hoc for Kruskal-Wallis
library(FSA)
dunnTest(response ~ group, data = data, method = "bonferroni")

# Friedman test (repeated measures)
friedman.test(response ~ condition | subject, data = data)
```

### Chi-Square Tests

```r
# Chi-square test of independence
cont_table <- table(data$var1, data$var2)
chisq.test(cont_table)

# With Yates' continuity correction
chisq.test(cont_table, correct = TRUE)

# Fisher's exact test (small samples)
fisher.test(cont_table)

# Goodness-of-fit
observed <- c(25, 30, 45)
expected_prop <- c(0.25, 0.25, 0.50)
chisq.test(observed, p = expected_prop)
```

### Correlation Tests

```r
# Pearson correlation
cor.test(x, y, method = "pearson")

# Spearman rank correlation
cor.test(x, y, method = "spearman")

# Kendall's tau
cor.test(x, y, method = "kendall")

# Multiple correlations
library(corrplot)
cor_matrix <- cor(data |> select(where(is.numeric)))
corrplot(cor_matrix, method = "circle")

# Test all correlations
library(psych)
corr.test(data |> select(where(is.numeric)))
```

## Mixed Effects Models

### Linear Mixed Models

```r
library(lme4)

# Random intercept
model <- lmer(y ~ x1 + x2 + (1 | group), data = data)

# Random slope
model <- lmer(y ~ x1 + x2 + (x1 | group), data = data)

# Random intercept and slope
model <- lmer(y ~ x1 + x2 + (1 + x1 | group), data = data)

# Summary
summary(model)

# Fixed effects with p-values
library(lmerTest)
model <- lmer(y ~ x1 + x2 + (1 | group), data = data)
summary(model)

# Random effects
ranef(model)
coef(model)

# Predictions
predict(model, newdata = new_data)

# Model comparison
model1 <- lmer(y ~ x1 + (1 | group), data = data)
model2 <- lmer(y ~ x1 + x2 + (1 | group), data = data)
anova(model1, model2)
```

### Generalized Linear Mixed Models

```r
# Logistic mixed model
model <- glmer(outcome ~ x1 + x2 + (1 | group),
               data = data, family = binomial)

# Poisson mixed model
model <- glmer(count ~ x1 + x2 + (1 | group),
               data = data, family = poisson)
```

## Survival Analysis

```r
library(survival)

# Create survival object
surv_obj <- Surv(time = data$time, event = data$event)

# Kaplan-Meier estimator
km_fit <- survfit(surv_obj ~ group, data = data)
plot(km_fit, xlab = "Time", ylab = "Survival Probability")

# Log-rank test
survdiff(surv_obj ~ group, data = data)

# Cox proportional hazards
cox_model <- coxph(surv_obj ~ age + treatment, data = data)
summary(cox_model)

# Hazard ratios
exp(coef(cox_model))
exp(confint(cox_model))

# Check proportional hazards assumption
cox.zph(cox_model)
```

## Regularization

### Ridge, Lasso, Elastic Net

```r
library(glmnet)

# Prepare data
x <- model.matrix(y ~ . - 1, data = train)
y <- train$y

# Ridge (alpha = 0)
ridge_model <- glmnet(x, y, alpha = 0)
plot(ridge_model, xvar = "lambda")

# Lasso (alpha = 1)
lasso_model <- glmnet(x, y, alpha = 1)
plot(lasso_model, xvar = "lambda")

# Elastic net (0 < alpha < 1)
enet_model <- glmnet(x, y, alpha = 0.5)

# Cross-validation to choose lambda
cv_model <- cv.glmnet(x, y, alpha = 1)
plot(cv_model)
best_lambda <- cv_model$lambda.min
best_lambda_1se <- cv_model$lambda.1se

# Fit with best lambda
final_model <- glmnet(x, y, alpha = 1, lambda = best_lambda)
coef(final_model)

# Predictions
x_test <- model.matrix(y ~ . - 1, data = test)
predictions <- predict(final_model, newx = x_test)
```

## Model Interpretation

### Coefficient Interpretation

```r
# Linear regression: β = change in y for 1-unit change in x
# Logistic: exp(β) = odds ratio for 1-unit change in x
# Log-transformed y: % change in y = 100 * (exp(β) - 1)
# Log-transformed x: change in y = β * log(change in x)

# Standardized coefficients (compare effect sizes)
library(effectsize)
standardize_parameters(model)

# Marginal effects
library(marginaleffects)
avg_slopes(model)
```

### Prediction Intervals

```r
# Linear model
predict(model, newdata = new_data, interval = "prediction", level = 0.95)

# GLM (approximate)
library(ciTools)
add_pi(data, model, alpha = 0.05)
```

### Variable Importance

```r
# For linear/GLM models
library(caret)
varImp(model)

# Permutation importance
library(vip)
vip(model, method = "permute", target = "y", metric = "rmse")
```

## Best Practices

✅ **Always check assumptions** before interpreting results
✅ **Use diagnostic plots** to identify issues
✅ **Report effect sizes** and confidence intervals, not just p-values
✅ **Standardize predictors** for comparing effects
✅ **Use robust methods** when assumptions violated
✅ **Cross-validate** for predictive performance
✅ **Consider domain knowledge** in model selection
✅ **Check for influential observations**

❌ **Don't rely** solely on p-values
❌ **Don't ignore** assumption violations
❌ **Don't overfit** with too many predictors
❌ **Don't forget** to check multicollinearity
❌ **Don't use** stepwise selection blindly

## Quick Reference

| Task | Function |
|------|----------|
| Linear regression | `lm(y ~ x, data)` |
| Logistic regression | `glm(y ~ x, data, family = binomial)` |
| Poisson regression | `glm(y ~ x, data, family = poisson)` |
| ANOVA | `aov(y ~ group, data)` |
| Mixed model | `lmer(y ~ x + (1\|group), data)` |
| Regularized | `glmnet(x, y, alpha = 1)` |
| Diagnostics | `plot(model)` |
| Tidy output | `broom::tidy(model)` |
| Predictions | `predict(model, newdata)` |

---

**Remember**: Statistical significance (p < 0.05) doesn't equal practical significance. Always consider effect sizes and domain context.
