import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlotScreen extends StatefulWidget {
  @override
  _PlotScreenState createState() => _PlotScreenState();
}

class _PlotScreenState extends State<PlotScreen> {
  String plotData = '';
  // List<Map<String, dynamic>> tableData = [];
  List<dynamic> tableData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    plotData = ''; // Reset plotData
    tableData = []; // Reset tableData
    super.dispose();
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/get_plot'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        plotData = data['plot_data'];
      });
    } else {
      throw Exception('Failed to load plot data');
    }
  }

  void _getTable() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/get_table'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      print(responseData);

      if (responseData.containsKey('table_data')) {
        var tableData = responseData['table_data'];

        // Check if tableData is a String
        if (tableData is String) {
          // Parse the String as a JSON array
          List<dynamic> records = json.decode(tableData);
          print(records);
          // Check if records is a list and contains map entries
          if (records is List &&
              records.isNotEmpty &&
              records.first is Map<String, dynamic>) {
            // Format the content
            List<DataRow> dataRows = [];
            for (Map<String, dynamic> record in records) {
              dataRows.add(DataRow(
                cells: [
                  DataCell(Text(record['Date'])),
                  DataCell(Text(record['Quantity'])),
                ],
              ));
            }

            // Show the dialog box with DataTable
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Table Data'),
                  content: SingleChildScrollView(
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Month')),
                        DataColumn(label: Text('Forecasted Quantity')),
                      ],
                      rows: dataRows,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    }
  }

  void _getTable2() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/spareParts_data'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);

      print(responseData);

      if (responseData.isNotEmpty) {
        // Format the content
        List<DataRow> dataRows = [];
        for (var record in responseData) {
          dataRows.add(DataRow(
            cells: [
              DataCell(Text(record['System'])),
              DataCell(Text(record['Quantity'])),
            ],
          ));
        }

        // Show the dialog box with DataTable
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('April 2024'),
              content: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('System')),
                    DataColumn(label: Text('Quantity')),
                  ],
                  rows: dataRows,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('April 2024'),
              content: Text('No data available.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 720,
            width: 1370,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/background.png'),
              ),
            ),
          ),
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
                            text: 'Yearly Prediction Preview',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 32,
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
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(55, 0, 0, 0.10),
                        width: 500,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xddff8518),
                        ),
                      ),
                      Container(
                        width: 200,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xddff8518),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: plotData.isNotEmpty
                        ? Image.memory(
                            base64.decode(plotData),
                            width: 800,
                            height: 400,
                            fit: BoxFit.cover,
                          )
                        : CircularProgressIndicator(),
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 55),
                        child: ElevatedButton(
                          onPressed: _getTable,
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xddff8518),
                          ),
                          child: SizedBox(
                            height: 30.0,
                            child: Center(
                              child: Text(
                                'Show Details',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        // Adding another button
                        onPressed: _getTable2,
                        style: ElevatedButton.styleFrom(
                          primary: Color(
                              0xddff8518), // Change color as per your requirement
                        ),
                        child: SizedBox(
                          height: 30.0,
                          child: Center(
                            child: Text(
                              'Next Month Preview', // Change text as per your requirement
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  //     SizedBox(height: 20),
                  //     if (tableData.isNotEmpty)
                  //       DataTable(
                  //         columns: [
                  //           DataColumn(label: Text('Column 1')),
                  //           DataColumn(label: Text('Column 2')),
                  //           // Add more columns as needed
                  //         ],
                  //         rows: tableData
                  //             .map(
                  //               (row) => DataRow(
                  //                 cells: [
                  //                   DataCell(Text('${row['key1']}')),
                  //                   DataCell(Text('${row['key2']}')),
                  //                   // Add more cells as needed
                  //                 ],
                  //               ),
                  //             )
                  //             .toList(),
                  //       )
                  //     else
                  //       Text('Table data not available'),
                ],
              ),
            ),
          ),
          // Positioned(
          //   left: 10,
          //   top: 10,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Color(0xddff8518),
          //       shape: BoxShape.circle,
          //     ),
          //     child: IconButton(
          //       icon: Icon(Icons.arrow_back),
          //       color: Colors.white,
          //       onPressed: () {
          //         Navigator.pop(context);
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
