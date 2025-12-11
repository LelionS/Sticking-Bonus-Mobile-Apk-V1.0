import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:grafting_app/models/sticking_record.dart';
import 'package:hive/hive.dart';
import '../models/variety.dart';
import '../models/employee.dart';
import 'package:flutter/services.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  Variety? selectedVariety;
  Employee? selectedEmployee;
  int? numberStuck;
  double? durationHours;
  DateTime entryDate = DateTime.now();

  List<Variety> varieties = [];
  List<Employee> employees = [];

  final _varietyController = TextEditingController();
  final _employeeController = TextEditingController();
  final _countController = TextEditingController();
  final _durationController = TextEditingController();

  late Box<StickingRecord> stickingBox;

  // Scanner buffer
  final List<String> _scanBuffer = [];

  @override
  void initState() {
    super.initState();
    _loadLocalData();

    stickingBox = Hive.box<StickingRecord>('sticking_records');

    // Zebra scanner listener
    RawKeyboard.instance.addListener(_handleRawKeyEvent);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleRawKeyEvent);
    _varietyController.dispose();
    _employeeController.dispose();
    _countController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _loadLocalData() {
    try {
      final varietyBox = Hive.box<Variety>('varieties');
      final employeeBox = Hive.box<Employee>('employees');

      varieties = varietyBox.values.toList();
      employees = employeeBox.values.toList();

      if (varieties.isNotEmpty && selectedVariety == null) {
        selectedVariety = varieties.first;
        _varietyController.text = selectedVariety!.name;
      }

      setState(() {});
    } catch (e) {
      debugPrint('Error loading local data: $e');
    }
  }

  // --- ZEBRA SCANNER HANDLING ---
  void _handleRawKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey.keyLabel;

      // Collect characters
      if (key.length == 1 && RegExp(r'[0-9]').hasMatch(key)) {
        _scanBuffer.add(key);
      }

      // ENTER = scan complete
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        final scanned = _scanBuffer.join().trim();
        _scanBuffer.clear();
        _handlePayrollScan(scanned);
      }
    }
  }

  // --- PROCESS PAYROLL ONLY ---
  void _handlePayrollScan(String payroll) {
    if (payroll.isEmpty) return;

    final match = employees.firstWhere(
      (e) => e.payrollNumber.toString() == payroll,
      orElse: () => Employee(
        id: -1,
        name: '',
        payrollNumber: 0,
        designation: '',
        department: '',
      ),
    );

    if (match.id != -1) {
      setState(() {
        selectedEmployee = match;
        _employeeController.text = '${match.name} (${match.payrollNumber})';
      });
    }
  }

  void _saveEntry() {
    final count = int.tryParse(_countController.text.trim()) ?? 0;
    final duration = double.tryParse(_durationController.text.trim()) ?? 0.0;

    if (selectedVariety == null ||
        selectedEmployee == null ||
        count <= 0 ||
        duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields before saving')),
      );
      return;
    }

    final record = StickingRecord(
      variety: selectedVariety!.name,
      employee: selectedEmployee!.name,
      numberStuck: count,
      durationHours: duration,
      date: entryDate,
    );

    stickingBox.add(record);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record saved locally')),
    );

    setState(() {
      selectedEmployee = null;
      numberStuck = null;
      durationHours = null;
      _employeeController.clear();
      _countController.clear();
      _durationController.clear();
      entryDate = DateTime.now();
    });
  }

  Widget _buildEmployeeTypeAhead() {
    return TypeAheadField<Employee>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: _employeeController,
        decoration: InputDecoration(
          labelText: 'Select or Search Employee',
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      suggestionsCallback: (pattern) {
        final lower = pattern.toLowerCase();
        return employees.where((e) =>
            e.name.toLowerCase().contains(lower) ||
            e.payrollNumber.toString().contains(pattern));
      },
      itemBuilder: (context, suggestion) =>
          ListTile(title: Text('${suggestion.name} (${suggestion.payrollNumber})')),
      onSuggestionSelected: (suggestion) {
        setState(() {
          selectedEmployee = suggestion;
          _employeeController.text =
              '${suggestion.name} (${suggestion.payrollNumber})';
        });
      },
      noItemsFoundBuilder: (_) =>
          const Padding(padding: EdgeInsets.all(8), child: Text('No match found')),
    );
  }

  Widget _buildTypeAhead<T>({
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
      itemBuilder: (context, suggestion) =>
          ListTile(title: Text(labelBuilder(suggestion))),
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

  @override
  Widget build(BuildContext context) {
    final canSave = selectedVariety != null &&
        selectedEmployee != null &&
        int.tryParse(_countController.text.trim()) != null &&
        double.tryParse(_durationController.text.trim()) != null &&
        int.tryParse(_countController.text.trim())! > 0 &&
        double.tryParse(_durationController.text.trim())! > 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Sticking Entry',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildTypeAhead<Variety>(
                  label: 'Select or Search Variety',
                  controller: _varietyController,
                  source: varieties,
                  labelBuilder: (v) => v.name,
                  onSelected: (v) => setState(() => selectedVariety = v),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Data Entry',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildEmployeeTypeAhead(),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _countController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Number Stuck',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (v) =>
                          setState(() => numberStuck = int.tryParse(v)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _durationController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Time Taken (hrs, e.g., 1.5)',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (v) =>
                          setState(() => durationHours = double.tryParse(v)),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: canSave ? _saveEntry : null,
                            icon: const Icon(Icons.save),
                            label: const Text('Save'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedEmployee = null;
                                numberStuck = null;
                                durationHours = null;
                                _employeeController.clear();
                                _countController.clear();
                                _durationController.clear();
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear Entry'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
