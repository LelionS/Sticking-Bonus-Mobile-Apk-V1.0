import 'package:hive/hive.dart';
part 'variety.g.dart';

@HiveType(typeId: 2)
class Variety extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int varietyCode;

  @HiveField(2)
  String name;

  @HiveField(3)
  String licensor;

  @HiveField(4)
  String varietyColor;

  @HiveField(5)
  String productType;

  @HiveField(6)
  bool activate;

  Variety({
    required this.id,
    required this.varietyCode,
    required this.name,
    required this.licensor,
    required this.varietyColor,
    required this.productType,
    required this.activate,
  });

  factory Variety.fromJson(Map<String, dynamic> json) => Variety(
        id: json['id'],
        varietyCode: json['variety'],
        name: json['name'],
        licensor: json['licensor'] ?? '',
        varietyColor: json['variety_color'] ?? '',
        productType: json['product_type'] ?? '',
        activate: json['activate'] ?? false,
      );
}
