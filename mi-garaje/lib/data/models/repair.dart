import 'package:mi_garaje/data/models/activity.dart';

class Repair extends Activity {
  String repairType;
  String? photo;
  String? details;
  double? cost;

  Repair({
    super.idActivity,
    required super.date,
    this.photo,
    this.details,
    required this.repairType,
    this.cost,
  }) : super(activityType: ActivityType.repair);

  @override
  String get getTpye => repairType;

  @override
  double? get getCost => cost;

  @override
  Map<String, dynamic> toMap() {
    return {
      'idActivity': idActivity,
      'date': date.toIso8601String(),
      'activityType': activityType.name,
      'photo': photo,
      'details': details,
      'cost': cost,
      'repairType': repairType,
    };
  }

  static Repair fromMap(Map<String, dynamic> map) {
    return Repair(
      idActivity: map['idActivity'],
      date: DateTime.parse(map['date']),
      photo: map['photo'],
      details: map['details'],
      cost: map['cost'],
      repairType: map['repairType'],
    );
  }
}
