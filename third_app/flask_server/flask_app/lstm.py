import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense
from tensorflow.keras.optimizers import Adam
import matplotlib.pyplot as plt
import tensorflow.keras.backend as K
import calendar
import datetime
from sklearn.metrics import mean_squared_error


    
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
    
# Load your dataset
fileName = 'spareParts.xlsx'
df = pd.read_excel(fileName)

# Define columns to keep
columns_to_keep = ['Train No.', 'System ', 'Date', 'Quantity']  

# Keep specific columns
df = df.loc[:, columns_to_keep]

# Group by month and sum the quantities
df = df.groupby(pd.Grouper(key='Date', freq='M')).sum().reset_index()
last_index = df.index[-1]

# Convert 'Date' column to datetime
df['Date'] = pd.to_datetime(df['Date'])
print("Datatset: \n", df)

# Sort DataFrame by date
df.sort_values(by='Date', inplace=True)

# Normalize data
scaler = MinMaxScaler(feature_range=(0, 1))
df['quantity_normalized'] = scaler.fit_transform(df[['Quantity']])

# Define the window size
window_size = 12  

# Function to create sequences
def create_sequences(data, window_size):
    X, y = [], []
    for i in range(len(data) - window_size):
        X.append(data[i:(i + window_size)])
        y.append(data[i + window_size])
    return np.array(X), np.array(y)

# Create sequences
X, y = create_sequences(df['quantity_normalized'].values, window_size)

# Split into train and test sets
train_size = int(len(X) * 0.8)
test_size = len(X) - train_size
X_train, X_test = X[:train_size], X[train_size:]
y_train, y_test = y[:train_size], y[train_size:]
print("Test Set:\n", y_test)

# Define the LSTM model
model = Sequential([
    LSTM(50, input_shape=(window_size, 1)),
    Dense(1)
])

def rmse(y_true, y_pred):
    return K.sqrt(K.mean(K.square(y_pred - y_true)))

# Define the optimizer
optimizer = Adam(clipvalue=1.0)
model.compile(optimizer=optimizer, loss=rmse)

# Reshape data for LSTM input: [samples, time steps, features]
X_train = X_train.reshape((X_train.shape[0], X_train.shape[1], 1))
X_test = X_test.reshape((X_test.shape[0], X_test.shape[1], 1))

# Train the model
model.fit(X_train, y_train, epochs=100, batch_size=32, verbose=1)

# Evaluate the model
train_loss = model.evaluate(X_train, y_train, verbose=0)
test_loss = model.evaluate(X_test, y_test, verbose=0)
print(f'Train Loss: {train_loss:.4f}')
print(f'Test Loss: {test_loss:.4f}')

# Generate sequences for forecasting
last_sequence = df['quantity_normalized'].values[-window_size:].reshape(1, -1)
forecasted_values = []

for _ in range(12):  # Forecasting for the next 12 months
    # Reshape data for LSTM input
    last_sequence = last_sequence.reshape((1, window_size, 1))
    
    # Make prediction
    next_pred = model.predict(last_sequence)
    
    # Append the prediction to forecasted values
    forecasted_values.append(next_pred[0, 0])
    
    # Reshape next_pred to match the shape of last_sequence for concatenation
    next_pred_reshaped = next_pred.reshape((1, 1, 1))
    
    # Update last sequence by removing the first element and adding the prediction
    last_sequence = np.append(last_sequence[:, 1:, :], next_pred_reshaped, axis=1)

# --> Root MSE
# Inverse transform the test set values
y_test_inv = scaler.inverse_transform(y_test.reshape(-1, 1))
# Inverse transform the forecasted values
forecasted_values_inv = scaler.inverse_transform(np.array(forecasted_values).reshape(-1, 1))
# Inverse transform the forecasted values for the test period
forecasted_values_test_inv = scaler.inverse_transform(np.array(forecasted_values[:len(y_test)]).reshape(-1, 1))

# Calculate RMSE
rmse_test = np.sqrt(mean_squared_error(y_test_inv, forecasted_values_test_inv))
print(f'Test RMSE: {rmse_test:.4f}')

# # Print the forecasted values
# for i, val in enumerate(forecasted_values_inv, 1):
#     rounded_val = round(val[0])
#     print(f"Forecast for Month {i}: {rounded_val}")   
    
last_date = df['Date'].iloc[-1]

# Create a list of dates for the forecasted period
dates = []
for i in range(1, len(forecasted_values_inv) + 1):
    # Get the year and month of the last_date
    year = last_date.year + (last_date.month + i - 1) // 12
    month = (last_date.month + i - 1) % 12 + 1
    
    # Calculate the last date of the month
    last_day = calendar.monthrange(year, month)[1]
    forecasted_date = datetime.datetime(year, month, last_day)
    
    dates.append(forecasted_date)

# Create a DataFrame with 'Date' and 'Quantity' columns
forecast_df = pd.DataFrame({'Date': dates, 'Quantity': [round(val[0]) for val in forecasted_values_inv]})
print("\nForecasting: \n", forecast_df)

df_combined = pd.concat([
    df[['Date', 'Quantity']].assign(Flag=0), 
    forecast_df[['Date', 'Quantity']].assign(Flag=1)
], ignore_index=True)

columns_to_keep = ['Date', 'Quantity', 'Flag']  
df_combined = df_combined.loc[:, columns_to_keep]
df_combined['Quantity'] = df_combined['Quantity'].round()

print("\nCombined Dataframe:")
print(df_combined)
  
plot_graph(df_combined)