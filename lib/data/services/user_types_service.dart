import 'package:cloud_firestore/cloud_firestore.dart';

class UserTypesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Metodo para obtener la lista de tipos añadidos y eliminados por el usuario
  Future<Map<String, List<String>>> getUserData(
      String ownerId, String ownerType, String typeName) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection(ownerType).doc(ownerId).get();
      var userData = userSnapshot.data() as Map<String, dynamic>;

      List<String> addedFuelTypes =
          List<String>.from(userData["added$typeName"] ?? []);
      List<String> removedFuelTypes =
          List<String>.from(userData["removed$typeName"] ?? []);

      return {
        "added": addedFuelTypes,
        "removed": removedFuelTypes,
      };
    } catch (e) {
      print("Error al obtener los datos del usuario: $e");
      return {};
    }
  }

  // Metodo para añadir un type al usuario
  Future<void> addType(
      String ownerId, String ownerType, String type, String typeName) async {
    try {
      await _firestore.collection(ownerType).doc(ownerId).update({
        "added$typeName": FieldValue.arrayUnion([type]),
      });
    } catch (e) {
      print(e);
    }
  }

  // Metodo para eliminar un type del usuario
  Future<void> removeType(String ownerId, String ownerType, String type,
      String typeName, bool addOrRemove) async {
    try {
      if (addOrRemove) {
        await _firestore.collection(ownerType).doc(ownerId).update({
          "added$typeName": FieldValue.arrayRemove([type]),
        });
      } else {
        await _firestore.collection(ownerType).doc(ownerId).update({
          "removed$typeName": FieldValue.arrayUnion([type]),
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // Metodo para reactivar un type del usuario
  Future<void> reactivateType(
      String ownerId, String ownerType, String type, String typeName) async {
    try {
      await _firestore.collection(ownerType).doc(ownerId).update({
        "removed$typeName": FieldValue.arrayRemove([type]),
      });
    } catch (e) {
      print(e);
    }
  }

  // Método para obtener los tabs guardados del usuario
  Future<List<String>> getTabs(String ownerId, String ownerType) async {
    final userRef = _firestore.collection(ownerType).doc(ownerId);
    final doc = await userRef.get();

    if (doc.exists) {
      return List<String>.from(doc.data()?['addedActivity'] ?? []);
    }

    return [];
  }

  // Método para transpasar los types de un usuario a una familia
  Future<void> transformTypesToFamily(String userId, String idFamily) async {
    for (String typeName in [
      "Fuel",
      "Repair",
      "Record",
      "Vehicle",
      "Activity"
    ]) {
      await getUserData(userId, "users", typeName).then((userData) {
        List<String> addedTypes = userData["added"] ?? [];
        if (addedTypes.isNotEmpty) {
          _firestore.collection("families").doc(idFamily).update({
            "added$typeName": FieldValue.arrayUnion(addedTypes),
          });
        }

        List<String> removedTypes = userData["removed"] ?? [];
        if (removedTypes.isNotEmpty) {
          _firestore.collection("families").doc(idFamily).update({
            "removed$typeName": FieldValue.arrayUnion(removedTypes),
          });
        }
      });
    }

    deleteTypeFromUser(userId);
  }

  Future<void> deleteTypeFromUser(String userId) async {
    for (String typeName in [
      "Fuel",
      "Repair",
      "Record",
      "Vehicle",
      "Activity"
    ]) {
      _firestore.collection("users").doc(userId).update({
        "added$typeName": FieldValue.delete(),
        "removed$typeName": FieldValue.delete(),
      });
    }
  }
}
