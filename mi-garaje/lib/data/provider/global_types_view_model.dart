import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mi_garaje/data/services/user_types_service.dart';
import 'package:mi_garaje/data/services/global_types_service.dart';

class GlobalTypesViewModel extends ChangeNotifier {
  GlobalTypesViewModel();
  final UserTypesService _userTypeService = UserTypesService();

  final _refuelTypesController = StreamController<List<String>>.broadcast();
  final _removedrefuelTypesController = StreamController<List<String>>.broadcast();

  late final Map<String, List<String>> _globalTypes;
  Map<String, List<String>> get globalTypes => _globalTypes;

  final List<String> _tabs = [];

  late String _userId;

  @override
  void dispose() {
    _refuelTypesController.close();
    _removedrefuelTypesController.close();
    super.dispose();
  }

  // Método para inicializar
  Future<void> initializeUser(String userId) async {
    _userId = userId;
    await getTabs();
  }

  // Método para obtener los tipos
  Future<List<String>> getActivitiesType(String typeName) async {
    Map<String, List<String>> userRefuelData = await _userTypeService.getUserData(_userId, typeName);

    return userRefuelData['added'] ?? [];
  }

  // Método que retorna los tipos
  Future<List<String>> getTypes(String typeName) async {
    try {
    Map<String, List<String>> userRefuelData = await _userTypeService.getUserData(_userId, typeName);
    List<String> addedRefuelTypes = userRefuelData['added'] ?? [];
    List<String> removedRefuelTypes = userRefuelData['removed'] ?? [];

    List<String> refuelTypes = _globalTypes[typeName]!;

    refuelTypes = refuelTypes.where((type) => !removedRefuelTypes.contains(type)).toList();
    refuelTypes.addAll(addedRefuelTypes);

    return refuelTypes;
    } catch (e) {
      print("Error al obtener tipos de $typeName: $e");
      return [];
    }
  }

  // Método que retorna el Stream de tipos
  Stream<List<String>> getTypesStream(String typeName) {
    _emitTypes(typeName);
    return _refuelTypesController.stream;
  }

  // Método para emitir los tipos de repostaje
  Future<void> _emitTypes(String typeName) async {
    try {
      Map<String, List<String>> userRefuelData = await _userTypeService.getUserData(_userId, typeName);
      List<String> addedRefuelTypes = userRefuelData['added'] ?? [];
      List<String> removedRefuelTypes = userRefuelData['removed'] ?? [];

      List<String> refuelTypes = _globalTypes[typeName]!;

      refuelTypes = refuelTypes.where((type) => !removedRefuelTypes.contains(type)).toList();
      refuelTypes.addAll(addedRefuelTypes);

      _refuelTypesController.add(refuelTypes);
    } catch (e) {
      print("Error al obtener tipos de repostaje: $e");
      _refuelTypesController.addError(e); // Si hay un error, se lo emite al stream
    }
  }

  // Método que retorna el Stream de tipos eliminados
  Stream<List<String>> getRemovedTypesStream(String typeName) {
    _emitRemovedTypes(typeName);
    return _removedrefuelTypesController.stream;
  }

  // Método para emitir los tipos de repostaje eliminados
  Future<void> _emitRemovedTypes(String typeName) async {
    try {
      Map<String, List<String>> userRefuelData = await _userTypeService.getUserData(_userId, typeName);
      List<String> removedRefuelTypes = userRefuelData['removed'] ?? [];

      _removedrefuelTypesController.add(removedRefuelTypes);
    } catch (e) {
      print("Error al obtener tipos de repostaje eliminados: $e");
      _removedrefuelTypesController.addError(e);
    }
  }

  // Método para eliminar un tipo
  Future<void> removeType(String type, String typeName) async {
    try {
      if (_globalTypes[typeName]!.contains(type)) {
        await _userTypeService.removeType(_userId, type, typeName, false);
      }
      else {
         await _userTypeService.removeType(_userId, type, typeName, true);
      }

      _emitTypes(typeName);
      _emitRemovedTypes(typeName);
    } catch (e) {
      print("Error al eliminar el tipo: $e");
    }
  }

  // Método para reactivar un tipo
  Future<void> reactivateType(String type, String typeName) async {
    try {
      await _userTypeService.reactivateType(_userId, type, typeName);
      _emitTypes(typeName);
      _emitRemovedTypes(typeName);
    } catch (e) {
      print("Error al reactivar el tipo: $e");
    }
  }

  // Método para añadir un tipo
  Future<void> addType(String type, String typeName) async {
    try {
      await _userTypeService.addType(_userId, type, typeName);
      _emitTypes(typeName);
      _emitRemovedTypes(typeName);
    } catch (e) {
      print("Error al añadir el tipo: $e");
    }
  }

  // Método para editar un tipo
  Future<void> editType(String oldType, String newType, String typeName) async {
    try {
      await _userTypeService.removeType(_userId, oldType, typeName, true);
      await _userTypeService.addType(_userId, newType, typeName);
      _emitTypes(typeName);
    } catch (e) {
      print("Error al editar el tipo: $e");
    }
  }

  // Cargar los tipos desde el servicio
  Future<void> loadGlobalTypes() async {
    await GlobalTypesService.loadTypes();
    _globalTypes = {
      "Refuel": GlobalTypesService.getTypes("tipos_repostaje"),
      "Repair": GlobalTypesService.getTypes("tipos_mantenimiento"),
      "Record": GlobalTypesService.getTypes("tipos_documentos"),
      "Vehicle": GlobalTypesService.getTypes("tipos_vehiculo"),
      "Activity": GlobalTypesService.getTypes("tipos_actividad"),
    };
  }

  Future<void> getTabs() async {
    _tabs.clear();
    _tabs.addAll(_globalTypes['Activity']!);
    _tabs.addAll(await _userTypeService.getTabs(_userId));
  }

  List<String> getTabsList() {
    return _tabs;
  }
}
