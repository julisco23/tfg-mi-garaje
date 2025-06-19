import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/notifier/auth_notifier.dart';
import 'package:mi_garaje/data/notifier/garage_notifier.dart';
import 'package:mi_garaje/data/services/garage_service.dart';

class ActivityState {
  final List<Activity> activities;

  const ActivityState({this.activities = const []});

  ActivityState copyWith({List<Activity>? activities}) {
    return ActivityState(activities: activities ?? this.activities);
  }
}

class ActivityNotifier extends AsyncNotifier<ActivityState> {
  final GarageService _garageService = GarageService();

  @override
  Future<ActivityState> build() async {
    try {
      final auth = ref.read(authProvider).value;
      final vehicleId = ref.watch(garageProvider).value?.selectedVehicle?.id;

      if (auth == null || vehicleId == null) return const ActivityState();

      return ActivityState(activities: await getActivitiesByVehicle(vehicleId));
    } catch (e, stackTrace) {
      throw AsyncError(e, stackTrace);
    }
  }

  Future<List<Activity>> getActivitiesByVehicle(String idVehicle) async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return [];
    return await _garageService.getActivities(
      idVehicle,
      auth.id,
      auth.type,
    );
  }

  Future<void> addActivity(Activity activity) async {
    final auth = ref.read(authProvider).value;
    final vehicleId = ref.read(garageProvider).value?.selectedVehicle?.id;
    if (auth == null || vehicleId == null) return;

    await _garageService.addActivity(vehicleId, activity, auth.id, auth.type);
    state = AsyncData(
        ActivityState(activities: [...?state.value?.activities, activity]));
  }

  Future<void> deleteActivity(Activity activity) async {
    final auth = ref.read(authProvider).value;
    final vehicleId = ref.read(garageProvider).value?.selectedVehicle?.id;
    if (auth == null || vehicleId == null) return;

    await _garageService.deleteActivity(
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

    await _garageService.updateActivity(
        vehicleId, activity, auth.id, auth.type);
    final updated = state.value!.activities.map((a) {
      return a.idActivity == activity.idActivity ? activity : a;
    }).toList();
    state = AsyncData(ActivityState(activities: updated));
  }

  Future<void> deleteAllActivities(String typeName,
      {isActivity = false}) async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return;

    await _garageService.removeAllActivities(
        auth.id, typeName, auth.type, isActivity);

    final activities = await getActivitiesByVehicle(
      ref.read(garageProvider).value!.selectedVehicle!.id!,
    );

    state = AsyncData(
      ActivityState(
        activities: activities,
      ),
    );
  }

  Future<void> editAllActivities(String oldName, String newName,
      {bool isActivity = false}) async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return;
    await _garageService.editAllActivities(
        auth.id, oldName, newName, auth.type, isActivity);
    final activities = await getActivitiesByVehicle(
      ref.read(garageProvider).value!.selectedVehicle!.id!,
    );

    state = AsyncData(
      ActivityState(
        activities: activities,
      ),
    );
  }
}

final activityProvider = AsyncNotifierProvider<ActivityNotifier, ActivityState>(
  () => ActivityNotifier(),
);
