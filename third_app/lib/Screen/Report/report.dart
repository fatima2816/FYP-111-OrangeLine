import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'web.dart';

void main() {
  runApp(MaterialApp(
    title: 'Syncfusion PDF Viewer Demo',
    home: ReportScreen(),
  ));
}

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<String> systemNames = [];
  final TextEditingController _textController = TextEditingController();
  List<String> systemNameList = [];
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: fetchSystemNames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: Text('Weekly Reporting and Analysis'),
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: Text('Images from Assets and Flask have an error'),
              ),
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        } else {
          List<Widget> imageWidgets = [
            buildImageWithText('Fault Statistics', 'assets/Fault_Table.png'),
            buildImageWithText('System Faults', 'assets/Systems_Graph.png'),
          ];

          imageWidgets.addAll(systemNames.map((systemName) {
            String imagePath = 'assets/$systemName.png';
            return buildImageWithText(systemName, imagePath);
          }));

          systemNames.forEach((systemName) {
            systemNameList.add(systemName);
          });

          return MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/background.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Centered Content
                  Center(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.all(20),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFF313134),
                          borderRadius: BorderRadius.circular(8.2151851654),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: 700,
                          maxHeight: 1000,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Weekly Reporting and Analysis',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children: imageWidgets,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Analysis',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 60),
                              child: TextField(
                                controller: _textController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Enter analysis here...',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                downloadReport();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xddff8518),
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              child: Text('Save as PDF'),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildImageWithText(String text, String imagePath) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Text(text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10.0),
          Image.asset(
            imagePath,
            width: 600, // Adjust width as needed
            height: 600, // Adjust height as needed
          ),
        ],
      ),
    );
  }

  // Function to fetch system names from Flask API
  Future<void> fetchSystemNames() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/report_data'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      systemNames = jsonResponse.cast<String>();
    } else {
      throw Exception('Failed to load system names');
    }
  }

  Future<void> downloadReport() async {
    PdfDocument document = PdfDocument();

    // Page for Weekly Report and Faults Statistics
    final page1 = document.pages.add();

    page1.graphics.drawString('Weekly Report and Analysis',
        PdfStandardFont(PdfFontFamily.helvetica, 30));

    page1.graphics.drawString(
        'Faults Statistics', PdfStandardFont(PdfFontFamily.helvetica, 20),
        bounds: Rect.fromLTWH(0, 70, 440, 550));

    page1.graphics.drawImage(PdfBitmap(await _readImageData('Fault_Table.png')),
        Rect.fromLTWH(0, 100, 440, 550));

    // New page for System Faults
    final page2 = document.pages.add();

    page2.graphics.drawString(
        'System Faults', PdfStandardFont(PdfFontFamily.helvetica, 20));
    page2.graphics.drawImage(
        PdfBitmap(await _readImageData('Systems_Graph.png')),
        Rect.fromLTWH(0, 100, 440, 550));

    Set<String> uniqueSystems = systemNameList.toSet();
    List<String> uniqueSystemsList = uniqueSystems.toList();

    for (int i = 0; i < uniqueSystemsList.length; i++) {
      String systemName = uniqueSystemsList[i];
      print(systemName);
      String imagePath = '$systemName.png';

      PdfPage page3 = document.pages.add();
      // Draw system name
      page3.graphics.drawString(
          systemName, PdfStandardFont(PdfFontFamily.helvetica, 20),
          bounds:
              Rect.fromLTWH(0, 100, 440, 50)); // Adjust Y position as needed

      // Draw image
      page3.graphics.drawImage(PdfBitmap(await _readImageData(imagePath)),
          Rect.fromLTWH(0, 100, 440, 550)); // Adjust Y position as needed
    }
    PdfPage page4 = document.pages.add();

    page4.graphics.drawString(
        'Faults Analysis', PdfStandardFont(PdfFontFamily.helvetica, 20));
    String analysisText = _textController.text;
    // Draw analysis text
    page4.graphics.drawString(
        analysisText, PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(
            20, 120, 400, 600)); // Adjust position and size as needed

    List<int> bytes = await document.save();
    document.dispose();
    saveAndLaunchFile(bytes, 'report.pdf');
  }

  Future<Uint8List> _readImageData(String name) async {
    final data = await rootBundle.load('assets/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
