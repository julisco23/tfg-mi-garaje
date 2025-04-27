import 'package:mi_garaje/data/models/activity.dart';

class CustomActivity extends Activity {
  String customType;
  String type;
  String? photo;
  String? details;

  CustomActivity({
    super.idActivity,
    required super.date,
    this.details,
    required this.type,
    required this.customType,
    this.photo,
    super.cost,
  }) : super(activityType: ActivityType.custom);

  @override
  String get getType => type;

  void setCustomType(String customType) {
    customType = customType;
  }

  @override
  String get getCustomType => customType;

  @override
  num? get getCost => cost;

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
      'cost': cost,
      'details': details,
      'customType': customType,
      'photo': photo,
      'type': type,
    };
  }

  static CustomActivity fromMap(Map<String, dynamic> map) {
    return CustomActivity(
      idActivity: map['idActivity'],
      date: DateTime.parse(map['date']),
      details: map['details'],
      cost: map['cost'], 
      customType: map['customType'],
      photo: map['photo'],
      type: map['type'],
    );
  }

  @override
  String toString() {
    return 'CustomActivity{idActivity: $idActivity, details: $details, cost: $cost}';
  }
}
