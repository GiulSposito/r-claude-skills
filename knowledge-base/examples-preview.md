# R Data Science Super Skill - Examples Preview

## Example 1: Complete EDA - Palmer Penguins

```r
# Complete Exploratory Data Analysis Example
# Dataset: Palmer Penguins
# Goal: Understand penguin characteristics and species differences

library(tidyverse)
library(palmerpenguins)
library(naniar)
library(corrplot)
library(GGally)

# 1. LOAD AND INSPECT ----
data("penguins")
glimpse(penguins)

# Dimensions
cat("Dataset dimensions:", nrow(penguins), "rows x", ncol(penguins), "columns\n")

# 2. DATA QUALITY ----
# Missing values
penguins %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "missing") %>%
  filter(missing > 0) %>%
  mutate(pct = missing / nrow(penguins) * 100)

# Visualize missing
vis_miss(penguins)

# Handle missing (complete case analysis for this example)
penguins_clean <- penguins %>% drop_na()

# 3. UNIVARIATE ANALYSIS ----

# Numeric variables
penguins_clean %>%
  select(where(is.numeric)) %>%
  summary()

# Distribution plots
penguins_clean %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything()) %>%
  ggplot(aes(x = value)) +
  geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7) +
  facet_wrap(~name, scales = "free") +
  theme_minimal() +
  labs(title = "Distribution of Numeric Variables")

# Categorical variables
penguins_clean %>%
  count(species) %>%
  ggplot(aes(x = species, y = n, fill = species)) +
  geom_col() +
  geom_text(aes(label = n), vjust = -0.5) +
  theme_minimal() +
  labs(title = "Penguin Species Distribution", y = "Count")

penguins_clean %>%
  count(island, species) %>%
  ggplot(aes(x = island, y = n, fill = species)) +
  geom_col(position = "dodge") +
  theme_minimal() +
  labs(title = "Species Distribution by Island")

# 4. BIVARIATE ANALYSIS ----

# Numeric vs Numeric
penguins_clean %>%
  ggplot(aes(x = bill_length_mm, y = bill_depth_mm, color = species)) +
  geom_point(size = 3, alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal() +
  labs(title = "Bill Dimensions by Species")

penguins_clean %>%
  ggplot(aes(x = flipper_length_mm, y = body_mass_g, color = species)) +
  geom_point(size = 3, alpha = 0.7) +
  geom_smooth(method = "lm") +
  theme_minimal() +
  labs(title = "Flipper Length vs Body Mass")

# Numeric vs Categorical
penguins_clean %>%
  ggplot(aes(x = species, y = body_mass_g, fill = species)) +
  geom_violin(alpha = 0.7) +
  geom_boxplot(width = 0.2, fill = "white") +
  theme_minimal() +
  labs(title = "Body Mass Distribution by Species")

penguins_clean %>%
  ggplot(aes(x = body_mass_g, fill = sex)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~species) +
  theme_minimal() +
  labs(title = "Body Mass by Species and Sex")

# 5. MULTIVARIATE ANALYSIS ----

# Correlation matrix
penguins_clean %>%
  select(where(is.numeric)) %>%
  cor() %>%
  corrplot(method = "circle", type = "upper",
           addCoef.col = "black", number.cex = 0.7)

# Pairwise plots with grouping
penguins_clean %>%
  select(species, bill_length_mm, bill_depth_mm, flipper_length_mm, body_mass_g) %>%
  ggpairs(aes(color = species, alpha = 0.5),
          upper = list(continuous = "points"),
          lower = list(continuous = "smooth"))

# PCA for dimensionality overview
pca_result <- penguins_clean %>%
  select(where(is.numeric)) %>%
  prcomp(scale. = TRUE)

pca_data <- pca_result %>%
  broom::augment(penguins_clean)

# PCA biplot
pca_data %>%
  ggplot(aes(x = .fittedPC1, y = .fittedPC2, color = species)) +
  geom_point(size = 3, alpha = 0.7) +
  stat_ellipse() +
  theme_minimal() +
  labs(title = "PCA: First Two Principal Components",
       x = paste0("PC1 (", round(summary(pca_result)$importance[2,1]*100, 1), "%)"),
       y = paste0("PC2 (", round(summary(pca_result)$importance[2,2]*100, 1), "%)"))

# 6. KEY INSIGHTS ----

# Statistical tests
# ANOVA for body mass across species
aov_result <- aov(body_mass_g ~ species, data = penguins_clean)
summary(aov_result)

# Pairwise t-tests
pairwise.t.test(penguins_clean$body_mass_g, penguins_clean$species,
                p.adjust.method = "bonferroni")

# Effect of sex on body mass
penguins_clean %>%
  group_by(species, sex) %>%
  summarise(
    mean_mass = mean(body_mass_g),
    sd_mass = sd(body_mass_g),
    n = n(),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = species, y = mean_mass, fill = sex)) +
  geom_col(position = "dodge") +
  geom_errorbar(aes(ymin = mean_mass - sd_mass, ymax = mean_mass + sd_mass),
                position = position_dodge(0.9), width = 0.2) +
  theme_minimal() +
  labs(title = "Mean Body Mass by Species and Sex", y = "Body Mass (g)")

# FINDINGS:
# 1. Three distinct species with clear morphological differences
# 2. Strong positive correlation between flipper length and body mass
# 3. Gentoo penguins are largest (higher body mass and flipper length)
# 4. Adelie penguins have deeper bills relative to length
# 5. Sexual dimorphism present in all species (males larger)
# 6. Species are found on different islands (some overlap)
# 7. Bill dimensions separate species well (potential for classification)
# 8. Missing data primarily in sex variable (could be imputed or excluded)

# NEXT STEPS:
# - Build classification model to predict species
# - Investigate sex prediction using morphological features
# - Analyze temporal trends if year is relevant
# - Consider mixed-effects models accounting for island
```

