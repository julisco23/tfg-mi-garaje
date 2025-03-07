import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/services/car_service.dart';

class GarageProvider extends ChangeNotifier {
  final CarService carService = CarService();
  String? _userId;
  
  Vehicle? _selectedVehicle;
  bool _initialized = false;

  // Getters
  Vehicle? get selectedVehicle => _selectedVehicle;

  void initializeUser(String userId) {
    _userId = userId;
  }

  // Método para obtener primer vehículos (si existe)
  Future<bool> hasVehicles() async {
    if (_initialized) {
      return _selectedVehicle != null;
    }
    _initialized = true;

    setSelectedVehicle(await carService.getFirstVehicle(_userId!));
    
    return _selectedVehicle != null;
  }

  // Stream para obtener vehículos
  Stream<List<Vehicle>> get vehiclesStream {
    return carService.getVehiclesStream(_userId!);
  }

  // Cambiar de vehículo
  Future<void> setSelectedVehicle(Vehicle? vehicle) async {
    if (vehicle == null) {
      _selectedVehicle = null;
      //notifyListeners();
      print("Vehículo seleccionado: $_selectedVehicle");
      return;
    }
    if (vehicle != selectedVehicle) {
      _selectedVehicle = vehicle;
    } 
    
    loadActivities();
  }

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
    setSelectedVehicle(vehicle);
  }

  Future<void> deleteVehicle(Vehicle vehicle) async {
    await carService.deleteVehicle(vehicle.id!, _userId!);
    if (vehicle == selectedVehicle) {
      setSelectedVehicle(await carService.getFirstVehicle(_userId!));
    }
    if (_selectedVehicle == null) {
      _initialized = false;
      notifyListeners();
    }
    print("Terminando delteVehicle");
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await carService.updateVehicle(vehicle, _userId!);
    setSelectedVehicle(vehicle);
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
}
