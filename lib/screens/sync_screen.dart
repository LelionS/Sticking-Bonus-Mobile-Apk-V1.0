import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grafting_app/models/sticking_record.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/variety.dart';
import '../models/employee.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  late Box<StickingRecord> stickingBox;
  late Box<Variety> varietyBox;
  late Box<Employee> employeeBox;

  bool syncing = false;
  String statusMessage = '';

  @override
  void initState() {
    super.initState();
    stickingBox = Hive.box<StickingRecord>('sticking_records');
    varietyBox = Hive.box<Variety>('varieties');
    employeeBox = Hive.box<Employee>('employees');
  }

  Future<void> _syncData() async {
    final records = stickingBox.values.toList();

    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No records to sync')),
      );
      return;
    }

    setState(() {
      syncing = true;
      statusMessage = 'Syncing ${records.length} records...';
    });

    int successCount = 0;

    for (var record in records) {
      try {
        final varietyObj = varietyBox.values.firstWhere(
          (v) => v.name == record.variety,
          orElse: () => throw Exception('Variety not found'),
        );

        final employeeObj = employeeBox.values.firstWhere(
          (e) => e.name == record.employee,
          orElse: () => throw Exception('Employee not found'),
        );

        // Prepare payload including durationHours
        final payload = {
          'variety': varietyObj.id,
          'employee': employeeObj.id,
          'payroll_number': employeeObj.payrollNumber,
          'number_stuck': record.numberStuck,
          'duration_hours': record.durationHours,
          'date': record.date.toIso8601String(),
        };

        final response = await http.post(
          Uri.parse('http://<ip address or dns>/api/daily-sticking/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          successCount++;
          await record.delete();
        } else {
          debugPrint(
              'Failed to sync record ${record.key}: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        debugPrint('Error syncing record ${record.key}: $e');
      }
    }

    setState(() {
      syncing = false;
      statusMessage = 'Sync completed. $successCount/${records.length} records synced.';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(statusMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Sync Data',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.sync, color: Colors.green),
                title: const Text('Sync Local Records'),
                subtitle: Text('Total records: ${stickingBox.length}\n$statusMessage'),
                trailing: syncing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : ElevatedButton(
                        onPressed: _syncData,
                        child: const Text('Start Sync'),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: stickingBox.listenable(),
                builder: (context, Box<StickingRecord> box, _) {
                  if (box.isEmpty) {
                    return const Center(
                      child: Text('No local records to display'),
                    );
                  }

                  final records = box.values.toList().reversed.toList();

                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('${record.variety} — ${record.employee}'),
                          subtitle: Text(
                            'Stuck: ${record.numberStuck}\n'
                            'Time: ${record.durationHours} hrs\n'
                            'Date: ${record.date.toLocal().toString().split(" ")[0]}',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

