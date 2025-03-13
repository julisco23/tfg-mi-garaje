import 'package:mi_garaje/data/models/custom.dart';
import 'package:mi_garaje/data/models/record.dart';
import 'package:mi_garaje/data/models/refuel.dart';
import 'package:mi_garaje/data/models/repair.dart';

enum ActivityType { 
  refuel, 
  repair, 
  record,
  custom;

  String get getName {
    switch (this) {
      case ActivityType.refuel:
        return "Repostaje";
      case ActivityType.repair:
        return "Mantenimiento";
      case ActivityType.record:
        return "Documento";
      case ActivityType.custom:
        return "Personalizado";
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

  String get getActivityType;
  String get getTpye;
  num? get getCost;

  bool get isCost => getCost != null;
  
  Map<String, dynamic> toMap();

  static Activity fromMap(Map<String, dynamic> map) {
    try {
      final tipo = ActivityType.values.byName(map['activityType']);
      
      switch (tipo) {
        case ActivityType.record:
          return Record.fromMap(map);
        case ActivityType.refuel:
          return Refuel.fromMap(map);
        case ActivityType.repair:
          return Repair.fromMap(map);
        case ActivityType.custom:
          return CustomActivity.fromMap(map);
      }
    } catch (e) {
      throw Exception('Error al convertir Actividad: ${map['activityType']} - $e');
    }
  }

    @override
  String toString() {
    return 'Activty{idActivity: $idActivity, activityType: ${activityType.getName}, cost: $cost}';
  }
}
