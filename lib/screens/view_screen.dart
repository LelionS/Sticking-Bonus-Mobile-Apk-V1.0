import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/variety.dart';
import '../models/employee.dart';
import '../models/sticking_record.dart';

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  late Box<StickingRecord> stickingBox;
  late Box<Variety> varietyBox;
  late Box<Employee> employeeBox;

  List<Variety> varieties = [];
  List<Employee> employees = [];

  @override
  void initState() {
    super.initState();
    stickingBox = Hive.box<StickingRecord>('sticking_records');
    varietyBox = Hive.box<Variety>('varieties');
    employeeBox = Hive.box<Employee>('employees');

    varieties = varietyBox.values.toList();
    employees = employeeBox.values.toList();
  }

  Widget _buildTypeAheadField<T>({
    required String label,
    required TextEditingController controller,
    required List<T> source,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onSelected,
  }) {
    return TypeAheadField<T>(
      suggestionsCallback: (pattern) {
        return source
            .where((item) =>
                labelBuilder(item).toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, suggestion) {
        return ListTile(title: Text(labelBuilder(suggestion)));
      },
      onSuggestionSelected: (suggestion) {
        controller.text = labelBuilder(suggestion);
        onSelected(suggestion);
      },
      noItemsFoundBuilder: (_) =>
          const Padding(padding: EdgeInsets.all(8), child: Text('No match found')),
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _editRecord(StickingRecord record) {
    Variety? selectedVariety =
        varieties.firstWhere((v) => v.name == record.variety, orElse: () => varieties.first);
    Employee? selectedEmployee =
        employees.firstWhere((e) => e.name == record.employee, orElse: () => employees.first);

    final varietyController = TextEditingController(text: record.variety);
    final employeeController = TextEditingController(text: record.employee);
    final countController = TextEditingController(text: record.numberStuck.toString());
    final durationController =
        TextEditingController(text: record.durationHours.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Record'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTypeAheadField<Variety>(
                label: 'Variety',
                controller: varietyController,
                source: varieties,
                labelBuilder: (v) => v.name,
                onSelected: (v) => selectedVariety = v,
              ),
              const SizedBox(height: 8),
              _buildTypeAheadField<Employee>(
                label: 'Employee',
                controller: employeeController,
                source: employees,
                labelBuilder: (e) => e.name,
                onSelected: (e) => selectedEmployee = e,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: countController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sticking Count',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: durationController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Time Taken (hrs)',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final count = int.tryParse(countController.text) ?? 0;
              final duration = double.tryParse(durationController.text) ?? 0.0;

              if (count <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid sticking count')),
                );
                return;
              }

              record.variety = selectedVariety!.name;
              record.employee = selectedEmployee!.name;
              record.numberStuck = count;
              record.durationHours = duration;
              record.save();

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Record updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'View Sticking Records',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: stickingBox.listenable(),
        builder: (context, Box<StickingRecord> box, _) {
          final records = box.values.toList().reversed.toList();

          if (records.isEmpty) {
            return const Center(child: Text('No records found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text('${record.variety} (${record.employee})'),
                  subtitle: Text(
                    'Stuck: ${record.numberStuck}\n'
                    'Time: ${record.durationHours} hrs\n'
                    'Date: ${record.date.toLocal().toString().split(" ")[0]}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editRecord(record),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          record.delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Record deleted')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
