import pandas as pd
import matplotlib.pyplot as plt
from statsmodels.tsa.arima.model import ARIMA
from flask import Flask, render_template, send_file, request, jsonify
import io
import base64
import seaborn as sns
from io import BytesIO
import supabase 
from rdflib import Graph
from logic import extractFaultSolution
from ontology import get_system, get_equipment, get_location
from werkzeug.utils import secure_filename
from ocr import perform_ocr
import os
from datetime import datetime, timedelta
from supabase import create_client, Client
from ConsolidatedWheelRawData import mainFun4
from matplotlib.ticker import MaxNLocator
import pytesseract
import csv


plt.switch_backend('agg')

pytesseract.pytesseract.tesseract_cmd = r'C:\Users\Fatima Abdul Wahid\AppData\Local\Programs\Tesseract-OCR\tesseract.exe'




# Define your Supabase project URL and API key
supabase_url = "https://typmqqidaijuobjosrpi.supabase.co"
supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cG1xcWlkYWlqdW9iam9zcnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTM0MzkzODAsImV4cCI6MjAwOTAxNTM4MH0.Ihde633Yj9FFaQ7hKLooxDxaFEno4fK8YxSb3gy8S4c"

supabase_client = supabase.Client(supabase_url, supabase_key)

app = Flask(__name__)



def login(username, password):
    # Query Supabase for user with provided username
    query = supabase_client.from_('Users').select('*').eq('username', username)
    response = query.execute()
    print(response)
    
    user = response.data
    mypassword = user[0]['password']
    print("SFjh")
    print(user)
        # Check if the entered password matches the password in the database
    if mypassword== password:
        return True, user
    else:
        return False, "Incorrect password."
    

@app.route('/login', methods=['POST'])
def user_login():
    data = request.get_json()
    if 'username' not in data or 'password' not in data:
        return jsonify({"error": "Missing username or password"}), 400

    username = data['username']
    password = data['password']

    success, user_info = login(username, password)
    print(user_info)
    if success:
        return jsonify({"status": "success", "user_info": user_info})
    else:
        return jsonify({"status": "error", "message": user_info}), 401

#Spare part prediction

def read_data(fileName):
    # Read the Excel file into a DataFrame
    df = pd.read_excel(fileName)

    # Get column names
    column_names = df.columns
    print(column_names)
    print("\n")

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

def fit_arima(df_monthly):
    model = ARIMA(df_monthly['Quantity'], order=(5, 1, 2))  # ARIMA(p,d,q) order selection might need to be optimized
    model_fit = model.fit()
    return model_fit

def make_predictions(model_fit, start_date, periods):
    # Make predictions
    forecast_index = pd.date_range(start=start_date, periods=periods, freq='M')  # Forecast for given number of months starting from the start_date
    forecast = model_fit.forecast(steps=periods)
    df_predicted = pd.DataFrame({'Date': forecast_index, 'Quantity': forecast})
    return df_predicted



@app.route('/get_plot', methods=['GET'])
def get_plot():

    global new_df
    fileName = 'spareParts.xlsx'
    df = read_data(fileName)
    
    # Display the DataFrame after keeping specific columns
    print(df)
    print("\n")
    
    # Display the DataFrame after aggregating the spare parts by month
    df_actual = aggregate_by_month(df)
    print("Actual Quantity:")
    print(df_actual)
    print("\n")
    
    # Fit ARIMA model
    model_fit = fit_arima(df_actual)
    
    # Make predictions
    start_date = pd.Timestamp('2024-03-01')  # Start date for predictions
    periods = 13  # Number of periods to forecast
    df_predicted = make_predictions(model_fit, start_date, periods)
    print("Forecasted Quantity:")
    print(df_predicted)
    new_df=df_predicted
    print(new_df)
    
    # Combine specific columns from df_actual and df_predicted and add a flag column
    df_combined = pd.concat([
        df_actual[['Date', 'Quantity']].assign(Flag=0), 
        df_predicted[['Date', 'Quantity']].assign(Flag=1)
    ], ignore_index=True)
    
    columns_to_keep = ['Date', 'Quantity', 'Flag']  
    df_combined = df_combined.loc[:, columns_to_keep]

    # Print the combined DataFrame
    print("Combined DataFrame:")
    print(df_combined)

    df_sorted = df_combined.sort_values(by='Date')

    # Create separate DataFrames for each flag
    actual_data = df_sorted[df_sorted['Flag'] == 0]
    predicted_data = df_sorted[df_sorted['Flag'] == 1]

    # Create a figure and axis object
    plt.figure(figsize=(12, 6))

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

       # Convert plot to base64-encoded image
    buffer = BytesIO()
    plt.savefig(buffer, format='png')
    buffer.seek(0)
    plot_data = base64.b64encode(buffer.read()).decode('utf-8')
    plt.close()


    # Return the plot data as a JSON response
    return jsonify({'plot_data': plot_data})

