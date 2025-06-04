import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/provider/auth_notifier.dart';
import 'package:mi_garaje/data/provider/garage_notifier.dart';
import 'package:mi_garaje/data/services/garage_service.dart';

class ActivityState {
  final List<Activity> activities;

  const ActivityState({this.activities = const []});

  ActivityState copyWith({List<Activity>? activities}) {
    return ActivityState(activities: activities ?? this.activities);
  }
}

class ActivityNotifier extends AsyncNotifier<ActivityState> {
  final VehicleService _vehicleService = VehicleService();

  @override
  Future<ActivityState> build() async {
    try {
      final auth = ref.read(authProvider).value;
      final vehicleId = ref.watch(garageProvider).value?.selectedVehicle?.id;

      if (auth == null || vehicleId == null) return const ActivityState();

      if (!auth.isUser) {
        return const ActivityState(activities: []);
      }

      return ActivityState(activities: await getActivitiesByVehicle(vehicleId));
    } catch (e, stackTrace) {
      throw AsyncError(e, stackTrace);
    }
  }

  void clearActivities() {
    state = AsyncData(const ActivityState());
  }

  //TODO Mirar
  Future<List<Activity>> getActivitiesByVehicle(String idVehicle) async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return [];
    return await _vehicleService.getActivities(
      idVehicle,
      auth.id,
      auth.type,
    );
  }

  Future<void> addActivity(Activity activity) async {
    final auth = ref.read(authProvider).value;
    final vehicleId = ref.read(garageProvider).value?.selectedVehicle?.id;
    if (auth == null || vehicleId == null) return;

    await _vehicleService.addActivity(vehicleId, activity, auth.id, auth.type);
    state = AsyncData(
        ActivityState(activities: [...?state.value?.activities, activity]));
  }

  Future<void> deleteActivity(Activity activity) async {
    final auth = ref.read(authProvider).value;
    final vehicleId = ref.read(garageProvider).value?.selectedVehicle?.id;
    if (auth == null || vehicleId == null) return;

    await _vehicleService.deleteActivity(
        vehicleId, activity.idActivity!, auth.id, auth.type);
    final current = state.valueOrNull!.activities
        .where((a) => a.idActivity != activity.idActivity)
        .toList();
    state = AsyncData(ActivityState(activities: current));
  }

  Future<void> updateActivity(Activity activity) async {
    final auth = ref.read(authProvider).value;
    final vehicleId = ref.read(garageProvider).value?.selectedVehicle?.id;
    if (auth == null || vehicleId == null) return;

    await _vehicleService.updateActivity(
        vehicleId, activity, auth.id, auth.type);
    final updated = state.value!.activities.map((a) {
      return a.idActivity == activity.idActivity ? activity : a;
    }).toList();
    state = AsyncData(ActivityState(activities: updated));
  }

  Future<void> deleteAllActivities(String typeName,
      {String type = "custom"}) async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return;

    await _vehicleService.removeAllActivities(
        auth.id, typeName, type, auth.type);
  }

  Future<void> editAllActivities(String oldName, String newName,
      {String type = "custom"}) async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return;
    await _vehicleService.editAllActivities(
        auth.id, oldName, newName, type, auth.type);
  }
}

final activityProvider = AsyncNotifierProvider<ActivityNotifier, ActivityState>(
  () => ActivityNotifier(),
);
