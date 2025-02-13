import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mi_garaje/data/models/car.dart';
import 'package:mi_garaje/data/models/option.dart';

class CarService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Añadir un coche (se genera un ID único)
  Future<String?> addCar(Car car) async {
    try {
      final docRef = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('cars')
        .add(car.toMap());

      car.setId(docRef.id);

      return null;
    } catch (e) {
      print("Error al aañdir el coche" + e.toString());
      return 'Error al añadir el coche';
    }
  }

  /// Obtener todos los coches del usuario junto con sus opciones
  Future<List<Car>> getAllCars() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('cars')
          .get();

      List<Car> cars = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        Car car = Car.fromMap(data)..id = doc.id;

        // Cargar las opciones de este coche
        final optionsSnapshot = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('cars')
            .doc(car.id)
            .collection('options')
            .get();

        car.options = optionsSnapshot.docs.map((optionDoc) {
          final optionData = optionDoc.data();
          return Option.fromMap(optionData)..id = optionDoc.id;
        }).toList();

        cars.add(car);
      }

      return cars;
    } catch (e) {
      print('Error al obtener los coches y sus opciones: $e');
      return [];
    }
  }

  /// Eliminar un coche específico por su ID
  Future<void> deleteCar(String carId) async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).collection('cars').doc(carId).delete();
      print('Coche eliminado correctamente.');
    } catch (e) {
      print('Error al eliminar el coche: $e');
    }
  }

  // Añadir una opción a un coche específico
  Future<void> addCarOption(String carId, Option option) async {
    try {
      print("Añadiendo opción a Firestore: ${option.toMap()}");

      DocumentReference optionRef = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('cars')
        .doc(carId)
        .collection('options')
        .add(option.toMap());

      print("Opción añadida con ID: ${optionRef.id}");

      option.setId(optionRef.id);

      // Añadir el ID de la opción a la base de datos
      await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('cars')
        .doc(carId)
        .collection('options')
        .doc(optionRef.id)
        .update({'id': optionRef.id});

    } catch (e) {
      print("Error al añadir la opción: $e");
    }
  }

  Future<void> updateCarOption(String carId, Option option) async {
    try {
      await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('cars')
        .doc(carId)
        .collection('options')
        .doc(option.id)
        .update(option.toMap());

    } catch (e) {
      print("Error al actualizar la opción: $e");
    }
  }

  Future<void> deleteCarOption(String carId, String optionId) async {
    try {
      await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('cars')
        .doc(carId)
        .collection('options')
        .doc(optionId)
        .delete();
    } catch (e) {
      print("Error al eliminar la opción: $e");
    }
  }
}