@app.route('/get_table', methods=['GET'])
def get_table():
    global new_df  # Access the global variable
    print(new_df)
    # Check if df_predicted is not None
    if new_df  is not None:
        # Convert df_predicted to JSON
        new_df ['Date'] = new_df ['Date'].astype(str)
        new_df['Quantity'] = new_df['Quantity'].astype(float).round(2)

        new_df ['Quantity'] = new_df ['Quantity'].astype(str)

        table_data = new_df.to_json(orient='records')
        print(table_data)
        return jsonify({'table_data': table_data})
    else:
        return jsonify({'error': 'No predicted data available'})



#WHEEL DATA FORM
    

# Create a dictionary to store all data

all_fault_info = {
    'fault_info': {},
    'fault_status': {},
    'fault_detection': {},
}

all_data = {
    'general_info': {},
    'intial_measurement': {},
    'final_measurement': {},
}

@app.route('/')
def home():
    return "Home Page"

@app.route('/general_info', methods=['POST'])

def general_info():
    if request.method == 'POST':
        data = request.get_json()
        a = data['_dateController']
        b = data['_timeController']
        c = data['trainNo']
        d = int(data['wheelSetNo'])


        response_data = {
            'date': a,
            'time': b,
            'trainNo': c,
            'wheelSetNo': d
        }
        
    all_data['general_info'] = data
    return jsonify(response_data)


@app.route('/intial_measurement', methods=['POST'])

def intial_measurement():
    if request.method == 'POST':
        data = request.get_json()
        BLWheelTreadValue = data.get('BLWheelTread', '')
        BRWheelTreadValue = data.get('BRWheelTread', '')
        BLFlangeThicknessValue = data.get('BLFlangeThickness', '')
        BRFlangeThicknessValue = data.get('BRFlangeThickness', '')
        BLFlangeHeightValue = data.get('BLFlangeHeight', '')
        BRFlangeHeightValue = data.get('BRFlangeHeight', '')
        BLFlangeGradientValue = data.get('BLFlangeGradient', '')
        BRFlangeGradientValue = data.get('BRFlangeGradient', '')
        BLRadialDeviationValue = data.get('BLRadialDeviation', '')
        BRRadialDeviationValue = data.get('BRRadialDeviation', '')
      

        # Create a response dictionary
        response_data = {
            'BLWheelTread': BLWheelTreadValue,
            'BRWheelTread': BRWheelTreadValue,
            'BLFlangeThickness': BLFlangeThicknessValue,
            'BRFlangeThickness': BRFlangeThicknessValue,
            'BLFlangeHeight': BLFlangeHeightValue,
            'BRFlangeHeight': BRFlangeHeightValue,
            'BLFlangeGradient': BLFlangeGradientValue,
            'BRFlangeGradient': BRFlangeGradientValue,
            'BLRadialDeviation': BLRadialDeviationValue,
            'BRRadialDeviation': BRRadialDeviationValue,
            
        }
        all_data['intial_measurement'] = data
        return jsonify(response_data)

 
@app.route('/final_measurement', methods=['POST'])
   
