// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:printing/printing.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// void main() {
//   runApp(MaterialApp(
//     title: 'Syncfusion PDF Viewer Demo',
//     home: ReportScreen(),
//   ));
// }

// class ReportScreen extends StatefulWidget {
//   @override
//   _ReportScreenState createState() => _ReportScreenState();
// }

// class _ReportScreenState extends State<ReportScreen> {
//   Uint8List? _pdfData;

//   @override
//   void initState() {
//     super.initState();
//     _loadPdf();
//   }

//   Future<void> _loadPdf() async {
//     final ByteData data = await rootBundle.load('assets/sample.pdf');
//     setState(() {
//       _pdfData = data.buffer.asUint8List();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             height: double.infinity,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 fit: BoxFit.cover,
//                 image: AssetImage('assets/background.png'),
//               ),
//             ),
//           ),
//           Center(
//             child: SingleChildScrollView(
//               child: Container(
//                 margin: EdgeInsets.all(20),
//                 padding: EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Color(0xFF313134),
//                   borderRadius: BorderRadius.circular(8.2151851654),
//                 ),
//                 constraints: BoxConstraints(
//                   maxWidth: 700,
//                   maxHeight: 1000,
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (_pdfData != null)
//                       Container(
//                         height: 800,
//                         child: SfPdfViewer.memory(
//                           _pdfData!,
//                         ),
//                       )
//                     else
//                       CircularProgressIndicator(),
//                     SizedBox(height: 20),
//                     TextButton(
//                       onPressed: () => _printPdf(),
//                       style: ButtonStyle(
//                         backgroundColor:
//                             MaterialStateProperty.all<Color>(Colors.orange),
//                         minimumSize: MaterialStateProperty.all<Size>(
//                           Size(200, 50), // Set the minimum size of the button
//                         ),
//                       ),
//                       child: Text(
//                         'Print Report',
//                         style: TextStyle(
//                           color: Colors.white, // Set text color to white
//                           fontSize: 18, // Adjust font size as needed
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _printPdf() async {
//     if (_pdfData != null) {
//       await Printing.layoutPdf(
//         onLayout: (_) async => _pdfData!,
//       );
//     } else {
//       // Handle case where PDF data is not available
//     }
//   }
// }
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';

// void main() {
//   runApp(ReportScreen());
// }

// class ReportScreen extends StatelessWidget {
//   List<String> systemNames = [];

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<void>(
//       future: fetchSystemNames(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return MaterialApp(
//             home: Scaffold(
//               appBar: AppBar(
//                 title: Text('Weekly Reporting and Analysis'),
//               ),
//               body: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//           );
//         } else if (snapshot.hasError) {
//           return MaterialApp(
//             home: Scaffold(
//               appBar: AppBar(
//                 title: Text('Images from Assets and Flask have an error'),
//               ),
//               body: Center(
//                 child: Text('Error: ${snapshot.error}'),
//               ),
//             ),
//           );
//         } else {
//           List<Widget> imageWidgets = [
//             buildImageWithText('Fault Statistics', 'assets/Fault_Table.png'),
//             buildImageWithText('System Faults', 'assets/Systems_Graph.png'),
//           ];

//           imageWidgets.addAll(systemNames.map((systemName) {
//             String imagePath = 'assets/$systemName.png';
//             return buildImageWithText(systemName, imagePath);
//           }));

//           return MaterialApp(
//             home: Scaffold(
//               body: Stack(
//                 children: [
//                   // Background Image
//                   Positioned.fill(
//                     child: Image.asset(
//                       'assets/background.png',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   // Centered Content
//                   Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Weekly Reporting and Analysis',
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         Expanded(
//                           child: ListView(
//                             shrinkWrap: true,
//                             children: imageWidgets,
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         Text(
//                           'Analysis',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF222229),
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 20),
//                           child: TextField(
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: Color(0xFF222229),
//                               hintText: 'Enter analysis here...',
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         ElevatedButton(
//                           onPressed: () {
//                             downloadReport();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color(0xFF222229),
//                             textStyle: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           child: Text('Save as PDF'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//       },
//     );
//   }

//   Widget buildImageWithText(String text, String imagePath) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10.0),
//       child: Column(
//         children: [
//           Text(text,
//               style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20.0,
//                   fontWeight: FontWeight.bold)),
//           SizedBox(height: 10.0),
//           Image.asset(
//             imagePath,
//             width: 600, // Adjust width as needed
//             height: 600, // Adjust height as needed
//           ),
//         ],
//       ),
//     );
//   }

//   // Function to fetch system names from Flask API
//   Future<void> fetchSystemNames() async {
//     final response =
//         await http.get(Uri.parse('http://127.0.0.1:8000/report_data'));
//     if (response.statusCode == 200) {
//       systemNames = jsonDecode(response.body).cast<String>();
//     } else {
//       throw Exception('Failed to load system names');
//     }
//   }

//   Future<void> downloadReport() async {
//     final pdf = pw.Document();
//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) => pw.Center(
//           child: pw.Text('Hello World', style: pw.TextStyle(fontSize: 40)),
//         ),
//       ),
//     );
//     final output = await getTemporaryDirectory();
//     final file = File('/report.pdf');
//     await file.writeAsBytes(await pdf.save());
//   }
// }

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
  Uint8List? _pdfData;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final ByteData data = await rootBundle.load('assets/sample.pdf');
    setState(() {
      _pdfData = data.buffer.asUint8List();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/background.png'),
              ),
            ),
          ),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_pdfData != null)
                      Container(
                        height: 800,
                        child: SfPdfViewer.memory(
                          _pdfData!,
                        ),
                      )
                    else
                      CircularProgressIndicator(),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () => _printPdf(),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.orange),
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size(200, 50), // Set the minimum size of the button
                        ),
                      ),
                      child: Text(
                        'Print Report',
                        style: TextStyle(
                          color: Colors.white, // Set text color to white
                          fontSize: 18, // Adjust font size as needed
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printPdf() async {
    if (_pdfData != null) {
      await Printing.layoutPdf(
        onLayout: (_) async => _pdfData!,
      );
    } else {
      // Handle case where PDF data is not available
    }
  }
}
