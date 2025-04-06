#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Apr  6 11:44:07 2025

@author: Lena
"""

import pandas as pd
import matplotlib.pyplot as plt

# Read 
fatalities_df = pd.read_csv("StormEvents_fatalities-ftp_v1.0_d2010_c20220425.csv")

# Drop rows 
filtered_df = fatalities_df.dropna(subset=["FATALITY_AGE", "FATALITY_SEX"])

# Define age 
age_bins = [0, 9, 19, 29, 39, 49, 59, 69, 79, 89, 99, 150]
age_labels = ['0-9', '10-19', '20-29', '30-39', '40-49',
              '50-59', '60-69', '70-79', '80-89', '90-99', '100+']

# Assign 
filtered_df["AGE_GROUP"] = pd.cut(filtered_df["FATALITY_AGE"], bins=age_bins, labels=age_labels, right=True)

# Group 
age_gender_counts = filtered_df.groupby(["AGE_GROUP", "FATALITY_SEX"]).size().unstack(fill_value=0)

# Plot stacked bar chart
age_gender_counts.plot(kind="bar", stacked=True)
plt.title("Fatality Counts by Age Group and Gender")
plt.xlabel("Age Group")
plt.ylabel("Number of Fatalities")
plt.legend(title="Gender")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