def final_measurement():
    if request.method == 'POST':
        data = request.get_json()
        ALWheelTreadValue = data.get('ALWheelTread', '')
        ARWheelTreadValue = data.get('ARWheelTread', '')
        ALFlangeThicknessValue = data.get('ALFlangeThickness', '')
        ARFlangeThicknessValue = data.get('ARFlangeThickness', '')
        ALFlangeHeightValue = data.get('ALFlangeHeight', '')
        ARFlangeHeightValue = data.get('ARFlangeHeight', '')
        ALFlangeGradientValue = data.get('ALFlangeGradient', '')
        ARFlangeGradientValue = data.get('ARFlangeGradient', '')
        ALRadialDeviationValue = data.get('ALRadialDeviation', '')
        ARRadialDeviationValue = data.get('ARRadialDeviation', '')
        
    

        # Create a response dictionary
        response_data = {
            'ALWheelTread': ALWheelTreadValue,
            'ARWheelTread': ARWheelTreadValue,
            'ALFlangeThickness': ALFlangeThicknessValue,
            'ARFlangeThickness': ARFlangeThicknessValue,
            'ALFlangeHeight': ALFlangeHeightValue,
            'ARFlangeHeight': ARFlangeHeightValue,
            'ALFlangeGradient': ALFlangeGradientValue,
            'ARFlangeGradient': ARFlangeGradientValue,
            'ALRadialDeviation': ALRadialDeviationValue,
            'ARRadialDeviation': ARRadialDeviationValue,
            
        }
        all_data['final_measurement'] = data

        # Convert date and time to the required format
       # Extract general info data
        general_info_data = all_data['general_info']
        
       # Extract date and time strings
        date_string = general_info_data['_dateController']
        time_string = general_info_data['_timeController']
        
        # Convert date string to a date object
        
        formatted_date = datetime.strptime(date_string, '%Y-%m-%d').date()
        formatted_date = formatted_date.strftime('%Y-%m-%d')
        print(formatted_date)

        # Convert time string to a time object
        
        
        formatted_time = datetime.strptime(time_string, '%H:%M:%S').time()
        formatted_time = formatted_time.strftime('%H:%M:%S')

        

        
        trainNo = general_info_data['trainNo']
        wheelSetNo = general_info_data['wheelSetNo']

         # Extract initial measurement data
        initial_measurement_data = all_data['intial_measurement']
        BLWheelTreadValue = initial_measurement_data['BLWheelTread']
        BRWheelTreadValue = initial_measurement_data['BRWheelTread']
        BLFlangeThicknessValue = initial_measurement_data['BLFlangeThickness']
        BRFlangeThicknessValue = initial_measurement_data['BRFlangeThickness']
        BLFlangeHeightValue = initial_measurement_data['BLFlangeHeight']
        BRFlangeHeightValue = initial_measurement_data['BRFlangeHeight']
        BLFlangeGradientValue = initial_measurement_data['BLFlangeGradient']
        BRFlangeGradientValue = initial_measurement_data['BRFlangeGradient']
        BLRadialDeviationValue = initial_measurement_data['BLRadialDeviation']
        BRRadialDeviationValue = initial_measurement_data['BRRadialDeviation']
        print("geee",BLFlangeGradientValue)

        # Define your Supabase project URL and API key
        supabase_url = "https://typmqqidaijuobjosrpi.supabase.co"
        supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cG1xcWlkYWlqdW9iam9zcnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTM0MzkzODAsImV4cCI6MjAwOTAxNTM4MH0.Ihde633Yj9FFaQ7hKLooxDxaFEno4fK8YxSb3gy8S4c"

            # Initialize the Supabase client
        supabase_client = supabase.Client(supabase_url, supabase_key)
        table_name = "manualwheelrawdata"
        
        insert_data = {
        'manual_date': formatted_date,
        'manual_time': formatted_time,
        'train_no': trainNo, 
        'wheelset_no':wheelSetNo,
       'blwheeltread': BLWheelTreadValue,
        'brwheeltread': BRWheelTreadValue,  
        'blflangethickness': BLFlangeThicknessValue,  
        'brflangethickness': BRFlangeThicknessValue,  
        'blflangeheight': BLFlangeHeightValue,  
        'brflangeheight': BRFlangeHeightValue,  
        'blflangegradient': BLFlangeGradientValue,  
        'brflangegradient': BRFlangeGradientValue,  
        'bl_axialdeviation': BLRadialDeviationValue,  
        'br_axialdeviation': BRRadialDeviationValue,  
        'alwheeltread': ALWheelTreadValue,  
        'arwheeltread': ARWheelTreadValue,  
        'alflangethickness': ALFlangeThicknessValue,  
        'arflangethickness': ARFlangeThicknessValue, 
        'alflangeheight': ALFlangeHeightValue, 
        'arflangeheight': ARFlangeHeightValue,  
        'alflangegradient': ALFlangeGradientValue,  
        'arflangegradient': ARFlangeGradientValue,  
        'al_axialdeviation': ALRadialDeviationValue,  
        'ar_axialdeviation': ARRadialDeviationValue,  
    }

        supabase_client.table(table_name).insert(insert_data).execute()
                    
      
       
        return jsonify({"message": "Dummy data inserted successfully"})


    
