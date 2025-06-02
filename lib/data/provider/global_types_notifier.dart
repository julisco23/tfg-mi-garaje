import 'dart:async';

import 'package:mi_garaje/data/provider/auth_notifier.dart';
import 'package:mi_garaje/data/services/user_types_service.dart';
import 'package:mi_garaje/data/services/global_types_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalTypesState {
  final Map<String, List<String>> globalTypes;
  final List<String> tabs;

  GlobalTypesState({
    this.globalTypes = const {},
    this.tabs = const [],
  });

  GlobalTypesState copyWith({
    Map<String, List<String>>? globalTypes,
    List<String>? tabs,
  }) {
    return GlobalTypesState(
      globalTypes: globalTypes ?? this.globalTypes,
      tabs: tabs ?? this.tabs,
    );
  }
}

class GlobalTypesNotifier extends AsyncNotifier<GlobalTypesState> {
  final UserTypesService _userTypeService = UserTypesService();

  @override
  Future<GlobalTypesState> build() async {
    final auth = ref.watch(authProvider).value;
    if (auth == null) return GlobalTypesState();

    await GlobalTypesService.loadTypes();
    final globalTypes = GlobalTypesService.getTypes();

    final userTabs = await _userTypeService.getTabs(auth.id, auth.type);

    final activityTabs = globalTypes['Activity'] ?? [];

    return GlobalTypesState(
        globalTypes: globalTypes, tabs: [...activityTabs, ...userTabs]);
  }

  Future<List<String>> getTypes(String typeName) async {
    final auth = ref.watch(authProvider).value;
    if (auth == null) return [];

    final userFuelData =
        await _userTypeService.getUserData(auth.id, auth.type, typeName);

    final added = userFuelData['added'] ?? [];
    final removed = userFuelData['removed'] ?? [];

    final base = state.value?.globalTypes[typeName] ?? [];

    final result = [
      ...base.where((type) => !removed.contains(type)),
      ...added,
    ];

    return result;
  }

  Future<List<String>> getRemovedTypes(String typeName) async {
    final auth = ref.watch(authProvider).value;
    if (auth == null) return [];

    final userFuelData =
        await _userTypeService.getUserData(auth.id, auth.type, typeName);
    return userFuelData['removed'] ?? [];
  }

  Future<void> addType(String type, String typeName) async {
    final auth = ref.watch(authProvider).value;
    if (auth == null) return;
    await _userTypeService.addType(auth.id, auth.type, type, typeName);
  }

  Future<void> removeType(
    String type,
    String typeName,
  ) async {
    final auth = ref.watch(authProvider).value;
    if (auth == null) return;

    final isGlobal =
        state.value!.globalTypes[typeName]?.contains(type) ?? false;

    await _userTypeService.removeType(
      auth.id,
      auth.type,
      type,
      typeName,
      !isGlobal,
    );
  }

  Future<void> reactivateType(
    String type,
    String typeName,
  ) async {
    final auth = ref.watch(authProvider).value;
    if (auth == null) return;
    await _userTypeService.reactivateType(auth.id, auth.type, type, typeName);
  }

  Future<void> editType(
    String oldType,
    String newType,
    String typeName,
  ) async {
    final auth = ref.watch(authProvider).value;
    if (auth == null) return;

    await _userTypeService.removeType(
      auth.id,
      auth.type,
      oldType,
      typeName,
      true,
    );

    await _userTypeService.addType(
      auth.id,
      auth.type,
      newType,
      typeName,
    );
  }

  List<String> getTabsList() {
    return state.value?.tabs ?? [];
  }

  Future<void> convertToFamily() async {
    final auth = ref.watch(authProvider).value;
    if (auth == null) return;
    await _userTypeService.transformTypesToFamily(
        auth.user!.id!, auth.family!.id!);
  }

  Future<void> joinFamily() async {
    final auth = ref.watch(authProvider).value;
    if (auth == null) return;
    await _userTypeService.deleteTypeFromUser(auth.user!.id!);
  }
}

final globalTypesProvider =
    AsyncNotifierProvider<GlobalTypesNotifier, GlobalTypesState>(
  () => GlobalTypesNotifier(),
);
