import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/car.dart';
import 'package:mi_garaje/data/models/option.dart';
import 'package:mi_garaje/data/services/car_service.dart';

class GarageViewModel extends ChangeNotifier {
  bool _isLoadingCars = true;

  bool get isLoadingCars => _isLoadingCars;

  void toggleLoadingCars() {
    _isLoadingCars = !_isLoadingCars;
  }

  Car? _selectedCoche;

  // Lista local para almacenar los coches
  final List<Car> _coches = [];

  void cerrarSesion() {
    _coches.clear();
    _selectedCoche = null;
    _isCochesCargados = false;
    toggleLoadingCars();
    notifyListeners();
  }

  bool _isCochesCargados = false;

  bool get isCochesCargados => _isCochesCargados;

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
    Car nuevoCoche = Car(
        name: 'Coche ${_coches.length + 1}', initial: 'C${_coches.length + 1}');

    // Guardamos el coche en Firestore
    await CarService().addCar(nuevoCoche);

    // Agregamos el coche a la lista local
    _coches.add(nuevoCoche);

    // Actualizamos la UI
    _selectedCoche = nuevoCoche;
    notifyListeners();
  }

  // Eliminar un coche de la lista
  void eliminarCoche(Car coche) async {
    // Eliminamos el coche de Firestore
    await CarService().deleteCar(coche.id!);

    // Eliminamos el coche de la lista local
    _coches.removeWhere((car) => car.id == coche.id);

    // Notificamos a los escuchadores para que la UI se actualice
    notifyListeners();
  }

  // Establecer el coche seleccionado
  void setSelectedCoche(Car coche) {
    _selectedCoche = coche;
    notifyListeners();
  }

  // Actualizar el coche seleccionado
  void agregarOpcion(Option option) {
    CarService().addCarOption(selectedCoche!.id!, option);
    selectedCoche!.addOption(option);
    notifyListeners();
  }

  // Eliminar una opción del coche seleccionado
  void eliminarOpcion(Option option) {
    CarService().deleteCarOption(selectedCoche!.id!, option.id!);
    selectedCoche!.removeOption(option);
    notifyListeners();
  }

  // Actualizar una opción del coche seleccionado
  void updateOption(Option option) {
    CarService().updateCarOption(selectedCoche!.id!, option);
    selectedCoche!.updateOption(option);
    notifyListeners();
  }

}
