// import 'package:flutter/material.dart';
// import 'package:supabase/supabase.dart';

// class FaultsEditor extends StatefulWidget {
//   @override
//   _FaultsEditorState createState() => _FaultsEditorState();
// }

// class _FaultsEditorState extends State<FaultsEditor> {
//   late SupabaseClient _client;
//   List<String> _filteredFaultDescriptions = [];
//   List<String> _faultDescriptions = [];
//   List<String> _systems = [];
//   List<String> _equipments = [];
//   String? _selectedSystem;
//   String? _selectedEquipment;

//   @override
//   void initState() {
//     super.initState();
//     _initializeSupabase();
//     _fetchFaultDescriptions();
//     _fetchSystemAndEquipment();
//   }

//   void _initializeSupabase() {
//     String supabaseUrl = "https://typmqqidaijuobjosrpi.supabase.co";
//     String supabaseKey =
//         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cG1xcWlkYWlqdW9iam9zcnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTM0MzkzODAsImV4cCI6MjAwOTAxNTM4MH0.Ihde633Yj9FFaQ7hKLooxDxaFEno4fK8YxSb3gy8S4c";

//     _client = SupabaseClient(supabaseUrl, supabaseKey);
//   }

//   Future<void> _fetchFaultDescriptions() async {
//     final response =
//         await _client.from('FaultDetection').select('fault_desc').execute();

//     if (response.data == null) {
//       print('No fault descriptions found');
//       return;
//     }

//     List<String> faultDescriptions = [];

//     for (var row in response.data!) {
//       String? faultDesc = row['fault_desc'] as String?;
//       if (faultDesc != null && !faultDescriptions.contains(faultDesc)) {
//         faultDescriptions.add(faultDesc);
//       }
//     }

//     setState(() {
//       _faultDescriptions = faultDescriptions;
//       _filteredFaultDescriptions =
//           _faultDescriptions; // Initialize filtered list
//     });
//   }

//   Future<void> _fetchSystemAndEquipment() async {
//     final response =
//         await _client.from('FaultData').select('System, Equipment').execute();

//     if (response.data == null) {
//       print('No system and equipment found');
//       return;
//     }

//     Set<String> systems = {};
//     Set<String> equipments = {};

//     for (var item in response.data!) {
//       if (item['System'] != null) {
//         systems.add(item['System'] as String);
//       }
//       if (item['Equipment'] != null) {
//         equipments.add(item['Equipment'] as String);
//       }
//     }

//     setState(() {
//       _systems = systems.toList()..sort();
//       _equipments = equipments.toList()..sort();
//     });
//   }

//   Future<void> _applyFilter() async {
//     if (_selectedSystem != null && _selectedEquipment != null) {
//       String normalizedSystem =
//           _selectedSystem!.toLowerCase().replaceAll('_', ' ');
//       String normalizedEquipment =
//           _selectedEquipment!.toLowerCase().replaceAll('_', ' ');

//       // Filter fault descriptions based on selected system and equipment
//       List<String> filteredFaultDescriptions = _faultDescriptions.where((desc) {
//         String normalizedDesc = desc.replaceAll('_', ' ').toLowerCase();
//         return normalizedDesc.contains(normalizedSystem) &&
//             normalizedDesc.contains(normalizedEquipment);
//       }).toList();

//       setState(() {
//         _filteredFaultDescriptions = filteredFaultDescriptions;
//       });
//     }
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
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     'Faults',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: _filteredFaultDescriptions.length,
//                     itemBuilder: (context, index) {
//                       return SizedBox(
//                         width: double.infinity,
//                         child: Card(
//                           elevation: 2,
//                           margin:
//                               EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                           color: Color(0xFF313134),
//                           child: ListTile(
//                             title: Text(
//                               _filteredFaultDescriptions[index],
//                               style: TextStyle(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             top: 16,
//             right: 16,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 _showFilterDialog(context);
//               },
//               icon: Icon(Icons.filter_list),
//               label: Text('Filter'),
//               style: ElevatedButton.styleFrom(
//                 primary: Colors.orange,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showFilterDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text("Filter Options"),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text('System: '),
//                   DropdownButton<String>(
//                     value: _selectedSystem ?? _systems.first,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedSystem = value;
//                       });
//                     },
//                     items:
//                         _systems.map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                   ),
//                   SizedBox(height: 16),
//                   Text('Equipment: '),
//                   DropdownButton<String>(
//                     value: _selectedEquipment ?? _equipments.first,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedEquipment = value;
//                       });
//                     },
//                     items: _equipments
//                         .map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                   ),
//                 ],
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(); // Close the dialog
//                     _applyFilter(); // Apply filter when "Filter" button is pressed
//                   },
//                   child: Text("Filter"),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

// class FaultsEditor extends StatefulWidget {
//   @override
//   _FaultsEditorState createState() => _FaultsEditorState();
// }

