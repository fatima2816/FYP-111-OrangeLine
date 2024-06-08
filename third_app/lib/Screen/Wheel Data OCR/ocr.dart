import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:third_app/Screen/Wheel Data OCR/init_measurements.dart';
import 'package:third_app/Screen/Wheel Data OCR/data_manager.dart';
import 'package:third_app/Screen/Wheel Data OCR/general_info.dart';
import 'package:third_app/Screen/Wheel Data OCR/final_measurements.dart';
import 'package:third_app/Screen/Wheel Data OCR/wheel_analysis.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ocr(),
    );
  }
}

class ocr extends StatefulWidget {
  final String? path;

  ocr({Key? key, this.path}) : super(key: key);

  @override
  _ocrState createState() => _ocrState();
}

class _ocrState extends State<ocr> {
  File? _image;
  bool isImageUploaded = false;

  Future getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        isImageUploaded = true;
        _pickImageAndSend();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _pickImageAndSend() async {
    if (_image != null) {
      try {
        // Prepare the image file for upload
        final File imageFile = _image!;

        final uri = Uri.parse('http://127.0.0.1:8000/upload_image');
        final request = http.MultipartRequest('POST', uri)
          ..files.add(http.MultipartFile(
            'image',
            imageFile.readAsBytes().asStream(),
            imageFile.lengthSync(),
            filename: 'image.jpg',
          ))
          ..headers['Content-Type'] = 'image/jpeg';

        final response = await request.send();

        if (response.statusCode == 200) {
          print('Image uploaded successfully');
          // Read the response stream and convert it to a string
          final responseBody = await response.stream.bytesToString();
          print('Response: $responseBody');

          // Convert responseBody into a Map
          final Map<String, String> responseMap =
              Map<String, String>.from(jsonDecode(responseBody));

          // Set the response data into DataManager
          DataManager().trainData = responseMap;

          print('Map: $responseMap');
        } else {
          print('Image upload failed with status code: ${response.statusCode}');
        }
      } catch (e) {
        print("Error sending image: $e");
      }
    }
  }

  void wheel_form() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const MultiStepForm();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
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
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center vertically
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
                                text: 'Wheel Data OCR',
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
                      SizedBox(height: 8),
                      _image == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 400,
                                  width: 400,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/upload_image.png',
                                          height: 200,
                                          width: 200,
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          'Drag and drop to upload',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.file(
                                  _image!,
                                  height: 400,
                                  width: 400,
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                      Container(
                        height: 50,
                        width: 200,
                        child: ElevatedButton(
                          onPressed: isImageUploaded ? wheel_form : getImage,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Text(
                            isImageUploaded ? 'Submit' : 'Upload Image',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
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

class MultiStepForm extends StatefulWidget {
  const MultiStepForm({super.key});

  @override
  _MultiStepFormState createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final int _totalPages = 3;

  Future<void> sendOCRToFlaskAPI() async {
    try {
      //const String apiUrl = 'http://192.168.0.115:8000/upload_ocr';
      const String apiUrl = 'http://127.0.0.1:8000/upload_ocr';
      print('\n*****************************************');
      DataManager().trainData['afterCut'] = DataManager.afterCut.toString();
      String jsonData = jsonEncode(DataManager().trainData);
      print('Converted to JSON $jsonData');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData, // Use jsonData directly, no need for double encoding
      );

      if (response.statusCode == 200) {
        print('Data sent successfully');
        print('Response: ${response.body}');
        // Navigator.of(context).push(MaterialPageRoute(
        //   builder: (context) {
        //     return const WheelAnalysis();
        //   },
        // ));

        // Handle the response from the server
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              // Adding multi-form pages here
              children: const [
                GeneralInfo(),
                InitMeasurements(),
                FinalMeasurements(),
              ],
            ),
          ),
          // Container(
          //   color: const Color(
          //       0xFFFF8518), // Change page indicators background color
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: List<Widget>.generate(_totalPages, (int index) {
          //       return Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: Container(
          //           width: 8.0,
          //           height: 8.0,
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             color: _currentPage == index
          //                 ? const Color(
          //                     0xFFff8518) // Active page indicator color
          //                 : const Color(
          //                     0xFF313134), // Inactive page indicator color
          //           ),
          //         ),
          //       );
          //     }),
          //   ),
          // ),
          Container(
            color: const Color(0xFFFF8518), // Change this color if needed
            child: Row(
// Change buttons background color

              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == 0) {
                      Navigator.of(context).pop(); // Navigate back to ocr.dart
                    } else if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        return Color(
                            0xFF313134); // Color when button is enabled
                      },
                    ),
                  ),
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _totalPages - 1) {
                      sendOCRToFlaskAPI();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return const WheelAnalysis();
                        },
                      ));
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        return _currentPage == _totalPages - 1
                            ? Colors.orange
                            : Color(0xFF313134);
                      },
                    ),
                  ),
                  child:
                      Text(_currentPage == _totalPages - 1 ? 'Submit' : 'Next'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
