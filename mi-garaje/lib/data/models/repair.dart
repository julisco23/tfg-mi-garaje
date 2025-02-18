import 'package:mi_garaje/data/models/activity.dart';

enum RepairType {
  frenoDelantero,
  frenoTrasero,
  aceite,
  filtroAceite,
  filtroAire,
  filtroCombustible,
  bateria,
  neumaticos,
  correaDistribucion;

  String get getName {
    switch (this) {
      case RepairType.frenoDelantero:
        return "Freno Delantero";
      case RepairType.frenoTrasero:
        return "Freno Trasero";
      case RepairType.aceite:
        return "Cambio de Aceite";
      case RepairType.filtroAceite:
        return "Filtro de Aceite";
      case RepairType.filtroAire:
        return "Filtro de Aire";
      case RepairType.filtroCombustible:
        return "Filtro de Combustible";
      case RepairType.bateria:
        return "Cambio de Batería";
      case RepairType.neumaticos:
        return "Cambio de Neumáticos";
      case RepairType.correaDistribucion:
        return "Correa de Distribución";
    }
  }
}


class Repair extends Actividad {
  RepairType repairType;
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
  String get getTpye => repairType.getName;

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
      'repairType': repairType.name,
    };
  }

  static Repair fromMap(Map<String, dynamic> map) {
    return Repair(
      idActivity: map['idActivity'],
      date: DateTime.parse(map['date']),
      photo: map['photo'],
      details: map['details'],
      cost: map['cost'],
      repairType: RepairType.values.byName(map['repairType']),
    );
  }
}