// class _FaultsEditorState extends State<FaultsEditor> {
//   late SupabaseClient _client;
//   List<String> _filteredFaultDescriptions = [];
//   List<String> _faultDescriptions = [];
//   List<String> _systems = [];
//   List<String> _equipments = [];
//   String? _selectedSystem;
//   String? _selectedEquipment;

//   @override
//   void initState() {
//     super.initState();
//     _initializeSupabase();
//     _fetchFaultDescriptions();
//     // _fetchSystemAndEquipment();
//   }

// void _initializeSupabase() {
//   String supabaseUrl = "https://typmqqidaijuobjosrpi.supabase.co";
//   String supabaseKey =
//       "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cG1xcWlkYWlqdW9iam9zcnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTM0MzkzODAsImV4cCI6MjAwOTAxNTM4MH0.Ihde633Yj9FFaQ7hKLooxDxaFEno4fK8YxSb3gy8S4c";

//   _client = SupabaseClient(supabaseUrl, supabaseKey);
// }

//   Future<void> _fetchFaultDescriptions() async {
//     final response =
//         await _client.from('FaultDetection').select('fault_desc').execute();

//     if (response.data == null) {
//       print('No fault descriptions found');
//       return;
//     }

//     List<String> faultDescriptions = [];

//     for (var row in response.data!) {
//       String? faultDesc = row['fault_desc'] as String?;
//       if (faultDesc != null && !faultDescriptions.contains(faultDesc)) {
//         faultDescriptions.add(faultDesc);
//       }
//     }

//     setState(() {
//       _faultDescriptions = faultDescriptions;
//       _filteredFaultDescriptions =
//           _faultDescriptions; // Initialize filtered list
//     });
//   }

//   // Future<void> _fetchSystemAndEquipment() async {
//   //   final response =
//   //       await _client.from('FaultData').select('System, Equipment').execute();

//   //   if (response.data == null) {
//   //     print('No system and equipment found');
//   //     return;
//   //   }

//   //   Set<String> systems = {};
//   //   Set<String> equipments = {};

//   //   for (var item in response.data!) {
//   //     if (item['System'] != null) {
//   //       systems.add(item['System'] as String);
//   //     }
//   //     if (item['Equipment'] != null) {
//   //       equipments.add(item['Equipment'] as String);
//   //     }
//   //   }

//   //   setState(() {
//   //     _systems = systems.toList()..sort();
//   //     _equipments = equipments.toList()..sort();
//   //   });
//   // }

//   // Future<void> _applyFilter() async {
//   //   if (_selectedSystem != null && _selectedEquipment != null) {
//   //     String normalizedSystem =
//   //         _selectedSystem!.toLowerCase().replaceAll('_', ' ');
//   //     String normalizedEquipment =
//   //         _selectedEquipment!.toLowerCase().replaceAll('_', ' ');

//   //     // Filter fault descriptions based on selected system and equipment
//   //     List<String> filteredFaultDescriptions = _faultDescriptions.where((desc) {
//   //       String normalizedDesc = desc.replaceAll('_', ' ').toLowerCase();
//   //       return normalizedDesc.contains(normalizedSystem) &&
//   //           normalizedDesc.contains(normalizedEquipment);
//   //     }).toList();

//   //     setState(() {
//   //       _filteredFaultDescriptions = filteredFaultDescriptions;
//   //     });
//   //   }
//   // }

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
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     'Faults',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: _filteredFaultDescriptions.length,
//                     itemBuilder: (context, index) {
//                       return SizedBox(
//                         width: double.infinity,
//                         child: Card(
//                           elevation: 2,
//                           margin:
//                               EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                           color: Color(0xFF313134),
//                           child: ListTile(
//                             title: Text(
//                               _filteredFaultDescriptions[index],
//                               style: TextStyle(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Positioned(
//           //   top: 16,
//           //   right: 16,
//           //   child: ElevatedButton.icon(
//           //     onPressed: () {
//           //       _showFilterDialog(context);
//           //     },
//           //     icon: Icon(Icons.filter_list),
//           //     label: Text('Filter'),
//           //     style: ElevatedButton.styleFrom(
//           //       primary: Colors.orange,
//           //     ),
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }

