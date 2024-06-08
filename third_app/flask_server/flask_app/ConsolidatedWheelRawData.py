import supabase

# Define your Supabase project URL and API key
supabase_url = "https://typmqqidaijuobjosrpi.supabase.co"
supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cG1xcWlkYWlqdW9iam9zcnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTM0MzkzODAsImV4cCI6MjAwOTAxNTM4MH0.Ihde633Yj9FFaQ7hKLooxDxaFEno4fK8YxSb3gy8S4c"

# Initialize the Supabase client
supabase_client = supabase.Client(supabase_url, supabase_key)

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

def mainFun3(res_dict):
    trainNumber = res_dict["TrainNumber"]
    wheelSetNumber = res_dict["WheelSetNumber"]
    data = []

    table_name = "ConsolidatedWheelRawData"

    dec = wheelSetNumber
    shount, count = supabase_client.table(table_name) \
                        .select("*") \
                        .eq("TrainNumber", trainNumber) \
                        .eq("WheelSetNumber", wheelSetNumber) \
                        .execute()
    if shount[1] != []:
        data.append(shount[1])
    while (dec - 1) % 4 >= 1:
        dec = dec - 1
        shount, count = supabase_client.table(table_name) \
                        .select("*") \
                        .eq("TrainNumber", trainNumber) \
                        .eq("WheelSetNumber", dec) \
                        .execute()
        if shount[1] != []:
            data.append(shount[1])

    inc = wheelSetNumber
    while inc % 4 != 0:
        inc = inc + 1
        shount, count = supabase_client.table(table_name) \
                        .select("*") \
                        .eq("TrainNumber", trainNumber) \
                        .eq("WheelSetNumber", inc) \
                        .execute()
        if shount[1] != []:
            data.append(shount[1])

    data = flatten_list(data)

    # choosing only recent data
    for x in range(len(data) - 1):
        for y in range(x + 1, len(data)):
            if data[x]["WheelSetNumber"] == data[y]["WheelSetNumber"]:
                if data[x]["Time"] < data[y]["Time"]:
                    data[x]["TrainNumber"] = "999"
    
    x = 0
    while x < len(data):
        if data[x]["TrainNumber"] == "999":
            del data[x]
        else:
            x = x + 1

    # checking for 2mm difference in Diameter between same axel wheels
    x = 0
    while x < len(data):
        dif = abs(data[x]["LHS-Diameter"] - data[x]["RHS-Diameter"])
        data[x]["Dif-DiameterAxel"] = dif
        
        if dif < 2:
            data[x]["Fit-DiameterAxel"] = True
        else:
            data[x]["Fit-DiameterAxel"] = False
        x = x + 1

    # checking for 4mm difference in Diameter between same bogie wheels
    x = 0
    while x < len(data):
        if data[x]["WheelSetNumber"] % 2 == 0:
            diameters = []
            y = 0
            while y < len(data):
                if data[y]["WheelSetNumber"] == (data[x]["WheelSetNumber"] - 1):
                    diameters.append(data[x]["LHS-Diameter"])
                    diameters.append(data[x]["RHS-Diameter"])
                    diameters.append(data[y]["LHS-Diameter"])
                    diameters.append(data[y]["RHS-Diameter"])

                    dif = max(diameters) - min(diameters)
                    data[x]["Dif-DiameterBogie"] = dif
                    data[y]["Dif-DiameterBogie"] = dif
                    
                    if dif < 4:
                        data[x]["Fit-DiameterBogie"] = True
                        data[y]["Fit-DiameterBogie"] = True
                    else:
                        if max(diameters) == diameters[0] or max(diameters) == diameters[1]:
                            data[x]["Fit-DiameterBogie"] = False
                            data[y]["Fit-DiameterBogie"] = True
                        if max(diameters) == diameters[2] or max(diameters) == diameters[3]:
                            data[y]["Fit-DiameterBogie"] = False
                            data[x]["Fit-DiameterBogie"] = True
                y = y + 1
        x = x + 1
    
    # checking for 8mm difference in Diameter between same car wheels
    diameters = []
    x = 0
    while x < len(data):
        diameters.append(data[x]["LHS-Diameter"])
        diameters.append(data[x]["RHS-Diameter"])
        x = x + 1

    dif = max(diameters) - min(diameters)

    x = 0
    while x < len(data):
        data[x]["Dif-DiameterCar"] = dif
        x = x + 1
    
    if dif < 8:
        x = 0
        while x < len(data):
            data[x]["Fit-DiameterCar"] = True
            x = x + 1
    else:
        if max(diameters) == diameters[0] or max(diameters) == diameters[1]:
            data[0]["Fit-DiameterCar"] = False
            data[1]["Fit-DiameterCar"] = True
            data[2]["Fit-DiameterCar"] = True
            data[3]["Fit-DiameterCar"] = True
        if max(diameters) == diameters[2] or max(diameters) == diameters[3]:
            data[0]["Fit-DiameterCar"] = True
            data[1]["Fit-DiameterCar"] = False
            data[2]["Fit-DiameterCar"] = True
            data[3]["Fit-DiameterCar"] = True
        if max(diameters) == diameters[4] or max(diameters) == diameters[5]:
            data[0]["Fit-DiameterCar"] = True
            data[1]["Fit-DiameterCar"] = True
            data[2]["Fit-DiameterCar"] = False
            data[3]["Fit-DiameterCar"] = True
        if max(diameters) == diameters[6] or max(diameters) == diameters[7]:
            data[0]["Fit-DiameterCar"] = True
            data[1]["Fit-DiameterCar"] = True
            data[2]["Fit-DiameterCar"] = True
            data[3]["Fit-DiameterCar"] = False

    # checking for constraints of FlangeThickness and FlangeWidth
    x = 0
    while x < len(data):
        if data[x]["LHS-FlangeThickness"] <= 33 and data[x]["LHS-FlangeThickness"] >= 26:
            data[x]["LHS-Fit-FlangeThickness"] = True
        elif data[x]["LHS-FlangeThickness"] > 33 or data[x]["LHS-FlangeThickness"] < 26:
            data[x]["LHS-Fit-FlangeThickness"] = False
        if data[x]["RHS-FlangeThickness"] <= 33 and data[x]["RHS-FlangeThickness"] >= 26:
            data[x]["RHS-Fit-FlangeThickness"] = True
        elif data[x]["RHS-FlangeThickness"] > 33 or data[x]["RHS-FlangeThickness"] < 26:
            data[x]["RHS-Fit-FlangeThickness"] = False
        if data[x]["LHS-FlangeWidth"] <= 36 and data[x]["LHS-FlangeWidth"] >= 26:
            data[x]["LHS-Fit-FlangeWidth"] = True
        elif data[x]["LHS-FlangeWidth"] > 36 or data[x]["LHS-FlangeWidth"] < 26:
            data[x]["LHS-Fit-FlangeWidth"] = False
        if data[x]["RHS-FlangeWidth"] <= 36 and data[x]["RHS-FlangeWidth"] >= 26:
            data[x]["RHS-Fit-FlangeWidth"] = True
        elif data[x]["RHS-FlangeWidth"] > 36 or data[x]["RHS-FlangeWidth"] < 26:
            data[x]["RHS-Fit-FlangeWidth"] = False
        x = x + 1

    # update the ConsolidatedWheelRawData
    x = 0
    while x < len(data):
        response = supabase_client.table(table_name) \
                .update([data[x]]) \
                .eq("SR", data[x]["SR"]) \
                .execute()
        x = x + 1

