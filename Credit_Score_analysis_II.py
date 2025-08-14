#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Aug  1 15:06:57 2025

@author: mustafajiwani
"""


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Load datasets and create an identifier to separate them after processing
train_df = pd.read_csv("/Users/mustafajiwani/Desktop/Data Analyst/Personal Projects/Credit Score Classification Project 2/Datasets/Original/train.csv")
train_df["is_train"] = True

test_df = pd.read_csv("/Users/mustafajiwani/Desktop/Data Analyst/Personal Projects/Credit Score Classification Project 2/Datasets/Original/test.csv")
test_df["is_train"] = False

# Concatenate them
df = pd.concat([train_df, test_df], ignore_index=True)

df0 = df.copy()

df.duplicated().sum()

df.info()

# Convert Credit_History_Age to months
def convert_to_months(age_str):
    if pd.isna(age_str):
        return 0
    parts = age_str.split()
    years = int(parts[0])
    months = int(parts[3])
    return years * 12 + months
# NaNs have been transformed 0 

df['Credit_History_Age'] = df['Credit_History_Age'].apply(convert_to_months)

# Feature extraction from Payment_Behaviour
df = df[df['Payment_Behaviour'] != '!@9#%8']  
df[['Spending_Level', 'Payment_Value']] = df['Payment_Behaviour'].str.split('_', n=1, expand=True)
df['Payment_Value'] = df['Payment_Value'].str.extract(r'spent_(.*)_value')[0]

# Convert the 'Month' column to datetime, specifying the format
df['Month'] = pd.to_datetime(df['Month'], format='%B', errors='coerce')
df['Month'] = df['Month'].dt.month

# Drop unnecessary columns
df.drop(columns = ['ID', 'Customer_ID', 'Name', 'SSN', 'Payment_Behaviour', 'Type_of_Loan'], inplace=True)

# List of columns to convert to numeric
numeric_cols = [
    'Age', 'Annual_Income', 'Num_of_Loan', 'Changed_Credit_Limit', 'Num_of_Delayed_Payment',
    'Outstanding_Debt', 'Amount_invested_monthly', 'Monthly_Balance'
]

# Convert to numeric, force errors to NaN if parsing fails
for col in numeric_cols:
    df[col] = pd.to_numeric(df[col], errors='coerce')
    
# Filling missing values for numeric columns
missing_numeric_values = df.select_dtypes(include=['int64', 'float64']).columns
for col in missing_numeric_values:
    df[col] = df[col].fillna(df[col].median())

df.isnull().sum()

# Remove vague and insignifant data
df = df[df["Credit_History_Age"] != 0]
df = df[df['Occupation'] != '_______']
df = df[df['Credit_Mix'] != '_']

df.shape

## Save the cleaned DataFrame to a new CSV file
df.to_csv('cleaned_credit_score_data.csv', index=False)

description = df.describe(include='all')

# Check all numerical columns for negative values
for col in df.select_dtypes(include=['int64', 'float64']).columns:
    negatives = df[df[col] < 0]
    if not negatives.empty:
        print(f"\n🔍 Column '{col}' has {len(negatives)} negative values.")
        print(negatives.head())

# Check for impossible ranges in numerical columns
for col in df.select_dtypes(include=['int64', 'float64']).columns:
    print(f"\n🔍 Column '{col}' - Min: {df[col].min()}, Max: {df[col].max()}")

# Cleanup negative or weird numerical value 

# Age cannot be negative or unrealistically high (>120)
df['Age'] = df['Age'].apply(lambda x: x if 0 <= x <= 120 else None)

# Num_Bank_Accounts should not be negative
df['Num_Bank_Accounts'] = df['Num_Bank_Accounts'].apply(lambda x: x if x>=0 else None)

# Num_of_Loan should not be negative
df['Num_of_Loan'] = df['Num_of_Loan'].apply(lambda x: x if x>=0 else None)

# Delay_from_due_date has negative values but negative might indicate early payment, so we leave this for now

# Num_of_Delayed_Payment should not be negative
df['Num_of_Delayed_Payment'] = df['Num_of_Delayed_Payment'].apply(lambda x: x if x>=0 else None)

# Changed_Credit_Limit has negative values, and it can be negative (indicates reduction)

print('Null Values After Cleanup:')
print(df.isna().sum())

df.to_csv('cleaned_credit_score_data_v2.csv', index=False)

# Plotting histograms for numerical columns separately
def plot_and_store_histograms(df, cols):
    for col in cols:
        plt.figure(figsize=(6,4))
        df[col].hist(bins=20, color='skyblue', edgecolor='black')
        plt.title(col)
        plt.grid(False)
        plt.show()

numerical_cols = df.select_dtypes(include=['int64', 'float64']).columns
plot_and_store_histograms(df, numerical_cols)

# Plotting boxplots for numerical columns separately
def plot_and_store_boxplots(df, cols):
    for col in cols:
        plt.figure(figsize=(6,4))
        sns.boxplot(x=df[col], color='coral')
        plt.title(f"Boxplot of {col}")
        plt.grid(False)
        plt.show()
        
plot_and_store_boxplots(df, numerical_cols)

# Countplot for categorical columns
def plot_and_store_countplots(df, cols):
    for col in cols:
        plt.figure(figsize=(8, 5))
        sns.countplot(y=df[col], palette='Set2')
        plt.title(f"Count Plot of {col}")
        plt.grid(False)
        plt.tight_layout()
        plt.show()

categorical_cols = df.select_dtypes(include=['object']).columns
plot_and_store_countplots(df, categorical_cols)

# Filling missing values
df['Age'].fillna(df['Age'].median(), inplace=True)
df['Num_Bank_Accounts'].fillna(df['Num_Bank_Accounts'].mode()[0], inplace=True)
df['Num_of_Loan'].fillna(df['Num_of_Loan'].median(), inplace=True)
df['Num_of_Delayed_Payment'].fillna(df['Num_of_Delayed_Payment'].median(), inplace=True)

df.isnull().sum()

df.to_csv('cleaned_credit_score_data_v3.csv', index=False)

# Making a copy for cleaned training dataset
train_df1 = df[df['is_train'] == True].copy()

# Plotting histogram, and boxplot for numerical values in training dataset
numerical_cols1 = train_df1.select_dtypes(include=['int64', 'float64']).columns
plot_and_store_histograms(train_df1, numerical_cols1)

plot_and_store_boxplots(train_df1, numerical_cols1)

# Plotting countplot for categorical values in training dataset
categorical_cols1 = train_df1.select_dtypes(include=['object']).columns
plot_and_store_countplots(train_df1, categorical_cols1)

# Conducting ANOVA F-Test for correlation between independent numerical variables and target categorical variable
# And Chi square test for correlation between independent categorical variables and target categorical variable

from sklearn.feature_selection import f_classif, chi2
from sklearn.preprocessing import LabelEncoder

# Separate numerical and categorical columns
num_cols2 = train_df1.select_dtypes(include=['int64', 'float64']).columns.drop('Credit_Score', errors='ignore')
cat_cols2 = train_df1.select_dtypes(include=['object']).columns.drop('Credit_Score', errors='ignore')

# For f_classif (Numerical predictors)
X_num = train_df1[num_cols2]
y = train_df1['Credit_Score']

# Encoding y
le = LabelEncoder()
y_encoded = le.fit_transform(y)

f_scores, p_vals = f_classif(X_num, y_encoded)
pd.DataFrame({'Feature': num_cols2, 'F_Score': f_scores, 'p_value': p_vals}).sort_values(by='F_Score', ascending=False)

from sklearn.preprocessing import OrdinalEncoder

X_cat = train_df1[cat_cols2]
X_cat_encoded = OrdinalEncoder().fit_transform(X_cat)

chi2_scores, p_vals_cat = chi2(X_cat_encoded, y_encoded)
pd.DataFrame({'Feature': cat_cols2, 'Chi2 Scores': chi2_scores, 'p-value': p_vals_cat}).sort_values(by='Chi2 Scores', ascending=False)

# Calculate correlation matrix
corr_matrix = train_df1[numerical_cols1].corr()
# Plot heatmap
plt.figure(figsize=(12,10))
sns.heatmap(corr_matrix, annot=True, fmt=".2f", cmap='coolwarm', square=True)
plt.title("Correlation Heatmap of Numerical Features")
plt.show()

# Further multicollinearity check through VIF (Variance Inflation Factor)

from statsmodels.stats.outliers_influence import variance_inflation_factor
from sklearn.preprocessing import StandardScaler

# Standarizing the features

scaler = StandardScaler()
X_scaled = pd.DataFrame(scaler.fit_transform(X_num), columns=X_num.columns)

# Computing VIF for each feature
vif_data = pd.DataFrame()
vif_data['Feature'] = X_scaled.columns
vif_data['VIF'] = [variance_inflation_factor(X_scaled.values, i) for i in range(X_scaled.shape[1])]
vif_data.sort_values(by='VIF', ascending=False)

# VIF scores are <5 so no significant multicollinearity exists

# Running feature importance using Random Forest Classifier

from sklearn.ensemble import RandomForestClassifier

# Transforming ordinal encoded categorical values from an array to a dataframe
encoded_cat_col_names = ['Credit_Mix_encoded', 'Payment_of_Min_Amount_encoded', 'Payment_Value_encoded', 'Spending_Level_encoded', 'Occupation_encoded']
X_cat_encoded_df = pd.DataFrame(X_cat_encoded, columns=encoded_cat_col_names)

# Joining numercial variables dataframe and encoded categorical dataframe
X = pd.concat([X_num.reset_index(drop=True), X_cat_encoded_df.reset_index(drop=True)], axis=1)

# y already is defined as target variable

# Initialize and train the Random Forest
rf = RandomForestClassifier(random_state=42, n_estimators=100)
rf.fit(X,y)

# Get feature importances
importances = rf.feature_importances_
feat_imp_df = pd.DataFrame({'Feature': X.columns, 'Importance': importances}).sort_values(by='Importance', ascending=False)

print(feat_imp_df)

# Further steps:
    # Dropping features with importance less than 0.29
    # Making sure test dataset is also cleaned and encoded
    # Training an appropriate model using train dataset, and make prediction on test dataset

important_features = [
                      'Outstanding_Debt', 'Interest_Rate', 'Payment_of_Min_Amount_encoded',
                      'Credit_History_Age', 'Delay_from_due_date', 'Changed_Credit_Limit',
                      'Monthly_Balance', 'Amount_invested_monthly', 'Annual_Income',
                      'Total_EMI_per_month', 'Num_Credit_Inquiries', 'Credit_Utilization_Ratio',
                      'Num_Credit_Card', 'Monthly_Inhand_Salary', 'Age', 'Num_of_Delayed_Payment',
                      'Num_Bank_Accounts', 'Month', 'Credit_Mix_encoded'
                      ]