//   // void _showFilterDialog(BuildContext context) {
//   //   showDialog(
//   //     context: context,
//   //     builder: (BuildContext context) {
//   //       return StatefulBuilder(
//   //         builder: (context, setState) {
//   //           return AlertDialog(
//   //             title: Text("Filter Options"),
//   //             content: Column(
//   //               mainAxisSize: MainAxisSize.min,
//   //               children: [
//   //                 Text('System: '),
//   //                 DropdownButton<String>(
//   //                   value: _selectedSystem ?? _systems.first,
//   //                   onChanged: (value) {
//   //                     setState(() {
//   //                       _selectedSystem = value;
//   //                     });
//   //                   },
//   //                   items:
//   //                       _systems.map<DropdownMenuItem<String>>((String value) {
//   //                     return DropdownMenuItem<String>(
//   //                       value: value,
//   //                       child: Text(value),
//   //                     );
//   //                   }).toList(),
//   //                 ),
//   //                 SizedBox(height: 16),
//   //                 Text('Equipment: '),
//   //                 DropdownButton<String>(
//   //                   value: _selectedEquipment ?? _equipments.first,
//   //                   onChanged: (value) {
//   //                     setState(() {
//   //                       _selectedEquipment = value;
//   //                     });
//   //                   },
//   //                   items: _equipments
//   //                       .map<DropdownMenuItem<String>>((String value) {
//   //                     return DropdownMenuItem<String>(
//   //                       value: value,
//   //                       child: Text(value),
//   //                     );
//   //                   }).toList(),
//   //                 ),
//   //               ],
//   //             ),
//   //             actions: <Widget>[
//   //               TextButton(
//   //                 onPressed: () {
//   //                   Navigator.of(context).pop(); // Close the dialog
//   //                   _applyFilter(); // Apply filter when "Filter" button is pressed
//   //                 },
//   //                 child: Text("Filter"),
//   //               ),
//   //             ],
//   //           );
//   //         },
//   //       );
//   //     },
//   //   );
//   // }
// // // }
// import 'package:flutter/material.dart';
// import 'package:horizontal_data_table/horizontal_data_table.dart';

// class HorizontalTable extends StatefulWidget {
//   @override
//   _HorizontalTableState createState() => _HorizontalTableState();
// }

// class _HorizontalTableState extends State<HorizontalTable> {
//   late SupabaseClient _client;
//   List<FaultDataInfo> faultData = [];
//   List<String> _systems = [];
//   List<String> _equipments = [];
//   String? _selectedSystem;
//   String? _selectedEquipment;
//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   Future<void> _fetchData() async {
//     String supabaseUrl = "https://typmqqidaijuobjosrpi.supabase.co";
//     String supabaseKey =
//         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cG1xcWlkYWlqdW9iam9zcnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTM0MzkzODAsImV4cCI6MjAwOTAxNTM4MH0.Ihde633Yj9FFaQ7hKLooxDxaFEno4fK8YxSb3gy8S4c";

//     _client = SupabaseClient(supabaseUrl, supabaseKey);
//     final response = await _client.from('FaultData').select().execute();
//     print(response);
//     // if (response.data == null) {
//     final List<FaultDataInfo> data = (response.data as List)
//         .map((item) => FaultDataInfo.fromMap(item))
//         .toList();

//     setState(() {
//       faultData = data;
//     });
//     // } else {
//     //   // Handle error
//     //   print("error");
//     // }
//   }

//   Future<void> _fetchSystemAndEquipment() async {
//     final response =
//         await _client.from('FaultData').select('System, Equipment').execute();

//     if (response.data == null) {
//       print('No system and equipment found');
//       return;
//     }

//     Set<String> systems = {};
//     Set<String> equipments = {};

//     for (var item in response.data!) {
//       if (item['System'] != null) {
//         systems.add(item['System'] as String);
//       }
//       if (item['Equipment'] != null) {
//         equipments.add(item['Equipment'] as String);
//       }
//     }

//     setState(() {
//       _systems = systems.toList()..sort();
//       _equipments = equipments.toList()..sort();
//     });
//   }

//   Future<void> _applyFilter() async {
//     if (_selectedSystem != null && _selectedEquipment != null) {
//       String normalizedSystem =
//           _selectedSystem!.toLowerCase().replaceAll('_', ' ');
//       String normalizedEquipment =
//           _selectedEquipment!.toLowerCase().replaceAll('_', ' ');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         height: double.infinity,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             fit: BoxFit.cover,
//             image: AssetImage('assets/background.png'),
//           ),
//         ),
//         child: Stack(
//           children: [
//             Center(
//               child: SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.9,
//                 height: MediaQuery.of(context).size.height * 0.82,
//                 child: _getBodyWidget(),
//               ),
//             ),
//             Positioned(
//               top: 3,
//               right: 16,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   // _showFilterDialog(context);
//                 },
//                 icon: Icon(Icons.filter_list),
//                 label: Text('Filter'),
//                 style: ElevatedButton.styleFrom(
//                   primary: Colors.orange,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _getBodyWidget() {
//     return Center(
//       child: SizedBox(
//         width: MediaQuery.of(context).size.width *
//             0.9, // Adjust the width as needed
//         height: MediaQuery.of(context).size.height *
//             0.82, // Adjust the height as needed

//         child: HorizontalDataTable(
//           leftHandSideColumnWidth: 100,
//           rightHandSideColumnWidth: 1750,
//           isFixedHeader: true,
//           headerWidgets: _getTitleWidget(),
//           leftSideItemBuilder: _generateFirstColumnRow,
//           rightSideItemBuilder: _generateRightHandSideColumnRow,
//           itemCount: faultData.length,
//           rowSeparatorWidget: const Divider(
//             color: Colors.black54,
//             height: 1.0,
//             thickness: 0.0,
//           ),
//           leftHandSideColBackgroundColor: Color(0xFFFFFFFF),
//           rightHandSideColBackgroundColor: Color(0xFFFFFFFF),
//         ),
//       ),
//     );
//   }

