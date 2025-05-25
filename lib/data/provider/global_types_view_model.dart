import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mi_garaje/data/services/user_types_service.dart';
import 'package:mi_garaje/data/services/global_types_service.dart';

class GlobalTypesViewModel extends ChangeNotifier {
  final UserTypesService _userTypeService = UserTypesService();

  final _fuelTypesController = StreamController<List<String>>.broadcast();
  final _removedfuelTypesController =
      StreamController<List<String>>.broadcast();

  late final Map<String, List<String>> _globalTypes;
  Map<String, List<String>> get globalTypes => _globalTypes;

  final List<String> _tabs = [];

  @override
  void dispose() {
    _fuelTypesController.close();
    _removedfuelTypesController.close();
    super.dispose();
  }

  // Método para inicializar
  Future<void> initializeUser(String ownerId, String ownerType) async {
    await getTabs(ownerId, ownerType);
  }

  // Método que retorna los tipos
  Future<List<String>> getTypes(
      String ownerId, String ownerType, String typeName) async {
    try {
      Map<String, List<String>> userFuelData =
          await _userTypeService.getUserData(ownerId, ownerType, typeName);
      List<String> addedFuelTypes = userFuelData['added'] ?? [];
      List<String> removedFuelTypes = userFuelData['removed'] ?? [];

      List<String> types = _globalTypes[typeName]!;

      types = types.where((type) => !removedFuelTypes.contains(type)).toList();
      types.addAll(addedFuelTypes);

      return types;
    } catch (e) {
      print("Error al obtener tipos de $typeName: $e");
      return [];
    }
  }

  // Método que retorna el Stream de tipos
  Stream<List<String>> getTypesStream(
      String ownerId, String ownerType, String typeName) {
    _emitTypes(ownerId, ownerType, typeName);
    return _fuelTypesController.stream;
  }

  // Método para emitir los tipos de repostaje
  Future<void> _emitTypes(
      String ownerId, String ownerType, String typeName) async {
    try {
      Map<String, List<String>> userFuelData =
          await _userTypeService.getUserData(ownerId, ownerType, typeName);
      List<String> addedFuelTypes = userFuelData['added'] ?? [];
      List<String> removedFuelTypes = userFuelData['removed'] ?? [];

      List<String> fuelTypes = _globalTypes[typeName]!;

      fuelTypes =
          fuelTypes.where((type) => !removedFuelTypes.contains(type)).toList();
      fuelTypes.addAll(addedFuelTypes);

      _fuelTypesController.add(fuelTypes);
    } catch (e) {
      print("Error al obtener tipos de repostaje: $e");
      _fuelTypesController
          .addError(e); // Si hay un error, se lo emite al stream
    }
  }

  // Método que retorna el Stream de tipos eliminados
  Stream<List<String>> getRemovedTypesStream(
      String ownerId, String ownerType, String typeName) {
    _emitRemovedTypes(ownerId, ownerType, typeName);
    return _removedfuelTypesController.stream;
  }

  // Método para emitir los tipos de repostaje eliminados
  Future<void> _emitRemovedTypes(
      String ownerId, String ownerType, String typeName) async {
    try {
      Map<String, List<String>> userFuelData =
          await _userTypeService.getUserData(ownerId, ownerType, typeName);
      List<String> removedFuelTypes = userFuelData['removed'] ?? [];

      _removedfuelTypesController.add(removedFuelTypes);
    } catch (e) {
      print("Error al obtener tipos de repostaje eliminados: $e");
      _removedfuelTypesController.addError(e);
    }
  }

  // Método para eliminar un tipo
  Future<void> removeType(
      String ownerId, String ownerType, String type, String typeName) async {
    try {
      if (_globalTypes[typeName]!.contains(type)) {
        await _userTypeService.removeType(
            ownerId, ownerType, type, typeName, false);
      } else {
        await _userTypeService.removeType(
            ownerId, ownerType, type, typeName, true);
      }

      _emitTypes(ownerId, ownerType, typeName);
      _emitRemovedTypes(ownerId, ownerType, typeName);
    } catch (e) {
      print("Error al eliminar el tipo: $e");
    }
  }

  // Método para reactivar un tipo
  Future<void> reactivateType(
      String ownerId, String ownerType, String type, String typeName) async {
    try {
      await _userTypeService.reactivateType(ownerId, ownerType, type, typeName);
      _emitTypes(ownerId, ownerType, typeName);
      _emitRemovedTypes(ownerId, ownerType, typeName);
    } catch (e) {
      print("Error al reactivar el tipo: $e");
    }
  }

  // Método para añadir un tipo
  Future<void> addType(
      String ownerId, String ownerType, String type, String typeName) async {
    try {
      await _userTypeService.addType(ownerId, ownerType, type, typeName);
      _emitTypes(ownerId, ownerType, typeName);
      _emitRemovedTypes(ownerId, ownerType, typeName);
    } catch (e) {
      print("Error al añadir el tipo: $e");
    }
  }

  // Método para editar un tipo
  Future<void> editType(String ownerId, String ownerType, String oldType,
      String newType, String typeName) async {
    try {
      await _userTypeService.removeType(
          ownerId, ownerType, oldType, typeName, true);
      await _userTypeService.addType(ownerId, ownerType, newType, typeName);
      _emitTypes(ownerId, ownerType, typeName);
    } catch (e) {
      print("Error al editar el tipo: $e");
    }
  }

  // Cargar los tipos desde el servicio
  Future<void> loadGlobalTypes() async {
    await GlobalTypesService.loadTypes();
    _globalTypes = GlobalTypesService.getTypes();
  }

  Future<void> getTabs(String ownerId, String ownerType) async {
    _tabs.clear();
    _tabs.addAll(_globalTypes['Activity']!);
    _tabs.addAll(await _userTypeService.getTabs(ownerId, ownerType));
  }

  List<String> getTabsList() {
    return _tabs;
  }

  Future<void> convertToFamily(String userId, String familyId) async {
    await _userTypeService.transformTypesToFamily(userId, familyId);
  }

  Future<void> joinFamily(String userId) async {
    await _userTypeService.deleteTypeFromUser(userId);
  }
}
