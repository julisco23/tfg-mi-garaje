import 'package:mi_garaje/data/models/activity.dart';

class Record extends Activity {
  String recordType;
  String? photo;
  String? details;
  double? cost;

  Record({
    super.idActivity,
    required super.date,
    this.photo,
    this.details,
    this.cost,
    required this.recordType,
  }) : super(activityType: ActivityType.record);

  @override
  String get getTpye => recordType;

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
      'recordType': recordType,
    };
  }

  static Record fromMap(Map<String, dynamic> map) {
    return Record(
      idActivity: map['idActivity'],
      date: DateTime.parse(map['date']),
      photo: map['photo'],
      details: map['details'],
      cost: map['cost'],
      recordType: map['recordType'],
    );
  }

  @override
  String toString() {
    return 'Record{idActivity: $idActivity, date: $date, photo: $photo, details: $details, cost: $cost, recordType: $recordType}';
  }
}