//   List<Widget> _getTitleWidget() {
//     return [
//       _getTitleItemWidget('SR', 120, Color(0xFF222229)),
//       _getTitleItemWidget('Occurrence Date', 150, Colors.orange),
//       _getTitleItemWidget('Train Number', 150, Colors.orange),
//       _getTitleItemWidget('Car Number', 150, Colors.orange),
//       _getTitleItemWidget('Source', 150, Colors.orange),
//       _getTitleItemWidget('System', 150, Colors.orange),
//       _getTitleItemWidget('Equipment', 150, Colors.orange),
//       _getTitleItemWidget('Equipment Location', 200, Colors.orange),
//       // _getTitleItemWidget('Spare Parts Consumed', 200, Colors.orange),
//       // _getTitleItemWidget('Spare Parts Swapped', 200, Colors.orange),
//       _getTitleItemWidget('Description', 200, Colors.orange),
//       _getTitleItemWidget('Solution', 200, Colors.orange),
//       _getTitleItemWidget('Status', 100, Colors.orange),
//       _getTitleItemWidget('Resolution Date', 150, Colors.orange),
//     ];
//   }

//   Widget _getTitleItemWidget(String label, double width, Color color) {
//     return Container(
//       color: color,
//       child: Text(label,
//           style: TextStyle(
//               fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
//       width: width,
//       height: 56,
//       padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
//       alignment: Alignment.centerLeft,
//     );
//   }

//   Widget _generateFirstColumnRow(BuildContext context, int index) {
//     return Container(
//       color: Color(0xFF222229),
//       child: Text(faultData[index].sr.toString(),
//           style: TextStyle(
//               fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
//       width: 120,
//       height: 52,
//       padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
//       alignment: Alignment.centerLeft,
//     );
//   }

//   Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
//     final FaultDataInfo data = faultData[index];
//     if ((_selectedEquipment != null && data.equipment != _selectedEquipment) ||
//         (_selectedLocation != null &&
//             data.equipmentLocation != _selectedLocation)) {
//       return Container(); // Return an empty container if not matching filter
//     } else {
//       return Row(
//         children: <Widget>[
//           _getRowItemWidget(data.occurrenceDate, 150),
//           _getRowItemWidget(data.trainNumber, 150),
//           _getRowItemWidget(data.carNumber, 150),
//           _getRowItemWidget(data.source, 150),
//           _getRowItemWidget(data.system, 150),
//           _getRowItemWidget(data.equipment, 150),
//           _getRowItemWidget(data.equipmentLocation, 200),
//           _getRowItemWidget(data.description, 200),
//           _getRowItemWidget(data.solution, 200),
//           _getRowItemWidget(data.status, 100),
//           _getRowItemWidget(data.resolutionDate, 150),
//         ],
//       );
//     }
//   }
//   // Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
//   //   final FaultDataInfo data = faultData[index];
//   //   return Row(
//   //     children: <Widget>[
//   //       _getRowItemWidget(data.occurrenceDate, 150),
//   //       _getRowItemWidget(data.trainNumber, 150),
//   //       _getRowItemWidget(data.carNumber, 150),
//   //       _getRowItemWidget(data.source, 150),
//   //       _getRowItemWidget(data.system, 150),
//   //       _getRowItemWidget(data.equipment, 150),
//   //       _getRowItemWidget(data.equipmentLocation, 200),
//   //       // _getRowItemWidget(data.sparePartsConsumed.toString(), 200),
//   //       // _getRowItemWidget(data.sparePartsSwapped.toString(), 200),
//   //       _getRowItemWidget(data.description, 200),
//   //       _getRowItemWidget(data.solution, 200),
//   //       _getRowItemWidget(data.status, 100),
//   //       _getRowItemWidget(data.resolutionDate, 150),
//   //     ],
//   //   );
//   // }

//   Widget _getRowItemWidget(String label, double width) {
//     return Container(
//       child: Text(label, style: TextStyle(fontSize: 18)),
//       width: width,
//       height: 52,
//       padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
//       alignment: Alignment.centerLeft,
//     );
//   }
// }

// class FaultDataInfo {
//   final int sr;
//   final String occurrenceDate;
//   final String trainNumber;
//   final String carNumber;
//   final String source;
//   final String system;
//   final String equipment;
//   final String equipmentLocation;
//   // final bool sparePartsConsumed;
//   // final bool sparePartsSwapped;
//   final String description;
//   final String solution;
//   final String status;
//   final String resolutionDate;

//   FaultDataInfo({
//     required this.sr,
//     required this.occurrenceDate,
//     required this.trainNumber,
//     required this.carNumber,
//     required this.source,
//     required this.system,
//     required this.equipment,
//     required this.equipmentLocation,
//     // required this.sparePartsConsumed,
//     // required this.sparePartsSwapped,
//     required this.description,
//     required this.solution,
//     required this.status,
//     required this.resolutionDate,
//   });

