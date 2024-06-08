import 'package:flutter/material.dart';
// Import the Uint8List type.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:third_app/Screen/mainPage/EngineerDashboard.dart';
import 'package:third_app/main.dart';
import 'package:third_app/app_state.dart';
import 'package:third_app/Screen/Fault_Data/fault_prediction.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Page3(),
    );
  }
}

class Page3 extends StatefulWidget {
  final String? path;

  Page3({Key? key, this.path}) : super(key: key);

  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  String selectedValue5 = 'Open'; // Default selected value

  String fullName = AppState.fullName;
  String occupation = AppState.occupation;
  bool? isChecked = false;
  bool? isChecked2 = false;
  bool? isChecked3 = false;
  bool? isChecked4 = false;
  // bool selectedValue = false;
// ...
  bool getSelectedValue() {
    if (isChecked == true) {
      return true; // 'Yes' is selected
    } else if (isChecked2 == true) {
      return false; // 'No' is selected
    }
    return false;
  }

  TextEditingController _resdateController = TextEditingController();
  DateTime selectedResDate = DateTime.now();
  String dateErrorRes = ' ';

  void _validateResDate(String input) {
    if (input.isNotEmpty) {
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      try {
        dateFormat.parseStrict(input);
        setState(() {
          dateErrorRes = ' ';
        });
      } catch (e) {
        setState(() {
          dateErrorRes = 'Invalid date format. Please use dd-mm-yyyy.';
        });
      }
    }
  }

  void validateFields() {
    _validateResDate(_resdateController.text);
  }