## Example 2: Predictive Modeling - House Prices

```r
# Complete Machine Learning Workflow
# Dataset: House Prices (simulated Ames-like data)
# Goal: Predict house sale prices

library(tidymodels)
library(tidyverse)
library(vip)
library(doParallel)

# Setup parallel processing
registerDoParallel(cores = parallel::detectCores() - 1)

# 1. PROBLEM DEFINITION ----
# Task: Regression (predict SalePrice)
# Metric: RMSE, MAE, R²
# Goal: Accurate price predictions for real estate valuation

# 2. DATA PREPARATION ----
# Assume we have house_data loaded
set.seed(123)

# Initial split
data_split <- initial_split(house_data, prop = 0.8, strata = SalePrice)
train_data <- training(data_split)
test_data <- testing(data_split)

cat("Training samples:", nrow(train_data), "\n")
cat("Testing samples:", nrow(test_data), "\n")

# 3. FEATURE ENGINEERING ----
house_recipe <- recipe(SalePrice ~ ., data = train_data) %>%
  # Imputation
  step_impute_median(all_numeric_predictors()) %>%
  step_impute_mode(all_nominal_predictors()) %>%
  # Feature engineering
  step_log(SalePrice, base = 10) %>%  # Log transform target
  step_mutate(
    Age = YrSold - YearBuilt,
    IsRemodeled = if_else(YearRemodAdd != YearBuilt, 1, 0),
    TotalBath = FullBath + 0.5 * HalfBath,
    TotalSF = GrLivArea + TotalBsmtSF
  ) %>%
  # Handle rare categories
  step_other(all_nominal_predictors(), threshold = 0.05) %>%
  # Create dummy variables
  step_dummy(all_nominal_predictors()) %>%
  # Remove zero variance
  step_zv(all_predictors()) %>%
  # Remove highly correlated features
  step_corr(all_numeric_predictors(), threshold = 0.9) %>%
  # Normalize
  step_normalize(all_numeric_predictors())

# Check recipe
house_recipe %>%
  prep() %>%
  bake(new_data = NULL) %>%
  glimpse()

# 4. MODEL SPECIFICATIONS ----

# Linear regression baseline
lm_spec <- linear_reg() %>%
  set_engine("lm") %>%
  set_mode("regression")

# Ridge regression
ridge_spec <- linear_reg(penalty = tune(), mixture = 0) %>%
  set_engine("glmnet") %>%
  set_mode("regression")

# Lasso regression
lasso_spec <- linear_reg(penalty = tune(), mixture = 1) %>%
  set_engine("glmnet") %>%
  set_mode("regression")

# Random forest
rf_spec <- rand_forest(
  mtry = tune(),
  trees = 500,
  min_n = tune()
) %>%
  set_engine("ranger", importance = "impurity") %>%
  set_mode("regression")

# XGBoost
xgb_spec <- boost_tree(
  trees = tune(),
  tree_depth = tune(),
  learn_rate = tune(),
  loss_reduction = tune()
) %>%
  set_engine("xgboost") %>%
  set_mode("regression")

# 5. WORKFLOWS ----
lm_wf <- workflow() %>% add_recipe(house_recipe) %>% add_model(lm_spec)
ridge_wf <- workflow() %>% add_recipe(house_recipe) %>% add_model(ridge_spec)
lasso_wf <- workflow() %>% add_recipe(house_recipe) %>% add_model(lasso_spec)
rf_wf <- workflow() %>% add_recipe(house_recipe) %>% add_model(rf_spec)
xgb_wf <- workflow() %>% add_recipe(house_recipe) %>% add_model(xgb_spec)

# 6. RESAMPLING ----
set.seed(456)
folds <- vfold_cv(train_data, v = 10, strata = SalePrice)

# 7. HYPERPARAMETER TUNING ----

# Fit baseline (no tuning)
lm_fit <- lm_wf %>% fit_resamples(folds)

# Tune ridge
ridge_grid <- grid_regular(penalty(range = c(-5, 5)), levels = 50)
ridge_tune <- ridge_wf %>% tune_grid(folds, grid = ridge_grid)

# Tune lasso
lasso_grid <- grid_regular(penalty(range = c(-5, 5)), levels = 50)
lasso_tune <- lasso_wf %>% tune_grid(folds, grid = lasso_grid)

# Tune random forest
rf_grid <- grid_regular(
  mtry(range = c(5, 30)),
  min_n(range = c(2, 20)),
  levels = 5
)
rf_tune <- rf_wf %>% tune_grid(folds, grid = rf_grid)

# Tune XGBoost
xgb_grid <- grid_latin_hypercube(
  trees(range = c(100, 1000)),
  tree_depth(range = c(3, 10)),
  learn_rate(range = c(-3, -1)),
  loss_reduction(range = c(-5, -1)),
  size = 20
)
xgb_tune <- xgb_wf %>% tune_grid(folds, grid = xgb_grid)

# 8. MODEL EVALUATION ----

# Compare models
results <- bind_rows(
  lm_fit %>% collect_metrics() %>% mutate(model = "Linear Regression"),
  ridge_tune %>% show_best("rmse", n = 1) %>% mutate(model = "Ridge"),
  lasso_tune %>% show_best("rmse", n = 1) %>% mutate(model = "Lasso"),
  rf_tune %>% show_best("rmse", n = 1) %>% mutate(model = "Random Forest"),
  xgb_tune %>% show_best("rmse", n = 1) %>% mutate(model = "XGBoost")
) %>%
  filter(.metric == "rmse") %>%
  arrange(mean)

print(results)

# Visualize tuning results for best model (e.g., XGBoost)
autoplot(xgb_tune)

# Select best XGBoost model
best_xgb <- xgb_tune %>% select_best("rmse")
final_xgb_wf <- xgb_wf %>% finalize_workflow(best_xgb)

# 9. FINAL MODEL ----
final_fit <- final_xgb_wf %>% last_fit(data_split)

# Test set performance
final_fit %>% collect_metrics()

# Predictions
predictions <- final_fit %>% collect_predictions()

# Prediction plot
predictions %>%
  ggplot(aes(x = 10^SalePrice, y = 10^.pred)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "red") +
  geom_point(alpha = 0.5) +
  scale_x_log10(labels = scales::dollar) +
  scale_y_log10(labels = scales::dollar) +
  theme_minimal() +
  labs(title = "Predicted vs Actual House Prices",
       x = "Actual Price", y = "Predicted Price")

# Residual plot
predictions %>%
  mutate(residual = SalePrice - .pred) %>%
  ggplot(aes(x = 10^.pred, y = residual)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  geom_point(alpha = 0.5) +
  geom_smooth(se = TRUE) +
  scale_x_log10(labels = scales::dollar) +
  theme_minimal() +
  labs(title = "Residual Plot", x = "Predicted Price", y = "Residuals")

# 10. MODEL INTERPRETATION ----
final_model <- final_fit %>% extract_fit_parsnip()

# Variable importance
vip(final_model, num_features = 20)

# Save model
saveRDS(final_xgb_wf, "final_house_price_model.rds")

# RESULTS:
# - Best model: XGBoost with RMSE = $X, R² = 0.XX
# - Key predictors: OverallQual, TotalSF, GrLivArea, Age
# - Model explains XX% of variance in house prices
# - Feature engineering (TotalSF, Age) improved performance
# - Ready for production deployment
```

