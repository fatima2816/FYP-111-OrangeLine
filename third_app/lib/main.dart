import 'package:flutter/material.dart';
import 'package:third_app/Screen/mainPage/ManagerDashboard.dart';
import 'package:third_app/Screen/mainPage/EngineerDashboard.dart';
import 'package:third_app/Screen/mainPage/Home.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
// Inside your login page
import 'app_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: LoginScreen(),
//     );
//   }
// }

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  String result = '';
  bool isPasswordVisible = false;
  bool? checked = false;

  void checkLoginFields(BuildContext context) {
    if (FieldsEmpty()) {
      // Show a Snackbar if any field is empty
      final snackBar = SnackBar(
        content: Text('Fields are empty.'),
        duration: Duration(seconds: 1),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      loginUser();
    }
  }

  bool FieldsEmpty() {
    // Check if any of the TextControllers has empty text
    return emailController.text.isEmpty || passController.text.isEmpty;
  }

  final String apiUrl = "http://127.0.0.1:8000/login";

  Future<void> loginUser() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': emailController.text,
          'password': passController.text,
        }),
      );

      if (response.statusCode == 200) {
        //Decode JSON string
        Map<String, dynamic> responseData = jsonDecode(response.body);

        // Accessing user_info array
        List<dynamic> userInfo = responseData['user_info'];

        // Accessing occupation from user_info
        String occupation = userInfo[0]['occupation'];
// Accessing occupation from user_info
        String full_name = userInfo[0]['full_name'];
        AppState.fullName = full_name;
        // After fetching the occupation value
        AppState.occupation = occupation;

        switch (occupation) {
          // case 'Admin':
          //   Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(builder: (context) => AdminHomePage()),
          //   );
          // break;
          case 'Manager':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ManagerDashboard()),
            );
            break;
          case 'Engineer':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EngineerDashboard()),
            );
            break;
          default:
            // Handle other occupations or roles
            break;
        }
      } else {
        final snackBar = SnackBar(
          content: Text('Incorrect username or password.'),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (error) {
      print('Error: $error');
      final snackBar = SnackBar(
        content: Text('An error occurred. Please try again later.'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // Future<void> loginUser() async {
  // final String apiUrl =
  //     "http://127.0.0.1:8000/login"; // Update with your Flask API endpoint

  //   final response = await http.post(
  //     Uri.parse(apiUrl),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({
  //       'username': emailController.text,
  //       'password': passController.text,
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     print('Data sent successfully');
  //     print('Response: ${response.body}');
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => MyDashboard(),
  //       ),
  //     );
  //   } else {
  //     final snackBar = SnackBar(
  //       content: Text('Incorrect Password or username'),
  //       duration: Duration(seconds: 1),
  //     );
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF111112),
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: Row(
          children: [
            // Add an image here
            Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: Image.asset(
                'assets/Logo.png', // Replace with your image asset
                width: 70, // Adjust the width as needed
                height: 50, // Adjust the height as needed
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
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 720,
            width: 1370,
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/background.png'),
              ),
            ),
          ),
          Positioned(
            left: 300,
            top: 20,
            child: Container(
              width: 800,
              height: 570,
              decoration: BoxDecoration(
                color: Color(0xFF313134).withOpacity(0.8),
                borderRadius: BorderRadius.circular(20.2151851654),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(250, 16, 250, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Username',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            controller: emailController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 20.0),
                              hintText: 'Username',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(250, 16, 250, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            controller: passController,
                            obscureText: !isPasswordVisible,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 20.0),
                              hintText: 'Password',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(250, 2, 250, 12),
                    child: Row(
                      children: [
                        Checkbox(
                          value: checked,
                          activeColor: Color(0xddff8518),
                          onChanged: (newBool) {
                            setState(() {
                              checked = newBool;
                            });
                          },
                        ),
                        Text(
                          'Remember Me',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      checkLoginFields(context);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xddff8518),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(300, 60),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