def mainFun4(trainNumber):
    #trainNumber = "OL014"

    data = []
    table_name = "ConsolidatedWheelRawData"

    shount, count = supabase_client.table(table_name) \
                        .select("*") \
                        .eq("TrainNumber", trainNumber) \
                        .execute()
    if shount[1] != []:
        data.append(shount[1])

    data = flatten_list(data)

    # choosing only recent data
    for x in range(len(data) - 1):
        for y in range(x + 1, len(data)):
            if data[x]["WheelSetNumber"] == data[y]["WheelSetNumber"]:
                if data[x]["Time"] < data[y]["Time"]:
                    data[x]["TrainNumber"] = "999"

    x = 0
    while x < len(data):
        if data[x]["TrainNumber"] == "999":
            del data[x]
        else:
            x = x + 1
    
    # recognizing fit and unfit wheels
    x = 0
    while x < len(data):
        if data[x]["Fit-DiameterAxel"] == True and data[x]["Fit-DiameterBogie"] == True and data[x]["Fit-DiameterCar"] == True and data[x]["LHS-Fit-FlangeThickness"] == True and data[x]["RHS-Fit-FlangeThickness"] == True and data[x]["LHS-Fit-FlangeWidth"] == True and data[x]["RHS-Fit-FlangeWidth"] == True:
            data[x]["Fit"] = True
        else:
            data[x]["Fit"] = False
        x = x + 1

    keys = ["WheelSetNumber", "Fit"]

    send = []
    x = 0
    while x < len(data):
        mes_dict = {key:value for key, value in data[x].items() if key in keys}
        send.append(mes_dict)
        x = x + 1

    return send