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
- Create interactive Tableau dashboards to visualize findings.
- Discuss model performance and potential business use cases.

## 🔍 Key Insights
**Python & Machine Learning Findings**
- Random Forest Classifier was trained on reduced features after feature selection (ANOVA, Chi-square, VIF, feature importance).
- Achieved strong accuracy and F1-score on training data, showing the model can effectively classify credit scores into Good, Standard, and Poor categories.
- Validation Accuracy: [78%]. See
- Top predictive features included:
`Outstanding_Debt`
`Interest_Rate`
`Credit_Mix`
`Credit_History_Age`
`Delay_from_due_date`
`Changed_Credit_Limit`
`Monthly_Inhand_Salary`
