import 'package:mi_garaje/data/models/activity.dart';

class CustomActivity extends Activity {
  String customType;
  String title;
  String? photo;
  String? details;

  CustomActivity({
    super.idActivity,
    required super.date,
    this.details,
    required this.customType,
    required this.title,
    this.photo,
    super.cost,
  }) : super(activityType: ActivityType.custom);

  @override
  String get getActivityType => customType;

  @override
  String get getTpye => title;

  @override
  num? get getCost => cost;

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
      'title': title,
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
      title: map['title'],
    );
  }

  @override
  String toString() {
    return 'CustomActivity{idActivity: $idActivity, details: $details, cost: $cost}';
  }
}
