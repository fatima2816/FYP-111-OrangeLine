import 'package:flutter/material.dart';
import 'dart:convert';
// Import the Uint8List type.
import 'package:http/http.dart' as http;
import 'package:third_app/app_state.dart';
import 'package:third_app/Screen/mainPage/EngineerDashboard.dart';
import 'package:third_app/Screen/mainPage/ManagerDashboard.dart';
import 'package:flutter/services.dart';
import 'package:third_app/main.dart';
import 'package:third_app/app_state.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Page2(),
    );
  }
}

class Page2 extends StatefulWidget {
  final String? path;

  Page2({Key? key, this.path}) : super(key: key);

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  String fullName = AppState.fullName;
  String occupation = AppState.occupation;

  TextEditingController ALWheelTreadController = TextEditingController();
  TextEditingController ARWheelTreadController = TextEditingController();
  TextEditingController ALFlangeThicknessController = TextEditingController();
  TextEditingController ARFlangeThicknessController = TextEditingController();
  TextEditingController ALFlangeHeightController = TextEditingController();
  TextEditingController ARFlangeHeightController = TextEditingController();
  TextEditingController ALFlangeGradientController = TextEditingController();
  TextEditingController ARFlangeGradientController = TextEditingController();
  TextEditingController ALRadialDeviationController = TextEditingController();
  TextEditingController ARRadialDeviationController = TextEditingController();