@app.route('/get_combined_data', methods=['GET'])
def get_combined_data():
    return jsonify(all_data)

#Fault Data Form

@app.route('/get_related_system', methods=['POST'])
def get_related_system():
    selected_class = request.json.get('class_instance')

    # Call function to retrieve related equipment
    related_system = get_system(selected_class)

    return jsonify({"related_system": related_system})

@app.route('/get_related_equipment', methods=['POST'])
def get_related_equipment():
    selected_system = request.json.get('system_instance')

    # Call function to retrieve related equipment
    related_equipment = get_equipment(selected_system)

    return jsonify({"related_equipment": related_equipment})

@app.route('/get_related_location', methods=['POST'])
def get_related_location():
    selected_equipment = request.json.get('equipment_instance')

    # Call function to retrieve related equipment
    related_location = get_location(selected_equipment)

    return jsonify({"related_location": related_location})


#Fault Solution 

# Load the OWL file
g = Graph()
g.parse("orange.owl", format="xml")



@app.route('/extract_fault_solution', methods=['POST'])
def api_extract_fault_solution():
    data = request.get_json()

    if 'user_entry_text' not in data:
        return jsonify({'error': 'Missing user_entry_text parameter'}), 400

    user_entry_text = data['user_entry_text']

    # Call your function to extract fault solutions
    fault_solution = extractFaultSolution(user_entry_text)

    # Return the fault solutions as JSON
    return jsonify({'fault_solutions': fault_solution})



# Wheel Analysis

# Define the directory where you want to save the uploaded images
UPLOAD_FOLDER = 'uploadedimages'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Create the upload directory if it doesn't exist
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

@app.route('/upload_image', methods=['POST'])
def upload_image():
    if request.method == 'POST':
        # Check if the 'image' file is included in the request
        if 'image' not in request.files:
            return jsonify({"message": "No file part"})

        imagefile = request.files['image']
        # Check if the file is empty
        if imagefile.filename == '':
            return jsonify({"message": "No selected file"})

        # Securely obtain the filename and save it
        filename = secure_filename(imagefile.filename)
        imagepath=(os.path.join(app.config['UPLOAD_FOLDER'], filename))
        imagefile.save(imagepath)

        ocr_text=perform_ocr(imagepath)
        print(ocr_text)

        return jsonify(ocr_text)
    
