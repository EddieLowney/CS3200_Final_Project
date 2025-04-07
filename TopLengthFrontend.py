import panel as pn
from TopLengthBackend import StormEventsBackend
import pandas as pd
import matplotlib.pyplot as plt

pn.extension()

class StormEventsDashboard:
    def __init__(self):
        """ Create Dashboard """
        self.backend = StormEventsBackend()
        
        # Create widgets
        self.num_storms = pn.widgets.IntSlider(
            name='Number of Storms', 
            start=1, 
            end=50, 
            value=10
        )
    
        # Create output panes
        self.plot_pane = pn.pane.Matplotlib(height=500, sizing_mode='stretch_width')
        self.data_table = pn.widgets.DataFrame(height=300, sizing_mode='stretch_width')
        
       
        # Create cards
        self.controls_card = pn.Card(
            pn.Column(
                self.num_storms

            ),
            title="Storm Filters",
            width=350,
            collapsed=False
        )
        
        # Create tabs
        self.main_tabs = pn.Tabs(
            ("Storm Paths", self.plot_pane),
            ("Storm Data", self.data_table),
            active=0
        )
        
        # Layout
        self.layout = pn.template.FastListTemplate(
            title='Storm Events Dashboard',
            sidebar=[self.controls_card],
            main=[self.main_tabs],
            theme_toggle=False
        )
        
        # Initial load
        self.num_storms.param.watch(self.update_dashboard, 'value')

        # Initial load
        self.update_dashboard()

    def update_dashboard(self, *events):
        """Update both plot and table"""
        num_storms = self.num_storms.value
  
        
        # Update plot
        df = self.backend.get_storm_data(num_storms)

        fig = self.backend.create_map(df)
        if fig:
            self.plot_pane.object = fig
            plt.close(fig)
        
        # Update table
        self.data_table.value = df[['cz_name', 'state', 'event_type', 'distance_moved_km']]

    def view(self):
        return self.layout

# Create and serve
dashboard = StormEventsDashboard()
pn.serve(dashboard.view())  
