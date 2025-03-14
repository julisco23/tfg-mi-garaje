import 'package:mi_garaje/data/models/activity.dart';

class Vehicle {
  String? id;
  String? name;
  String brand;
  String? model;
  String? photo;
  String vehicleType;
  DateTime? creationDate;

  List<Activity> activities = [];

  Vehicle({
    this.id,
    this.name,
    required this.brand,
    required this.model,
    this.creationDate,
    this.photo,
    required this.vehicleType,
  }) {
    creationDate = creationDate ?? DateTime.now();
  }

  void setActivities(List<Activity> activities) {
    this.activities = activities;
  }

  void addActivity(Activity activity) {
    activities.add(activity);
  }

  void setId(String id) {
    this.id = id;
  }

  String getId() {
    return id!;
  }

  String? getName() {
    return name;
  }

  String getBrand() {
    return brand;
  }

  String? getModel() {
    return model;
  }

  String? getPhoto() {
    return photo;
  }

  String getVehicleType() {
    return vehicleType;
  }

  void setVeicleType(String vehicleType) {
    this.vehicleType = vehicleType;
  }

  String getInitial() {
    return name != null && name!.isNotEmpty ? name!.substring(0, 1).toUpperCase() : brand.substring(0, 1).toUpperCase();
  }

  String getNameTittle() {
    return name ?? brand;
  }

  void removeActivity(Activity activity) {
    activities.remove(activity);
  }

  void updateActivity(Activity activity) {
    final index = activities
        .indexWhere((element) => element.idActivity == activity.idActivity);
    if (index != -1) {
      activities[index] = activity;
    }
  }

  List<Activity> getActivities(String type) {
    List<Activity> filteredActivities;
    if (!["Repair", "Refuel", "Record"].contains(type)){
      filteredActivities = activities.where((activity) => activity.getType == type).toList();
    } else {
      filteredActivities = activities.where((activity) => activity.getActivityType == type).toList();
    }
    
    filteredActivities.sort((a, b) => b.date.compareTo(a.date));
    return filteredActivities;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'model': model,
      'photo': photo,
      'vehicleType': vehicleType,
      'creationDate': creationDate!.toIso8601String(),
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      name: map['name'] as String?,
      brand: map['brand'] as String,
      model: map['model'] as String?,
      photo: map['photo'] as String?,
      vehicleType: map['vehicleType'],
      creationDate: DateTime.parse(map['creationDate']),
    );
  }

  @override
  String toString() {
    return 'Vehicle{id: $id, brand: $brand, vehicleType: $vehicleType}';
  }

   @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vehicle &&
        other.id == id &&
        other.brand == brand &&
        other.model == model;
  }

  @override
  int get hashCode {
    return id.hashCode ^ brand.hashCode ^ (model?.hashCode ?? 0);
  }
}
