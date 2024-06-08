import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:third_app/Screen/Wheel_Analysis/Page1.dart';
import 'package:third_app/Screen/fault_detection/Page3.dart';
import 'package:third_app/Screen/Fault_Data/first.dart';
import 'package:third_app/Screen/Wheel Data OCR/ocr.dart';
import 'package:third_app/Screen/Report/report.dart';
import 'package:third_app/Screen/crud_app/edit_faults.dart';
import 'package:third_app/Screen/mainPage/Home.dart';
import 'package:third_app/main.dart';
import 'package:third_app/app_state.dart';

void main() {
  runApp(MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primarySwatch: Colors.orange,
//         scaffoldBackgroundColor: Colors.black,
//       ),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EngineerDashboard(),
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.black,
      ),
    );
  }
}

class EngineerDashboard extends StatefulWidget {
  // final String role; // Define the named parameter 'role'

  // EngineerDashboard(
  //     {required this.role}); // Constructor with named parameter 'role'

  @override
  _EngineerDashboardState createState() => _EngineerDashboardState();
}

class _EngineerDashboardState extends State<EngineerDashboard> {
  int _selectedMenuItem = 0; // Track the selected menu item
  String occupation = AppState.occupation;
  String fullName = AppState.fullName;
  void _onMenuItemSelected(int index) {
    setState(() {
      _selectedMenuItem = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      drawer: MyDrawer(
        selectedMenuItem: _selectedMenuItem,
        onMenuItemSelected: _onMenuItemSelected,
      ),
      body: _getPage(_selectedMenuItem), // Show the selected page
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return Home();
      case 1:
        return Page1();
      case 2:
        return first();
      case 3:
        return Page3();
      case 4:
        return ocr();
      // case 5:
      //   return FaultsEditor();
      case 5:
        return ReportScreen();

      default:
        return Container(); // Return an empty container if index is out of range
    }
  }

  AppBar _buildAppBar() {
    Color appBarColor;

    // Set different app bar colors based on the selected menu item
    switch (_selectedMenuItem) {
      case 0:
        appBarColor = Colors.black; // Color for the first page
        break;
      case 1:
        appBarColor = Color(0xFF111112); // Color for the second page
        break;
      case 2:
        appBarColor = Color(0xFF111112); // Color for the third page
        break;
      case 3:
        appBarColor = Color(0xFF111112); // Color for the fourth page
        break;
      case 4:
        appBarColor = Color(0xFF111112); // Color for the fifth page
        break;
      case 5:
        appBarColor = Color(0xFF111112); // Color for the fifth page
        break;
      default:
        appBarColor = Colors.black; // Default color
    }

    return AppBar(
      backgroundColor: appBarColor,
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

          SizedBox(width: 450),
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
                  value: choice.toLowerCase(), // Use lowercase for consistency
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
                                  color:
                                      Colors.orange, // Set icon color to orange
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
                                color: Colors.black, // Set text color to black
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
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              choice,
                              style: TextStyle(
                                color: Colors.black, // Set text color to black
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
    );
  }
  // drawer: MyDrawer(
  //   selectedMenuItem: _selectedMenuItem,
  //   onMenuItemSelected: (int index) {
  //     setState(() {
  //       if (index == 0) {
  //         Navigator.push(context,
  //             MaterialPageRoute(builder: (context) => MyDashboard()));
  //       } else {
  //         _selectedMenuItem = index;
  //         print(_selectedMenuItem);
  //         if (index == 1) {
  //           Navigator.push(
  //               context, MaterialPageRoute(builder: (context) => Page1()));
  //         } else if (index == 2) {
  //           Navigator.push(
  //               context, MaterialPageRoute(builder: (context) => first()));
  //         } else if (index == 3) {
  //           Navigator.push(
  //               context, MaterialPageRoute(builder: (context) => Page3()));
  //         } else if (index == 4) {
  //           Navigator.push(
  //               context, MaterialPageRoute(builder: (context) => ocr()));
  //         } else if (index == 5) {
  //           Navigator.push(context,
  //               MaterialPageRoute(builder: (context) => PlotScreen()));
  //         } else {
  //           // Handle other menu items or scenarios if needed
  //           print('fail');
  //         }
  //       }
  //     });
  //     // Navigator.pop(context);
  //   },
  // ),
//     body: Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Container(
//             margin: EdgeInsets.only(top: 0, bottom: 20),
//             color: Color(0xddff8518),
//             height: 200,
//             width: 1250,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(
//                           left: 16.0, top: 0), // Adjust left padding
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Lahore Metro',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 30),
//                           Row(
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Passenger Capacity',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   SizedBox(height: 10),
//                                   Text(
//                                     '300 Person',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   SizedBox(height: 20),
//                                   Text(
//                                     'Total Staff',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   SizedBox(height: 10),
//                                   Text(
//                                     '345',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(width: 60),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Engine Fitness',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   SizedBox(height: 10),
//                                   Text(
//                                     '100%',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   SizedBox(height: 20),
//                                   Text(
//                                     'Maintenance and Repair',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   SizedBox(height: 10),
//                                   Text(
//                                     'On Schedule',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(5.0),
//                   child: Image.asset(
//                     'assets/pic.png',
//                     width: 500,
//                     height: 400,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 20),
//           Row(
//             mainAxisAlignment:
//                 MainAxisAlignment.start, // Align to the start (left)
//             children: [
//               SizedBox(width: 60),
//               Text(
//                 'Overview',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               SizedBox(width: 60),
//               _buildCard('Statistics', Icons.show_chart),
//               SizedBox(width: 180), // Add space between cards
//               _buildCard('Tasks', Icons.assignment),
//               SizedBox(width: 180),
//               _buildTimeContainer(),
//             ],
//           ),
//           SizedBox(height: 10),
//           SizedBox(height: 10),
//         ],
//       ),
//     ),
//   );
// }
}

class MyDrawer extends StatelessWidget {
  final int selectedMenuItem;
  final Function(int) onMenuItemSelected;

  const MyDrawer({
    Key? key,
    required this.selectedMenuItem,
    required this.onMenuItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFF313134),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              color: Color(0xFF313134),
              child: DrawerHeader(
                child: Center(
                  child: Text(
                    'MENU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF313134),
                ),
              ),
            ),
            Container(
              height: 910,
              color: Color(0xFF313134),
              child: Column(
                children: <Widget>[
                  _buildMenuItem(0, 'Home', Icons.home),
                  _buildMenuItem(1, 'Wheel Data Form', Icons.data_usage),
                  _buildMenuItem(2, 'Fault Data Form', Icons.edit),
                  _buildMenuItem(3, 'Fault Detection', Icons.warning),
                  _buildMenuItem(4, 'Wheel Analysis', Icons.analytics),
                  // _buildMenuItem(5, 'View Faults', Icons.error_outline),
                  _buildMenuItem(5, 'Report', Icons.description),
                  // _buildMenuItem(5, 'Spare Parts', Icons.settings),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index, String title, IconData icon) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: selectedMenuItem == index ? Color(0xddff8518) : Colors.white,
        ),
      ),
      onTap: () {
        onMenuItemSelected(index);
      },
      leading: Icon(
        icon,
        color: selectedMenuItem == index ? Color(0xddff8518) : Colors.white,
      ),
    );
  }
}
