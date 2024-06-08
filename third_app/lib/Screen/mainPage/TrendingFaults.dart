import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:supabase/supabase.dart' as supabase;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // Define the overall theme
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Trending Faults'),
        ),
        body: FaultsChart(),
      ),
    );
  }
}

class FaultData {
  final String equipment;
  final int faultsCount;

  FaultData(this.equipment, this.faultsCount);
}

class FaultsChart extends StatefulWidget {
  @override
  _FaultsChartState createState() => _FaultsChartState();
}

class _FaultsChartState extends State<FaultsChart> {
  late Future<List<FaultData>> _faultsData;

  late supabase.SupabaseClient supabaseClient;

  @override
  void initState() {
    super.initState();
    _faultsData = fetchAndProcessData();
  }

  Future<List<dynamic>> fetchAllRows(String tableName,
      {int pageSize = 1000}) async {
    int offset = 0;
    List<dynamic> allRows = [];

    String supabase_url = "https://typmqqidaijuobjosrpi.supabase.co";
    String supabase_key =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cG1xcWlkYWlqdW9iam9zcnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTM0MzkzODAsImV4cCI6MjAwOTAxNTM4MH0.Ihde633Yj9FFaQ7hKLooxDxaFEno4fK8YxSb3gy8S4c";

    var supabase_client = supabase.SupabaseClient(supabase_url, supabase_key);
    while (true) {
      final response = await supabase_client
          .from(tableName) // Use 'from' instead of 'table'
          .select("*")
          .range(offset, offset + pageSize - 1)
          .execute();
      List<dynamic> data = response.data;
      if (data.isEmpty) {
        break;
      }
      allRows.addAll(data);
      if (data.length < pageSize) {
        break;
      }
      offset += pageSize;
    }

    return allRows;
  }

  Future<List<FaultData>> fetchAndProcessData() async {
    // Replace these with your actual Supabase URL and Key
    const url = 'https://typmqqidaijuobjosrpi.supabase.co/rest/v1/FaultData';
    const headers = {
      'apikey':
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cG1xcWlkYWlqdW9iam9zcnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTM0MzkzODAsImV4cCI6MjAwOTAxNTM4MH0.Ihde633Yj9FFaQ7hKLooxDxaFEno4fK8YxSb3gy8S4c'
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> allRows = await fetchAllRows('FaultData');
      final processedData = _processData(allRows);
      print(processedData);
      return processedData;
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  List<FaultData> _processData(List<dynamic> rawData) {
    Map<String, int> equipmentFaults = {};

    for (var row in rawData) {
      final DateTime occurrenceDate =
          DateFormat('yyyy-MM-dd').parse(row['OccurrenceDate']);
      final DateTime startDate = DateTime(2020, 3, 1);
      final DateTime endDate = DateTime(2024, 3, 15);

      if (occurrenceDate.isAfter(startDate) &&
          occurrenceDate.isBefore(endDate)) {
        final String equipment = row['Equipment'] ?? 'Unknown';
        if (equipment != 'Others' && equipment != 'Unknown') {
          equipmentFaults[equipment] = (equipmentFaults[equipment] ?? 0) + 1;
        }
      }
    }

    final sortedEquipmentFaults = equipmentFaults.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEquipmentFaults
        .take(10)
        .map((e) => FaultData(e.key, e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FaultData>>(
      future: _faultsData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          final data = snapshot.data;
          if (data == null || data.isEmpty) {
            return Text('No data available');
          }

          return Container(
            width: 550,
            height: 550,
            child: SfCartesianChart(
              backgroundColor: Colors.transparent,
              primaryXAxis: CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),

                title: AxisTitle(
                  text: 'Equipments',
                  textStyle: TextStyle(color: Colors.white),
                ), // X-axis label

                labelRotation: 90,

                labelStyle: TextStyle(color: Colors.white),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: MajorGridLines(width: 0),

                labelStyle: TextStyle(color: Colors.white),
                title: AxisTitle(
                  text: 'Count', // Y-axis label
                  textStyle:
                      TextStyle(color: Colors.white), // Y-axis title color
                ), // Y-axis label
                interval: 50,
              ),
              title: ChartTitle(
                text: 'Trending Faults',
                textStyle: TextStyle(color: Colors.white),
              ),
              legend: Legend(isVisible: false),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                textStyle: TextStyle(color: Colors.white),
              ),
              plotAreaBorderWidth: 0,
              series: <CartesianSeries>[
                ColumnSeries<FaultData, String>(
                  dataSource: snapshot.data!,
                  xValueMapper: (FaultData faults, _) => faults.equipment,
                  yValueMapper: (FaultData faults, _) => faults.faultsCount,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(255, 133, 24, 1), // Orange color
                ),
              ],
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
