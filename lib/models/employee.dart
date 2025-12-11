import 'package:hive/hive.dart';
part 'employee.g.dart';

@HiveType(typeId: 0)
class Employee extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int payrollNumber;

  @HiveField(2)
  String name;

  @HiveField(3)
  String designation;

  @HiveField(4)
  String department;

  Employee({
    required this.id,
    required this.payrollNumber,
    required this.name,
    required this.designation,
    required this.department,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'],
        payrollNumber: json['payroll_number'],
        name: json['name'],
        designation: json['designation'],
        department: json['department'],
      );
}
