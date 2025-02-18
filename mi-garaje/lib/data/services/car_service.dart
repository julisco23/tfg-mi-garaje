import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mi_garaje/data/models/car.dart';
import 'package:mi_garaje/data/models/activity.dart';

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

      print("Añadiendo coche a Firestore: ${car.toMap()}");

      return null;
    } catch (e) {
      print("Error al añdir el coche" + e.toString());
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
        final actividadesSnapshot = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('cars')
            .doc(car.id)
            .collection('activities')
            .get();

        car.activities = actividadesSnapshot.docs.map((activityDoc) {
          final activitData = activityDoc.data();
          return Actividad.fromMap(activitData)..idActivity = activityDoc.id;
        }).toList();

        cars.add(car);
      }

      return cars;
    } catch (e) {
      print('Error al obtener los coches y sus opciones: $e');
      return [];
    }
  }

  Future<void> updateCar(Car car) async {
    try {
      await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('cars')
        .doc(car.id)
        .update(car.toMap());

        print("Coche actualizado en Firestore: ${car.toMap()}");
    } catch (e) {
      print("Error al actualizar el coche: $e");
    }
  }

  /// Eliminar un coche específico por su ID
  Future<void> deleteCar(String carId) async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).collection('cars').doc(carId).delete();
      print('Coche eliminado correctamente. ID: $carId');
    } catch (e) {
      print('Error al eliminar el coche: $e');
    }
  }

  // Añadir una actividad a un coche
  Future<void> addActivity(String carId, Actividad activity) async {
    try {
      DocumentReference activityRef = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('cars')
        .doc(carId)
        .collection('activities')
        .add(activity.toMap());

        activity.setId(activityRef.id);

      await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('cars')
        .doc(carId)
        .collection('activities')
        .doc(activityRef.id)
        .update({'idActivity': activityRef.id});

        print("Actividad añadida a Firestore: ${activity.toMap()}");

    } catch (e) {
      print("Error al añadir la actividad: $e");
    }
  }

  // Eliminar una actividad de un coche
  Future<void> deleteActivity(String carId, String activityId) async {
    try {
      await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('cars')
        .doc(carId)
        .collection('activities')
        .doc(activityId)
        .delete();

        print("Actividad eliminada en Firestore ID: $activityId");
    } catch (e) {
      print("Error al eliminar la actividad: $e");
    }
  }

  // Actualizar una actividad de un coche
  Future<void> updateActivity(String carId, Actividad activity) async {
    try {
      await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('cars')
        .doc(carId)
        .collection('activities')
        .doc(activity.idActivity)
        .update(activity.toMap());

        print("Actividad actualizada en Firestore: ${activity.toMap()}");
    } catch (e) {
      print("Error al actualizar la actividad: $e");
    }
  }
}
