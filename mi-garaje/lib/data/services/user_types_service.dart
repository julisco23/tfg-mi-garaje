import 'package:cloud_firestore/cloud_firestore.dart';

class UserTypesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Metodo para obtener la lista de tipos añadidos y eliminados por el usuario
  Future<Map<String, List<String>>> getUserData(String userId, String typeName) async {
    try {
      DocumentSnapshot userSnapshot = await _firestore.collection("users").doc(userId).get();
      var userData = userSnapshot.data() as Map<String, dynamic>;

      List<String> addedRefuelTypes = List<String>.from(userData["added$typeName"] ?? []);
      List<String> removedRefuelTypes = List<String>.from(userData["removed$typeName"] ?? []);

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
  Future<void> addType(String userId, String type, String typeName) async {
    try {
      await _firestore.collection("users").doc(userId).update({
        "added$typeName": FieldValue.arrayUnion([type]),
      });
    } catch (e) {
      print(e);
    }
  }

  // Metodo para eliminar un type del usuario
  Future<void> removeType(String userId, String type, String typeName, bool addOrRemove) async {
    try {
      if (addOrRemove) {
        await _firestore.collection("users").doc(userId).update({
          "added$typeName": FieldValue.arrayRemove([type]),
        });
      } else {
        await _firestore.collection("users").doc(userId).update({
          "removed$typeName": FieldValue.arrayUnion([type]),
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // Metodo para reactivar un type del usuario
  Future<void> reactivateType(String userId, String type, String typeName) async {
    try {
      await _firestore.collection("users").doc(userId).update({
        "removed$typeName": FieldValue.arrayRemove([type]),
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
      return List<String>.from(doc.data()?['addedActivity'] ?? []);
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
