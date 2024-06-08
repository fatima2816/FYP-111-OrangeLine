import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:supabase/supabase.dart' as supabase;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Repetitive Faults Chart'),
        ),
        body: RepetitiveFaultsChart(),
      ),
    );
  }
}

class EquipmentFault {
  final String equipmentKey;
  final int count;
  final DateTime date;

  EquipmentFault(this.equipmentKey, this.count, this.date);
}

class RepetitiveFaultsChart extends StatefulWidget {
  @override
  _RepetitiveFaultsChartState createState() => _RepetitiveFaultsChartState();
}

class _RepetitiveFaultsChartState extends State<RepetitiveFaultsChart> {
  late Future<List<EquipmentFault>> futureData;

  late supabase.SupabaseClient
      supabaseClient; // Use SupabaseClient instead of Client

  @override
  void initState() {
    super.initState();
    futureData = fetchEquipmentFaults();
  }

  Future<List<dynamic>> fetchAllRows2(String tableName,
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

  Future<List<EquipmentFault>> fetchEquipmentFaults() async {
    const String url =
        'https://typmqqidaijuobjosrpi.supabase.co/rest/v1/FaultData';
    final response = await http.get(Uri.parse(url), headers: {
      'apikey':
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cG1xcWlkYWlqdW9iam9zcnBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTM0MzkzODAsImV4cCI6MjAwOTAxNTM4MH0.Ihde633Yj9FFaQ7hKLooxDxaFEno4fK8YxSb3gy8S4c',
    });

    if (response.statusCode == 200) {
      List<dynamic> rawData = await fetchAllRows2('FaultData');
      return processData(rawData);
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<EquipmentFault> processData(List<dynamic> rawData) {
    Map<String, Map<String, dynamic>> equipmentFaults = {};
    DateTime currentDateTime = DateTime.now();
    DateTime lastWeekDateTime = currentDateTime.subtract(Duration(days: 220));

    for (var row in rawData) {
      String equipment = row["Equipment"] ?? "Unknown";
      String trainNumber = row["TrainNumber"].toString();
      String carNumber = row["CarNumber"].toString();
      DateTime faultDate = DateTime.parse(row["OccurrenceDate"]);

      if (equipment == "Others" || equipment.isEmpty) continue;

      String equipmentKey = "$equipment\_$trainNumber\_$carNumber";

      if (!equipmentFaults.containsKey(equipmentKey)) {
        equipmentFaults[equipmentKey] = {
          "count": 0,
          "date": faultDate,
        };
      }

      equipmentFaults[equipmentKey]?["count"] += 1;
      equipmentFaults[equipmentKey]?["date"] = faultDate;
    }

    List<EquipmentFault> filteredFaults = [];

    equipmentFaults.forEach((key, value) {
      DateTime date = value["date"];
      int count = value["count"];

      if (date.isAfter(lastWeekDateTime) && count > 1) {
        filteredFaults.add(EquipmentFault(key, count, date));
      }
    });

    filteredFaults.sort((a, b) => b.date.compareTo(a.date));

    return filteredFaults;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EquipmentFault>>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: 550,
              height: 550,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                backgroundColor: Colors.transparent,
                primaryXAxis: CategoryAxis(
                  majorGridLines: MajorGridLines(width: 0),
                  title: AxisTitle(
                    text: 'Equipments',
                    textStyle: TextStyle(color: Colors.white),
                  ), // X-axis label
                  labelStyle: TextStyle(color: Colors.white),
                  // Experiment with this value to reduce label clutter

                  labelRotation: 90,
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: MajorGridLines(width: 0),
                  labelStyle: TextStyle(color: Colors.white),
                  title: AxisTitle(
                    text: 'Count',
                    textStyle: TextStyle(color: Colors.white),
                  ), // Y-axis label
                  interval: 2,
                ),
                title: ChartTitle(
                  text: 'Repetitive Faults',
                  textStyle: TextStyle(color: Colors.white),
                ),
                series: <CartesianSeries>[
                  ColumnSeries<EquipmentFault, String>(
                    dataSource: snapshot.data!,
                    xValueMapper: (EquipmentFault fault, _) =>
                        fault.equipmentKey,
                    yValueMapper: (EquipmentFault fault, _) => fault.count,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(color: Colors.white),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    pointColorMapper: (EquipmentFault fault, _) {
                      DateTime faultDate = DateTime(
                          fault.date.year, fault.date.month, fault.date.day);
                      DateTime currentDate = DateTime.now();
                      DateTime currentDateWithoutTime = DateTime(
                          currentDate.year, currentDate.month, currentDate.day);

                      return faultDate.isAtSameMomentAs(currentDateWithoutTime)
                          ? Colors.red
                          : Color.fromRGBO(255, 133, 24, 1);
                    },
                  )
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }
}
