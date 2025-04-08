import mysql.connector
import matplotlib.pyplot as plt

# Step 1: Connect to the database
connection = mysql.connector.connect(
    host='localhost',
    user='root',
    password='Colon0125',
    database='storm'
)

# Step 2: Query the results from the `avg_losses_by_magnitude` table
cursor = connection.cursor()

# Fetch data for plotting
cursor.execute("SELECT magnitude, average_property_loss, average_crop_loss, average_total_loss FROM avg_losses_by_magnitude")
data = cursor.fetchall()

# Close the cursor and connection
cursor.close()
connection.close()

# Step 3: Prepare the data for plotting
magnitudes = [row[0] for row in data]
avg_property_loss = [row[1] for row in data]
avg_crop_loss = [row[2] for row in data]
avg_total_loss = [row[3] for row in data]

# Step 4: Create the bar plot
fig, ax = plt.subplots(figsize=(10, 6))

# Plot each loss type
bar_width = 0.2
index = range(len(magnitudes))

ax.bar(index, avg_property_loss, bar_width, label='Property Loss', color='b')
ax.bar([i + bar_width for i in index], avg_crop_loss, bar_width, label='Crop Loss', color='g')
ax.bar([i + 2*bar_width for i in index], avg_total_loss, bar_width, label='Total Loss', color='r')

# Step 5: Customize the plot
ax.set_xlabel('Storm Magnitude')
ax.set_ylabel('Average Loss ($)')
ax.set_title('Average Losses by Storm Magnitude')
ax.set_xticks([i + bar_width for i in index])
ax.set_xticklabels(magnitudes)
ax.legend()

# Step 6: Show the plot
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
