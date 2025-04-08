import mysql.connector
import pandas as pd
import matplotlib.pyplot as plt

'''
Retrieves storm event durations from a MySQL database and visualizes 
them by event type using a box plot.
'''

# Connect to MySQL
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Colon0125",
    database="storm"
)

query = "SELECT EVENT_TYPE, BEGIN_DATE_TIME, END_DATE_TIME FROM events"

df = pd.read_sql(query, conn)

# Convert to datetime
df['BEGIN_DATE_TIME'] = pd.to_datetime(df['BEGIN_DATE_TIME'], errors='coerce')
df['END_DATE_TIME'] = pd.to_datetime(df['END_DATE_TIME'], errors='coerce')

# Drop rows where conversion failed
df = df.dropna(subset=['BEGIN_DATE_TIME', 'END_DATE_TIME'])

# Calculate duration in minutes
df['DURATION_MINUTES'] = (df['END_DATE_TIME'] - df['BEGIN_DATE_TIME']).dt.total_seconds() / 60

# Filter out negative durations
df_valid = df[df['DURATION_MINUTES'] >= 0]

# Group by event type, only include types with >= 30 events
grouped = df_valid.groupby('EVENT_TYPE')['DURATION_MINUTES'].apply(list)
grouped = grouped[grouped.apply(len) >= 30]

# Plot
plt.figure(figsize=(20, 10))
plt.boxplot(grouped.values, vert=True, patch_artist=True)
plt.xticks(range(1, len(grouped) + 1), grouped.index, rotation=90)
plt.ylabel('Duration (minutes)')
plt.title('Storm Durations Grouped by Event Type')
plt.grid(True)
plt.tight_layout()
plt.show()

conn.close()
