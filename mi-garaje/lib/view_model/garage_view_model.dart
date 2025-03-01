import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/services/car_service.dart';

class GarageViewModel extends ChangeNotifier {
  CarService carService = CarService();
  bool _isLoadingVehicles = true;
  bool _isVehiclesCargados = false;
  Vehicle? _selectedVehicle;

  // Lista local para almacenar los coches
  final List<Vehicle> _vehicles = [];

  // Getters
  bool get isLoadingVehicles => _isLoadingVehicles;
  bool get isVehiclesCargados => _isVehiclesCargados;

  // METODOS
  // Cambiar el estado de carga de los coches
  void toggleLoadingVehicles() {
    _isLoadingVehicles = !_isLoadingVehicles;
    notifyListeners();
  }

  // Cerrar la sesión del usuario
  void cerrarSesion() {
    _vehicles.clear();
    _selectedVehicle = null;
    _isVehiclesCargados = false;
    toggleLoadingVehicles();
    notifyListeners();
  }

  // Cargar los coches del usuario
  Future<void> loadVehicles() async {
    if (_isVehiclesCargados) return;

    final vehicles = await carService.getAllVehicles();
    _vehicles.addAll(vehicles);
    if (_vehicles.isNotEmpty) {
      _selectedVehicle = _vehicles.first;
    }
    _isVehiclesCargados = true;
    notifyListeners();
  }

  // Obtener todos los coches locales (visualización)
  List<Vehicle> get coches => _vehicles;

  // Verificar si la lista de coches está vacía
  bool get isEmpty => _vehicles.isEmpty;

  // Obtener el coche seleccionado
  Vehicle? get selectedVehicle => _selectedVehicle;

  // Agregar un coche a la lista
  void addVehicle(Vehicle vehicle) async {
    await carService.addVehicle(vehicle);
    _vehicles.add(vehicle);
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  // Eliminar un coche de la lista
  void deleteVehicle(Vehicle vehicle) async {
    await carService.deleteVehicle(vehicle.id!);

    _vehicles.remove(vehicle);
    if (_selectedVehicle == vehicle) {
      _selectedVehicle = _vehicles.isNotEmpty ? _vehicles.first : null;
    }
    notifyListeners();
  }

  // Actualizar un coche de la lista
  void updateVehicle(Vehicle vehicle) async {
    await carService.updateVehicle(vehicle);
    _vehicles[_vehicles.indexWhere((element) => element.id == vehicle.id)] =
        vehicle;
    notifyListeners();
  }

  // Establecer el coche seleccionado
  void setSelectedVehicle(Vehicle vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  // Añadir una actividad al coche seleccionado
  void addActivity(Activity activity) {
    carService.addActivity(_selectedVehicle!.id!, activity);
    _selectedVehicle!.addActivity(activity);
    notifyListeners();
  }

  // Eliminar una actividad del coche seleccionado
  void deleteActivity(Activity activity) {
    carService.deleteActivity(_selectedVehicle!.id!, activity.idActivity!);
    _selectedVehicle!.removeActivity(activity);
    notifyListeners();
  }

  // Actualizar una actividad del coche seleccionado
  void updateActivity(Activity activity) {
    carService.updateActivity(_selectedVehicle!.id!, activity);
    _selectedVehicle!.updateActivity(activity);
    notifyListeners();
  }

  // Eliminar garaje
  Future<void> deleteGarage() async {
    await carService.eliminarGaraje();
    cerrarSesion();
  }
}
