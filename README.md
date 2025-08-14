# Credit Score Classification Project
A complete, reproducible workflow that goes from data cleaning and modeling in Python, to SQL-based EDA for original vs. predicted credit scores, and Tableau dashboards for executive‑level storytelling.

## Dataset
The dataset used for this project is publicly available on Kaggle:  
[Credit Score Classification Dataset] ([https://www.kaggle.com/datasets/...](https://www.kaggle.com/datasets/parisrohan/credit-score-classification))

## 🛠 Tools Used
- **Python**: For data cleaning, exploratory data analysis (EDA), and machine learning (scikit-learn, pandas, seaborn, matplotlib).
- **SQL (MySQL)**: For querying and analyzing large datasets, including joins, aggregations, and window functions.
- **Tableau**: For creating interactive visualizations and dashboards.
- **GitHub**: For version control

## 📂 Project Structure
- `Credit_data_analysis` – All SQL queries used for analysis
- `Credit_Score_analysis_II` – Python code for EDA and ML
- `Credit Score Classification and Analysis Portfolio` – Tableau workbook with all dashboards
- `dashboard_screenshots` – PNG snapshots of the Tableau dashboards
- `pythonplots` - PNG snapshots of significant python visualizations

## 📌 Project Overview
- Classify customers into credit score categories (e.g., Poor / Standard / Good). Because the public test set does not include original credit scores, we validate predictions by checking whether predicted scores in the test set preserve the same relationships seen in the train set across demographics and financial behaviors.
- This project focuses on analyzing customer financial and demographic data to classify credit scores and identify factors that influence them.
- The dataset contains features such as age, bank accounts, loans, payment history, and annual income.
- I explored the data, cleaned and prepared it, performed feature selection, and built a Random Forest Classifier to predict credit scores.
- In addition, I created Tableau dashboards to visualize key trends and patterns, providing both business insights and model interpretability.

## 🎯 Objectives
- Perform exploratory data analysis (EDA) to understand the dataset and uncover patterns.
- Handle missing values, outliers, and negative values in financial metrics.
- Engineer meaningful features for modeling.
- Reduce features using statistical tests (ANOVA, Chi-Square, VIF) and feature importance.
- Train and evaluate a Random Forest Classifier to predict credit scores.
- Analyze cleaned data in SQL in four incremental phases.
- Create interactive Tableau dashboards to visualize findings.
- Discuss model performance and potential business use cases.

## 🔍 Key Insights
### Python & Machine Learning Findings
- Random Forest Classifier was trained on reduced features after feature selection (ANOVA, Chi-square, VIF, feature importance).
- Achieved strong accuracy and F1-score on training data, showing the model can effectively classify credit scores into Good, Standard, and Poor categories.
- **Validation Accuracy**: **`78%`**. See `model_evaluation.txt` for more.
- Top predictive features included:
  
  `Outstanding_Debt`
  `Interest_Rate`
  `Credit_Mix`
  `Credit_History_Age`
  `Delay_from_due_date`
  `Changed_Credit_Limit`

### Tableau Observations

#### Demographics & Financial Profiles
  
- **Age Distribution**: Customers aged 30–40 are the largest group (34.2%), followed by 18–30 (31.8%).
- **Occupation**: Lawyers are slightly overrepresented, but other occupations are fairly balanced.
- **Income**: Majority of customers earn <50k annually (62.7%).
- **Credit Mix & Payment Behavior**: Standard credit mix dominates. Good credit mix → higher EMIs; Bad credit mix → more inquiries.
- **Credit Utilization**: Most customers fall in moderate usage (30–60%), with 36.5% in low usage (<30%).

#### Credit Score Distribution & Predictive Alignment

- **Overall**: Standard credit score is most common; distribution is preserved between train and predicted test sets.
    - Poor: 28.99% (Train) | 27.70% (Test)
    - Standard: 53.15% | 56.05%
    - Good: 17.86% | 16.25%
- **By Age**: Younger groups (10–18) have more Poor scores; 30–40 group has the highest Good scores. Train/test alignment is consistent.
- **By Occupation**: Engineers have relatively higher Poor credit proportion; Journalists have higher Good proportion.
- **By Income**: Higher income (100k–500k) → higher Good score percentage.

#### Behavioral & Risk Indicators
  
- **Repayment Delays**: Good credit scores correlate with fewer delayed payments; Poor scores correlate with more delays.
- **Spending & Debt**: Good scores → higher salary, lower debt; Poor scores → lower salary, higher debt.
- **Credit Utilization**: Majority of customers have low utilization corresponding with better scores.
- **Credit History Age**: Standard/Good score holders have 20–24 years of credit history.
- **Loan Activity**: Avg loans generally increase as credit score decreases, except a slight anomaly in predicted Good credit test set (8.28 vs 5.44 in train).
- **EMI & Investments**: Good scores → higher EMI & investments; Poor scores → lower EMI & investments.
- **High-Risk vs Low-Risk Habits**: Low-risk (Good score) customers have fewer delayed payments, fewer loans, and slightly lower credit utilization than Medium/High-risk customers.

#### Model Validation
  
- Random Forest model validated with accuracy/confusion matrix on train/validation sets.
- Side-by-side analysis in SQL + Tableau confirms behavioral patterns and distributions of predicted test set align with original train data.

**`Conclusion`**: Predicted credit scores preserve the same demographic and financial patterns as the train set, providing qualitative validation in absence of test labels.

## 🧩 How This Project Ties Together
- Python ensures clean, well‑engineered data and a validated model.
- SQL provides auditable, slice‑wise comparisons of original vs. predicted credit scores.
- Tableau communicates the findings through clear dashboards that confirm whether predictions behave like labeled data across demographics and behaviors.
- In absence of ground‑truth labels for the test set, this combined approach gives a responsible and transparent qualitative validation of predictions.
