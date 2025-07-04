import 'package:mi_garaje/data/models/activity.dart';

class Record extends Activity {
  String recordType;
  String? photo;
  String? details;

  Record({
    super.idActivity,
    required super.date,
    super.cost,
    this.photo,
    this.details,
    required this.recordType,
  }) : super(activityType: ActivityType.record);

  @override
  String get getType => recordType;

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
      'photoURL': photo,
      'details': details,
      'cost': cost,
      'subType': recordType,
    };
  }

  static Record fromMap(Map<String, dynamic> map) {
    return Record(
      idActivity: map['idActivity'],
      date: DateTime.parse(map['date']),
      photo: map['photoURL'],
      details: map['details'],
      cost: map['cost'],
      recordType: map['subType'],
    );
  }

  @override
  Record copyWith({
    String? idActivity,
    DateTime? date,
    num? cost,
    String? type,
    String? photo,
    String? details,
  }) {
    return Record(
      idActivity: idActivity ?? this.idActivity,
      date: date ?? this.date,
      cost: cost ?? this.cost,
      recordType: type ?? recordType,
      photo: photo ?? this.photo,
      details: details ?? this.details,
    );
  }
}
