import 'package:mi_garaje/data/models/activity.dart';

class Fuel extends Activity {
  String fuelType;
  num costLiter;

  Fuel({
    super.idActivity,
    required super.date,
    required super.cost,
    required this.fuelType,
    required this.costLiter,
  }) : super(activityType: ActivityType.fuel);

  num get getLiters => (cost! / costLiter);

  @override
  String get getType => fuelType;

  @override
  num? get getCost => cost;

  num get getPrecioLitros => costLiter;

  @override
  String get getCustomType => activityType.getName;

  @override
  String? get getDetails => null;

  @override
  String? get getPhoto => null;

  @override
  Map<String, dynamic> toMap() {
    return {
      'idActivity': idActivity,
      'date': date.toIso8601String(),
      'activityType': activityType.name,
      'fuelType': fuelType,
      'costLiter': costLiter,
      'cost': cost,
    };
  }

  static Fuel fromMap(Map<String, dynamic> map) {
    return Fuel(
      idActivity: map['idActivity'],
      date: DateTime.parse(map['date']),
      fuelType: map['fuelType'],
      costLiter: map['costLiter'],
      cost: map['cost'],
    );
  }

  Fuel copyWith({
    String? idActivity,
    DateTime? date,
    num? cost,
    String? type,
    num? costLiter,
  }) {
    return Fuel(
      idActivity: idActivity ?? this.idActivity,
      date: date ?? this.date,
      cost: cost ?? this.cost,
      fuelType: type ?? fuelType,
      costLiter: costLiter ?? this.costLiter,
    );
  }
}
