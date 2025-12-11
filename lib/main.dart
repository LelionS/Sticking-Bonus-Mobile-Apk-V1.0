import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'models/employee.dart';
import 'models/variety.dart';
import 'models/sticking_record.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  Hive.registerAdapter(EmployeeAdapter());
  Hive.registerAdapter(VarietyAdapter());
  Hive.registerAdapter(StickingRecordAdapter());

  await Hive.openBox<Employee>('employees');
  await Hive.openBox<Variety>('varieties');
  await Hive.openBox<StickingRecord>('sticking_records');

  runApp(const GraftingApp());
}

class GraftingApp extends StatelessWidget {
  const GraftingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grafting System',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
