import 'package:mi_garaje/data/models/activity.dart';

class Refuel extends Activity {
  String recordType;
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
  String get getTpye => recordType;

  @override
  double? get getCost => cost;

  double get getPrecioLitros => costLiter;

  @override
  Map<String, dynamic> toMap() {
    return {
      'idActivity': idActivity,
      'date': date.toIso8601String(),
      'activityType': activityType.name,
      'recordType': recordType,
      'costLiter': costLiter,
      'cost': cost,
    };
  }

  static Refuel fromMap(Map<String, dynamic> map) {
    return Refuel(
      idActivity: map['idActivity'],
      date: DateTime.parse(map['date']),
      recordType: map['recordType'],
      costLiter: map['costLiter'].toDouble(),
      cost: map['cost'].toDouble(),
    );
  }
}

