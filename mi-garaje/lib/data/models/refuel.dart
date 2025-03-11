import 'package:mi_garaje/data/models/activity.dart';

class Refuel extends Activity {
  String refuelType;
  num costLiter;

  Refuel({
    super.idActivity,
    required super.date,
    required super.cost,
    required this.refuelType,
    required this.costLiter,
  }) : super(activityType: ActivityType.refuel);

  num get getLiters => (cost! / costLiter);

  @override
  String get getTpye => refuelType;

  @override
  num? get getCost => cost;

  num get getPrecioLitros => costLiter;

  @override
  Map<String, dynamic> toMap() {
    return {
      'idActivity': idActivity,
      'date': date.toIso8601String(),
      'activityType': activityType.name,
      'refuelType': refuelType,
      'costLiter': costLiter,
      'cost': cost,
    };
  }

  static Refuel fromMap(Map<String, dynamic> map) {
    return Refuel(
      idActivity: map['idActivity'],
      date: DateTime.parse(map['date']),
      refuelType: map['refuelType'],
      costLiter: map['costLiter'],
      cost: map['cost'],
    );
  }
}