//   factory FaultDataInfo.fromMap(Map<String, dynamic> map) {
//     return FaultDataInfo(
//       sr: map['SR'] ?? 0, // Assuming 'SR' is an integer, replace with 0 if null
//       occurrenceDate: map['OccurrenceDate'] ?? "",
//       trainNumber: map['TrainNumber'] ?? "",
//       carNumber: map['CarNumber'] ?? "",
//       source: map['Source'] ?? "",
//       system: map['System'] ?? "",
//       equipment: map['Equipment'] ?? "",
//       equipmentLocation: map['EquipmentLocation'] ?? "",
//       // For boolean fields, you can set them to false if null
//       // sparePartsConsumed: map['SparePartsConsumed'] ?? false,
//       // sparePartsSwapped: map['SparePartsSwapped'] ?? false,
//       description: map['Description'] ?? "",
//       solution: map['Solution'] ?? "",
//       status: map['Status'] ?? "",
//       resolutionDate: map['ResolutionDate'] ?? "",
//     );
//   }
//   void _showFilterDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text("Filter Options"),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text('System: '),
//                   DropdownButton<String>(
//                     value: _selectedSystem ?? _systems.first,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedSystem = value;
//                       });
//                     },
//                     items:
//                         _systems.map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                   ),
//                   SizedBox(height: 16),
//                   Text('Equipment: '),
//                   DropdownButton<String>(
//                     value: _selectedEquipment ?? _equipments.first,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedEquipment = value;
//                       });
//                     },
//                     items: _equipments
//                         .map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                   ),
//                 ],
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(); // Close the dialog
//                     _applyFilter(); // Apply filter when "Filter" button is pressed
//                   },
//                   child: Text("Filter"),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:horizontal_data_table/horizontal_data_table.dart';
// // Import SupabaseClient package
// import 'package:supabase/supabase.dart';

// class HorizontalTable extends StatefulWidget {
//   @override
//   _HorizontalTableState createState() => _HorizontalTableState();
// }

// class _HorizontalTableState extends State<HorizontalTable> {
//   late SupabaseClient _client;
//   List<FaultDataInfo> faultData = [];
//   List<String> _systems = [];
//   List<String> _equipments = [];
//   List<String> _locations = []; // Added locations list
//   String? _selectedSystem;
//   String? _selectedEquipment;
//   String? _selectedLocation; // Added selected location variable

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//     _fetchSystemAndEquipment();
//   }

//   Future<void> _fetchData() async {
//     String supabaseUrl = "https://typmqqidaijuobjosrpi.supabase.co";
//     String supabaseKey =
//         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cG1xcWlkYWlqdW9iam9zcnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTM0MzkzODAsImV4cCI6MjAwOTAxNTM4MH0.Ihde633Yj9FFaQ7hKLooxDxaFEno4fK8YxSb3gy8S4c";

//     _client = SupabaseClient(supabaseUrl, supabaseKey);
//     final response = await _client.from('FaultData').select().execute();

//     final List<FaultDataInfo> data = (response.data as List)
//         .map((item) => FaultDataInfo.fromMap(item))
//         .toList();

//     setState(() {
//       faultData = data;
//     });
//   }

//   Future<void> _fetchSystemAndEquipment() async {
//     final response = await _client
//         .from('FaultData')
//         .select('System, Equipment, EquipmentLocation')
//         .execute();

//     Set<String> systems = {};
//     Set<String> equipments = {};
//     Set<String> locations = {}; // Initialize locations set

//     for (var item in response.data!) {
//       if (item['System'] != null) {
//         systems.add(item['System'] as String);
//       }
//       if (item['Equipment'] != null) {
//         equipments.add(item['Equipment'] as String);
//       }
//       if (item['EquipmentLocation'] != null) {
//         locations.add(item['EquipmentLocation'] as String);
//       }
//     }

//     setState(() {
//       _systems = systems.toList()..sort();
//       _equipments = equipments.toList()..sort();
//       _locations = locations.toList()..sort(); // Update locations list
//     });
//   }

//   Future<void> _applyFilter() async {
//     if (_selectedSystem != null ||
//         _selectedEquipment != null ||
//         _selectedLocation != null) {
//       List<FaultDataInfo> filteredData = faultData.where((data) {
//         bool systemMatch =
//             _selectedSystem == null || data.system == _selectedSystem;
//         bool equipmentMatch =
//             _selectedEquipment == null || data.equipment == _selectedEquipment;
//         bool locationMatch = _selectedLocation == null ||
//             data.equipmentLocation == _selectedLocation;
//         return systemMatch && equipmentMatch && locationMatch;
//       }).toList();

