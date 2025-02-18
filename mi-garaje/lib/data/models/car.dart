import 'package:mi_garaje/data/models/activity.dart';

class Car {
  String? id;
  String name;
  String initial;

  List<Actividad> activities = [];

  Car({
    this.id,
    required this.name,
    required this.initial,
  });

  void addActivity(Actividad activity) {
    activities.add(activity);
  }

  void setId(String id) {
    this.id = id;
  }

  String getId() {
    return id!;
  }

  String getName() {
    return name;
  }

  String getInitial() {
    return initial;
  }

  void removeActivity(Actividad activity) {
    activities.remove(activity);
  }

  void updateActivity(Actividad activity) {
    final index = activities.indexWhere((element) => element.idActivity == activity.idActivity);
    activities[index] = activity;
  }

  List<Actividad> getActivities(ActivityType type) {
    List<Actividad> filteredActivities = [];

    for (var activity in activities) {
      if (activity.activityType == type) {
        filteredActivities.add(activity);
      }
    }

    filteredActivities.sort((a, b) => b.date.compareTo(a.date));
    return filteredActivities;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'initial': initial,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      name: map['name'] as String,
      initial: map['initial'] as String,
    );
  }

}
