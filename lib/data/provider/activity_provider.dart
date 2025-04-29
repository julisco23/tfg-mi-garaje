import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/services/garage_service.dart';

class ActivityProvider extends ChangeNotifier {
  final CarService carService = CarService();
  List<Activity> _activities = [];

  // Limpiar actividades
  void clearActivities() {
    _activities = [];
  }

  // Getter para obtener todas las actividades
  List<Activity> get activities => _activities;

  // Getter para las actividades filtradas por tipo
  List<Activity> getActivities(String activityType) {
    List<Activity> filteredActivities = [];

    filteredActivities = _activities
        .where((activity) => activity.getCustomType == activityType)
        .toList();

    filteredActivities.sort((a, b) => b.date.compareTo(a.date));

    return filteredActivities;
  }

  // Cargar actividades del vehículo seleccionado
  Future<void> loadActivities(
      String vehicleId, String ownerId, String ownerType) async {
    _activities = await carService.getActivities(vehicleId, ownerId, ownerType);
    notifyListeners();
  }

  // Métodos para manejar actividades
  Future<void> addActivity(String vehicleId, String ownerId, String ownerType,
      Activity activity) async {
    await carService.addActivity(vehicleId, activity, ownerId, ownerType);
    _activities.add(activity);
    notifyListeners();
  }

  Future<void> deleteActivity(String vehicleId, String ownerId,
      String ownerType, Activity activity) async {
    await carService.deleteActivity(
        vehicleId, activity.idActivity!, ownerId, ownerType);
    _activities.remove(activity);
    notifyListeners();
  }

  Future<void> updateActivity(String vehicleId, String ownerId,
      String ownerType, Activity activity) async {
    await carService.updateActivity(vehicleId, activity, ownerId, ownerType);

    int index =
        _activities.indexWhere((act) => act.idActivity == activity.idActivity);
    _activities[index] = activity;
    notifyListeners();
  }

  // Eliminar todas las actividades de un tipo específico para un vehículo
  Future<void> deleteAllActivities(
      String ownerId, String ownerType, String typeName,
      {String type = "custom"}) async {
    await carService.removeAllActivities(ownerId, typeName, type, ownerType);
  }

  // Editar todas las actividades de un tipo específico (cambiar nombre)
  Future<void> editAllActivities(
      String ownerId, String ownerType, String oldName, String newName,
      {String type = "custom"}) async {
    await carService.editAllActivities(
        ownerId, oldName, newName, type, ownerType);
  }
}