  Future<void> selectResDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedResDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedResDate) {
      setState(() {
        selectedResDate = picked;
        _resdateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> sendDataInDatabase(String selected, bool? isChecked,
      bool? isChecked2, bool? isChecked3, bool? isChecked4) async {
    final data = {
      '_resdateController': (_resdateController.text),
      'status': selected,
      'sparePartsConsumed':
          isChecked != null ? (isChecked ? 'Yes' : 'No') : 'No',
      'partsSwapped': isChecked3 != null ? (isChecked3 ? 'Yes' : 'No') : 'No',
    };
    final url = Uri.parse(
        'http://127.0.0.1:8000/fault_status'); // Replace with your Flask API endpoint URL

    print(data);
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Data sent successfully');
      print('Response: ${response.body}');
    } else {
      print('Failed to send data. Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF111112),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Add an image here
            Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: Image.asset(
                'assets/Logo.png', // Replace with your image asset
                width: 70, // Adjust the width as needed
                height: 70, // Adjust the height as needed
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orange Line Maintenance System',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),

            SizedBox(width: 510),
            Icon(Icons.person, color: Colors.white), // Display the person icon
            SizedBox(width: 5), // Add some space between the icon and the text
            Text(
              'Welcome, $fullName', // Display user's full name
              style: TextStyle(color: Colors.white),
            ),
            PopupMenuButton<String>(
              offset: Offset(0, 40),
              icon: Icon(Icons.arrow_drop_down,
                  color: Colors.white), // Display the dropdown icon
              onSelected: (value) {
                if (value == 'logout') {
                  // Navigate to the login page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  'Logout', // Logout option
                ].map((String choice) {
                  return PopupMenuItem<String>(
                    value:
                        choice.toLowerCase(), // Use lowercase for consistency
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {}, // Empty onTap handler
                                  child: Icon(
                                    Icons.person, // User icon
                                    color: Colors
                                        .orange, // Set icon color to orange
                                    size: 40, // Increase icon size
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                            height:
                                8), // Add some space between the icon and text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {}, // Empty onTap handler
                              child: Text(
                                '$fullName - $occupation', // Display user's name and occupation
                                style: TextStyle(
                                  color:
                                      Colors.black, // Set text color to black
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (choice ==
                            'Logout') // Check if the item is the logout option
                          InkWell(
                            onTap: () {
                              // Handle logout option
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  choice,
                                  style: TextStyle(
                                    color:
                                        Colors.black, // Set text color to black
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (choice !=
                            'Logout') // Display non-pressable items as simple text
                          Container(
                            alignment: Alignment.center,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                choice,
                                style: TextStyle(
                                  color:
                                      Colors.black, // Set text color to black
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.orange, // Set the icon (menu) color to orange
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 720,
          width: 1370,
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/background.png'),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 250,
                top: 50,
                child: Container(
                  width: 895,
                  height: 590,
                  decoration: BoxDecoration(
                    color: Color(0xFF313134),
                    borderRadius: BorderRadius.circular(20.2151851654),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(50, 15, 0, 25),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 26.2151851654,
                              fontWeight: FontWeight.w400,
                              height: 1.2125,
                              color: Color(0xFFFFFFFF),
                            ),
                            children: [
                              TextSpan(
                                text: 'Fault Data Entry',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 35,
                                  fontWeight: FontWeight.normal,
                                  height: 1.2125,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              TextSpan(text: ' '),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(55, 0, 0, 0),
                        padding: EdgeInsets.fromLTRB(41, 20, 12, 20),
                        height: 80,
                        width: 750,
                        decoration: BoxDecoration(
                          color: Color(0xFF222229),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 43, 0.18),
                              child: Center(
                                child: Text(
                                  'General Information',
                                  style: TextStyle(
                                    fontSize: 20.2151851654,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(30, 0, 30, 0.18),
                              child: Text(
                                'Fault Status',
                                style: TextStyle(
                                  fontSize: 20.2151851654,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xddff8518),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(40, 0, 0, 0.18),
                              child: Text(
                                'Fault Detection',
                                style: TextStyle(
                                  fontSize: 20.2151851654,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(55, 0, 0, 0.10),
                            width: 280,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(0xddff8518),
                            ),
                          ),
                          Container(
                            // No margin for the second Container
                            width: 180,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(0xddff8518),
                            ),
                          ),
                          Container(
                            // No margin for the second Container
                            width: 290,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(0xFF222229),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 55),
                      Padding(
                        padding: EdgeInsets.only(left: 70),
                        child: Row(
                          children: [
                            Text(
                              'Fault Status',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                                color: Color(0xffffffff),
                              ),
                            ),
                            SizedBox(
                              width: 5, // Add spacing between the text and "*"
                            ),
                            Text(
                              '*',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 70),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 168,
                              height: 40,
                              child: DropdownButton<String>(
                                value: selectedValue5,
                                items: [
                                  'Open',
                                  'Closed',
                                  'Pending',
                                  'Under Observation',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedValue5 = newValue!;
                                  });
                                },
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Color(0xddff8518)),
                                iconSize: 24,
                                isExpanded: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.only(left: 60),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5, // Add spacing between the text and "*"
                            ),
                            Text(
                              'Resolution Date',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                                color: Color(0xffffffff),
                              ),
                            ),
                            Text(
                              ' *',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: EdgeInsets.only(left: 60),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 180,
                              height: 50,
                              child: TextFormField(
                                controller: _resdateController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'dd-mm-yyyy',
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.calendar_today),
                                    onPressed: () => selectResDate(context),
                                  ),
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xddff8518),
                                      width: 2,
                                    ),
                                  ),
                                  errorText: dateErrorRes,
                                ),
                                onTap: () => selectResDate(context),
                                onChanged: _validateResDate,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 220,
                top: 590,
                child: Align(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(height: 0),
                            Padding(
                              padding: EdgeInsets.only(left: 570),
                              child: SizedBox(
                                width: 130,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Navigate back when the back button is pressed
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Back',
                                    style: TextStyle(
                                      color: Color(0xffffffff),
                                      fontSize: 17,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xddff8518),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 130,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  sendDataInDatabase(selectedValue5, isChecked,
                                      isChecked2, isChecked3, isChecked4);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FaultPrediction(), // Provide the role parameter here
                                    ),
                                  );
                                },
                                child: Text(
                                  'Next',
                                  style: TextStyle(
                                    color: Color(0xffffffff),
                                    fontSize: 17,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xddff8518),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 710,
                top: 280,
                child: Align(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 60),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5, // Add spacing between the text and "*"
                            ),
                            Text(
                              'Spare Parts Consumed',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                                color: Color(0xffffffff),
                              ),
                            ),
                            Text(
                              ' *',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left:
                                    60), // Use EdgeInsets.only for left padding
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isChecked,
                                  activeColor: Color(0xddff8518),
                                  onChanged: (newBool) {
                                    setState(() {
                                      isChecked = newBool;
                                    });
                                  },
                                ),
                                Text('Yes'),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left:
                                    60), // Use EdgeInsets.only for left padding
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isChecked2,
                                  activeColor: Color(0xddff8518),
                                  onChanged: (newBool) {
                                    setState(() {
                                      isChecked2 = newBool;
                                    });
                                  },
                                ),
                                Text('No'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20), // Add spacing between the sections
                      Padding(
                        padding: EdgeInsets.only(left: 60),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5, // Add spacing between the text and "*"
                            ),
                            Text(
                              'Parts Swapped',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                                color: Color(0xffffffff),
                              ),
                            ),
                            Text(
                              ' *',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left:
                                    60), // Use EdgeInsets.only for left padding
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isChecked3,
                                  activeColor: Color(0xddff8518),
                                  onChanged: (newBool) {
                                    setState(() {
                                      isChecked3 = newBool;
                                    });
                                  },
                                ),
                                Text('Yes'),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left:
                                    60), // Use EdgeInsets.only for left padding
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isChecked4,
                                  activeColor: Color(0xddff8518),
                                  onChanged: (newBool) {
                                    setState(() {
                                      isChecked4 = newBool;
                                    });
                                  },
                                ),
                                Text('No'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Positioned(
              //   left: 10,
              //   top: 10,
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: Color(0xddff8518), // Replace with your desired color
              //       shape: BoxShape.circle, // Makes the container circular
              //     ),
              //     child: IconButton(
              //       icon: Icon(Icons.arrow_back),
              //       color: Colors.white, // Icon color
              //       onPressed: () {
              //         // Navigate back when the back button is pressed
              //         Navigator.pop(context);
              //       },
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