//       setState(() {
//         faultData = filteredData;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         height: double.infinity,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             fit: BoxFit.cover,
//             image: AssetImage('assets/background.png'),
//           ),
//         ),
//         child: Stack(
//           children: [
//             Center(
//               child: SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.9,
//                 height: MediaQuery.of(context).size.height * 0.82,
//                 child: _getBodyWidget(),
//               ),
//             ),
//             Positioned(
//               top: 3,
//               right: 16,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   _showFilterDialog(context);
//                 },
//                 icon: Icon(Icons.filter_list),
//                 label: Text('Filter'),
//                 style: ElevatedButton.styleFrom(
//                   primary: Colors.orange,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _getBodyWidget() {
//     return Center(
//       child: SizedBox(
//         width: MediaQuery.of(context).size.width *
//             0.9, // Adjust the width as needed
//         height: MediaQuery.of(context).size.height *
//             0.82, // Adjust the height as needed

//         child: HorizontalDataTable(
//           leftHandSideColumnWidth: 100,
//           rightHandSideColumnWidth: 1750,
//           isFixedHeader: true,
//           headerWidgets: _getTitleWidget(),
//           leftSideItemBuilder: _generateFirstColumnRow,
//           rightSideItemBuilder: _generateRightHandSideColumnRow,
//           itemCount: faultData.length,
//           rowSeparatorWidget: const Divider(
//             color: Colors.black54,
//             height: 1.0,
//             thickness: 0.0,
//           ),
//           leftHandSideColBackgroundColor: Color(0xFFFFFFFF),
//           rightHandSideColBackgroundColor: Color(0xFFFFFFFF),
//         ),
//       ),
//     );
//   }

//   List<Widget> _getTitleWidget() {
//     return [
//       _getTitleItemWidget('SR', 120, Color(0xFF222229)),
//       _getTitleItemWidget('Occurrence Date', 150, Colors.orange),
//       _getTitleItemWidget('Train Number', 150, Colors.orange),
//       _getTitleItemWidget('Car Number', 150, Colors.orange),
//       _getTitleItemWidget('Source', 150, Colors.orange),
//       _getTitleItemWidget('System', 150, Colors.orange),
//       _getTitleItemWidget('Equipment', 150, Colors.orange),
//       _getTitleItemWidget('Equipment Location', 200, Colors.orange),
//       _getTitleItemWidget('Description', 200, Colors.orange),
//       _getTitleItemWidget('Solution', 200, Colors.orange),
//       _getTitleItemWidget('Status', 100, Colors.orange),
//       _getTitleItemWidget('Resolution Date', 150, Colors.orange),
//     ];
//   }

//   Widget _getTitleItemWidget(String label, double width, Color color) {
//     return Container(
//       color: color,
//       child: Text(label,
//           style: TextStyle(
//               fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
//       width: width,
//       height: 56,
//       padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
//       alignment: Alignment.centerLeft,
//     );
//   }

//   Widget _generateFirstColumnRow(BuildContext context, int index) {
//     return Container(
//       color: Color(0xFF222229),
//       child: Text(faultData[index].sr.toString(),
//           style: TextStyle(
//               fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
//       width: 120,
//       height: 52,
//       padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
//       alignment: Alignment.centerLeft,
//     );
//   }

//   Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
//     final FaultDataInfo data = faultData[index];
//     if ((_selectedEquipment != null && data.equipment != _selectedEquipment) ||
//         (_selectedLocation != null &&
//             data.equipmentLocation != _selectedLocation)) {
//       return Container(); // Return an empty container if not matching filter
//     } else {
//       return Row(
//         children: <Widget>[
//           _getRowItemWidget(data.occurrenceDate, 150),
//           _getRowItemWidget(data.trainNumber, 150),
//           _getRowItemWidget(data.carNumber, 150),
//           _getRowItemWidget(data.source, 150),
//           _getRowItemWidget(data.system, 150),
//           _getRowItemWidget(data.equipment, 150),
//           _getRowItemWidget(data.equipmentLocation, 200),
//           _getRowItemWidget(data.description, 200),
//           _getRowItemWidget(data.solution, 200),
//           _getRowItemWidget(data.status, 100),
//           _getRowItemWidget(data.resolutionDate, 150),
//         ],
//       );
//     }
//   }

//   Widget _getRowItemWidget(String label, double width) {
//     return Container(
//       child: Text(label, style: TextStyle(fontSize: 18)),
//       width: width,
//       height: 52,
//       padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
//       alignment: Alignment.centerLeft,
//     );
//   }

//   void _showFilterDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text("Filter Options"),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text('System: '),
//                   DropdownButton<String>(
//                     value: _selectedSystem ?? _systems.first,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedSystem = value;
//                         _applyFilter(); // Apply filter when system changes
//                       });
//                     },
//                     items:
//                         _systems.map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                   ),
//                   SizedBox(height: 16),
//                   Text('Equipment: '),
//                   DropdownButton<String>(
//                     value: _selectedEquipment ?? _equipments.first,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedEquipment = value;
//                         _applyFilter(); // Apply filter when equipment changes
//                       });
//                     },
//                     items: _equipments
//                         .map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                   ),
//                   SizedBox(height: 16),
//                   Text('Location: '),
//                   DropdownButton<String>(
//                     value: _selectedLocation ?? _locations.first,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedLocation = value;
//                         _applyFilter(); // Apply filter when location changes
//                       });
//                     },
//                     items: _locations
//                         .map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                   ),
//                 ],
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(); // Close the dialog
//                   },
//                   child: Text("Close"),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class FaultDataInfo {
//   final int sr;
//   final String occurrenceDate;
//   final String trainNumber;
//   final String carNumber;
//   final String source;
//   final String system;
//   final String equipment;
//   final String equipmentLocation;
//   final String description;
//   final String solution;
//   final String status;
//   final String resolutionDate;

