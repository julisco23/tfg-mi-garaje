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

  // Metodo para reactivar un type del usuario
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
}
