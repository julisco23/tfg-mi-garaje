import 'package:mi_garaje/data/models/record.dart';
import 'package:mi_garaje/data/models/refuel.dart';
import 'package:mi_garaje/data/models/repair.dart';

enum ActivityType { 
  refuel, 
  repair, 
  record;

  String get getName {
    switch (this) {
      case ActivityType.refuel:
        return "Repostajes";
      case ActivityType.repair:
        return "Reparaciones";
      case ActivityType.record:
        return "Documentos";
    }
  }
}

abstract class Activity {
  String? idActivity;
  DateTime date;
  final ActivityType activityType;

  Activity({
    this.idActivity,
    required this.date,
    required this.activityType,
  });

  void setId(String id) {
    idActivity = id;
  }

  String get getTpye;
  double? get getCost;

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
      }
    } catch (e) {
      throw Exception('************* Error al convertir Actividad: ${map['activityType']} - $e');
    }
  }
}
