import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:third_app/Screen/Fault_Data/Page3.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: first(),
    );
  }
}

class first extends StatefulWidget {
  final String? path;

  first({Key? key, this.path}) : super(key: key);

  @override
  _firstState createState() => _firstState();
}

class _firstState extends State<first> {
  String selectedValue = 'Option 1'; // Default selected value
  String selectedValue2 = 'Option 1'; // Default selected value
  String selectedValue3 = 'Select system';
  String selectedValue4 = 'Select equipment'; //temporary for system
  String selectedValue5 = 'Select location'; //temporary for equipment
  String selectedValue6 = '4 Day Power'; //temporary for equipment location

  final ValueNotifier<String> selectedValue3Controller =
      ValueNotifier<String>('Select system'); // Default selected value
  final ValueNotifier<String> selectedValue4Controller =
      ValueNotifier<String>('Select equipment'); // Default selected value

  // Initialize the Supabase client
  var supabaseClient = SupabaseClient(
    "https://typmqqidaijuobjosrpi.supabase.co",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cG1xcWlkYWlqdW9iam9zcnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTM0MzkzODAsImV4cCI6MjAwOTAxNTM4MH0.Ihde633Yj9FFaQ7hKLooxDxaFEno4fK8YxSb3gy8S4c",
  );

  // List of options for the dropdown
  List<String> options = []; // Empty list initially
  List<String> options2 = []; // Empty list initially for carNo
  List<String> systemList = []; // Empty list intially for system
  List<String> equipmentList = []; // Empty list intially for equipment
  List<String> locationList = []; // Empty list intially for location
  TextEditingController _timeController = TextEditingController();
  String timeError = ' ';

  @override
  void initState() {
    super.initState();

    _dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
    _timeController.text = DateFormat('HH:mm:ss').format(DateTime.now());
    // Fetch data from Supabase and update options list
    fetchOptionsData();
    fetchOptionsData2();
    fetchSystem();
    selectedValue3Controller.addListener(() {
      fetchEquipment();
    });
    selectedValue4Controller.addListener(() {
      fetchLocation();
    });
  }

  Future<void> fetchOptionsData() async {
    final response = await supabaseClient
        .from('train') // Replace with your actual table name
        .select('trainno') // Replace with the column containing the options
        .execute();

    final List<dynamic> data = response.data as List<dynamic>;
    setState(() {
      options = data.map<String>((item) => item['trainno'] as String).toList();
      selectedValue = options.isNotEmpty ? options[0] : 'No Options';
    });
  }

  Future<void> fetchOptionsData2() async {
    final response = await supabaseClient
        .from('train') // Replace with your actual table name
        .select('carNo') // Replace with the column containing the options
        .execute();

    final List<dynamic> data2 = response.data as List<dynamic>;

    // Filter out null values from the 'carNo' column
    final List<String> nonNullOptions = data2
        .where((item) => item['carNo'] != null)
        .map<String>((item) => item['carNo'] as String)
        .toList();

    setState(() {
      options2 = nonNullOptions;
      selectedValue2 = options2.isNotEmpty ? options2[0] : 'No Options';
    });
  }

  Future<void> fetchSystem() async {
    final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/get_related_system'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'class_instance': 'System'}));

    if (response.statusCode == 200) {
      setState(() {
        List<dynamic> temp = jsonDecode(response.body)['related_system'];
        systemList = temp.map((dynamic item) => item.toString()).toList();
        selectedValue3 = systemList.isNotEmpty ? systemList[0] : 'No Options';
      });
    } else {
      throw Exception('Failed to load system');
    }
  }