//   FaultDataInfo({
//     required this.sr,
//     required this.occurrenceDate,
//     required this.trainNumber,
//     required this.carNumber,
//     required this.source,
//     required this.system,
//     required this.equipment,
//     required this.equipmentLocation,
//     required this.description,
//     required this.solution,
//     required this.status,
//     required this.resolutionDate,
//   });

//   factory FaultDataInfo.fromMap(Map<String, dynamic> map) {
//     return FaultDataInfo(
//       sr: map['SR'] ?? 0, // Assuming 'SR' is an integer, replace with 0 if null
//       occurrenceDate: map['OccurrenceDate'] ?? "",
//       trainNumber: map['TrainNumber'] ?? "",
//       carNumber: map['CarNumber'] ?? "",
//       source: map['Source'] ?? "",
//       system: map['System'] ?? "",
//       equipment: map['Equipment'] ?? "",
//       equipmentLocation: map['EquipmentLocation'] ?? "",
//       // For boolean fields, you can set them to false if null
//       // sparePartsConsumed: map['SparePartsConsumed'] ?? false,
//       // sparePartsSwapped: map['SparePartsSwapped'] ?? false,
//       description: map['Description'] ?? "",
//       solution: map['Solution'] ?? "",
//       status: map['Status'] ?? "",
//       resolutionDate: map['ResolutionDate'] ?? "",
//     );
//   }
// }
import 'package:horizontal_data_table/horizontal_data_table.dart';

class HorizontalTable extends StatefulWidget {
  @override
  _HorizontalTableState createState() => _HorizontalTableState();
}

