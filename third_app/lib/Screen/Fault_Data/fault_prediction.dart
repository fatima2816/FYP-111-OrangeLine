import 'package:flutter/material.dart';
import 'dart:convert';
// Import the Uint8List type.
import 'package:http/http.dart' as http;
import 'package:third_app/Screen/mainPage/EngineerDashboard.dart';
import 'package:third_app/main.dart';
import 'package:third_app/app_state.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FaultPrediction(),
    );
  }
}

class FaultPrediction extends StatefulWidget {
  final String? path;

  FaultPrediction({Key? key, this.path}) : super(key: key);

  @override
  _FaultPredictionState createState() => _FaultPredictionState();
}

class _FaultPredictionState extends State<FaultPrediction> {
  TextEditingController FaultInputController = TextEditingController();
  TextEditingController FaultSolutionController = TextEditingController();
  String fullName = AppState.fullName;
  String occupation = AppState.occupation;

  Future<void> getFaultSolution(String faultDescription) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/extract_fault_solution'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'user_entry_text': faultDescription}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final faultSolutions = data['fault_solutions'];

      // Update the FaultSolutionController text field with the obtained fault solutions
      FaultSolutionController.text = faultSolutions.join('\n');
    } else {
      // Handle error, you can show a snackbar or display an error message
      print('Failed to get fault solutions: ${response.statusCode}');
    }
  }

  void clearTextFields() {
    FaultInputController.clear();
    FaultSolutionController.clear();
  }

  Future<void> sendDataRequest() async {
    final url = Uri.parse('http://127.0.0.1:8000/fault_detection_info');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final data = <String, dynamic>{
      'faultdescController': (FaultInputController.text),
      'faultsolController': (FaultSolutionController.text),
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      print('Data sent successfully');
      print('Response: ${response.body}');

      clearTextFields();
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
      body: Container(
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
                                color: Color(0xFFFFFFFF),
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
                            color: Color(0xddff8518),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Padding(
                      padding: EdgeInsets.only(left: 60),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 5, // Add spacing between the text and "*"
                          ),
                          Text(
                            'Fault Description',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              color: Color(0xffffffff),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(left: 60),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 650,
                            height: 100,
                            child: TextField(
                              maxLines: 6,
                              controller: FaultInputController,
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                color:
                                    Colors.white, // Set the text color to black
                              ),
                              decoration: InputDecoration(
                                hintText: 'Add Fault description',
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xddff8518),
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xddff8518),
                                    width: 2,
                                  ),
                                ),
                              ),
                              onEditingComplete: () {
                                // Call the function to get fault solutions
                                getFaultSolution(FaultInputController.text);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    Padding(
                      padding: EdgeInsets.only(left: 60),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 5, // Add spacing between the text and "*"
                          ),
                          Text(
                            'Fault Solution',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              color: Color(0xffffffff),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(left: 60),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 650,
                            height: 100,
                            child: TextField(
                              maxLines: 6,
                              controller: FaultSolutionController,
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                color:
                                    Colors.white, // Set the text color to black
                              ),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xddff8518),
                                    width: 2,
                                  ),
                                ),
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
                  ],
                ),
              ),
            ),
            Positioned(
              left: 785,
              top: 590,
              child: Align(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Row(
                        children: [
                          SizedBox(height: 5),
                          SizedBox(width: 10),
                          SizedBox(
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
                          SizedBox(width: 10), // Add some space between buttons
                          SizedBox(
                            width: 130,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                 Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EngineerDashboard(),
        ),
      );
                                // sendDataRequest();
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
    );
  }
}
