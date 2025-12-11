import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/employee.dart';
import '../models/variety.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  bool _loading = false;
  String _status = 'Press the download icon to fetch data.';
  String _searchQuery = '';

  List<Employee> employees = [];
  List<Variety> varieties = [];

  String? selectedEmployeeFilter;
  List<String> employeeFilterOptions = [];

  final Map<String, String> apiUrls = {
    "employees": "http://<ip address or dns>/api/employees/",
    "varieties": "http://<ip address or dns>/api/varieties/",
  };

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final empBox = Hive.box<Employee>('employees');
    final varBox = Hive.box<Variety>('varieties');

    setState(() {
      employees = empBox.values.toList();
      varieties = varBox.values.toList();

      if (employees.isNotEmpty || varieties.isNotEmpty) {
        _status = 'Showing previously downloaded data.';
      }

      _prepareEmployeeFilters();
    });
  }

  void _prepareEmployeeFilters() {
    final departments = employees.map((e) => e.department ?? 'Unknown').toSet().toList();
    setState(() {
      employeeFilterOptions = ['All', ...departments];
      selectedEmployeeFilter ??= 'All';
    });
  }

  Future<void> _saveJsonToFile(String filename, List data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename.json');
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }

  Future<void> _downloadData() async {
    setState(() {
      _loading = true;
      _status = 'Downloading data...';
    });

    try {
      // Download Employees
      final empResp = await http.get(Uri.parse(apiUrls['employees']!));
      if (empResp.statusCode == 200) {
        final List empList = jsonDecode(empResp.body);
        final box = Hive.box<Employee>('employees');
        await box.clear();
        employees = empList.map((e) => Employee.fromJson(e)).toList();
        for (var e in employees) box.add(e);
        await _saveJsonToFile('employees', empList);
        _prepareEmployeeFilters();
      }

      // Download Varieties
      final varResp = await http.get(Uri.parse(apiUrls['varieties']!));
      if (varResp.statusCode == 200) {
        final List varList = jsonDecode(varResp.body);
        final box = Hive.box<Variety>('varieties');
        await box.clear();
        varieties = varList.map((v) {
          final map = v as Map<String, dynamic>;
          // safely parse int fields
          return Variety(
            id: map['id'] ?? 0,
            varietyCode: map['variety'] != null ? int.tryParse(map['variety'].toString()) ?? 0 : 0,
            name: map['name'] ?? '',
            licensor: map['licensor'] ?? '',
            varietyColor: map['variety_color'] ?? '',
            productType: map['product_type'] ?? '',
            activate: map['activate'] ?? false,
          );
        }).toList();
        for (var v in varieties) box.add(v);
        await _saveJsonToFile('varieties', varList);
      }

      setState(() {
        _status = 'Data downloaded successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error downloading data: $e';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Widget> _buildEmployeeCategory() {
    var filtered = employees;
    if (selectedEmployeeFilter != null && selectedEmployeeFilter != 'All') {
      filtered = filtered.where((e) => (e.department ?? 'Unknown') == selectedEmployeeFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (filtered.isEmpty) return [];

    return [
      Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Employees (${filtered.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            DropdownButton<String>(
              value: selectedEmployeeFilter,
              items: employeeFilterOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (val) => setState(() => selectedEmployeeFilter = val),
            ),
          ],
        ),
      ),
      ...filtered.map((e) => ListTile(
            title: Text('${e.name} (${e.payrollNumber})'),
            subtitle: e.department != null ? Text(e.department!) : null,
            tileColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            shape: const Border(bottom: BorderSide(color: Colors.grey, width: 0.3)),
          )),
    ];
  }

  List<Widget> _buildVarietyCategory() {
    var filtered = _searchQuery.isEmpty
        ? varieties
        : varieties.where((v) => '${v.name} (${v.varietyCode})'.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    if (filtered.isEmpty) return [];

    return [
      Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('Varieties (${filtered.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      ...filtered.map((v) => ListTile(
            title: Text('${v.name} (${v.varietyCode})'),
            subtitle: Text('${v.productType} | ${v.varietyColor}'),
            tileColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            shape: const Border(bottom: BorderSide(color: Colors.grey, width: 0.3)),
          )),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: const Text('Download Data'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: _loading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.download),
            onPressed: _loading ? null : _downloadData,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(_status, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ),
          Expanded(
            child: ListView(
              children: [
                ..._buildEmployeeCategory(),
                ..._buildVarietyCategory(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

