import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/car.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/services/car_service.dart';

class GarageViewModel extends ChangeNotifier {
  
  bool _isLoadingCars = true;
  bool _isCochesCargados = false;
  Car? _selectedCoche;

  // Lista local para almacenar los coches
  final List<Car> _coches = [];

  // Getters
  bool get isLoadingCars => _isLoadingCars;
  bool get isCochesCargados => _isCochesCargados;

  // METODOS
  // Cambiar el estado de carga de los coches
  void toggleLoadingCars() {
    _isLoadingCars = !_isLoadingCars;
  }

  // Cerrar la sesión del usuario
  void cerrarSesion() {
    _coches.clear();
    _selectedCoche = null;
    _isCochesCargados = false;
    toggleLoadingCars();
    notifyListeners();
  }

  // Cargar los coches del usuario
  Future<void> loadCoches() async {
    if (_isCochesCargados) return;

    final coches = await CarService().getAllCars();
    _coches.addAll(coches);
    if (_coches.isNotEmpty) {
      _selectedCoche = _coches.first;
    }
    _isCochesCargados = true;
    notifyListeners();
  }

  // Obtener todos los coches locales (visualización)
  List<Car> get coches => _coches;

  // Verificar si la lista de coches está vacía
  bool get isEmpty => _coches.isEmpty;

  // Obtener el coche seleccionado
  Car? get selectedCoche => _selectedCoche;

  // Agregar un coche a la lista
  void agregarCoche() async {
    Car nuevoCoche = Car(name: 'Coche ${_coches.length + 1}', initial: 'C${_coches.length + 1}');
    await CarService().addCar(nuevoCoche);
    _coches.add(nuevoCoche);
    _selectedCoche = nuevoCoche;
    notifyListeners();
  }

  // Eliminar un coche de la lista
  void eliminarCoche(Car coche) async {
    await CarService().deleteCar(coche.id!);
    _coches.removeWhere((car) => car.id == coche.id);
    notifyListeners();
  }

  // Establecer el coche seleccionado
  void setSelectedCoche(Car coche) {
    _selectedCoche = coche;
    notifyListeners();
  }

  // Añadir una actividad al coche seleccionado
  void addActivity(Actividad activity) {
    CarService().addActivity(selectedCoche!.id!, activity);
    selectedCoche!.addActivity(activity);
    notifyListeners();
  }

  // Eliminar una actividad del coche seleccionado
  void deleteActivity(Actividad activity) {
    CarService().deleteActivity(selectedCoche!.id!, activity.idActivity!);
    selectedCoche!.removeActivity(activity);
    notifyListeners();
  }

  // Actualizar una actividad del coche seleccionado
  void updateActivity(Actividad activity) {
    CarService().updateActivity(selectedCoche!.id!, activity);
    selectedCoche!.updateActivity(activity);
    notifyListeners();
  }

}
