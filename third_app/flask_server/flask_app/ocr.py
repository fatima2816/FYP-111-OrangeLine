import pytesseract
import cv2
import numpy as np
import re
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


def perform_ocr(image_path):
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
    text = pytesseract.image_to_string(image, lang='eng', config='--psm 4')
    print('Text: $text')
        
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
    keys = ["Date", "Time", "TrainNumber", "WheelSetNumber", "B-LHS-Diameter", "B-RHS-Diameter", "B-LHS-FlangeThickness", "B-RHS-FlangeThickness", "B-LHS-FlangeWidth", "B-RHS-FlangeWidth", "B-LHS-Qr", "B-RHS-Qr", "B-LHS-RadialDeviation", "B-RHS-RadialDeviation", "A-LHS-Diameter", "A-RHS-Diameter", "A-LHS-FlangeThickness", "A-RHS-FlangeThickness", "A-LHS-FlangeWidth", "A-RHS-FlangeWidth", "A-LHS-Qr", "A-RHS-Qr", "A-LHS-RadialDeviation", "A-RHS-RadialDeviation"]
    # Create a dictionary by zipping keys and values from the flattened list
    res_dict = dict(zip(keys, flat_list))
    
    return res_dict