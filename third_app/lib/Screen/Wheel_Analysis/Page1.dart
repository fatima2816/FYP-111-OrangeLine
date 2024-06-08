import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:third_app/Screen/Wheel_Analysis/generalInfo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Page1(),
    );
  }
}

class Page1 extends StatefulWidget {
  final String? path;

  Page1({Key? key, this.path}) : super(key: key);

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  TextEditingController _dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String dateError = ' ';

  void _validateDate(String input) {
    if (input.isNotEmpty) {
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      try {
        dateFormat.parseStrict(input);
        setState(() {
          dateError = ' ';
        });
      } catch (e) {
        setState(() {
          dateError = 'Invalid date format. Please use dd-mm-yyyy.';
        });
      }
    }
  }

  TextEditingController _timeController = TextEditingController();
  String timeError = ' ';

  void _validateTime(String input) {
    final timePattern = RegExp(r'^[0-2][0-9]:[0-5][0-9]:[0-5][0-9]$');

    if (!timePattern.hasMatch(input)) {
      setState(() {
        timeError = 'Invalid time format. Please use hh:mm:ss.';
      });
    } else {
      setState(() {
        timeError = ' ';
      });
    }
  }

  // Function to check if a string contains only integer values
  bool isInteger(String text) {
    for (int i = 0; i < text.length; i++) {
      int charCode = text.codeUnitAt(i);
      if (charCode < 48 || charCode > 57) {
        return false;
      }
    }
    return true;
  }

  void validateFields1() {
    _validateDate(_dateController.text);
    _validateTime(_timeController.text);

    // Check if trainNo contains only integers
    if (wheelSetNoController.text.isEmpty ||
        !isInteger(wheelSetNoController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid wheel set number.'),
        ),
      );
    } else if (_dateController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Date and Time fields cannot be empty.'),
        ),
      );
    } else {
      checkFields0(context);
    }
  }

  TextEditingController trainNoController = TextEditingController();
  TextEditingController wheelSetNoController = TextEditingController();
  String result = '';
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
    _timeController.text = DateFormat('HH:mm:ss').format(DateTime.now());
  }

  bool FieldsEmpty() {
    // Check if any of the TextControllers has empty text
    return trainNoController.text.isEmpty || wheelSetNoController.text.isEmpty;
  }

  void checkFields0(BuildContext context) {
    if (FieldsEmpty()) {
      // Show a Snackbar if any field is empty
      final snackBar = SnackBar(
        content: Text('Fields are empty.'),
        duration: Duration(seconds: 1),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // sendRequest();
    } else {
      sendPostRequest();
    }
  }

  Future<void> sendPostRequest() async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/general_info'); // Replace with your Flask API endpoint URL
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final data = <String, dynamic>{
      '_dateController': (_dateController.text),
      '_timeController': (_timeController.text),
      'trainNo': (trainNoController.text),
      'wheelSetNo': int.parse(wheelSetNoController.text),
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      print('Data sent successfully');
      print('Response: ${response.body}');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => generalInfo(),
        ),
      );
    } else {
      print('Failed to send data. Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // String currentDateTime = getCurrentDateTime();
    return Scaffold(
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
                                text: 'Wheel Data Entry',
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
                                    color: Color(0xddff8518),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(30, 0, 30, 0.18),
                              child: Text(
                                'Initial Measurements',
                                style: TextStyle(
                                  fontSize: 20.2151851654,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(40, 0, 0, 0.18),
                              child: Text(
                                'Final Measurements',
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
                            width: 470,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(0xFF222229),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 275,
                top: 280,
                child: Align(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5, // Add spacing between the text and "*"
                            ),
                            Text(
                              'Date',
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
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 250,
                              height: 50,
                              child: TextFormField(
                                controller: _dateController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'dd-mm-yyyy',
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.calendar_today),
                                    onPressed: () => selectDate(context),
                                  ),
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xddff8518),
                                      width: 2,
                                    ),
                                  ),
                                  errorText: dateError,
                                ),
                                onTap: () => selectDate(context),
                                onChanged: _validateDate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5, // Add spacing between the text and "*"
                            ),
                            Text(
                              'Time',
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
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 250,
                              height: 50,
                              child: TextFormField(
                                controller: _timeController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'hh:mm:ss',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,

                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xddff8518),
                                      width: 2,
                                    ),
                                  ),
                                  errorText: timeError,
                                  // errorBorder: OutlineInputBorder(
                                  //   borderSide: BorderSide(
                                  //     color: Color(
                                  //         0xddff8518), // Set the border color to orange for errors
                                  //     width: 2,
                                  //   ),
                                  // ),
                                ),
                                onChanged: _validateTime,
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
                left: 700,
                top: 280,
                child: Align(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5, // Add spacing between the text and "*"
                            ),
                            Text(
                              'Train Number',
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
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 250,
                              height: 40,
                              child: TextField(
                                controller: trainNoController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Enter train number',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xddff8518),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10), // Add spacing between the sections
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5, // Add spacing between the text and "*"
                            ),
                            Text(
                              'Wheel set Number',
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
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 250,
                              height: 40,
                              child: TextField(
                                controller: wheelSetNoController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Enter wheel set number',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xddff8518),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 150),
                      Padding(
                        padding: EdgeInsets.only(left: 240),
                        child: SizedBox(
                          width: 130,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              validateFields1();
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
