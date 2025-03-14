import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/custom.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/services/car_service.dart';

class GarageProvider extends ChangeNotifier {
  final CarService carService = CarService();
  String? _userId;
  String? _idFamily;
  
  Vehicle? _selectedVehicle;
  bool _initialized = false;

  // Getters
  Vehicle? get selectedVehicle => _selectedVehicle;

  bool get isFamily => _idFamily != null;

  late List<Vehicle> _vehicles;
  List<Vehicle> get vehicles {
    _vehicles.sort((a, b) => a.creationDate!.compareTo(b.creationDate!));
    return _vehicles;
  }

  void initializeUser(String userId, {String? idFamily}) {
    _idFamily = idFamily;
    _userId = userId;
    print("User: $_userId, Family: $_idFamily");
  }

  // Método para obtener primer vehículos (si existe)
  Future<bool> hasVehicles() async {
    if (_initialized) {
      return _selectedVehicle != null;
    }
    _initialized = true;

    if (isFamily) {
      _vehicles = await carService.getVehiclesFuture(_idFamily!, "families");
    } else {
      _vehicles = await carService.getVehiclesFuture(_userId! , "users");
    }

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
    if (isFamily) {
      _vehicles = await carService.getVehiclesFuture(_idFamily!, "families");
    } else {
      _vehicles = await carService.getVehiclesFuture(_userId!, "users");
    }

    print("Vehículos cargados: ${_vehicles.toString()}");

    await setSelectedVehicle( _vehicles.firstWhere(
      (vehicle) => vehicle.id == _selectedVehicle!.id, 
      orElse: () => _vehicles.first,
    ));
  }

  // Cargar actividades
  Future<void> loadActivities() async {
    if (_selectedVehicle != null) {
      if (isFamily) {
        await carService.getActivities(_selectedVehicle!.id!, _idFamily!, "families").then((activities) {
          _selectedVehicle!.setActivities(activities);
          print("Actividades cargadas [${_selectedVehicle!.activities.length}]: ${_selectedVehicle!.activities}");
        });
      } else {
        await carService.getActivities(_selectedVehicle!.id!, _userId!, "users").then((activities) {
          _selectedVehicle!.setActivities(activities);
          print("Actividades cargadas [${_selectedVehicle!.activities.length}]: ${_selectedVehicle!.activities}");
        });
      }
    }

    notifyListeners();
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    _userId = null;
    _idFamily = null;
    _vehicles = [];
    _initialized = false;
    _selectedVehicle = null;
    print("User: $_userId, Vehicle: $_selectedVehicle, Initialized: $_initialized");
  }

  // Métodos para manejo de vehículos
  Future<void> addVehicle(Vehicle vehicle) async {
    if (isFamily) {
      await carService.addVehicle(vehicle, _idFamily!, "families");
    } else {
      await carService.addVehicle(vehicle, _userId!, "users");
    }
    _vehicles.add(vehicle);
    setSelectedVehicle(vehicle);
  }

  Future<void> deleteVehicle(Vehicle vehicle) async {
    if (isFamily) {
      await carService.deleteVehicle(vehicle.id!, _idFamily!, "families");
    } else {
      await carService.deleteVehicle(vehicle.id!, _userId!, "users");
    }
    _vehicles.remove(vehicle);

    if (vehicle == selectedVehicle) {
      setSelectedVehicle(_vehicles.isNotEmpty ? _vehicles.first : null);
    }

    if (_selectedVehicle == null) {
      _initialized = false;
    }
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    if (isFamily) {
      await carService.updateVehicle(vehicle, _idFamily!, "families");
    } else {
      await carService.updateVehicle(vehicle, _userId!, "users");
    }
    _vehicles[_vehicles.indexWhere((element) => element.id == vehicle.id)] = vehicle;

    setSelectedVehicle(vehicle);
    notifyListeners();
  }

  // Métodos para manejo de actividades
  void addActivity(Activity activity) {
    if (_selectedVehicle != null) {
      if (isFamily) {
        carService.addActivity(_selectedVehicle!.id!, activity, _idFamily!, "families");
      } else {
        carService.addActivity(_selectedVehicle!.id!, activity, _userId!, "users");
      }
      _selectedVehicle!.addActivity(activity);
      notifyListeners();
    }
  }

  void deleteActivity(Activity activity) {
    if (_selectedVehicle != null) {
      if (isFamily) {
        carService.deleteActivity(_selectedVehicle!.id!, activity.idActivity!, _idFamily!, "families");
      } else {
        carService.deleteActivity(_selectedVehicle!.id!, activity.idActivity!, _userId!, "users");
      }
      _selectedVehicle!.removeActivity(activity);
      notifyListeners();
    }
  }

  void updateActivity(Activity activity) {
    if (_selectedVehicle != null) {
      if (isFamily) {
        carService.updateActivity(_selectedVehicle!.id!, activity, _idFamily!, "families");
      } else {
        carService.updateActivity(_selectedVehicle!.id!, activity, _userId!, "users");
      }
      _selectedVehicle!.updateActivity(activity);
      notifyListeners();
    }
  }

  void deleteAllActivities(String typeName, {String? type}) {
    type ??= "custom";
    if (isFamily) {
      carService.removeAllActivities(_idFamily!, typeName, type, "families");
    } else {
      carService.removeAllActivities(_userId!, typeName, type, "users");
    }
    if (type == "custom") {
      for (var vehicle in _vehicles) {
        vehicle.activities.removeWhere((activity) => activity.getType == typeName);
      }
    }
    notifyListeners();
  }

  void editAllActivities(String oldName, String newName, {String? type}) {
    type ??= "custom";

    if (isFamily) {
      carService.editAllActivities(_idFamily!, oldName, newName, type, "families");
    } else {
      carService.editAllActivities(_userId!, oldName, newName, type, "users");
    }

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
    if (isFamily) {
      await carService.deleteVehicleType(_idFamily!, type, typeName, "families");
    } else {
      await carService.deleteVehicleType(_userId!, type, typeName, "users");
    }
    notifyListeners();
  }

  Future<void> updateVehicleType(String oldName, String newName, String type) async {
    if (isFamily) {
      await carService.updateVehicleType(_idFamily!, oldName, newName, type, "families");
    } else {
      await carService.updateVehicleType(_userId!, oldName, newName, type, "users");
    }
    notifyListeners();
  }

  Future<void> convertToFamily(String idFamily) async {
    await carService.convertToFamily(_userId!, idFamily);
    await carService.deleteVehicles(_userId!, "users");

    _idFamily = idFamily;
    notifyListeners();
  }

  Future<void> joinFamily(String idFamily) async {
    await carService.deleteVehicles(_userId!, "users");

    _idFamily = idFamily;
    refreshGarage();
    notifyListeners();
  }

  Future<void> leaveFamily(bool delete) async {
    if (delete) {
      await carService.deleteVehicles(_idFamily!, "families");
    }
    _idFamily = null;
    _vehicles.clear();
    _selectedVehicle = null;
    notifyListeners();
  }
}