class _HorizontalTableState extends State<HorizontalTable> {
  late SupabaseClient _client;
  List<FaultDataInfo> faultData = [];
  List<String> _systems = [];
  List<String> _equipments = [];
  List<String> _statuses = []; // Added statuses list
  String? _selectedSystem;
  String? _selectedEquipment;
  String? _selectedStatus; // Added selected status variable

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchSystemAndEquipment();
  }

  Future<void> _fetchData() async {
    String supabaseUrl = "https://typmqqidaijuobjosrpi.supabase.co";
    String supabaseKey =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cG1xcWlkYWlqdW9iam9zcnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTM0MzkzODAsImV4cCI6MjAwOTAxNTM4MH0.Ihde633Yj9FFaQ7hKLooxDxaFEno4fK8YxSb3gy8S4c";

    _client = SupabaseClient(supabaseUrl, supabaseKey);
    final response = await _client.from('FaultData').select().execute();

    final List<FaultDataInfo> data = (response.data as List)
        .map((item) => FaultDataInfo.fromMap(item))
        .toList();

    setState(() {
      faultData = data;
    });
  }

  Future<void> _fetchSystemAndEquipment() async {
    final response = await _client
        .from('FaultData')
        .select('System, Equipment, Status')
        .execute();

    Set<String> systems = {};
    Set<String> equipments = {};
    Set<String> statuses = {}; // Initialize statuses set

    for (var item in response.data!) {
      if (item['System'] != null) {
        systems.add(item['System'] as String);
      }
      if (item['Equipment'] != null) {
        equipments.add(item['Equipment'] as String);
      }
      if (item['Status'] != null) {
        statuses.add(item['Status'] as String);
      }
    }

    setState(() {
      _systems = systems.toList()..sort();
      _equipments = equipments.toList()..sort();
      _statuses = statuses.toList()..sort(); // Update statuses list
    });
  }

  Future<void> _applyFilter() async {
    if (_selectedSystem != null ||
        _selectedEquipment != null ||
        _selectedStatus != null) {
      List<FaultDataInfo> filteredData = faultData.where((data) {
        bool systemMatch =
            _selectedSystem == null || data.system == _selectedSystem;
        bool equipmentMatch =
            _selectedEquipment == null || data.equipment == _selectedEquipment;
        bool statusMatch =
            _selectedStatus == null || data.status == _selectedStatus;
        return systemMatch && equipmentMatch && statusMatch;
      }).toList();

      setState(() {
        faultData = filteredData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/background.png'),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.82,
                child: _getBodyWidget(),
              ),
            ),
            Positioned(
              top: 3,
              right: 16,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showFilterDialog(context);
                },
                icon: Icon(Icons.filter_list),
                label: Text('Filter'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBodyWidget() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width *
            0.9, // Adjust the width as needed
        height: MediaQuery.of(context).size.height *
            0.82, // Adjust the height as needed

        child: HorizontalDataTable(
          leftHandSideColumnWidth: 100,
          rightHandSideColumnWidth: 1600,
          isFixedHeader: true,
          headerWidgets: _getTitleWidget(),
          leftSideItemBuilder: _generateFirstColumnRow,
          rightSideItemBuilder: _generateRightHandSideColumnRow,
          itemCount: faultData.length,
          rowSeparatorWidget: const Divider(
            color: Colors.black54,
            height: 1.0,
            thickness: 0.0,
          ),
          leftHandSideColBackgroundColor: Color(0xFFFFFFFF),
          rightHandSideColBackgroundColor: Color(0xFFFFFFFF),
        ),
      ),
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget('SR', 120, Color(0xFF222229)),
      _getTitleItemWidget('Occurrence Date', 150, Colors.orange),
      _getTitleItemWidget('Train Number', 150, Colors.orange),
      _getTitleItemWidget('Car Number', 150, Colors.orange),
      _getTitleItemWidget('Source', 150, Colors.orange),
      _getTitleItemWidget('System', 150, Colors.orange),
      _getTitleItemWidget('Equipment', 150, Colors.orange),
      _getTitleItemWidget(
          'Status', 150, Colors.orange), // Include status column
      _getTitleItemWidget('Description', 200, Colors.orange),
      _getTitleItemWidget('Solution', 200, Colors.orange),
      _getTitleItemWidget('Resolution Date', 150, Colors.orange),
    ];
  }

  Widget _getTitleItemWidget(String label, double width, Color color) {
    return Container(
      color: color,
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
      width: width,
      height: 56,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      color: Color(0xFF222229),
      child: Text(faultData[index].sr.toString(),
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      width: 120,
      height: 52,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    final FaultDataInfo data = faultData[index];
    if ((_selectedEquipment != null && data.equipment != _selectedEquipment) ||
        (_selectedSystem != null && data.system != _selectedSystem) ||
        (_selectedStatus != null && data.status != _selectedStatus)) {
      return Container(); // Return an empty container if not matching filter
    } else {
      return Row(
        children: <Widget>[
          _getRowItemWidget(data.occurrenceDate, 150),
          _getRowItemWidget(data.trainNumber, 150),
          _getRowItemWidget(data.carNumber, 150),
          _getRowItemWidget(data.source, 150),
          _getRowItemWidget(data.system, 150),
          _getRowItemWidget(data.equipment, 150),
          _getRowItemWidget(data.status, 150), // Add status widget
          _getRowItemWidget(data.description, 200),
          _getRowItemWidget(data.solution, 200),
          _getRowItemWidget(data.resolutionDate, 150),
        ],
      );
    }
  }

  Widget _getRowItemWidget(String label, double width) {
    return Container(
      child: Text(label, style: TextStyle(fontSize: 18)),
      width: width,
      height: 52,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Filter Options"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('System: '),
                  DropdownButton<String>(
                    value: _selectedSystem ?? _systems.first,
                    onChanged: (value) {
                      setState(() {
                        _selectedSystem = value;
                        _applyFilter(); // Apply filter when system changes
                      });
                    },
                    items:
                        _systems.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  Text('Equipment: '),
                  DropdownButton<String>(
                    value: _selectedEquipment ?? _equipments.first,
                    onChanged: (value) {
                      setState(() {
                        _selectedEquipment = value;
                        _applyFilter(); // Apply filter when equipment changes
                      });
                    },
                    items: _equipments
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  Text('Status: '), // Add status filter
                  DropdownButton<String>(
                    value: _selectedStatus ?? _statuses.first,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                        _applyFilter(); // Apply filter when status changes
                      });
                    },
                    items:
                        _statuses.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class FaultDataInfo {
  final int sr;
  final String occurrenceDate;
  final String trainNumber;
  final String carNumber;
  final String source;
  final String system;
  final String equipment;
  final String status; // Include status field
  final String description;
  final String solution;
  final String resolutionDate;

  FaultDataInfo({
    required this.sr,
    required this.occurrenceDate,
    required this.trainNumber,
    required this.carNumber,
    required this.source,
    required this.system,
    required this.equipment,
    required this.status, // Add status parameter
    required this.description,
    required this.solution,
    required this.resolutionDate,
  });

  factory FaultDataInfo.fromMap(Map<String, dynamic> map) {
    return FaultDataInfo(
      sr: map['SR'] ?? 0,
      occurrenceDate: map['OccurrenceDate'] ?? "",
      trainNumber: map['TrainNumber'] ?? "",
      carNumber: map['CarNumber'] ?? "",
      source: map['Source'] ?? "",
      system: map['System'] ?? "",
      equipment: map['Equipment'] ?? "",
      status: map['Status'] ?? "", // Initialize status field
      description: map['Description'] ?? "",
      solution: map['Solution'] ?? "",
      resolutionDate: map['ResolutionDate'] ?? "",
    );
  }
}
