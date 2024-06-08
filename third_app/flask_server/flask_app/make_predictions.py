import pandas as pd
import joblib
import matplotlib.pyplot as plt

def read_data(fileName):
    
    # Read the Excel file into a DataFrame
    df = pd.read_excel(fileName)

    # Get column names
    # column_names = df.columns

    # Define columns to keep
    columns_to_keep = ['Train No.', 'System ', 'Date', 'Quantity']  

    # Keep specific columns
    df = df.loc[:, columns_to_keep]
    return df

def aggregate_by_month(df):
    
    # Convert 'Date' column to datetime if it's not already
    df['Date'] = pd.to_datetime(df['Date'])
    
    # Group by month and sum the quantities
    df = df.groupby(pd.Grouper(key='Date', freq='ME')).sum().reset_index()
    return df

# Send combined_df as argument i.e. training set as well as predictions
def plot_graph(df):
    
    # Sort DataFrame by Date
    df_sorted = df.sort_values(by='Date')

    # Create separate DataFrames for each flag
    actual_data = df_sorted[df_sorted['Flag'] == 0]
    predicted_data = df_sorted[df_sorted['Flag'] == 1]

    # Create a figure and axis object
    plt.figure(figsize=(10, 6))

    # Plot actual data with blue color and solid line
    plt.plot(actual_data['Date'], actual_data['Quantity'], label='Actual', color='blue', marker='o')

    # Plot predicted data with orange color and solid line
    plt.plot(predicted_data['Date'], predicted_data['Quantity'], label='Predicted', color='orange', marker='o')

    # Connect the lines between actual and predicted data
    plt.plot([actual_data['Date'].iloc[-1], predicted_data['Date'].iloc[0]],
             [actual_data['Quantity'].iloc[-1], predicted_data['Quantity'].iloc[0]],
             color='orange')

    # Add a legend
    plt.legend()

    # Add title and labels
    plt.title('Actual vs. Predicted Quantity')
    plt.xlabel('Date')
    plt.ylabel('Quantity')

    # Rotate x-axis labels for better readability
    plt.xticks(rotation=45)

    # Show grid
    plt.grid(True)

    # Show plot
    plt.tight_layout()
    plt.show()
    
    
def make_predictions(model_fit, start_date, periods):
    
    # Make predictions
    forecast_index = pd.date_range(start=start_date, periods=periods, freq='ME')  # Forecast for given number of months starting from the start_date
    forecast = model_fit.forecast(steps=periods)
    df_predicted = pd.DataFrame({'Date': forecast_index, 'Quantity': forecast})
    return df_predicted


if __name__ == "__main__":
    
    fileName = 'spareParts.xlsx'
    df = read_data(fileName)
    df_actual = aggregate_by_month(df)
    
    # Load the trained model
    loaded_model = joblib.load("model.pkl")  

    # Define the start date and number of periods for predictions
    start_date = pd.Timestamp('2024-03-31')
    periods = 9

    # Make predictions using the loaded model
    df_predicted = make_predictions(loaded_model, start_date, periods)
    
    df_combined = pd.concat([
        df_actual[['Date', 'Quantity']].assign(Flag=0), 
        df_predicted[['Date', 'Quantity']].assign(Flag=1)
    ], ignore_index=True)
    
    columns_to_keep = ['Date', 'Quantity', 'Flag']  
    df_combined = df_combined.loc[:, columns_to_keep]
    df_combined['Quantity'] = df_combined['Quantity'].round()
    
    print("Combined Dataframe: \n")
    print(df_combined)
    
    plot_graph(df_combined)