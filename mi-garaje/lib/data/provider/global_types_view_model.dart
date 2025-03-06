import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mi_garaje/data/services/global_types_service.dart';

class GlobalTypesViewModel extends ChangeNotifier {
  GlobalTypesViewModel() : _globalTypes = {};
  final UserTypesService _userTypeService = UserTypesService();

  final _refuelTypesController = StreamController<List<String>>.broadcast();
  final _removedrefuelTypesController = StreamController<List<String>>.broadcast();
  final Map<String, List<String>> _globalTypes;

  Map<String, List<String>> get globalTypes => _globalTypes;

  late String _userId;

  @override
  void dispose() {
    _refuelTypesController.close();
    _removedrefuelTypesController.close();
    super.dispose();
  }

  // Método para inicializar
  Future<void> initialize(String userId) async {
    _userId = userId;
    _globalTypes["refuelTypes"] = await _userTypeService.getGlobalTypes("refuelTypes");
    _globalTypes["recordTypes"] = await _userTypeService.getGlobalTypes("recordTypes");
    _globalTypes["repairTypes"] = await _userTypeService.getGlobalTypes("repairTypes");
  }

  // Método que retorna el Stream de tipos
  Stream<List<String>> getTypesStream(String typeName, String add, String remove) {
    _emitTypes(typeName, add, remove); // Emitir los tipos por primera vez
    return _refuelTypesController.stream; // Devuelve el stream
  }

  // Método para emitir los tipos de repostaje
  Future<void> _emitTypes(String typeName, String add, String remove) async {
    try {
      Map<String, List<String>> userRefuelData = await _userTypeService.getUserData(_userId, add, remove);
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
  Stream<List<String>> getRemovedTypesStream(String add, String remove) {
    _emitRemovedTypes(add, remove);
    return _removedrefuelTypesController.stream;
  }

  // Método para emitir los tipos de repostaje eliminados
  Future<void> _emitRemovedTypes(String add, String remove) async {
    try {
      Map<String, List<String>> userRefuelData = await _userTypeService.getUserData(_userId, add, remove);
      List<String> removedRefuelTypes = userRefuelData['removed'] ?? [];

      _removedrefuelTypesController.add(removedRefuelTypes);
    } catch (e) {
      print("Error al obtener tipos de repostaje eliminados: $e");
      _removedrefuelTypesController.addError(e);
    }
  }

  // Método para eliminar un tipo
  Future<void> removeType(String type, String typeName, String add, String remove) async {
    try {
      if (_globalTypes[typeName]!.contains(type)) {
        await _userTypeService.removeType(_userId, type, remove);
        _emitTypes(typeName, add, remove);
        _emitRemovedTypes(add, remove);
      }
      else {
         await _userTypeService.removeType(_userId, type, add);
        _emitTypes(typeName, add, remove);
        _emitRemovedTypes(add, remove);
      }
    } catch (e) {
      print("Error al eliminar el tipo: $e");
    }
  }

  // Método para reactivar un tipo
  Future<void> reactivateType(String type, String typeName, String add, String remove) async {
    try {
      await _userTypeService.reactivateType(_userId, type, remove);
      _emitTypes(typeName, add, remove);
      _emitRemovedTypes(add, remove);
    } catch (e) {
      print("Error al reactivar el tipo: $e");
    }
  }

  // Método para añadir un tipo
  Future<void> addType(String type, String typeName, String add, String remove) async {
    try {
      await _userTypeService.addType(_userId, type, add);
      _emitTypes(typeName, add, remove);
      _emitRemovedTypes(add, remove);
    } catch (e) {
      print("Error al añadir el tipo: $e");
    }
  }

  // Método para editar un tipo
  Future<void> editType(String oldType, String newType, String typeName, String add, String remove) async {
    try {
      await _userTypeService.removeType(_userId, oldType, add);
      await _userTypeService.addType(_userId, newType, add);
      _emitTypes(typeName, add, remove);
    } catch (e) {
      print("Error al editar el tipo: $e");
    }
  }
}
