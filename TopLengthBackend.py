import mysql.connector
import pandas as pd
import geopandas as gpd
from shapely.geometry import Point, LineString
import matplotlib.pyplot as plt
import numpy as np
from geopy.distance import geodesic

class StormEventsBackend:
    def __init__(self):
        self.conn = None
        self.cursor = None
        self.connect_to_db()
    
    def connect_to_db(self):
        """Establish database connection"""
    
        self.conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password="Colon0125",
            database="storm"
        )
        self.cursor = self.conn.cursor(dictionary=True)
       

    def get_storm_data(self, number_of_storms=10):
        """Retrieve storm data from database"""
        
        self.cursor.callproc("Top50HurricanesByMagnitude", [number_of_storms])
        results = []
        for result in self.cursor.stored_results():
            results.extend(result.fetchall())
        return pd.DataFrame(results)
     
           
    def create_map(self, df):
        """Create visualization of storm paths and return figure"""
        if df.empty:
            print("No data to plot")
            return None

        # Create figure
        fig, ax = plt.subplots(figsize=(15, 10))
        
        # Load the US states shapefile
        states = gpd.read_file("cb_2022_us_state_20m/cb_2022_us_state_20m.shp")
        contiguous = states[~states['STUSPS'].isin(['PR', 'GU', 'VI', 'MP', 'AS'])]

        # Create GeoDataFrames for start and end points
        start_geom = [Point(xy) for xy in zip(df['start_longitude'], df['start_latitude'])]
        gdf_start = gpd.GeoDataFrame(df, geometry=start_geom, crs="EPSG:4326")

        end_geom = [Point(xy) for xy in zip(df['end_longitude'], df['end_latitude'])]
        gdf_end = gpd.GeoDataFrame(df, geometry=end_geom, crs="EPSG:4326")

        # Create storm path lines
        lines = [LineString([(row['start_longitude'], row['start_latitude']), 
                             (row['end_longitude'], row['end_latitude'])]) 
                for _, row in df.iterrows()]
        
        gdf_lines = gpd.GeoDataFrame(
            df,
            geometry=lines,
            crs="EPSG:4326"
        )

        # Plot base map
        contiguous.plot(ax=ax, color='lightgray', edgecolor='gray', alpha=0.5)

        # Plot storm paths with fixed color and line width
        gdf_lines.plot(
            ax=ax,
            color='blue',  
            linewidth=1,   
            alpha=0.7,
            label='Storm Paths'
        )

        # Plot points (Start and End)
        gdf_start.plot(ax=ax, color='green', markersize=50, marker='o', label='Start Points')
        gdf_end.plot(ax=ax, color='darkred', markersize=50, marker='X', label='End Points')

        # Set boundaries and labels
        ax.set_xlim([-130, -60])
        ax.set_ylim([20, 55])
        ax.set_aspect('auto')
        ax.set_title(f"Paths of Top {len(df)} Storms", fontsize=16, fontweight='bold')
        ax.set_xlabel("Longitude", fontsize=12)
        ax.set_ylabel("Latitude", fontsize=12)
        ax.legend(fontsize=10, loc='upper right')

        return fig
            
       
    def close(self):
        """Clean up database connections"""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()


