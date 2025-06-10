import 'package:mi_garaje/data/models/activity.dart';

class Repair extends Activity {
  String repairType;
  String? photo;
  String? details;

  Repair({
    super.idActivity,
    required super.date,
    this.photo,
    this.details,
    required this.repairType,
    super.cost,
  }) : super(activityType: ActivityType.repair);

  @override
  String get getType => repairType;

  @override
  num? get getCost => cost;

  @override
  String get getCustomType => activityType.getName;

  @override
  String? get getDetails => details;

  @override
  String? get getPhoto => photo;

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

  Repair copyWith({
    String? idActivity,
    DateTime? date,
    num? cost,
    String? type,
    String? photo,
    String? details,
  }) {
    return Repair(
      idActivity: idActivity ?? this.idActivity,
      date: date ?? this.date,
      cost: cost ?? this.cost,
      repairType: type ?? repairType,
      photo: photo ?? this.photo,
      details: details ?? this.details,
    );
  }
}
