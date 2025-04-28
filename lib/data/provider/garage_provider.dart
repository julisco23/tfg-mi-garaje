import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/services/garage_service.dart';

class GarageProvider extends ChangeNotifier {
  final CarService carService = CarService();
  Vehicle? _selectedVehicle;
  bool _initialized = false;
  List<Vehicle> _vehicles = [];

  String get id => _selectedVehicle!.id!;
  bool get isVehicleSelected => _selectedVehicle != null;

  // Getters
  Vehicle? get selectedVehicle => _selectedVehicle;

  List<Vehicle> get vehicles {
    _vehicles.sort((a, b) => a.getNameTittle().compareTo(b.getNameTittle()));
    return _vehicles;
  }

  // Verificar si hay vehículos
  Future<bool> hasVehicles(String ownerId, String ownerType) async {
    if (_initialized) return isVehicleSelected;
    _initialized = true;

    await getVehicles(ownerId, ownerType);

    return isVehicleSelected;
  }

  // Obtener vehículo seleccionado
  Future<void> getVehicles(String ownerId, String ownerType) async {
    _vehicles = await carService.getVehiclesFuture(ownerId, ownerType);

    if (_vehicles.isNotEmpty) {
      _selectedVehicle = _vehicles.first;
    }
  }

  // Cambiar vehículo seleccionado
  Future<void> setSelectedVehicle(Vehicle? vehicle) async {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  // Recargar lista de vehículos
  Future<void> refreshGarage(String ownerId, String ownerType) async {
    _vehicles = await carService.getVehiclesFuture(ownerId, ownerType);

    await setSelectedVehicle(_vehicles.firstWhere(
      (vehicle) => vehicle.id == _selectedVehicle?.id,
      orElse: () => _vehicles.first,
    ));
  }

  // Cerrar sesión
  void cerrarSesion() {
    _initialized = false;
    _vehicles.clear();
    _selectedVehicle = null;
  }

  Future<void> eliminarCuenta(
      String ownerId, String ownerType, bool deleteFamily) async {
    _initialized = false;
    leaveFamily(ownerId, ownerType, deleteFamily);
  }

  // Métodos para manejar vehículos
  Future<void> addVehicle(
      String ownerId, String ownerType, Vehicle vehicle) async {
    await carService.addVehicle(vehicle, ownerId, ownerType);
    _vehicles.add(vehicle);
    setSelectedVehicle(vehicle);
  }

  Future<void> deleteVehicle(
      String ownerId, String ownerType, Vehicle vehicle) async {
    await carService.deleteVehicle(vehicle.id!, ownerId, ownerType);
    _vehicles.remove(vehicle);

    if (vehicle == _selectedVehicle) {
      setSelectedVehicle(_vehicles.isNotEmpty ? _vehicles.first : null);
    }

    if (_selectedVehicle == null) _initialized = false;
  }

  Future<void> updateVehicle(
      String ownerId, String ownerType, Vehicle vehicle) async {
    await carService.updateVehicle(vehicle, ownerId, ownerType);
    _vehicles[_vehicles.indexWhere((v) => v.id == vehicle.id)] = vehicle;
    setSelectedVehicle(vehicle);
    notifyListeners();
  }

  Future<void> deleteVehicleType(
      String ownerId, String ownerType, String type, String typeName) async {
    await carService.deleteVehicleType(ownerId, type, typeName, ownerType);
    refreshGarage(ownerId, ownerType);
    notifyListeners();
  }

  Future<void> updateVehicleType(String ownerId, String ownerType,
      String oldName, String newName, String type) async {
    await carService.updateVehicleType(
        ownerId, oldName, newName, type, ownerType);
    refreshGarage(ownerId, ownerType);
    notifyListeners();
  }

  // Manejo de familia
  Future<void> convertToFamily(String userId, String idFamily) async {
    await carService.convertToFamily(userId, idFamily);
    await carService.deleteVehicles(userId, "users");

    notifyListeners();
  }

  Future<void> joinFamily(String userId, String idFamily) async {
    await carService.deleteVehicles(userId, "users");

    refreshGarage(idFamily, "families");
    notifyListeners();
  }

  Future<void> leaveFamily(
      String ownerId, String ownerType, bool delete) async {
    if (delete) {
      await carService.deleteVehicles(ownerId, ownerType);
    }

    _vehicles.clear();
    _selectedVehicle = null;
    _initialized = false;
  }
}