## Example 3: Time Series Forecasting - Retail Sales

```r
# Complete Time Series Forecasting Example
# Dataset: Retail sales data
# Goal: Forecast next 12 months of sales

library(fpp3)
library(tidyverse)

# 1. DATA PREPARATION ----
# Assume retail_data has Date and Sales columns
retail_ts <- retail_data %>%
  mutate(Month = yearmonth(Date)) %>%
  as_tsibble(index = Month) %>%
  select(Month, Sales)

# Check for gaps
scan_gaps(retail_ts)

# 2. VISUALIZATION AND EXPLORATION ----
# Time plot
retail_ts %>%
  autoplot(Sales) +
  labs(title = "Monthly Retail Sales", y = "Sales ($)")

# Seasonal plots
retail_ts %>%
  gg_season(Sales, labels = "both") +
  labs(title = "Seasonal Plot of Retail Sales")

retail_ts %>%
  gg_subseries(Sales) +
  labs(title = "Subseries Plot")

# ACF and PACF
retail_ts %>%
  gg_tsdisplay(Sales, plot_type = "partial")

# 3. DECOMPOSITION ----
retail_dcmp <- retail_ts %>%
  model(stl = STL(Sales))

components(retail_dcmp) %>% autoplot()

# Check strength of seasonality and trend
retail_ts %>%
  features(Sales, feat_stl)

# 4. STATIONARITY ----
# Check for differencing needed
retail_ts %>%
  features(Sales, unitroot_kpss)

retail_ts %>%
  features(Sales, unitroot_ndiffs)

# 5. MODEL SPECIFICATION ----
retail_models <- retail_ts %>%
  model(
    # Simple methods
    mean = MEAN(Sales),
    naive = NAIVE(Sales),
    snaive = SNAIVE(Sales),
    drift = RW(Sales ~ drift()),

    # Exponential smoothing
    ets_auto = ETS(Sales),
    ets_aaa = ETS(Sales ~ error("A") + trend("A") + season("A")),
    ets_mam = ETS(Sales ~ error("M") + trend("A") + season("M")),

    # ARIMA
    arima_auto = ARIMA(Sales),
    arima_manual = ARIMA(Sales ~ pdq(1,1,1) + PDQ(1,1,1)),

    # Dynamic regression (with trend and season)
    arima_reg = ARIMA(Sales ~ trend() + season()),

    # Neural network
    nnetar = NNETAR(Sales)
  )

# 6. MODEL DIAGNOSTICS ----
# Residual diagnostics for best ETS model
retail_models %>%
  select(ets_auto) %>%
  gg_tsresiduals()

# Ljung-Box test
augment(retail_models) %>%
  filter(.model == "ets_auto") %>%
  features(.innov, ljung_box, lag = 24, dof = 0)

# 7. MODEL SELECTION ----
# Training accuracy
retail_models %>%
  accuracy() %>%
  arrange(RMSE)

# Cross-validation with time series
retail_cv <- retail_ts %>%
  stretch_tsibble(.init = 36, .step = 1)

retail_cv_fit <- retail_cv %>%
  model(
    ets = ETS(Sales),
    arima = ARIMA(Sales)
  )

retail_cv_fc <- retail_cv_fit %>%
  forecast(h = 12)

retail_cv_fc %>%
  accuracy(retail_ts) %>%
  arrange(RMSE)

# 8. FORECASTING ----
# Generate 12-month forecast
retail_fc <- retail_models %>%
  forecast(h = 12)

# Visualize forecasts
retail_fc %>%
  autoplot(retail_ts, level = c(80, 95)) +
  facet_wrap(~.model, ncol = 3) +
  labs(title = "Retail Sales Forecasts by Method")

# Focus on best models
retail_fc %>%
  filter(.model %in% c("ets_auto", "arima_auto", "nnetar")) %>%
  autoplot(retail_ts, level = 95) +
  labs(title = "12-Month Retail Sales Forecast (Best Models)")

# 9. FORECAST EVALUATION ----
# If we have test data
test_accuracy <- retail_fc %>%
  accuracy(test_data) %>%
  arrange(RMSE)

print(test_accuracy)

# Prediction intervals
retail_fc %>%
  filter(.model == "ets_auto") %>%
  hilo(level = c(80, 95)) %>%
  unpack_hilo(cols = c("80%", "95%"))

# 10. FINAL FORECAST ----
# Refit best model on full data
final_model <- retail_ts %>%
  model(best = ETS(Sales))

final_fc <- final_model %>%
  forecast(h = 12)

# Visualize with confidence bands
final_fc %>%
  autoplot(retail_ts) +
  labs(title = "Final 12-Month Retail Sales Forecast",
       y = "Sales ($)", x = "Month")

# Export forecast
final_fc %>%
  as_tibble() %>%
  select(Month, .mean, .distribution) %>%
  write_csv("retail_sales_forecast.csv")

# INSIGHTS:
# - Sales show clear seasonality (peak in December)
# - Upward trend present over time
# - ETS(M,A,M) performed best (multiplicative errors and seasonality)
# - Forecast for next 12 months: $X to $Y million
# - Uncertainty increases further into future
# - Monitor actuals monthly and refit as needed
```

