import 'package:flutter/material.dart';
import 'data_manager.dart';
import 'package:third_app/main.dart';
//import 'app_data.dart';
import 'package:third_app/app_state.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InitMeasurements(),
    );
  }
}

class CustomTextWidget extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final double letterSpacing;

  const CustomTextWidget({
    Key? key,
    required this.text,
    this.textStyle = const TextStyle(
      fontFamily: 'Open Sans',
      fontSize: 30,
      fontWeight: FontWeight.w400,
      color: Color(0xFFFF8518),
    ),
    this.letterSpacing = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textStyle.copyWith(letterSpacing: letterSpacing),
    );
  }
}

class InitMeasurements extends StatefulWidget {
  const InitMeasurements({super.key});

  @override
  _InitMeasurementsState createState() => _InitMeasurementsState();
}

class _InitMeasurementsState extends State<InitMeasurements> {
  String? selectedOption = 'No';
  String fullName = AppState.fullName;
  String occupation = AppState.occupation;
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
                top: 30,
                child: Container(
                  width: 895,
                  height: 590,
                  decoration: BoxDecoration(
                    color: Color(0xFF313134),
                    borderRadius: BorderRadius.circular(20.2151851654),
                  ),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 35, top: 75),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextWidget(
                                  text: 'Initial',
                                  letterSpacing: 2.0,
                                ),
                                SizedBox(height: 8),
                                CustomTextWidget(
                                  text: 'Measurements',
                                  letterSpacing: 2.0,
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.only(left: 35, top: 42),
                              child: Row(
                                children: [
                                  CustomTextWidget(
                                    text: 'Diameter',
                                    textStyle: TextStyle(
                                      fontSize: 22,
                                      color: Color(0xFFF5F5F5),
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                            padding: const EdgeInsets.only(left: 35, top: 6),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Container(
                                      width: 150,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ), // Adjust the width as needed
                                      child: TextField(
                                        onChanged: (newValue) {
                                          DataManager()
                                                  .trainData['B-LHS-Diameter'] =
                                              newValue;
                                        },
                                        style: const TextStyle(
                                          color: Color(0xFFF5F5F5),
                                        ),
                                        controller: TextEditingController(
                                            text: DataManager().trainData[
                                                    'B-LHS-Diameter'] ??
                                                ''),
                                        decoration: InputDecoration(
                                          hintText: 'Left',
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          filled: true,
                                          fillColor: const Color(0xFF313134),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFFF8518),
                                                width: 2.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    width:
                                        16), // Add spacing between the two columns
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Container(
                                      width: 150,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ), // Adjust the width as needed
                                      child: TextField(
                                        onChanged: (newValue) {
                                          DataManager()
                                                  .trainData['B-RHS-Diameter'] =
                                              newValue;
                                        },
                                        style: const TextStyle(
                                          color: Color(0xFFF5F5F5),
                                        ),
                                        controller: TextEditingController(
                                            text: DataManager().trainData[
                                                    'B-RHS-Diameter'] ??
                                                ''),
                                        decoration: InputDecoration(
                                          hintText: 'Right',
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          filled: true,
                                          fillColor: const Color(0xFF313134),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFFF8518),
                                                width: 2.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.only(left: 35, top: 42),
                              child: Row(
                                children: [
                                  CustomTextWidget(
                                    text: 'Flange Thickness',
                                    textStyle: TextStyle(
                                      fontSize: 22,
                                      color: Color(0xFFF5F5F5),
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                            padding: const EdgeInsets.only(left: 35, top: 6),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Container(
                                      width: 150,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ), // Adjust the width as needed
                                      child: TextField(
                                        onChanged: (newValue) {
                                          DataManager().trainData[
                                                  'B-LHS-FlangeThickness'] =
                                              newValue;
                                        },
                                        style: const TextStyle(
                                          color: Color(0xFFF5F5F5),
                                        ),
                                        controller: TextEditingController(
                                            text: DataManager().trainData[
                                                    'B-LHS-FlangeThickness'] ??
                                                ''),
                                        decoration: InputDecoration(
                                          hintText: 'Left',
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          filled: true,
                                          fillColor: const Color(0xFF313134),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFFF8518),
                                                width: 2.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    width:
                                        16), // Add spacing between the two columns
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Container(
                                      width: 150,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ), // Adjust the width as needed
                                      child: TextField(
                                        onChanged: (newValue) {
                                          DataManager().trainData[
                                                  'B-RHS-FlangeThickness'] =
                                              newValue;
                                        },
                                        style: const TextStyle(
                                          color: Color(0xFFF5F5F5),
                                        ),
                                        controller: TextEditingController(
                                            text: DataManager().trainData[
                                                    'B-RHS-FlangeThickness'] ??
                                                ''),
                                        decoration: InputDecoration(
                                          hintText: 'Right',
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          filled: true,
                                          fillColor: const Color(0xFF313134),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFFF8518),
                                                width: 2.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.only(left: 35, top: 42),
                              child: Row(
                                children: [
                                  CustomTextWidget(
                                    text: 'Flange Width',
                                    textStyle: TextStyle(
                                      fontSize: 22,
                                      color: Color(0xFFF5F5F5),
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                            padding: const EdgeInsets.only(left: 35, top: 6),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Container(
                                      width: 150,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ), // Adjust the width as needed
                                      child: TextField(
                                        onChanged: (newValue) {
                                          DataManager().trainData[
                                              'B-LHS-FlangeWidth'] = newValue;
                                        },
                                        style: const TextStyle(
                                          color: Color(0xFFF5F5F5),
                                        ),
                                        controller: TextEditingController(
                                            text: DataManager().trainData[
                                                    'B-LHS-FlangeWidth'] ??
                                                ''),
                                        decoration: InputDecoration(
                                          hintText: 'Left',
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          filled: true,
                                          fillColor: const Color(0xFF313134),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFFF8518),
                                                width: 2.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    width:
                                        16), // Add spacing between the two columns
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Container(
                                      width: 150,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ), // Adjust the width as needed
                                      child: TextField(
                                        onChanged: (newValue) {
                                          DataManager().trainData[
                                              'B-RHS-FlangeWidth'] = newValue;
                                        },
                                        style: const TextStyle(
                                          color: Color(0xFFF5F5F5),
                                        ),
                                        controller: TextEditingController(
                                            text: DataManager().trainData[
                                                    'B-LHS-FlangeWidth'] ??
                                                ''),
                                        decoration: InputDecoration(
                                          hintText: 'Right',
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          filled: true,
                                          fillColor: const Color(0xFF313134),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFFF8518),
                                                width: 2.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.only(left: 35, top: 42),
                              child: Row(
                                children: [
                                  CustomTextWidget(
                                    text: 'Flange Gradient',
                                    textStyle: TextStyle(
                                      fontSize: 22,
                                      color: Color(0xFFF5F5F5),
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                            padding: const EdgeInsets.only(left: 35, top: 6),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Container(
                                      width: 150,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ), // Adjust the width as needed
                                      child: TextField(
                                        onChanged: (newValue) {
                                          DataManager().trainData['B-LHS-Qr'] =
                                              newValue;
                                        },
                                        style: const TextStyle(
                                          color: Color(0xFFF5F5F5),
                                        ),
                                        controller: TextEditingController(
                                            text: DataManager()
                                                    .trainData['B-LHS-Qr'] ??
                                                ''),
                                        decoration: InputDecoration(
                                          hintText: 'Left',
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          filled: true,
                                          fillColor: const Color(0xFF313134),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFFF8518),
                                                width: 2.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    width:
                                        16), // Add spacing between the two columns
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Container(
                                      width: 150,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ), // Adjust the width as needed
                                      child: TextField(
                                        onChanged: (newValue) {
                                          DataManager().trainData['B-RHS-Qr'] =
                                              newValue;
                                        },
                                        style: const TextStyle(
                                          color: Color(0xFFF5F5F5),
                                        ),
                                        controller: TextEditingController(
                                            text: DataManager()
                                                    .trainData['B-RHS-Qr'] ??
                                                ''),
                                        decoration: InputDecoration(
                                          hintText: 'Right',
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          filled: true,
                                          fillColor: const Color(0xFF313134),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFFF8518),
                                                width: 2.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.only(left: 35, top: 42),
                              child: Row(
                                children: [
                                  CustomTextWidget(
                                    text: 'Radial Deviation',
                                    textStyle: TextStyle(
                                      fontSize: 22,
                                      color: Color(0xFFF5F5F5),
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                            padding: const EdgeInsets.only(left: 35, top: 6),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Container(
                                      width: 150,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ), // Adjust the width as needed
                                      child: TextField(
                                        onChanged: (newValue) {
                                          DataManager().trainData[
                                                  'B-LHS-RadialDeviation'] =
                                              newValue;
                                        },
                                        style: const TextStyle(
                                          color: Color(0xFFF5F5F5),
                                        ),
                                        controller: TextEditingController(
                                            text: DataManager().trainData[
                                                    'B-LHS-RadialDeviation'] ??
                                                ''),
                                        decoration: InputDecoration(
                                          hintText: 'Left',
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          filled: true,
                                          fillColor: const Color(0xFF313134),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFFF8518),
                                                width: 2.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    width:
                                        16), // Add spacing between the two columns
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Container(
                                      width: 150,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ), // Adjust the width as needed
                                      child: TextField(
                                        onChanged: (newValue) {
                                          DataManager().trainData[
                                                  'B-RHS-RadialDeviation'] =
                                              newValue;
                                        },
                                        style: const TextStyle(
                                          color: Color(0xFFF5F5F5),
                                        ),
                                        controller: TextEditingController(
                                            text: DataManager().trainData[
                                                    'B-RHS-RadialDeviation'] ??
                                                ''),
                                        decoration: InputDecoration(
                                          hintText: 'Right',
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          filled: true,
                                          fillColor: const Color(0xFF313134),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFFF8518),
                                                width: 2.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.only(left: 35, top: 42),
                              child: Row(
                                children: [
                                  CustomTextWidget(
                                    text: 'After Cut',
                                    textStyle: TextStyle(
                                      fontSize: 22,
                                      color: Color(0xFFF5F5F5),
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 35, top: 6, bottom: 30),
                            child: Container(
                              width: 200, // Adjust the width as needed
                              decoration: BoxDecoration(
                                color: const Color(
                                    0xFF313134), // Background color of the dropdown button container
                                borderRadius: BorderRadius.circular(
                                    10), // Rounded corners
                              ),
                              child: Align(
                                alignment: Alignment
                                    .centerRight, // Align the selected text to the right
                                child: DropdownButtonFormField<String>(
                                  value: selectedOption,
                                  items: const <DropdownMenuItem<String>>[
                                    DropdownMenuItem<String>(
                                      value: 'Yes',
                                      child: Text(
                                        'Yes',
                                        style: TextStyle(
                                          color:
                                              Color(0xFFF5F5F5), // Text color
                                          fontSize: 16, // Text size
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'No',
                                      child: Text(
                                        'No',
                                        style: TextStyle(
                                          color:
                                              Color(0xFFF5F5F5), // Text color
                                          fontSize: 16, // Text size
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedOption = newValue;

                                      bool flag = false;
                                      if (selectedOption == "Yes") {
                                        flag = true;
                                      } else if (selectedOption == "No") {
                                        flag = false;
                                      }
                                      DataManager.afterCut = flag;
                                      print(
                                          "After Cut flag changed to ${DataManager.afterCut}");
                                      // Update trainData based on the selectedOption
                                      if (selectedOption == "Yes") {
                                        DataManager().appData =
                                            DataManager().trainData;

                                        DataManager()
                                                .trainData['A-LHS-Diameter'] =
                                            '999';
                                        DataManager().trainData[
                                            'A-LHS-FlangeThickness'] = '999';
                                        DataManager().trainData[
                                            'A-LHS-FlangeWidth'] = '999';
                                        DataManager().trainData['A-LHS-Qr'] =
                                            '999';
                                        DataManager().trainData[
                                            'A-LHS-RadialDeviation'] = '999';
                                        DataManager()
                                                .trainData['A-RHS-Diameter'] =
                                            '999';
                                        DataManager().trainData[
                                            'A-RHS-FlangeThickness'] = '999';
                                        DataManager().trainData[
                                            'A-RHS-FlangeWidth'] = '999';
                                        DataManager().trainData['A-RHS-Qr'] =
                                            '999';
                                        DataManager().trainData[
                                            'A-RHS-RadialDeviation'] = '999';
                                        // print('After Cut is No: ${DataManager().trainData}');
                                        // print('App Data: ${DataManager().appData}');
                                      } else {
                                        // Restore trainData to the original values
                                        DataManager()
                                                .trainData['A-LHS-Diameter'] =
                                            '0.0';
                                        DataManager().trainData[
                                            'A-LHS-FlangeThickness'] = '0.0';
                                        DataManager().trainData[
                                            'A-LHS-FlangeWidth'] = '0.0';
                                        DataManager().trainData['A-LHS-Qr'] =
                                            '0.0';
                                        DataManager().trainData[
                                            'A-LHS-RadialDeviation'] = '0.0';
                                        DataManager()
                                                .trainData['A-RHS-Diameter'] =
                                            '0.0';
                                        DataManager().trainData[
                                            'A-RHS-FlangeThickness'] = '0.0';
                                        DataManager().trainData[
                                            'A-RHS-FlangeWidth'] = '0.0';
                                        DataManager().trainData['A-RHS-Qr'] =
                                            '0.0';
                                        DataManager().trainData[
                                            'A-RHS-RadialDeviation'] = '0.0';
                                        // print('After Cut is No: ${DataManager().trainData}');
                                        // print('App Data: ${DataManager().appData}');
                                      }
                                    });
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(
                                        0xFF313134), // Background color of the dropdown button
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFFF8518), width: 2.0),
                                    ),
                                  ),
                                  elevation:
                                      1, // Set the elevation to change the background color of the dropdown
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Color(
                                        0xFFF5F5F5), // Color of the dropdown arrow
                                  ),
                                  dropdownColor: const Color(
                                      0xFF313134), // Background color of the dropdown list
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
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