  Future<void> fetchEquipment() async {
    selectedValue3 = selectedValue3Controller.value;
    selectedValue4Controller.value = 'Select equipment';
    if (selectedValue3 != 'Select system') {
      final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/get_related_equipment'),
          headers: <String, String>{'Content-Type': 'application/json'},
          body:
              jsonEncode(<String, String>{'system_instance': selectedValue3}));

      if (response.statusCode == 200) {
        setState(() {
          List<dynamic> temp = jsonDecode(response.body)['related_equipment'];
          equipmentList = temp.map((dynamic item) => item.toString()).toList();
          selectedValue4 =
              equipmentList.isNotEmpty ? equipmentList[0] : 'No Options';
        });
      } else {
        throw Exception('Failed to load equipment');
      }
    }
  }

  Future<void> fetchLocation() async {
    selectedValue4 = selectedValue4Controller.value;
    //selectedValue5 = 'Select location';
    if (selectedValue4 != 'Select equipment') {
      final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/get_related_location'),
          headers: <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode(
              <String, String>{'equipment_instance': selectedValue4}));

      if (response.statusCode == 200) {
        setState(() {
          List<dynamic> temp = jsonDecode(response.body)['related_location'];
          locationList = temp.map((dynamic item) => item.toString()).toList();
          selectedValue5 =
              locationList.isNotEmpty ? locationList[0] : 'No Options';
        });
      } else {
        throw Exception('Failed to load location');
      }
    }
  }

  // Future<void> fetchOptionsData3() async {
  //   final response = await supabaseClient
  //       .from('train') // Replace with your actual table name
  //       .select('system') // Replace with the column containing the options
  //       .execute();

  //   final List<dynamic> data3 = response.data as List<dynamic>;

  //   // Filter out null values from the 'carNo' column
  //   final List<String> nonNullOptions = data3
  //       .where((item) => item['system'] != null)
  //       .map<String>((item) => item['system'] as String)
  //       .toList();

  //   setState(() {
  //     options3 = nonNullOptions;
  //     print(options3);
  //     selectedValue3 = options3.isNotEmpty ? options3[0] : 'No Options';
  //   });
  // }

  TextEditingController _dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String dateError = ' ';

  void _validateDate(String input) {
    if (input.isNotEmpty) {
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      try {
        dateFormat.parseStrict(input);
        setState(() {
          dateError = ' ';
        });
      } catch (e) {
        setState(() {
          dateError = 'Invalid date format. Please use dd-mm-yyyy.';
        });
      }
    }
  }

  void validateFields() {
    _validateDate(_dateController.text);
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> sendDataToDatabase(
      String selectedValue,
      String selectedValue2,
      String selectedValue5,
      String selectedValue6,
      String selectedValue3,
      String selectedValue4) async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/fault_info'); // Replace with your Flask API endpoint URL

    final data = <String, dynamic>{
      '_date1Controller': (_dateController.text),
      'trainNo': selectedValue,
      'CarNo': selectedValue2,
      'system': selectedValue3,
      'Equipment': selectedValue4,
      'Equipment_loc': selectedValue5,
      'Fault_Source': selectedValue6,
    };

    print(data);
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Data sent successfully');
      print('Response: ${response.body}');
    } else {
      print('Failed to send data. Error: ${response.statusCode}');
    }
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
                                    color: Color(0xddff8518),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(30, 0, 30, 0.18),
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
                                  color: Color(0xFFFFFFFF),
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
                            width: 470,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(0xFF222229),
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
                              'Date',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                                color: Color(0xffffffff),
                              ),
                            ),
                            Text(
                              ' *',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
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
                              width: 180,
                              height: 50,
                              child: TextFormField(
                                controller: _dateController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'dd-mm-yyyy',
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.calendar_today),
                                    onPressed: () => selectDate(context),
                                  ),
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xddff8518),
                                      width: 2,
                                    ),
                                  ),
                                  errorText: dateError,
                                ),
                                onTap: () => selectDate(context),
                                onChanged: _validateDate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 60),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              // Added a Row widget to include both text and asterisk
                              children: <Widget>[
                                Text(
                                  'Train No',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                    color: Color(0xffffffff),
                                  ),
                                ),
                                SizedBox(width: 5), //space between text and *
                                Text(
                                  '*', // Asterisk
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
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
                              width: 180,
                              height: 40,
                              child: DropdownButton<String>(
                                value: selectedValue,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedValue = newValue!;
                                  });
                                },
                                items: options.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Color(0xddff8518)),
                                iconSize: 24,
                                isExpanded: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 60),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              // Added a Row widget to include both text and asterisk
                              children: <Widget>[
                                Text(
                                  'Car No',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                    color: Color(0xffffffff),
                                  ),
                                ),
                                SizedBox(width: 5), //space between text and *
                                Text(
                                  '*', // Asterisk
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
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
                              width: 180,
                              height: 40,
                              child: DropdownButton<String>(
                                value: selectedValue2,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedValue2 = newValue!;
                                  });
                                },
                                items: options2.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Color(0xddff8518)),
                                iconSize: 24,
                                isExpanded: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 58),
                        child: Column(
                          children: <Widget>[
                            Row(
                              // Added a Row widget to include both text and asterisk
                              children: <Widget>[
                                Text(
                                  'Equipment Location',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                    color: Color(0xffffffff),
                                  ),
                                ),
                                SizedBox(width: 5), //space between text and *
                                Text(
                                  '*', // Asterisk
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Row(
                          children: [
                            SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.only(left: 42),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 180,
                                    height: 40,
                                    child: DropdownButton<String>(
                                      value: selectedValue5,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedValue5 = newValue!;
                                        });
                                      },
                                      items: locationList
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      icon: Icon(Icons.arrow_drop_down,
                                          color: Color(0xddff8518)),
                                      iconSize: 24,
                                      isExpanded: true,
                                    ),
                                  ),
                                ],
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
                left: 710,
                top: 280,
                child: Align(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            Text(
                              'Fault Source',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                                color: Color(0xffffffff),
                              ),
                            ),
                            SizedBox(
                              width: 5, // Add spacing between the text and "*"
                            ),
                            Text(
                              '*',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Row(
                          children: [
                            SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.only(left: 15),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 180,
                                    height: 40,
                                    child: DropdownButton<String>(
                                      value: selectedValue6,
                                      items: [
                                        '4 Day Power',
                                        '4 Day Non Power',
                                        'System Maintenance',
                                        'Mainline Return',
                                        'Status Card',
                                        'Station Guarantee',
                                        'TD',
                                        'RSMD',
                                        'Arrival Inspection',
                                        'Departure Inspection',
                                        'Train Operator',
                                        'Modification',
                                        'Transition',
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedValue6 = newValue!;
                                        });
                                      },
                                      icon: Icon(Icons.arrow_drop_down,
                                          color: Color(0xddff8518)),
                                      iconSize: 24,
                                      isExpanded:
                                          true, // Ensures the dropdown button expands to fill its container
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Column(
                          children: <Widget>[
                            Row(
                              // Added a Row widget to include both text and asterisk
                              children: <Widget>[
                                Text(
                                  'System',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                    color: Color(0xffffffff),
                                  ),
                                ),
                                SizedBox(width: 5), //space between text and *
                                Text(
                                  '*', // Asterisk
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 180,
                              height: 40,
                              child: DropdownButton<String>(
                                value: selectedValue3Controller.value,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedValue3Controller.value = newValue!;
                                  });
                                },
                                items: systemList.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Color(0xddff8518)),
                                iconSize: 24,
                                isExpanded: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Column(
                          children: <Widget>[
                            Row(
                              // Added a Row widget to include both text and asterisk
                              children: <Widget>[
                                Text(
                                  'Equipment',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                    color: Color(0xffffffff),
                                  ),
                                ),
                                SizedBox(width: 5), //space between text and *
                                Text(
                                  '*', // Asterisk
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 180,
                              height: 40,
                              child: DropdownButton<String>(
                                value: selectedValue4Controller.value,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedValue4Controller.value = newValue!;
                                  });
                                },
                                items: equipmentList
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Color(0xddff8518)),
                                iconSize: 24,
                                isExpanded: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 70),
                      Padding(
                        padding: EdgeInsets.only(left: 250),
                        child: SizedBox(
                          width: 130,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              sendDataToDatabase(
                                  selectedValue,
                                  selectedValue2,
                                  selectedValue5,
                                  selectedValue6,
                                  selectedValue3Controller.value,
                                  selectedValue4Controller.value);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Page3(),
                                ),
                              );
                            },
                            child: Text(
                              'Next',
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
                      ),
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