## Example 4: Text Analysis - Customer Reviews

```r
# Text Mining and Sentiment Analysis
# Dataset: Customer product reviews
# Goal: Analyze sentiment and extract insights

library(tidyverse)
library(tidytext)
library(textrecipes)
library(tidymodels)
library(wordcloud)
library(topicmodels)

# 1. DATA LOADING ----
# Assume reviews_data has columns: review_id, product, rating, text
glimpse(reviews_data)

# 2. TOKENIZATION ----
# Word tokens
review_words <- reviews_data %>%
  unnest_tokens(word, text)

# Bigrams
review_bigrams <- reviews_data %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2)

# 3. TEXT CLEANING ----
# Remove stop words
review_words_clean <- review_words %>%
  anti_join(stop_words, by = "word") %>%
  filter(!str_detect(word, "\\d+"))  # Remove numbers

# Custom stop words (domain-specific)
custom_stops <- tibble(word = c("product", "amazon", "bought"))
review_words_clean <- review_words_clean %>%
  anti_join(custom_stops, by = "word")

# 4. EXPLORATORY TEXT ANALYSIS ----
# Most frequent words
review_words_clean %>%
  count(word, sort = TRUE) %>%
  slice_head(n = 20) %>%
  ggplot(aes(x = n, y = reorder(word, n))) +
  geom_col(fill = "steelblue") +
  labs(title = "Top 20 Words in Reviews", x = "Frequency", y = NULL)

# Word cloud
review_words_clean %>%
  count(word) %>%
  with(wordcloud(word, n, max.words = 100, colors = brewer.pal(8, "Dark2")))

# TF-IDF to find distinctive words
review_tfidf <- review_words_clean %>%
  count(review_id, word) %>%
  bind_tf_idf(word, review_id, n) %>%
  arrange(desc(tf_idf))

# Words by rating
review_words_clean %>%
  inner_join(reviews_data %>% select(review_id, rating), by = "review_id") %>%
  count(rating, word) %>%
  group_by(rating) %>%
  slice_max(n, n = 10) %>%
  ggplot(aes(x = n, y = reorder_within(word, n, rating), fill = factor(rating))) +
  geom_col() +
  scale_y_reordered() +
  facet_wrap(~rating, scales = "free") +
  labs(title = "Top Words by Rating", x = "Frequency", y = NULL)

# 5. SENTIMENT ANALYSIS ----
# Using AFINN lexicon
review_sentiment_afinn <- review_words_clean %>%
  inner_join(get_sentiments("afinn"), by = "word") %>%
  group_by(review_id) %>%
  summarise(sentiment_score = sum(value), .groups = "drop") %>%
  inner_join(reviews_data, by = "review_id")

# Sentiment vs rating
review_sentiment_afinn %>%
  ggplot(aes(x = rating, y = sentiment_score, group = rating)) +
  geom_boxplot(fill = "lightblue") +
  labs(title = "Sentiment Score by Rating",
       x = "Star Rating", y = "AFINN Sentiment Score")

# Using bing lexicon (positive/negative)
review_sentiment_bing <- review_words_clean %>%
  inner_join(get_sentiments("bing"), by = "word") %>%
  count(review_id, sentiment) %>%
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) %>%
  mutate(sentiment = positive - negative) %>%
  inner_join(reviews_data, by = "review_id")

# Sentiment contribution by word
review_words_clean %>%
  inner_join(get_sentiments("bing"), by = "word") %>%
  count(word, sentiment, sort = TRUE) %>%
  group_by(sentiment) %>%
  slice_head(n = 10) %>%
  ggplot(aes(x = n, y = reorder(word, n), fill = sentiment)) +
  geom_col() +
  facet_wrap(~sentiment, scales = "free") +
  labs(title = "Words Contributing to Sentiment", x = "Frequency", y = NULL)

# 6. TOPIC MODELING ----
# Create document-term matrix
review_dtm <- review_words_clean %>%
  count(review_id, word) %>%
  cast_dtm(review_id, word, n)

# LDA with 5 topics
review_lda <- LDA(review_dtm, k = 5, control = list(seed = 123))

# Extract topics
review_topics <- tidy(review_lda, matrix = "beta")

# Top terms per topic
review_topics %>%
  group_by(topic) %>%
  slice_max(beta, n = 10) %>%
  ggplot(aes(x = beta, y = reorder_within(term, beta, topic), fill = factor(topic))) +
  geom_col() +
  scale_y_reordered() +
  facet_wrap(~topic, scales = "free") +
  labs(title = "Top Terms per Topic", x = "Beta (term probability)", y = NULL)

# Assign reviews to topics
review_gamma <- tidy(review_lda, matrix = "gamma") %>%
  group_by(document) %>%
  slice_max(gamma, n = 1) %>%
  rename(review_id = document)

# 7. TEXT CLASSIFICATION ----
# Predict rating from text using tidymodels

# Prepare data
set.seed(123)
review_split <- initial_split(reviews_data, strata = rating)
review_train <- training(review_split)
review_test <- testing(review_split)

# Recipe with textrecipes
text_recipe <- recipe(rating ~ text, data = review_train) %>%
  step_tokenize(text) %>%
  step_stopwords(text) %>%
  step_tokenfilter(text, max_tokens = 500) %>%
  step_tfidf(text)

# Model specification
svm_spec <- svm_linear() %>%
  set_engine("LiblineaR") %>%
  set_mode("classification")

# Workflow
text_wf <- workflow() %>%
  add_recipe(text_recipe) %>%
  add_model(svm_spec)

# Fit and evaluate
text_fit <- text_wf %>%
  last_fit(review_split)

text_fit %>% collect_metrics()

# Confusion matrix
text_fit %>%
  collect_predictions() %>%
  conf_mat(truth = rating, estimate = .pred_class) %>%
  autoplot(type = "heatmap")

# 8. INSIGHTS ----
# Key positive words
review_words_clean %>%
  inner_join(get_sentiments("bing"), by = "word") %>%
  filter(sentiment == "positive") %>%
  count(word, sort = TRUE) %>%
  slice_head(n = 20)

# Key negative words
review_words_clean %>%
  inner_join(get_sentiments("bing"), by = "word") %>%
  filter(sentiment == "negative") %>%
  count(word, sort = TRUE) %>%
  slice_head(n = 20)

# Bigram analysis for context
review_bigrams %>%
  separate(bigram, into = c("word1", "word2"), sep = " ") %>%
  filter(word1 == "not") %>%
  count(word2, sort = TRUE) %>%
  inner_join(get_sentiments("afinn"), by = c("word2" = "word")) %>%
  mutate(contribution = n * value) %>%
  arrange(contribution)

# FINDINGS:
# - Overall sentiment aligns well with star ratings
# - Common complaints: "battery life", "poor quality", "broke quickly"
# - Common praises: "excellent", "perfect", "highly recommend"
# - 5 main topics identified: quality, price, usability, durability, customer service
# - Text classification achieves XX% accuracy in predicting ratings
# - Negation handling needed for improved sentiment accuracy
```

These examples demonstrate complete, production-ready workflows that users can adapt to their specific data and contexts.