@app.route('/upload_ocr', methods=['POST'])
def upload_ocr():
    if request.method == 'POST':
        #try:
            data = request.get_json()
            print(type(data))
            # Access the values using data[]
            TrainNumber = data['TrainNumber']
            WheelSetNumber = data['WheelSetNumber']
            Date = data['Date']
            Time = data['Time']
           
            
            a_LHS_Diameter = data['A-LHS-Diameter']
            a_LHS_FlangeThickness = data['A-LHS-FlangeThickness']
            a_LHS_FlangeWidth = data['A-LHS-FlangeWidth']
            a_LHS_Qr = data['A-LHS-Qr']
            a_LHS_RadialDeviation = data['A-LHS-RadialDeviation']
            a_RHS_Diameter = data['A-RHS-Diameter']
            a_RHS_FlangeThickness = data['A-RHS-FlangeThickness']
            a_RHS_FlangeWidth = data['A-RHS-FlangeWidth']
            a_RHS_Qr = data['A-RHS-Qr']
            a_RHS_RadialDeviation = data['A-RHS-RadialDeviation']
            b_LHS_Diameter = data['B-LHS-Diameter']
            b_LHS_FlangeThickness = data['B-LHS-FlangeThickness']
            b_LHS_FlangeWidth = data['B-LHS-FlangeWidth']
            b_LHS_Qr = data['B-LHS-Qr']
            b_LHS_RadialDeviation = data['B-LHS-RadialDeviation']
            b_RHS_Diameter = data['B-RHS-Diameter']
            b_RHS_FlangeThickness = data['B-RHS-FlangeThickness']
            b_RHS_FlangeWidth = data['B-RHS-FlangeWidth']
            b_RHS_Qr = data['B-RHS-Qr']
            b_RHS_RadialDeviation = data['B-RHS-RadialDeviation']
           
            afterCut = data['afterCut']
            
            # Assuming the Date is in the format "06.06.2023"
            # formatted_date = datetime.strptime(Date, '%d.%m.%Y').date()
            # formatted_date = formatted_date.strftime('%Y-%m-%d')

            # Assuming the Time is in the format "92:50:15"
            # formatted_time = datetime.strptime(Time, '%H:%M:%S').time()
            # formatted_time = formatted_time.strftime('%H:%M:%S')
            
            supabase_url = "https://typmqqidaijuobjosrpi.supabase.co"
            supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cG1xcWlkYWlqdW9iam9zcnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTM0MzkzODAsImV4cCI6MjAwOTAxNTM4MH0.Ihde633Yj9FFaQ7hKLooxDxaFEno4fK8YxSb3gy8S4c"

                # Initialize the Supabase client
            supabase_client = supabase.Client(supabase_url, supabase_key)
            table_name = "ocrrawdata"
            
            ocr_data = {
                'ocr_date': Date,
                'ocr_time': Time,
                'train_no': TrainNumber,
                'wheelset_no': WheelSetNumber,
                'blwheeltread': b_LHS_Diameter,
                'brwheeltread': b_RHS_Diameter,
                'blflangethickness': b_LHS_FlangeThickness,
                'brflangethickness': b_RHS_FlangeThickness,
                'blflangeheight': b_LHS_FlangeWidth,
                'brflangeheight': b_RHS_FlangeWidth,
                'blflangegradient': b_LHS_Qr ,
                'brflangegradient': a_RHS_Qr ,
                'bl_axialdeviation': b_LHS_RadialDeviation,
                'br_axialdeviation': b_RHS_RadialDeviation,
                'alwheeltread': a_LHS_Diameter,
                'arwheeltread': a_RHS_Diameter,
                'alflangethickness': a_LHS_FlangeThickness,
                'arflangethickness': a_RHS_FlangeThickness,
                'alflangeheight': a_LHS_FlangeWidth,
                'arflangeheight': a_RHS_FlangeWidth,
                'alflangegradient': a_LHS_Qr ,
                'arflangegradient': a_RHS_Qr ,
                'al_axialdeviation': a_LHS_RadialDeviation,
                'ar_axialdeviation': a_RHS_RadialDeviation,
                'aftercut': afterCut
            }

            supabase_client.table(table_name).insert(ocr_data).execute()
  
            return jsonify({"message": "Dummy data inserted successfully"})

