import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:third_app/Screen/mainPage/EngineerDashboard.dart';
import 'package:third_app/Screen/mainPage/ManagerDashboard.dart';
import 'package:third_app/main.dart';
import 'package:third_app/app_state.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WheelAnalysis(),
    );
  }
}

class WheelAnalysis extends StatefulWidget {
  const WheelAnalysis({Key? key}) : super(key: key);

  @override
  _WheelAnalysisState createState() => _WheelAnalysisState();
}

class _WheelAnalysisState extends State<WheelAnalysis> {
  String selected_train_no = 'OL001';
  int _selectedMenu = 0;
  List<String> trainNumbers = List.generate(27, (index) {
    int number = index + 1;
    String formattedNumber = 'OL${number.toString().padLeft(3, '0')}';
    return formattedNumber;
  });

  bool isTrainNumberSelected = false;
  String apiResponse = '';
  String occupation = AppState.occupation;
  String fullName = AppState.fullName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF111112),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: Image.asset(
                'assets/Logo.png',
                width: 70,
                height: 70,
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
                  child: SingleChildScrollView(
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
                                  text: 'Wheel Analysis',
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
                        Padding(
                          padding: EdgeInsets.only(left: 35, top: 42),
                          child: Row(
                            children: [
                              Text(
                                'Train Number',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Color(0xFFF5F5F5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 35, top: 6, bottom: 30),
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFF313134),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: DropdownButtonFormField<String>(
                                value: selected_train_no,
                                items: trainNumbers.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                        color: Color(0xFFF5F5F5),
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selected_train_no =
                                        newValue ?? selected_train_no;
                                    print(
                                        "Selected option: $selected_train_no");
                                    isTrainNumberSelected = true;
                                    TrainToFlask(selected_train_no);
                                  });
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFF313134),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFF8518),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                elevation: 1,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFFF5F5F5),
                                ),
                                dropdownColor: const Color(0xFF313134),
                              ),
                            ),
                          ),
                        ),
                        if (apiResponse.isNotEmpty)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.only(left: 35),
                              child: DataTable(
                                columns: [
                                  DataColumn(
                                      label: Text('Wheel Set Number',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white))),
                                  DataColumn(
                                      label: Text('Result',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white))),
                                ],
                                rows: (jsonDecode(apiResponse) as List<dynamic>)
                                    .map((item) {
                                  int wheelSetNumber = item['WheelSetNumber'];
                                  bool isFit = item['Fit'];

                                  return DataRow(cells: [
                                    DataCell(Text('$wheelSetNumber',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white))),
                                    DataCell(Text('${isFit ? 'Fit' : 'Unfit'}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white))),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 140,
                top: 300,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xddff8518), // Replace with your desired color
                    shape: BoxShape.circle, // Makes the container circular
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.white, // Icon color
                    iconSize: 35,
                    onPressed: () {
                      // Navigate back when the back button is pressed
                      // Navigator.pop(context);
                      if (occupation == 'Engineer') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EngineerDashboard(),
                          ),
                        );
                      } else if (occupation == 'Manager') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManagerDashboard(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> TrainToFlask(String selectedTrainNo) async {
    try {
      //const String apiUrl = 'http://192.168.0.115:8000/wheel_analysis';
      const String apiUrl = 'http://127.0.0.1:8000/wheel_analysis';
      final Map<String, String> jsonData = {
        'selected_train_no': selectedTrainNo,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonData), // Convert jsonData to JSON
      );

      if (response.statusCode == 200) {
        print('Data sent successfully');
        print('Response: ${response.body}');
        // Handle the response from the server
        setState(() {
          apiResponse = response.body; // Update the response state
        });
      } else {
        print('Failed to send data. Status code: ${response.statusCode}');
        print('Error: ${response.body}');
        // Handle the error
      }
    } catch (e) {
      print('Error: $e');
      // Handle any exceptions
    }
  }
}


// List<Widget> _buildWheelSetInfo() {
//   // Parse the API response as a list of maps
//   List<Map<String, dynamic>> wheelSetInfoList = jsonDecode(apiResponse);

//   // Create a list of Widgets to display the information
//   List<Widget> wheelSetInfoWidgets = [];

//   for (var wheelSetInfo in wheelSetInfoList) {
//     // Extract the 'WheelSetNumber' and 'Fit' values
//     int wheelSetNumber = wheelSetInfo['WheelSetNumber'];
//     bool isFit = wheelSetInfo['Fit'];

//     // Create a Widget to display the information
//     Widget infoWidget = ListTile(
//       title: Text('Wheel Set Number: $wheelSetNumber'),
//       subtitle: Text('Fit: ${isFit ? 'Yes' : 'No'}'),
//     );

//     // Add the infoWidget to the list
//     wheelSetInfoWidgets.add(infoWidget);
//   }

//   return wheelSetInfoWidgets;
// }

