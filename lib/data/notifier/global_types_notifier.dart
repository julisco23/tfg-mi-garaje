import 'dart:async';

import 'package:mi_garaje/data/notifier/auth_notifier.dart';
import 'package:mi_garaje/data/services/user_types_service.dart';
import 'package:mi_garaje/data/services/global_types_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalTypesState {
  final Map<String, List<String>> globalTypes;
  final Map<String, List<String>> addedTypes;
  final Map<String, List<String>> removedTypes;
  final List<String> tabs;

  List<String> userTypes(String typeName) {
    return [
      ...?globalTypes[typeName]?.where((type) =>
          removedTypes[typeName] == null ||
          !removedTypes[typeName]!.contains(type)),
      ...?addedTypes[typeName],
    ];
  }

  List<String> userRemovedTypes(String typeName) {
    return removedTypes[typeName] ?? [];
  }

  bool isGlobalType(String typeName, String type) {
    return globalTypes[typeName]?.contains(type) ?? false;
  }

  GlobalTypesState({
    this.globalTypes = const {},
    this.addedTypes = const {},
    this.removedTypes = const {},
    this.tabs = const [],
  });

  GlobalTypesState copyWith({
    Map<String, List<String>>? globalTypes,
    Map<String, List<String>>? addedTypes,
    Map<String, List<String>>? removedTypes,
    List<String>? tabs,
  }) {
    return GlobalTypesState(
      globalTypes: globalTypes ?? this.globalTypes,
      addedTypes: addedTypes ?? this.addedTypes,
      removedTypes: removedTypes ?? this.removedTypes,
      tabs: tabs ?? this.tabs,
    );
  }
}

class GlobalTypesNotifier extends AsyncNotifier<GlobalTypesState> {
  final UserTypesService _userTypeService = UserTypesService();

  @override
  Future<GlobalTypesState> build() async {
    try {
      final auth = ref.watch(authProvider).value;
      if (auth == null) return GlobalTypesState();

      await GlobalTypesService.loadTypes();
      final globalTypes = GlobalTypesService.getTypes();
      final addedTypes = <String, List<String>>{};
      final removedTypes = <String, List<String>>{};

      final userTabs = await _userTypeService.getTabs(auth.id, auth.type);

      for (final type in globalTypes.keys) {
        await getTypes(type).then((types) {
          addedTypes[type] = types['added'] ?? [];
          removedTypes[type] = types['removed'] ?? [];
        });
      }

      final activityTabs = globalTypes['Activity'] ?? [];

      return GlobalTypesState(
          globalTypes: globalTypes,
          addedTypes: addedTypes,
          removedTypes: removedTypes,
          tabs: [...activityTabs, ...userTabs]);
    } catch (e, stackTrace) {
      throw AsyncError(e, stackTrace);
    }
  }

  Future<Map<String, List<String>>> getTypes(String typeName) async {
    final auth = ref.watch(authProvider).value;
    if (auth == null) return {};

    return await _userTypeService.getUserData(auth.id, auth.type, typeName);
  }

  Future<void> updateTypes(String typeName) async {
    List<String> currentaddedTypes = [];
    List<String> currentremovedTypes = [];

    final types = await getTypes(typeName);
    currentaddedTypes = types['added'] ?? [];
    currentremovedTypes = types['removed'] ?? [];

    state = AsyncData(
      state.value!.copyWith(
        addedTypes: {
          ...state.value!.addedTypes,
          typeName: currentaddedTypes,
        },
        removedTypes: {
          ...state.value!.removedTypes,
          typeName: currentremovedTypes,
        },
      ),
    );
  }

  Future<void> addType(String type, String typeName) async {
    final auth = ref.watch(authProvider).value;
    if (auth == null) return;
    await _userTypeService.addType(auth.id, auth.type, type, typeName);
    await updateTypes(typeName);
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

    await updateTypes(typeName);
  }

  Future<void> reactivateType(
    String type,
    String typeName,
  ) async {
    final auth = ref.watch(authProvider).value;
    if (auth == null) return;
    await _userTypeService.reactivateType(auth.id, auth.type, type, typeName);

    await updateTypes(typeName);
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

    await updateTypes(typeName);
  }
}

final globalTypesProvider =
    AsyncNotifierProvider<GlobalTypesNotifier, GlobalTypesState>(
  () => GlobalTypesNotifier(),
);
