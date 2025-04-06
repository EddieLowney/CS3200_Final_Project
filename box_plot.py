#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Apr  6 12:10:46 2025

@author: Lena
"""
import pandas as pd
import matplotlib.pyplot as plt

# Load the datasets
df = pd.read_csv("StormEvents_details-ftp_v1.0_d2020_c20240620.csv")

# Convert 
df['BEGIN_TIME'] = df['BEGIN_TIME'].astype(str).str.zfill(4)
df['END_TIME'] = df['END_TIME'].astype(str).str.zfill(4)

# Extract 
df['BEGIN_HOUR'] = df['BEGIN_TIME'].str[:2].astype(int)
df['BEGIN_MINUTE'] = df['BEGIN_TIME'].str[2:].astype(int)
df['END_HOUR'] = df['END_TIME'].str[:2].astype(int)
df['END_MINUTE'] = df['END_TIME'].str[2:].astype(int)

# Calculate 
df['DURATION_MINUTES'] = (df['END_HOUR'] * 60 + df['END_MINUTE']) - (df['BEGIN_HOUR'] * 60 + df['BEGIN_MINUTE'])

# Remove negative 
df_valid = df[df['DURATION_MINUTES'] >= 0]

# Group valid 
grouped = df_valid.groupby('EVENT_TYPE')['DURATION_MINUTES'].apply(list)

# Filter 
grouped = grouped[grouped.apply(len) >= 30]

# Sort 
medians = []
for durations in grouped.values:
    series = pd.Series(durations)
    medians.append(series.median())

sorted_indices = sorted(range(len(medians)))
sorted_grouped = grouped.iloc[sorted_indices]

# Plot 
plt.figure(figsize=(20, 10))
plt.boxplot(grouped.values, vert=True, patch_artist=True)
plt.xticks(range(1, len(grouped) + 1), grouped.index, rotation=90)
plt.ylabel('Duration (minutes)')
plt.title('Storm Durations Grouped by Event Type')
plt.grid(True)
plt.show()

