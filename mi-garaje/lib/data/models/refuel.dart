import 'package:mi_garaje/data/models/activity.dart';

enum RefuelType {
  gasolina,
  diesel,
  electrico,
  hibrido;

  String get getName {
    switch (this) {
      case RefuelType.gasolina:
        return "Gasolina";
      case RefuelType.diesel:
        return "Diésel";
      case RefuelType.electrico:
        return "Eléctrico";
      case RefuelType.hibrido:
        return "Híbrido";
    }
  }
}

class Refuel extends Activity {
  RefuelType recordType;
  double costLiter;
  double? cost;

  Refuel({
    super.idActivity,
    required super.date,

    required this.recordType,
    required this.costLiter,
    this.cost,
  }) : super(activityType: ActivityType.refuel);

  double get getLiters => (cost! / costLiter);

  @override
  String get getTpye => recordType.getName;

  @override
  double? get getCost => cost;

  double get getPrecioLitros => costLiter;

  @override
  Map<String, dynamic> toMap() {
    return {
      'idActivity': idActivity,
      'date': date.toIso8601String(),
      'activityType': activityType.name,
      'recordType': recordType.name,
      'costLiter': costLiter,
      'cost': cost,
    };
  }

  static Refuel fromMap(Map<String, dynamic> map) {
    return Refuel(
      idActivity: map['idActivity'],
      date: DateTime.parse(map['date']),
      recordType: RefuelType.values.byName(map['recordType']),
      costLiter: map['costLiter'],
      cost: map['cost'],
    );
  }
}

