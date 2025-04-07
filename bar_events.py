import mysql.connector
import pandas as pd
import matplotlib.pyplot as plt
# Connect to MySQL
conn = mysql.connector.connect(
    host="localhost",  # e.g. localhost or your server IP
    user="root",  # e.g. 'root'
    password="Colon0125",
    database="storm"
)

cursor = conn.cursor()

def get_storm_summary(state, year):
    state = state.upper()
    query = "CALL GetStormSummaryForStateYear(%s, %s)"
    cursor.execute(query, (state, year))
    result = cursor.fetchall()  # Get all results

    # Optionally, print out the result to check
    for row in result:
        print(row)

    return result


def get_storm_summary_df(state, year):
    result = get_storm_summary(state, year)
    # Assuming the structure: (state, total_events, total_deaths, ...)
    df = pd.DataFrame(result, columns=[
        'State', 'Total Events', 'Total Deaths', 'Total Property Damage',
        'Total Crop Damage', 'Total Fatalities', 'Counties Affected'
    ])
    
    return df



def plot_summary(df):
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    df.plot(kind="bar", x="State", y=[
        'Total Events', 'Total Deaths', 'Total Property Damage',
        'Total Crop Damage', 'Total Fatalities', 'Counties Affected'
    ], ax=ax, color=['blue', 'red', 'green', 'orange', 'purple', 'cyan'])

    # Adding titles and labels
    ax.set_title(f"Storm Summary for {df['State'][0]} (Year {df['State'][0]})")
    ax.set_ylabel("Values")
    ax.set_xlabel("State")

    plt.xticks(rotation=45)
    plt.tight_layout()

    plt.show()


if __name__ == "__main__":
    state = input("Which state do you want info on?")

    year = 2010  # Example year

    # Get the data
    df = get_storm_summary_df(state, year)

    # Plot the data
    plot_summary(df)

    # Close the connection when done
    cursor.close()
    conn.close()
