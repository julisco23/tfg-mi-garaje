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
      'photoURL': photo,
      'subType': type,
    };
  }

  static CustomActivity fromMap(Map<String, dynamic> map) {
    return CustomActivity(
      idActivity: map['idActivity'],
      date: DateTime.parse(map['date']),
      details: map['details'],
      cost: map['cost'],
      customType: map['customType'],
      photo: map['photoURL'],
      type: map['subType'],
    );
  }

  @override
  String toString() {
    return 'CustomActivity{idActivity: $idActivity, details: $details, cost: $cost}';
  }

  @override
  CustomActivity copyWith({
    String? idActivity,
    DateTime? date,
    num? cost,
    String? customType,
    String? type,
    String? photo,
    String? details,
  }) {
    return CustomActivity(
      idActivity: idActivity ?? this.idActivity,
      date: date ?? this.date,
      cost: cost ?? this.cost,
      customType: customType ?? this.customType,
      type: type ?? this.type,
      photo: photo ?? this.photo,
      details: details ?? this.details,
    );
  }
}
