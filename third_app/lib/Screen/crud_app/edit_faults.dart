import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

class FaultsEditor extends StatefulWidget {
  @override
  _FaultsEditorState createState() => _FaultsEditorState();
}

class _FaultsEditorState extends State<FaultsEditor> {
  late SupabaseClient _client;
  List<String> _filteredFaultDescriptions = [];
  List<String> _faultDescriptions = [];
  List<String> _systems = [];
  List<String> _equipments = [];
  String? _selectedSystem;
  String? _selectedEquipment;

  @override
  void initState() {
    super.initState();
    _initializeSupabase();
    _fetchFaultDescriptions();
    _fetchSystemAndEquipment();
  }

  void _initializeSupabase() {
    String supabaseUrl = "https://typmqqidaijuobjosrpi.supabase.co";
    String supabaseKey =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cG1xcWlkYWlqdW9iam9zcnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTM0MzkzODAsImV4cCI6MjAwOTAxNTM4MH0.Ihde633Yj9FFaQ7hKLooxDxaFEno4fK8YxSb3gy8S4c";

    _client = SupabaseClient(supabaseUrl, supabaseKey);
  }

  Future<void> _fetchFaultDescriptions() async {
    final response =
        await _client.from('FaultDetection').select('fault_desc').execute();

    if (response.data == null) {
      print('No fault descriptions found');
      return;
    }

    List<String> faultDescriptions = [];

    for (var row in response.data!) {
      String? faultDesc = row['fault_desc'] as String?;
      if (faultDesc != null && !faultDescriptions.contains(faultDesc)) {
        faultDescriptions.add(faultDesc);
      }
    }

    setState(() {
      _faultDescriptions = faultDescriptions;
      _filteredFaultDescriptions =
          _faultDescriptions; // Initialize filtered list
    });
  }

  Future<void> _fetchSystemAndEquipment() async {
    final response =
        await _client.from('FaultData').select('System, Equipment').execute();

    if (response.data == null) {
      print('No system and equipment found');
      return;
    }

    Set<String> systems = {};
    Set<String> equipments = {};

    for (var item in response.data!) {
      if (item['System'] != null) {
        systems.add(item['System'] as String);
      }
      if (item['Equipment'] != null) {
        equipments.add(item['Equipment'] as String);
      }
    }

    setState(() {
      _systems = systems.toList()..sort();
      _equipments = equipments.toList()..sort();
    });
  }

  Future<void> _applyFilter() async {
    if (_selectedSystem != null && _selectedEquipment != null) {
      String normalizedSystem =
          _selectedSystem!.toLowerCase().replaceAll('_', ' ');
      String normalizedEquipment =
          _selectedEquipment!.toLowerCase().replaceAll('_', ' ');

      // Filter fault descriptions based on selected system and equipment
      List<String> filteredFaultDescriptions = _faultDescriptions.where((desc) {
        String normalizedDesc = desc.replaceAll('_', ' ').toLowerCase();
        return normalizedDesc.contains(normalizedSystem) &&
            normalizedDesc.contains(normalizedEquipment);
      }).toList();

      setState(() {
        _filteredFaultDescriptions = filteredFaultDescriptions;
      });
    }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Faults',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredFaultDescriptions.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 2,
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          color: Color(0xFF313134),
                          child: ListTile(
                            title: Text(
                              _filteredFaultDescriptions[index],
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
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
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    _applyFilter(); // Apply filter when "Filter" button is pressed
                  },
                  child: Text("Filter"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
