import 'package:hive/hive.dart';

part 'sticking_record.g.dart';

@HiveType(typeId: 3) // Keep typeId unique across all Hive models
class StickingRecord extends HiveObject {
  @HiveField(0)
  String variety;

  @HiveField(1)
  String employee;

  @HiveField(2)
  int numberStuck;

  @HiveField(3)
  double durationHours; // Time spent in hours as decimal

  @HiveField(4)
  DateTime date;

  StickingRecord({
    required this.variety,
    required this.employee,
    required this.numberStuck,
    required this.durationHours,
    required this.date,
  });
}