@app.route('/upload_manual', methods=['POST'])
def upload_manual():
    if request.method == 'POST':
        #try:
            data = request.get_json()
            print(type(data))
            # Access the values using data[]
            a_LHS_Diameter = data['A-LHS-Diameter']
            a_LHS_FlangeThickness = data['A-LHS-FlangeThickness']
            a_LHS_FlangeWidth = data['A-LHS-FlangeWidth']
            a_LHS_Qr = data['A-LHS-Qr']
            a_LHS_RadialDeviation = data['A-LHS-RadialDeviation']
            a_RHS_Diameter = data['A-RHS-Diameter']
            a_RHS_FlangeThickness = data['A-RHS-FlangeThickness']
            a_RHS_FlangeWidth = data['A-RHS-FlangeWidth']
            a_RHS_Qr = data['A-RHS-Qr']
            a_RHS_RadialDeviation = data['A-RHS-RadialDeviation']
            b_LHS_Diameter = data['B-LHS-Diameter']
            b_LHS_FlangeThickness = data['B-LHS-FlangeThickness']
            b_LHS_FlangeWidth = data['B-LHS-FlangeWidth']
            b_LHS_Qr = data['B-LHS-Qr']
            b_LHS_RadialDeviation = data['B-LHS-RadialDeviation']
            b_RHS_Diameter = data['B-RHS-Diameter']
            b_RHS_FlangeThickness = data['B-RHS-FlangeThickness']
            b_RHS_FlangeWidth = data['B-RHS-FlangeWidth']
            b_RHS_Qr = data['B-RHS-Qr']
            b_RHS_RadialDeviation = data['B-RHS-RadialDeviation']
            Date = data['Date']
            Time = data['Time']
            TrainNumber = data['TrainNumber']
            WheelSetNumber = data['WheelSetNumber']
            
            supabase_url = "https://typmqqidaijuobjosrpi.supabase.co"
            supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cG1xcWlkYWlqdW9iam9zcnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTM0MzkzODAsImV4cCI6MjAwOTAxNTM4MH0.Ihde633Yj9FFaQ7hKLooxDxaFEno4fK8YxSb3gy8S4c"

                # Initialize the Supabase client
            supabase_client = supabase.Client(supabase_url, supabase_key)
            table_name = "manualwheelrawdata"
            
            manual_data = {
                'manual_date': Date,
                'manual_time': Time,
                'train_no': TrainNumber,
                'wheelset_no': WheelSetNumber,
                'blwheeltread': b_LHS_Diameter,
                'brwheeltread': b_RHS_Diameter,
                'blflangethickness': b_LHS_FlangeThickness,
                'brflangethickness': b_RHS_FlangeThickness,
                'blflangeheight': b_LHS_FlangeWidth,
                'brflangeheight': b_RHS_FlangeWidth,
                'blflangegradient': b_LHS_Qr ,
                'brflangegradient': a_RHS_Qr ,
                'bl_axialdeviation': b_LHS_RadialDeviation,
                'br_axialdeviation': b_RHS_RadialDeviation,
                'alwheeltread': a_LHS_Diameter,
                'arwheeltread': a_RHS_Diameter,
                'alflangethickness': a_LHS_FlangeThickness,
                'arflangethickness': a_RHS_FlangeThickness,
                'alflangeheight': a_LHS_FlangeWidth,
                'arflangeheight': a_RHS_FlangeWidth,
                'alflangegradient': a_LHS_Qr ,
                'arflangegradient': a_RHS_Qr ,
                'al_axialdeviation': a_LHS_RadialDeviation,
                'ar_axialdeviation': a_RHS_RadialDeviation,
            }

            supabase_client.table(table_name).insert(manual_data).execute()
  
            return jsonify({"message": "Dummy data inserted successfully"})
        
@app.route('/wheel_analysis', methods=['POST'])
def wheel_analysis():
    if request.method == 'POST':
        data = request.get_json()
        train_no = data['selected_train_no']
        result = mainFun4(train_no)
        return jsonify(result)
        


# Fault Detection
    
# def check_connection(supabase_client):
#     try:
#         # Retrieve a list of tables to verify the connection
#         tables = supabase_client.table('FaultDetection').select('fault_sol').execute()
#         print("Connection to Supabase successful!")
#         print("Tables in the database:", tables)
#     except Exception as e:
#         print("Error:", e)


# @app.route('/fault_detection', methods=['POST'])
# def fault_detection():
#     if request.method == 'POST':
#         data = request.get_json() 
#         print(data)

#         fault_description = data.get('faultdescController', '')
#         fault_solution = data.get('faultsolController', '')

       
      
       
#         table_name = "FaultDetection"
        
#         insert_faultdata = {
#         'fault_desc': fault_description,
#         'fault_sol': fault_solution,
        
      
#     }
#         print(insert_faultdata)
#         supabase_client.table(table_name).insert(insert_faultdata).execute()
        

#         # Respond back to Flutter application with a success message
#         return jsonify({'message': 'Data received successfully'}), 200
#     else:
#         return jsonify({'error': 'Invalid request method'}), 405


#Reporting 


current_date = datetime.now().date()
last_week = current_date - timedelta(days=200)

table_name = "FaultData"
rows = supabase_client.table(table_name).select("*").gte('OccurrenceDate', last_week).execute().data