  void checkFields2(BuildContext context) {
    if (FieldsEmpty()) {
      // Show a Snackbar if any field is empty
      final snackBar = SnackBar(
        content: Text('Fields are empty.'),
        duration: Duration(seconds: 1),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // sendRequests();
    } else {
      sendRequests2();
    }
  }

  bool FieldsEmpty() {
    // Check if any of the TextControllers has empty text
    return ALWheelTreadController.text.isEmpty ||
        ARWheelTreadController.text.isEmpty ||
        ALFlangeThicknessController.text.isEmpty ||
        ARFlangeThicknessController.text.isEmpty ||
        ALFlangeHeightController.text.isEmpty ||
        ARFlangeHeightController.text.isEmpty ||
        ALFlangeGradientController.text.isEmpty ||
        ARFlangeGradientController.text.isEmpty ||
        ALRadialDeviationController.text.isEmpty ||
        ARRadialDeviationController.text.isEmpty;
  }

  bool isDoubleOrInteger(BuildContext context, String text) {
    try {
      if (text.isEmpty) {
        ScaffoldMessenger.of(context)
            .hideCurrentSnackBar(); // Hide the Snackbar
        return true; // Empty text is considered valid
      }

      double.parse(text);
      return true; // It's a valid double
    } catch (_) {
      try {
        int.parse(text);
        return true; // It's a valid integer
      } catch (_) {
        // Show a Snackbar with an error message
        final snackBar = SnackBar(
          content: Text('Invalid input.'),
          duration: Duration(seconds: 1),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        return false; // Invalid input
      }
    }
  }

  Future<void> sendRequests2() async {
    // Access the occupation variable

    final url = Uri.parse(
        'http://127.0.0.1:8000/final_measurement'); // Replace with your Flask API endpoint URL
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final data = <String, dynamic>{
      'ALWheelTread': double.tryParse(ALWheelTreadController.text) ?? 0.0,
      'ARWheelTread': double.tryParse(ARWheelTreadController.text) ?? 0.0,
      'ALFlangeThickness':
          double.tryParse(ALFlangeThicknessController.text) ?? 0.0,
      'ARFlangeThickness':
          double.tryParse(ARFlangeThicknessController.text) ?? 0.0,
      'ALFlangeHeight': double.tryParse(ALFlangeHeightController.text) ?? 0.0,
      'ARFlangeHeight': double.tryParse(ARFlangeHeightController.text) ?? 0.0,
      'ALFlangeGradient':
          double.tryParse(ALFlangeGradientController.text) ?? 0.0,
      'ARFlangeGradient':
          double.tryParse(ARFlangeGradientController.text) ?? 0.0,
      'ALRadialDeviation':
          double.tryParse(ALRadialDeviationController.text) ?? 0.0,
      'ARRadialDeviation':
          double.tryParse(ARRadialDeviationController.text) ?? 0.0,
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
          builder: (context) => EngineerDashboard(),
        ),
      );
    } else {
      print('Failed to send data. Error: ${response.statusCode}');
    }
  }

// ...
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
                                    color: Color(0xFFFFFFFF),
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
                                  color: Color(0xddff8518),
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
                            width: 510,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(0xFF222229),
                            ),
                          ),
                          Container(
                            // No margin for the second Container
                            width: 240,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(0xddff8518),
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
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            Text(
                              'Wheel Tread Diameter',
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
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              height: 40,
                              child: TextField(
                                controller: ALWheelTreadController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Left Wheel',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xddff8518),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (text) {
                                  // Check if the entered text is a double or integer
                                  isDoubleOrInteger(context, text);
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              height: 40,
                              child: TextField(
                                controller: ARWheelTreadController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Right Wheel',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xddff8518),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (text) {
                                  // Check if the entered text is a double or integer
                                  isDoubleOrInteger(context, text);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20), // Add spacing between the sections
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5, // Add spacing between the text and "*"
                            ),
                            Text(
                              'Flange Thickness',
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
                              width: 150,
                              height: 40,
                              child: TextField(
                                controller: ALFlangeThicknessController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Left Wheel',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xddff8518),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (text) {
                                  // Check if the entered text is a double or integer
                                  isDoubleOrInteger(context, text);
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              height: 40,
                              child: TextField(
                                controller: ARFlangeThicknessController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Right Wheel',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xddff8518),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (text) {
                                  // Check if the entered text is a double or integer
                                  isDoubleOrInteger(context, text);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20), // Add spacing between the sections
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5, // Add spacing between the text and "*"
                            ),
                            Text(
                              'Flange Height',
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
                              width: 150,
                              height: 40,
                              child: TextField(
                                controller: ALFlangeHeightController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Left Wheel',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xddff8518),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (text) {
                                  // Check if the entered text is a double or integer
                                  isDoubleOrInteger(context, text);
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              height: 40,
                              child: TextField(
                                controller: ARFlangeHeightController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Right Wheel',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xddff8518),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (text) {
                                  // Check if the entered text is a double or integer
                                  isDoubleOrInteger(context, text);
                                },
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
                            Text(
                              'Flange Gradient',
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
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              height: 40,
                              child: TextField(
                                controller: ALFlangeGradientController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Left Wheel',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xddff8518),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (text) {
                                  // Check if the entered text is a double or integer
                                  isDoubleOrInteger(context, text);
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              height: 40,
                              child: TextField(
                                controller: ARFlangeGradientController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Right Wheel',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xddff8518),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (text) {
                                  // Check if the entered text is a double or integer
                                  isDoubleOrInteger(context, text);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20), // Add spacing between the sections
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5, // Add spacing between the text and "*"
                            ),
                            Text(
                              'Radial Deviation',
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
                              width: 150,
                              height: 40,
                              child: TextField(
                                controller: ALRadialDeviationController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Left Wheel',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xddff8518),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (text) {
                                  // Check if the entered text is a double or integer
                                  isDoubleOrInteger(context, text);
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              height: 40,
                              child: TextField(
                                controller: ARRadialDeviationController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Right Wheel',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xddff8518),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (text) {
                                  // Check if the entered text is a double or integer
                                  isDoubleOrInteger(context, text);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 140),
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 70),
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
                                  // Navigate to the RecognizePage when the button is clicked
                                  // selectedValue = getSelectedValue();
                                  checkFields2(context);
                                },
                                child: Text(
                                  'Submit',
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
            ],
          ),
        ),
      ),
    );
  }
}
