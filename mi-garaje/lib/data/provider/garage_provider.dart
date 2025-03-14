import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/custom.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/services/car_service.dart';

class GarageProvider extends ChangeNotifier {
  final CarService carService = CarService();
  String? _userId;
  
  Vehicle? _selectedVehicle;
  bool _initialized = false;

  // Getters
  Vehicle? get selectedVehicle => _selectedVehicle;

  late List<Vehicle> _vehicles;
  List<Vehicle> get vehicles {
    _vehicles.sort((a, b) => a.creationDate!.compareTo(b.creationDate!));
    return _vehicles;
  }

  void initializeUser(String userId) {
    _userId = userId;
  }

  // Método para obtener primer vehículos (si existe)
  Future<bool> hasVehicles() async {
    if (_initialized) {
      return _selectedVehicle != null;
    }
    _initialized = true;

    _vehicles = await carService.getVehiclesFuture(_userId!);

    if (_vehicles.isNotEmpty) {
      _selectedVehicle = _vehicles.first;
      await loadActivities();
    }
    
    return _selectedVehicle != null;
  }

  // Cambiar de vehículo
  Future<void> setSelectedVehicle(Vehicle? vehicle) async {
    _selectedVehicle = vehicle;
    print("Vehículo seleccionado: $_selectedVehicle");

    if (_selectedVehicle == null) {
      return;
    } else {
      await loadActivities();
    }
  }

  Future<void> refreshGarage() async {
    _vehicles = await carService.getVehiclesFuture(_userId!);

    print("Vehículos cargados: ${_vehicles.toString()}");

    await setSelectedVehicle( _vehicles.firstWhere(
      (vehicle) => vehicle.id == _selectedVehicle!.id, 
      orElse: () => _vehicles.first,
    ));
  }

  // Cargar actividades
  Future<void> loadActivities() async {
    if (_selectedVehicle != null) {
      await carService.getActivities(_selectedVehicle!.id!, _userId!).then((activities) {
        _selectedVehicle!.setActivities(activities);
        print("Actividades cargadas [${_selectedVehicle!.activities.length}]: ${_selectedVehicle!.activities}");
      });
    }

    notifyListeners();
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    _userId = null;
    _initialized = false;
    _selectedVehicle = null;
    print("User: $_userId, Vehicle: $_selectedVehicle, Initialized: $_initialized");
  }

  // Métodos para manejo de vehículos
  Future<void> addVehicle(Vehicle vehicle) async {
    await carService.addVehicle(vehicle, _userId!);
    _vehicles.add(vehicle);
    setSelectedVehicle(vehicle);
  }

  Future<void> deleteVehicle(Vehicle vehicle) async {
    await carService.deleteVehicle(vehicle.id!, _userId!);
    _vehicles.remove(vehicle);

    if (vehicle == selectedVehicle) {
      setSelectedVehicle(_vehicles.isNotEmpty ? _vehicles.first : null);
    }

    if (_selectedVehicle == null) {
      _initialized = false;
    }
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await carService.updateVehicle(vehicle, _userId!);
    _vehicles[_vehicles.indexWhere((element) => element.id == vehicle.id)] = vehicle;

    setSelectedVehicle(vehicle);
    notifyListeners();
  }

  // Métodos para manejo de actividades
  void addActivity(Activity activity) {
    if (_selectedVehicle != null) {
      carService.addActivity(_selectedVehicle!.id!, activity, _userId!);
      _selectedVehicle!.addActivity(activity);
      notifyListeners();
    }
  }

  void deleteActivity(Activity activity) {
    if (_selectedVehicle != null) {
      carService.deleteActivity(_selectedVehicle!.id!, activity.idActivity!, _userId!);
      _selectedVehicle!.removeActivity(activity);
      notifyListeners();
    }
  }

  void updateActivity(Activity activity) {
    if (_selectedVehicle != null) {
      carService.updateActivity(_selectedVehicle!.id!, activity, _userId!);
      _selectedVehicle!.updateActivity(activity);
      notifyListeners();
    }
  }

  void notify() {
    notifyListeners();
  }

  void deleteAllActivities(String typeName, {String? type}) {
    type ??= "custom";

    carService.removeAllActivities(_userId!, typeName, type);
    if (type == "custom") {
      for (var vehicle in _vehicles) {
        vehicle.activities.removeWhere((activity) => activity.getType == typeName);
      }
    }
    notifyListeners();
  }

  void editAllActivities(String oldName, String newName, {String? type}) {
    type ??= "custom";

    carService.editAllActivities(_userId!, oldName, newName, type);
    if (type == "custom") {
      for (var vehicle in _vehicles) {
        for (var activity in vehicle.activities) {
          if (activity.getType == oldName) {
            activity as CustomActivity;
            activity.setCustomType(newName);
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> deleteVehicleType(String type, String typeName) async {
    await carService.deleteVehicleType(_userId!, type, typeName);
    notifyListeners();
  }

  Future<void> updateVehicleType(String oldName, String newName, String type) async {
    await carService.updateVehicleType(_userId!, oldName, newName, type);
    notifyListeners();
  }
}
