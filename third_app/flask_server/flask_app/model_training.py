import pandas as pd
from statsmodels.tsa.arima.model import ARIMA
from statsmodels.tsa.statespace.sarimax import SARIMAX
import math
import mlflow
import mlflow.sklearn
import matplotlib.pyplot as plt

import warnings
warnings.filterwarnings("ignore")


# Note: When making validation sets, make sure that df_actual, df_validation and df_prediction_subset is mapped correctly 
# df_predictions will be mapped automatically

threshold = 10

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
    df = df.groupby(pd.Grouper(key='Date', freq='M')).sum().reset_index()
    return df

def fit_arima(df_monthly, params):
    
    model = ARIMA(df_monthly['Quantity'], order=params)  #
    model_fit = model.fit()
    return model_fit

def fit_sarima(df_monthly, params):
    seasonal_order = (0, 0, 0, 12)  
    model = SARIMAX(df_monthly['Quantity'], order=params, seasonal_order=seasonal_order)
    model_fit = model.fit()
    return model_fit

def plot_actual_predicted(actual_df, predicted_df):

    plt.figure(figsize=(10, 6))
    
    # Plot actual data line and points
    plt.plot(actual_df['Date'], actual_df['Quantity'], label='Actual', color='blue')
    plt.scatter(actual_df['Date'], actual_df['Quantity'], color='blue')  # Show points
    
    # Plot predicted data line and points
    plt.plot(predicted_df['Date'], predicted_df['Quantity'], label='Predicted', color='red', linestyle='dashed')
    plt.scatter(predicted_df['Date'], predicted_df['Quantity'], color='red')  # Show points
    
    plt.xlabel('Date')
    plt.ylabel('Quantity')
    plt.title('Actual vs Predicted Quantity')
    plt.legend()
    plt.grid(True)
    plt.xticks(rotation=45)  # Rotate x-axis labels for better readability
    plt.tight_layout()
    plt.show()

def train_and_evaluate(df_actual, df_validation, params):
    
    print("\nParameters: ", params)
    
    # Fit ARIMA model
    model_fit = fit_arima(df_actual, params)
    
    # Make predictions
    start_date = pd.Timestamp('2023-10-31')  # Start date for predictions
    periods = 14  # Number of periods to forecast
    df_predicted = make_predictions(model_fit, start_date, periods)
    
    df_predicted_subset = df_predicted.iloc[0:5]
    print("Predicted: \n",df_predicted)
    print("Predicted Subset: \n",df_predicted_subset)
    
    # Calculate RMSE
    rmse = calculate_root_mse(df_predicted_subset, df_validation)
    # pcp = calculate_pcp(df_validation, df_predicted_subset, 10)
    # plot_actual_predicted(df_validation, df_predicted_subset)
    
    return rmse, model_fit

def make_predictions(model_fit, start_date, periods):
    
    # Make predictions
    forecast_index = pd.date_range(start=start_date, periods=periods, freq='ME')  # Forecast for given number of months starting from the start_date
    forecast = model_fit.forecast(steps=periods)
    df_predicted = pd.DataFrame({'Date': forecast_index, 'Quantity': forecast})
    return df_predicted


def calculate_root_mse(df_predicted_subset, df_validation):
    
    target_column = 'Quantity'
    val = []
    pred = []

    # Iterate through the DataFrame and access the specific column value
    for _, row in df_predicted_subset.iterrows(): 
        col_value = float(row[target_column])  
        pred.append(col_value)
        
    for _, row in df_validation.iterrows():  
        col_value = float(row[target_column])  
        val.append(col_value)
    
    mse = sum((p - v) ** 2 for p, v in zip(pred, val)) / len(val)
    rmse = math.sqrt(mse)
    
    print("RMSE: ", rmse)
    return rmse

def calculate_mse(df_predicted_subset, df_validation):
    target_column = 'Quantity'
    val = []
    pred = []

    # Iterate through the DataFrame and access the specific column value
    for _, row in df_predicted_subset.iterrows():
        col_value = float(row[target_column])
        pred.append(col_value)

    for _, row in df_validation.iterrows():
        col_value = float(row[target_column])
        val.append(col_value)

    # Calculate Mean Squared Error (MSE)
    mse = sum((p - v) ** 2 for p, v in zip(pred, val)) / len(val)
    
    print("MSE: ", mse)
    return mse
    
def calculate_pcp(predictions, actuals, threshold):
    
    correct_count = 0
    total_count = predictions.shape[0]  
    
    for index, row in predictions.iterrows():
        pred = row['Quantity']  
        actual = actuals.loc[index, 'Quantity']  
        
        error = abs(pred - actual) / actual * 100
        if error <= threshold:
            correct_count += 1
    
    pcp = (correct_count / total_count) * 100
    return pcp


def run_experiment(df_actual, df_validation, order):
    with mlflow.start_run():
        # Train and evaluate model
        rmse, model = train_and_evaluate(df_actual, df_validation, order)
        
        # Log parameters and metrics
        mlflow.log_param("p", order[0])
        mlflow.log_param("d", order[1])
        mlflow.log_param("q", order[2])
        mlflow.log_metric("rmse", rmse)
        
        # Log the trained model
        mlflow.sklearn.log_model(model, "arima_model")
        # mlflow.sklearn.log_model(model, "sarima_model")


if __name__ == "__main__":
    
    fileName = 'spareParts.xlsx'
    df = read_data(fileName)
    # Linear interpolation to fill missing values
    df_interpolated = df.interpolate(method='linear')
    df_actual = aggregate_by_month(df_interpolated)
    
    # Display the DataFrame after keeping specific columns
    print("Complete Dataset: \n")
    print(df_actual)
    print("\n")

    # Create training and validation sets
    df_actual_subset = df_actual[0:9]
    df_validation = df_actual[9:]
    
    print("Train: \n",df_actual_subset)
    print("\nValidation: \n",df_validation)
    
    param_sets = [
        [1, 1, 2],
        [2, 1, 2],
        [1, 0, 2],
        [1, 1, 1],
        [5, 1, 2],
        [5, 0, 1],
        [5, 1, 1]
    ]
    
    # param_sets = [
    #     [5, 1, 2]
    # ]

    for params in param_sets:
        run_experiment(df_actual, df_validation, params)