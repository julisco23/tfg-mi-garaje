import 'package:mi_garaje/data/models/custom.dart';
import 'package:mi_garaje/data/models/record.dart';
import 'package:mi_garaje/data/models/fuel.dart';
import 'package:mi_garaje/data/models/repair.dart';

enum ActivityType {
  fuel,
  repair,
  record,
  custom;

  String get getName {
    switch (this) {
      case ActivityType.fuel:
        return "Fuel";
      case ActivityType.repair:
        return "Repair";
      case ActivityType.record:
        return "Record";
      case ActivityType.custom:
        return "Custom";
    }
  }
}

abstract class Activity {
  String? idActivity;
  DateTime date;
  num? cost;
  final ActivityType activityType;

  Activity({
    this.idActivity,
    required this.date,
    required this.activityType,
    this.cost,
  });

  void setId(String id) {
    idActivity = id;
  }

  String get getActivityType => activityType.getName;
  String get getType;
  String get getCustomType;
  num? get getCost;
  DateTime get getDate => date;

  String? get getDetails;

  bool get isCost => getCost != null;

  bool get isPhoto => getPhoto != null;
  String? get getPhoto;

  Map<String, dynamic> toMap();

  static Activity fromMap(Map<String, dynamic> map) {
    final tipoStr = map['activityType'];
    final tipo = ActivityType.values.firstWhere(
      (e) => e.name == tipoStr,
      orElse: () => throw Exception('Tipo de actividad desconocido: $tipoStr'),
    );

    switch (tipo) {
      case ActivityType.record:
        return Record.fromMap(map);
      case ActivityType.fuel:
        return Fuel.fromMap(map);
      case ActivityType.repair:
        return Repair.fromMap(map);
      case ActivityType.custom:
        return CustomActivity.fromMap(map);
    }
  }

  @override
  String toString() {
    return 'Activty{idActivity: $idActivity, activityType: ${activityType.getName}, cost: $cost}';
  }

  copyWith({required String type}) {}
}