@app.route('/report_data')
def faultTable():

    faultsOccurred = 0
    faultsResolved = 0
    faultsPending = 0
    faultsObservation = 0

    for row in rows:
        system = row["System"]
        equipment = row["Equipment"]
        status = row["Status"]

        if system == "Others" or system is None or equipment == "Others" or equipment is None:
            continue
        
        faultsOccurred += 1
        
        if status == 'Resolved':
            faultsResolved += 1
        elif status == 'Pending':
            faultsPending += 1
        elif status == 'Under Observation':
            faultsObservation += 1

    tableData = {
        "Fault Data": ["Faults Occurred", "Faults Resolved", "Faults Pending", "Faults Under Observation"],
        "Number of Faults": [faultsOccurred, faultsResolved, faultsPending, faultsObservation]
    }

    # Create figure and axis
    fig, ax = plt.subplots()

    # Hide axes
    ax.axis('tight')
    ax.axis('off')

    # Create table
    table = ax.table(cellText=list(zip(tableData["Fault Data"], map(str, tableData["Number of Faults"]))),
                    colLabels=["Fault Data", "Number of Faults"],  # Add column labels
                    cellLoc='center',
                    loc='center')

    # Adjust font size
    table.auto_set_font_size(False)
    table.set_fontsize(14)

    # Adjust cell heights
    table.scale(1.2, 1.6)

    # Save graph
    plt.savefig(f'../../assets/Fault_Table.png')

    return systemGraph()

def systemGraph():

    system_faults = {}

    for row in rows:
        system = row["System"]
        equipment = row["Equipment"]

        if system == "Others" or system is None or equipment == "Others" or equipment is None:
            continue

        if system not in system_faults:
            system_faults[system] = 0
        
        system_faults[system] += 1

    # Plotting
    sorted_system = sorted(system_faults.items(), key=lambda x: x[1], reverse=True)
    system_names = [item[0] for item in sorted_system]
    faults_counts = [item[1] for item in sorted_system]

    plt.figure(figsize=(12, 8))
    bars = plt.bar(system_names, faults_counts, color='skyblue', alpha=0.75, edgecolor='black')
    plt.title("System Faults", fontsize=16, fontweight='bold')
    plt.xlabel("System", fontsize=14)
    plt.ylabel("Faults Count", fontsize=14)
    max_faults_count = max(faults_counts)
    plt.xticks([])
    plt.yticks(range(5, max_faults_count + 5), fontsize=12)
    plt.gca().yaxis.set_major_locator(MaxNLocator(integer=True))  # Display only whole number values on y-axis
    plt.grid(color='gray', linestyle='--', linewidth=0.5, axis='y', alpha=0.7)

    fixed_vertical_height = 0.1

    for bar, label in zip(bars, system_names):
        yval = bar.get_height()
        plt.text(bar.get_x() + bar.get_width()/2, yval, int(yval), ha='center', va='bottom', fontsize=10, fontweight='bold')
        plt.text(bar.get_x() + bar.get_width()/2, fixed_vertical_height, label, ha='center', va='bottom', fontsize=10, color='black', rotation=90)

    plt.tight_layout()

    plt.savefig(f'../../assets/Systems_Graph.png')

    return equipmentGraph(system_names)

def equipmentGraph(system_names):

    # print(system_names)

    for savedSystems in system_names:

        equipment_faults = {}

        for row in rows:
            system = row["System"]

            if system == savedSystems:
                equipment = row["Equipment"]

                if system == "Others" or system is None or equipment == "Others" or equipment is None:
                    continue

                if equipment not in equipment_faults:
                    equipment_faults[equipment] = 0
        
                equipment_faults[equipment] += 1

        # Plotting
        sorted_equipment = sorted(equipment_faults.items(), key=lambda x: x[1], reverse=True)
        equipment_names = [item[0] for item in sorted_equipment]
        faults_counts = [item[1] for item in sorted_equipment]

        plt.figure(figsize=(12, 8))
        bars = plt.bar(equipment_names, faults_counts, color='orange', alpha=0.75, edgecolor='black')
        plt.title("Equipment Faults", fontsize=16, fontweight='bold')
        plt.xlabel("Equipment", fontsize=14)
        plt.ylabel("Faults Count", fontsize=14)
        max_faults_count = max(faults_counts)
        plt.xticks([])
        plt.yticks(range(5, max_faults_count + 5), fontsize=12)
        plt.gca().yaxis.set_major_locator(MaxNLocator(integer=True))  # Display only whole number values on y-axis
        plt.grid(color='gray', linestyle='--', linewidth=0.5, axis='y', alpha=0.7)

        fixed_vertical_height = 0.1

        for bar, label in zip(bars, equipment_names):
            yval = bar.get_height()
            plt.text(bar.get_x() + bar.get_width()/2, yval, int(yval), ha='center', va='bottom', fontsize=10, fontweight='bold')
            plt.text(bar.get_x() + bar.get_width()/2, fixed_vertical_height, label, ha='center', va='bottom', fontsize=10, color='black', rotation=90)

        plt.tight_layout()

        # Save the image with a specific name in a local folder
        plt.savefig(f'../../assets/{savedSystems}.png')

        return system_names


