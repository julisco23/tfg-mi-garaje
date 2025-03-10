import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/vehicle.dart';

class CarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener un stream de vehículos 
  Stream<List<Vehicle>> getVehiclesStream(String userId) {
    try {
      return _firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .snapshots()
        .map((snapshot) {
          debugPrint("Vehículos obtenidos: ${snapshot.docs.length}");
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Vehicle.fromMap(data)..id = doc.id;
          }).toList();
        });
    } catch (e) {
      debugPrint("Error al obtener todos los vehículos: $e");
      rethrow;
    }
  }

  // Obtener un future de vehículos
  Future<List<Vehicle>> getVehiclesFuture(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .get();

      debugPrint("Vehículos obtenidos: ${snapshot.docs.length}");

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Vehicle.fromMap(data)..id = doc.id;
      }).toList();
    } catch (e) {
      debugPrint("Error al obtener todos los vehículos: $e");
      rethrow;
    }
  }


  /// Obtener el primer vehículo 
  Future<Vehicle?> getFirstVehicle(String userId) async {
    try {
      print("User ID: $userId");
      final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .limit(1)
        .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final vehicle = Vehicle.fromMap(doc.data())..id = doc.id;
        return vehicle;
      }

      debugPrint("No hay vehículos disponibles.");
      return null;
    } catch (e) {
      print("Error al obtener el primer vehículo: $e");
      debugPrint("Error al obtener el primer vehículo: $e");
      rethrow;
    }
  }

  // Añadir un vehículo
  Future<void> addVehicle(Vehicle vehicle, String userId) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc();

      vehicle.setId(docRef.id);
      await docRef.set(vehicle.toMap());

      debugPrint("Vehículo añadido: ${vehicle.toString()}");
    } catch (e) {
      debugPrint("Error al añadir vehículo: $e");
      rethrow;
    }
  }

  // Actualizar un vehículo
  Future<void> updateVehicle(Vehicle vehicle, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicle.id)
          .update(vehicle.toMap());

      debugPrint("Vehículo actualizado: ${vehicle.toString()}");
    } catch (e) {
      debugPrint("Error al actualizar vehículo: $e");
      rethrow;
    }
  }

  // Eliminar un vehículo
  Future<void> deleteVehicle(String vehicleId, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .delete();

      debugPrint("Vehículo eliminado: $vehicleId");
    } catch (e) {
      debugPrint("Error al eliminar vehículo: $e");
      rethrow;
    }
  }

  // Obtener un stream de actividades
  Future<List<Activity>> getActivities(String carId, String userId) async {
    try {
      return await _firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc(carId)
        .collection('activities')
        .get()
        .then((querySnapshot) {
          return querySnapshot.docs.map((doc) {
            final data = doc.data();
            return Activity.fromMap(data)..idActivity = doc.id;
          }).toList();
        });
    } catch (e) {
      debugPrint("Error al obtener todas las actividades: $e");
      rethrow;
    }
  }

  // Añadir actividad a un coche
  Future<void> addActivity(String carId, Activity activity, String userId) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(carId)
          .collection('activities')
          .doc();

      activity.setId(docRef.id);
      await docRef.set(activity.toMap());

      debugPrint("Actividad añadida: ${activity.toMap()}");
    } catch (e) {
      debugPrint("Error al añadir actividad: $e");
      rethrow;
    }
  }

  // Eliminar actividad
  Future<void> deleteActivity(String carId, String activityId, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(carId)
          .collection('activities')
          .doc(activityId)
          .delete();

      debugPrint("Actividad eliminada: $activityId");
    } catch (e) {
      debugPrint("Error al eliminar actividad: $e");
      rethrow;
    }
  }

  // Actualizar actividad
  Future<void> updateActivity(String carId, Activity activity, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(carId)
          .collection('activities')
          .doc(activity.idActivity)
          .update(activity.toMap());

      debugPrint("Actividad actualizada: ${activity.toMap()}");
    } catch (e) {
      debugPrint("Error al actualizar actividad: $e");
      rethrow;
    }
  }
}
