import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/vehicle.dart';

class CarService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User user;

  // Añadir un vehículo (se genera un ID único)
  Future<String?> addVehicle(Vehicle vehicle) async {
    try {
      final docRef = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('vehicles')
        .add(vehicle.toMap());

      vehicle.setId(docRef.id);

      print("Añadiendo coche a Firestore: ${vehicle.toMap()}");

      return null;
    } catch (e) {
      print("Error al añdir el coche" + e.toString());
      return 'Error al añadir el coche';
    }
  }

  // Obtener todos los vehiculos del usuario
  Future<List<Vehicle>> getAllVehicles() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('vehicles')
          .get();

      List<Vehicle> vehicles = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        Vehicle vehicle = Vehicle.fromMap(data)..id = doc.id;

        // Cargar las opciones de este coche
        final actividadesSnapshot = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('vehicles')
            .doc(vehicle.id)
            .collection('activities')
            .get();

        vehicle.activities = actividadesSnapshot.docs.map((activityDoc) {
          final activitData = activityDoc.data();
          return Activity.fromMap(activitData)..idActivity = activityDoc.id;
        }).toList();

        vehicles.add(vehicle);
      }

      print('Coches cargados correctamente: ${vehicles.toString()}');

      return vehicles;
    } catch (e) {
      print('Error al obtener los coches y sus opciones: $e');
      return [];
    }
  }

  // Actualizar un vehículo
  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('vehicles')
        .doc(vehicle.id)
        .update(vehicle.toMap());

        print("Coche actualizado en Firestore: ${vehicle.toMap()}");
    } catch (e) {
      print("Error al actualizar el coche: $e");
    }
  }

  /// Eliminar un vehículo específico por su ID
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('vehicles')
        .doc(vehicleId)
        .delete();

      print('Coche eliminado correctamente. ID: $vehicleId');
    } catch (e) {
      print('Error al eliminar el coche: $e');
    }
  }



  // Añadir una actividad a un coche
  Future<void> addActivity(String carId, Activity activity) async {
    try {
      DocumentReference activityRef = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('vehicles')
        .doc(carId)
        .collection('activities')
        .add(activity.toMap());

        activity.setId(activityRef.id);

      await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('vehicles')
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
        .collection('vehicles')
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
  Future<void> updateActivity(String carId, Activity activity) async {
    try {
      await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('vehicles')
        .doc(carId)
        .collection('activities')
        .doc(activity.idActivity)
        .update(activity.toMap());

        print("Actividad actualizada en Firestore: ${activity.toMap()}");
    } catch (e) {
      print("Error al actualizar la actividad: $e");
    }
  }

  // Eliminar garaje
  Future<void> eliminarGaraje() async {
    try {
      final vehicles = await getAllVehicles();

      for (var vehicle in vehicles) {
        await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('vehicles')
          .doc(vehicle.id)
          .delete();

        for (var activity in vehicle.activities) {
          await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('vehicles')
            .doc(vehicle.id)
            .collection('activities')
            .doc(activity.idActivity)
            .delete();
        }
      }

      print("Garaje eliminado correctamente");
    } catch (e) {
      print("Error al eliminar el garaje: $e");
    }
  }
}