@app.route('/spareParts_data', methods=['GET'])
def get_data():
    data = []
    with open('sparePartsPrediction.csv', mode='r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            data.append(row)
    return jsonify(data)


# Fault Data Form

@app.route('/fault_info', methods=['POST'])

def fault_info():
    if request.method == 'POST':
        data = request.get_json()

        a = data['occurrenceDate']
        b = data['trainNumber']
        c = data['carNumber']
        d = data['system']
        e = data['equipment']
        f = data['equipmentLocation']
        g = data['source']

        response_data = {
            'occurrenceDate': a,
            'trainNumber': b,
            'carNumber': c,
            'system': d,
            'equipment': e,
            'equipmentLocation': f,
            'source': g,
        }
        
    all_fault_info['fault_info'] = data
    print(all_fault_info['fault_info'])

    return jsonify(response_data)

@app.route('/fault_status', methods=['POST'])
def fault_status():
    if request.method == 'POST':
        data = request.get_json()

        a = data['resolutionDate']
        b = data['status']
        c = data['sparePartsConsumed']
        d = data['sparePartsSwapped']

        response_data = {
            'resolutionDate': a,
            'status': b,
            'sparePartsConsumed': c,
            'sparePartsSwapped': d,
        }

    all_fault_info['fault_status'] = data
    print(all_fault_info['fault_status'])

    return jsonify(response_data)

@app.route('/fault_detection', methods=['POST'])
def fault_detection():
    if request.method == 'POST':
        data = request.get_json() 

        a = data.get('description', '')
        b = data.get('solution', '')

        response_data = {
            'description': a,
            'solution': b,
        }

    all_fault_info['fault_detection'] = data
    print(all_fault_info['fault_detection'])

    return jsonify(response_data)

@app.route('/fault_record', methods=['POST'])
def fault_record():

    # page 1
    fault_info_data = all_fault_info['fault_info']
   
    occurrenceDate = fault_info_data['occurrenceDate']
    trainNumber = fault_info_data['trainNumber']
    carNumber = fault_info_data['carNumber']
    system = fault_info_data['system']
    equipment = fault_info_data['equipment']
    equipmentLocation = fault_info_data['equipmentLocation']
    source = fault_info_data['source']

    occurrenceDate = datetime.strptime(occurrenceDate, '%Y-%m-%d').date()
    occurrenceDate = occurrenceDate.strftime('%Y-%m-%d')

    # page 2
    fault_info_data = all_fault_info['fault_status']

    resolutionDate = fault_info_data['resolutionDate']
    status = fault_info_data['status']
    sparePartsConsumed = fault_info_data['sparePartsConsumed']
    sparePartsSwapped = fault_info_data['sparePartsSwapped']
    
    if resolutionDate != '':
        resolutionDate = datetime.strptime(resolutionDate, '%Y-%m-%d').date()
        resolutionDate = resolutionDate.strftime('%Y-%m-%d')
    else:
        resolutionDate = None

    # page 3
    fault_info_data = all_fault_info['fault_detection']

    description = fault_info_data['description']
    solution = fault_info_data['solution']

    # data insertion
    table_name = "FaultData"

    record = supabase_client.table(table_name).select('*').order('SR', desc=True).limit(1).execute()
    data = record.data[0]
    serial = data['SR']
    serial = serial + 1

    insert_data = {     
        'SR': serial, 
        'OccurrenceDate': occurrenceDate,
        'TrainNumber': trainNumber, 
        'CarNumber': carNumber,
        'Source': source,
        'System': system,
        'Equipment': equipment,
        'EquipmentLocation': equipmentLocation,
        'SparePartsConsumed': sparePartsConsumed,
        'SparePartsSwapped': sparePartsSwapped,
        'Description': description,
        'Solution': solution,
        'Status': status,
        'ResolutionDate': resolutionDate,
    }

    print(insert_data)
    supabase_client.table(table_name).insert(insert_data).execute()
       
    return jsonify({"message": "Data inserted successfully"})


if __name__ == '__main__':
    app.run(debug=True, port=8000)
