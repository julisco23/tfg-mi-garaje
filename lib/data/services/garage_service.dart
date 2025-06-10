import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/vehicle.dart';

class GarageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Vehicle>> getVehiclesFuture(String id, String collection) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .doc(id)
          .collection('vehicles')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Vehicle.fromMap(data)..id = doc.id;
      }).toList();
    } catch (e) {
      throw Exception('fetch_vehicles_error');
    }
  }

  // Añadir un vehículo
  Future<void> addVehicle(Vehicle vehicle, String id, String collection) async {
    try {
      final docRef = _firestore
          .collection(collection)
          .doc(id)
          .collection('vehicles')
          .doc();

      vehicle.setId(docRef.id);
      await docRef.set(vehicle.toMap());
    } catch (e) {
      throw Exception('add_vehicle_error');
    }
  }

  // Eliminar un vehículo
  Future<void> deleteVehicle(
      String vehicleId, String id, String collection) async {
    try {
      await _firestore
          .collection(collection)
          .doc(id)
          .collection('vehicles')
          .doc(vehicleId)
          .delete();
    } catch (e) {
      throw Exception('delete_vehicle_error');
    }
  }

  // Actualizar un vehículo
  Future<void> updateVehicle(
      Vehicle vehicle, String id, String collection) async {
    try {
      await _firestore
          .collection(collection)
          .doc(id)
          .collection('vehicles')
          .doc(vehicle.id)
          .update(vehicle.toMap());
    } catch (e) {
      throw Exception('update_vehicle_error');
    }
  }

  // Obtener un stream de actividades
  Future<List<Activity>> getActivities(
      String carId, String id, String collection) async {
    try {
      return await _firestore
          .collection(collection)
          .doc(id)
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
      throw Exception('fetch_activities_error');
    }
  }

  // Añadir actividad a un coche
  Future<void> addActivity(
      String carId, Activity activity, String id, String collection) async {
    try {
      final docRef = _firestore
          .collection(collection)
          .doc(id)
          .collection('vehicles')
          .doc(carId)
          .collection('activities')
          .doc();

      activity.setId(docRef.id);
      await docRef.set(activity.toMap());
    } catch (e) {
      throw Exception('add_activity_error');
    }
  }

  // Eliminar actividad
  Future<void> deleteActivity(
      String carId, String activityId, String id, String collection) async {
    try {
      await _firestore
          .collection(collection)
          .doc(id)
          .collection('vehicles')
          .doc(carId)
          .collection('activities')
          .doc(activityId)
          .delete();
    } catch (e) {
      throw Exception('delete_activity_error');
    }
  }

  // Actualizar actividad
  Future<void> updateActivity(
      String carId, Activity activity, String id, String collection) async {
    try {
      await _firestore
          .collection(collection)
          .doc(id)
          .collection('vehicles')
          .doc(carId)
          .collection('activities')
          .doc(activity.idActivity)
          .update(activity.toMap());
    } catch (e) {
      throw Exception('update_activity_error');
    }
  }

  Future<void> removeAllActivities(
      String id, String typeName, String type, String collection) async {
    try {
      var vehiclesSnapshot = await _firestore
          .collection(collection)
          .doc(id)
          .collection('vehicles')
          .get();

      for (var vehicleDoc in vehiclesSnapshot.docs) {
        var vehicleId = vehicleDoc.id;

        var activitiesSnapshot = await _firestore
            .collection(collection)
            .doc(id)
            .collection('vehicles')
            .doc(vehicleId)
            .collection('activities')
            .get();

        List<String> activityIdsToDelete = [];
        for (var activityDoc in activitiesSnapshot.docs) {
          var activityData = activityDoc.data();

          if (activityData['${type.toLowerCase()}Type'] == typeName) {
            activityIdsToDelete.add(activityDoc.id);
          }
        }

        if (activityIdsToDelete.isNotEmpty) {
          for (var activityId in activityIdsToDelete) {
            await _firestore
                .collection(collection)
                .doc(id)
                .collection('vehicles')
                .doc(vehicleId)
                .collection('activities')
                .doc(activityId)
                .delete();
          }
        }
      }
    } catch (e) {
      throw Exception('delete_all_activities_error');
    }
  }

  Future<void> editAllActivities(String id, String oldName, String newName,
      String type, String collection) async {
    try {
      var vehiclesSnapshot = await _firestore
          .collection(collection)
          .doc(id)
          .collection('vehicles')
          .get();

      for (var vehicleDoc in vehiclesSnapshot.docs) {
        var vehicleId = vehicleDoc.id;

        var activitiesSnapshot = await _firestore
            .collection(collection)
            .doc(id)
            .collection('vehicles')
            .doc(vehicleId)
            .collection('activities')
            .get();

        for (var activityDoc in activitiesSnapshot.docs) {
          var activityData = activityDoc.data();

          if (activityData['${type.toLowerCase()}Type'] == oldName) {
            await _firestore
                .collection(collection)
                .doc(id)
                .collection('vehicles')
                .doc(vehicleId)
                .collection('activities')
                .doc(activityDoc.id)
                .update({'${type.toLowerCase()}Type': newName});
          }
        }
      }
    } catch (e) {
      throw Exception('edit_all_activities_error');
    }
  }

  Future<void> updateVehicleType(String id, String oldName, String newName,
      String type, String collection) async {
    try {
      var vehiclesSnapshot = await _firestore
          .collection(collection)
          .doc(id)
          .collection('vehicles')
          .get();

      for (var vehicleDoc in vehiclesSnapshot.docs) {
        var vehicleId = vehicleDoc.id;
        var vehicleData = vehicleDoc.data();

        if (vehicleData['${type.toLowerCase()}Type'] == oldName) {
          await _firestore
              .collection(collection)
              .doc(id)
              .collection('vehicles')
              .doc(vehicleId)
              .update({'${type.toLowerCase()}Type': newName});
        }
      }
    } catch (e) {
      throw Exception('edit_vehicleType_error');
    }
  }

  Future<void> deleteVehicleType(
      String id, String typeName, String type, String collection) async {
    try {
      var vehiclesSnapshot = await _firestore
          .collection(collection)
          .doc(id)
          .collection('vehicles')
          .get();

      for (var vehicleDoc in vehiclesSnapshot.docs) {
        var vehicleId = vehicleDoc.id;
        var vehicleData = vehicleDoc.data();

        if (vehicleData['${type.toLowerCase()}Type'] == typeName) {
          await _firestore
              .collection(collection)
              .doc(id)
              .collection('vehicles')
              .doc(vehicleId)
              .delete();
        }
      }
    } catch (e) {
      throw Exception('delete_vehicleType_error');
    }
  }

  Future<void> convertToFamily(String idUser, String idFamily) async {
    try {
      var vehiclesSnapshot = await _firestore
          .collection('users')
          .doc(idUser)
          .collection('vehicles')
          .get();

      for (var vehicleDoc in vehiclesSnapshot.docs) {
        var vehicleId = vehicleDoc.id;
        var vehicleData = vehicleDoc.data();

        // Copiar vehículo a la familia
        await _firestore
            .collection('families')
            .doc(idFamily)
            .collection('vehicles')
            .doc(vehicleId)
            .set(vehicleData);

        // Obtener todas las actividades del vehículo
        var activitiesSnapshot = await _firestore
            .collection('users')
            .doc(idUser)
            .collection('vehicles')
            .doc(vehicleId)
            .collection('activities')
            .get();

        for (var activityDoc in activitiesSnapshot.docs) {
          var activityId = activityDoc.id;
          var activityData = activityDoc.data();

          // Copiar actividad al vehículo en la familia
          await _firestore
              .collection('families')
              .doc(idFamily)
              .collection('vehicles')
              .doc(vehicleId)
              .collection('activities')
              .doc(activityId)
              .set(activityData);
        }
      }

      await deleteVehicles(idUser, "users");
    } catch (e) {
      throw Exception('create_family_error');
    }
  }

  Future<void> deleteVehicles(String userId, String collection) async {
    try {
      var vehiclesSnapshot = await _firestore
          .collection(collection)
          .doc(userId)
          .collection('vehicles')
          .get();

      for (var vehicleDoc in vehiclesSnapshot.docs) {
        var vehicleId = vehicleDoc.id;

        var activitiesSnapshot = await _firestore
            .collection(collection)
            .doc(userId)
            .collection('vehicles')
            .doc(vehicleId)
            .collection('activities')
            .get();

        for (var activityDoc in activitiesSnapshot.docs) {
          var activityId = activityDoc.id;

          await _firestore
              .collection(collection)
              .doc(userId)
              .collection('vehicles')
              .doc(vehicleId)
              .collection('activities')
              .doc(activityId)
              .delete();
        }

        await _firestore
            .collection(collection)
            .doc(userId)
            .collection('vehicles')
            .doc(vehicleId)
            .delete();
      }
    } catch (e) {
      throw Exception('delete_all_vehicles_error');
    }
  }
}
