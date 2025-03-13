import 'package:cloud_firestore/cloud_firestore.dart';

class UserTypesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Metodo para obtener los types globales
  Future<List<String>> getGlobalTypes(String typeName) async {
    try {
      DocumentSnapshot globalSnapshot = await _firestore.collection("globalTypes").doc("types").get();
      List<String> refuelTypes = List<String>.from(globalSnapshot[typeName] ?? []);
      print("Cargando $typeName types: $refuelTypes");
      return refuelTypes;
    } catch (e) {
      print("Error al obtener los tipos globales de refuel: $e");
      return [];
    }
  }

  // Metodo para obtener la lista de tipos añadidos y eliminados por el usuario
  Future<Map<String, List<String>>> getUserData(String userId, String added, String remove) async {
    try {
      DocumentSnapshot userSnapshot = await _firestore.collection("users").doc(userId).get();
      var userData = userSnapshot.data() as Map<String, dynamic>;

      List<String> addedRefuelTypes = List<String>.from(userData[added] ?? []);
      List<String> removedRefuelTypes = List<String>.from(userData[remove] ?? []);

      return {
        "added": addedRefuelTypes,
        "removed": removedRefuelTypes,
      };
    } catch (e) {
      print("Error al obtener los datos del usuario: $e");
      return {};
    }
  }

  // Metodo para añadir un type al usuario
  Future<void> addType(String userId, String type, String colectionName) async {
    try {
      await _firestore.collection("users").doc(userId).update({
        colectionName: FieldValue.arrayUnion([type]),
      });
    } catch (e) {
      print(e);
    }
  }

  // Metodo para eliminar un type del usuario
  Future<void> removeType(String userId, String type, String addOrRemove) async {
    try {
      if (addOrRemove.contains("added")) {
        await _firestore.collection("users").doc(userId).update({
          addOrRemove: FieldValue.arrayRemove([type]),
        });
      } else if (addOrRemove.contains("removed")) {
        await _firestore.collection("users").doc(userId).update({
          addOrRemove: FieldValue.arrayUnion([type]),
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // Metodo para reactivar un type del usuario
  Future<void> reactivateType(String userId, String type, String removedTypesName) async {
    try {
      await _firestore.collection("users").doc(userId).update({
        removedTypesName: FieldValue.arrayRemove([type]),
      });
    } catch (e) {
      print(e);
    }
  }

  // TABS
  // Método para guardar un nuevo activityType (tab) en Firestore
  Future<void> saveTab(String userId, String activityType) async {
    final userRef = _firestore.collection('users').doc(userId);

    await userRef.update({
      'tabs': FieldValue.arrayUnion([activityType]), // Añadir el nuevo tab (activityType)
    });
  }

  // Método para obtener los tabs guardados del usuario
  Future<List<String>> getTabs(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final doc = await userRef.get();

    if (doc.exists) {
      return List<String>.from(doc.data()?['addedActivities'] ?? []);
    }

    return [];
  }

  // Método para eliminar un tab (activityType) de Firestore
  Future<void> deleteTab(String userId, String activityType) async {
    final userRef = _firestore.collection('users').doc(userId);

    await userRef.update({
      'tabs': FieldValue.arrayRemove([activityType]), // Eliminar el tab (activityType)
    });
  }
}
