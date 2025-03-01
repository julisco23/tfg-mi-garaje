import 'package:mi_garaje/data/models/activity.dart';

enum RecordType {
  gasolina,
  diesel,
  electrico,
  hibrido;

  String get getName {
    switch (this) {
      case RecordType.gasolina:
        return "Gasolina";
      case RecordType.diesel:
        return "Diésel";
      case RecordType.electrico:
        return "Eléctrico";
      case RecordType.hibrido:
        return "Híbrido";
    }
  }
}

class Refuel extends Activity {
  RecordType recordType;
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
      recordType: RecordType.values.byName(map['recordType']),
      costLiter: map['costLiter'],
      cost: map['cost'],
    );
  }
}

