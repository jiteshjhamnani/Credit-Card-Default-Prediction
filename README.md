# Credit Card Default Prediction

Predicting whether a credit card customer will default on their payment next month, using their demographic profile, billing history, and repayment behavior.

## Problem Statement

Banks issue credit cards and record repayment behavior every month. Misjudging a risky customer as safe leads to bad debt, while misjudging a reliable customer as risky means turning away good business. This project builds a classification model that flags customers likely to default on their next payment, so that risk teams can act on it before the fact rather than after.

## Dataset

- **Source:** [Default of Credit Card Clients](https://archive.ics.uci.edu/dataset/350/default+of+credit+card+clients), UCI Machine Learning Repository (also available on [Kaggle](https://www.kaggle.com/datasets/uciml/default-of-credit-card-clients-dataset))
- **Size:** 30,000 customers, 24 original attributes
- **Target:** `default payment next month` — 1 if the customer defaulted, 0 otherwise
- **Class balance:** 77.9% did not default vs. 22.1% did — a real-world, imbalanced classification problem
- **Features:** credit limit, sex, education, marital status, age, 6 months of repayment status, 6 months of bill amounts, and 6 months of payment amounts (April–September 2005, Taiwan)

## Approach

The project follows a standard two-stage workflow, split across two notebooks.

### 1. Exploratory Data Analysis — [`notebooks/01_EDA.ipynb`](notebooks/01_EDA.ipynb)

- Checked for missing values and duplicates (none found)
- Studied the target distribution, numerical/categorical feature distributions, skewness, and outliers
- Cleaned invalid category codes in `EDUCATION` and `MARRIAGE` (e.g. undocumented 0/5/6 values folded into an "other" bucket)
- Analyzed how default rate varies with repayment history, credit utilization, and demographics
- Engineered 45 new features on top of the original 24, including:
  - **Utilization ratios** — bill amount relative to credit limit, per month, plus its average/min/max/std
  - **Payment ratios** — amount paid relative to amount billed, per month
  - **Delay statistics** — average/max/min repayment delay, count of late and seriously-late months, count of on-time months
  - **Trend features** — change in billing/payment amount from the oldest to the most recent month, recent-vs-older averages
- Saved intermediate outputs to `data/processed/clean_credit_data.csv` and `data/processed/feature_engineered_credit_data.csv`

### 2. Model Building — [`notebooks/model_building.ipynb`](notebooks/model_building.ipynb)

- Trained and compared five baseline classifiers: Logistic Regression, Decision Tree, Random Forest, XGBoost, and LightGBM
- Addressed class imbalance using **SMOTE** oversampling on the training set, and re-evaluated all models
- Ran a decision threshold sweep (0.10–0.90) on the best model to study the precision/recall trade-off, since the two error types (missing a defaulter vs. flagging a reliable customer) don't cost the same
- Used feature importance to identify the strongest predictors of default, and dropped highly correlated/redundant features (correlation > 0.90) to end up with a leaner, more stable feature set
- Compared model performance before and after this feature pruning step to confirm no drop in predictive power

### 3. SQL Database Analysis — [`sql/analysis.sql`](sql/analysis.sql)

- Extended the project by loading the cleaned credit-card dataset into a local **SQLite database** without modifying the existing ML workflow
- Created a `customers` table from `data/processed/clean_credit_data.csv` using [`sql/create_database.py`](sql/create_database.py)
- Performed SQL-based analysis on customer demographics, credit limits, billing amounts, repayment behavior, and default patterns
- Analyzed overall default rate and default distribution across education, marital status, and age
- Compared average credit limits, bill amounts, and payment amounts between defaulters and non-defaulters
- Used `CASE` statements to analyze default rates across different credit-limit categories
- Used a **CTE (Common Table Expression)** to calculate education-level default statistics
- Used the **`RANK()` window function** to rank customers by credit limit
- Added analytical queries for identifying high-credit-limit defaulters, customers with high outstanding bills, and customers whose bill amount exceeds their credit limit

## Results

**Baseline comparison** (no resampling):

| Model | Accuracy | Precision | Recall | F1 | ROC-AUC |
|---|---|---|---|---|---|
| LightGBM | 0.815 | 0.646 | 0.362 | 0.464 | 0.778 |
| Random Forest | 0.811 | 0.623 | 0.362 | 0.458 | 0.763 |
| XGBoost | 0.808 | 0.613 | 0.356 | 0.451 | 0.754 |
| Logistic Regression | 0.814 | 0.666 | 0.314 | 0.427 | 0.751 |
| Decision Tree | 0.721 | 0.376 | 0.396 | 0.386 | 0.605 |

All models start with high accuracy but low recall on the minority (default) class — expected given the 78/22 class imbalance, and the main problem SMOTE is meant to address.

**Impact of SMOTE** (recall on the default class, the metric that matters most for this problem):

| Model | Recall (before) | Recall (after SMOTE) | ROC-AUC (before) | ROC-AUC (after SMOTE) |
|---|---|---|---|---|
| Random Forest | 0.362 | **0.458** | 0.763 | 0.757 |
| XGBoost | 0.356 | 0.431 | 0.754 | 0.753 |
| LightGBM | 0.362 | 0.446 | 0.778 | 0.771 |

SMOTE trades a bit of precision and ROC-AUC for a meaningful jump in recall — catching more actual defaulters, which is the more expensive mistake to make in a credit risk setting.

**Final model:** Random Forest + SMOTE, retrained after dropping redundant/highly-correlated features:

| Metric | Score |
|---|---|
| Accuracy | 0.802 |
| Precision | 0.563 |
| Recall | 0.469 |
| F1 | 0.512 |
| F2 | 0.486 |
| ROC-AUC | 0.756 |

Feature pruning kept performance essentially unchanged (F1 0.505 → 0.512, ROC-AUC roughly flat) while cutting away 12 redundant columns — a simpler, easier-to-maintain feature set at no real cost in accuracy.

## Project Structure
