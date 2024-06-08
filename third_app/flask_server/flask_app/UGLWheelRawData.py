import cv2
import numpy as np
import re
import supabase
from ConsolidatedWheelRawData import mainFun3
from PIL import Image

def isfloat(num):
    try:
        float(num)
        return True
    except ValueError:
        return False
    
def run(string):
    # Make own character set and pass
    # this as argument in compile method
    regex = re.compile(':')
     
    # Pass the string in search
    # method of regex object.   
    if(regex.search(string) != None):
        return True
    
def detectdate(test_str):
    words = test_str.split()
    for word in words:
        if len(word) == 10 and word[2] == "." and word[5] == ".":
            return True
        
def flatten_list(lst):
    result = []
    for item in lst:
        if isinstance(item, list):
            # If the item is a list, recursively flatten it
            result.extend(flatten_list(item))
        else:
            # If the item is not a list, add it to the result
            result.append(item)
    return result

def mainFun1(image_path):
    # Load the image
    image = cv2.imread(image_path)

    # cropped image
    image = image[80:1680, 0:4000]

    # Convert the image to grayscale (if it's not already)
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # Apply a median filter to remove speckles and enhance clarity
    image = cv2.GaussianBlur(gray_image, (7, 7), 0)  # Adjust kernel size as needed
    # Adjust the kernel size as needed

    # Save the filtered image (optional)
    cv2.imwrite('filtered_img.jpg', image)

    # Perform OCR on the filtered image
    import pytesseract

    # Configure Tesseract OCR
   # pytesseract.pytesseract.tesseract_cmd = r'C:\\Program Files\\Tesseract-OCR\\tesseract.exe'

    # Perform OCR on the filtered image
    text = pytesseract.image_to_string(image, lang='eng', config='--psm 4')
    # print("text:", text)


    key_list = []
    val_list = []
    lint = ''

    words = text.split()

    for word in words:
        if word.isalpha():
            # Word contains only alphabets, so it's a key
            lint = lint + ' ' + word
        elif isfloat(word) or run(word) or word.isalnum() or detectdate(word):
            # Word contains only numbers, so it's a value
            if lint:
                # Ensure there's a corresponding key before adding the value
                num = word
                key_list.append(lint)
                val_list.append(num)
                lint = ''
            elif num:
                temp = []
                temp.append(num)
                temp.append(word)
                val_list.pop()
                val_list.append(temp)
                num = ''

    del key_list[2:4], val_list[2:4]
    del key_list[3], val_list[3]
    del key_list[4:7], val_list[4:7]
    del key_list[5], val_list[5]
    del key_list[9:15], val_list[9:15]
    del key_list[10:12], val_list[10:12]

    # Flatten the list1 to create list2
    flat_list = flatten_list(val_list)

    # Define keys for the dictionary
    keys1 = ["Date", "Time", "TrainNumber", "WheelSetNumber", "B-LHS-Diameter", "B-RHS-Diameter", "B-LHS-FlangeThickness", "B-RHS-FlangeThickness", "B-LHS-FlangeWidth", "B-RHS-FlangeWidth", "B-LHS-Qr", "B-RHS-Qr", "B-LHS-RadialDeviation", "B-RHS-RadialDeviation", "A-LHS-Diameter", "A-RHS-Diameter", "A-LHS-FlangeThickness", "A-RHS-FlangeThickness", "A-LHS-FlangeWidth", "A-RHS-FlangeWidth", "A-LHS-Qr", "A-RHS-Qr", "A-LHS-RadialDeviation", "A-RHS-RadialDeviation"]

    # Create a dictionary by zipping keys and values from the flattened list
    res_dict = dict(zip(keys1, flat_list))

    if float(res_dict["A-LHS-Diameter"]) > 900:
        res_dict["AfterCut"] = True
    else:
        res_dict["AfterCut"] = False

    # comment these when verification page is made
    # res_dict["Time"] = "02:58:15"
    # res_dict["WheelSetNumber"] = 10
    # res_dict["TrainNumber"] = "OL014"
    #res_dict["B-LHS-Diameter"] = 836.454
    return res_dict

def mainFun2(res_dict):
    # Define your Supabase project URL and API key
    supabase_url = "https://typmqqidaijuobjosrpi.supabase.co"
    supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cG1xcWlkYWlqdW9iam9zcnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTM0MzkzODAsImV4cCI6MjAwOTAxNTM4MH0.Ihde633Yj9FFaQ7hKLooxDxaFEno4fK8YxSb3gy8S4c"

    # Initialize the Supabase client
    supabase_client = supabase.Client(supabase_url, supabase_key)

    # Define your table name 1 in Supabase
    table_name1 = "UGLWheelRawData"

    #Insert the data into the Supabase table 1
    response = supabase_client.table(table_name1) \
              .insert([res_dict]) \
              .execute()

    keys2 = ["Date", "Time", "TrainNumber", "WheelSetNumber", "B-LHS-Diameter", "B-RHS-Diameter", "B-LHS-FlangeThickness", "B-RHS-FlangeThickness", "B-LHS-FlangeWidth", "B-RHS-FlangeWidth"]
    mes_dict = {key:value for key, value in res_dict.items() if key in keys2}

    mes_dict["Mode"] = "UGL"
    mes_dict["LHS-Diameter"] = mes_dict.pop("B-LHS-Diameter")
    mes_dict["RHS-Diameter"] = mes_dict.pop("B-RHS-Diameter")
    mes_dict["LHS-FlangeThickness"] = mes_dict.pop("B-LHS-FlangeThickness")
    mes_dict["RHS-FlangeThickness"] = mes_dict.pop("B-RHS-FlangeThickness")
    mes_dict["LHS-FlangeWidth"] = mes_dict.pop("B-LHS-FlangeWidth")
    mes_dict["RHS-FlangeWidth"] = mes_dict.pop("B-RHS-FlangeWidth")

    # Define your table name 2 in Supabase
    table_name2 = "ConsolidatedWheelRawData"

    # Insert the data into the Supabase table 2
    response = supabase_client.table(table_name2) \
              .insert([mes_dict]) \
              .execute()

    mainFun3(res_dict)