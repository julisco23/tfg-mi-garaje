import 'package:cloud_firestore/cloud_firestore.dart';

class UserTypesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Metodo para obtener la lista de tipos añadidos y eliminados por el usuario
  Future<Map<String, List<String>>> getUserData(
      String ownerId, String ownerType, String typeName) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection(ownerType).doc(ownerId).get();

      var userData = userSnapshot.data() as Map<String, dynamic>?;

      List<String> addedFuelTypes =
          List<String>.from(userData?["added$typeName"] ?? []);
      List<String> removedFuelTypes =
          List<String>.from(userData?["removed$typeName"] ?? []);

      return {
        "added": addedFuelTypes,
        "removed": removedFuelTypes,
      };
    } catch (e) {
      throw Exception('get_user_data_error');
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
      throw Exception('add_type_error');
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
      throw Exception('remove_type_error');
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
      throw Exception('reactivate_type_error');
    }
  }

  // Método para obtener los tabs guardados del usuario
  Future<List<String>> getTabs(String ownerId, String ownerType) async {
    try {
      final userRef = _firestore.collection(ownerType).doc(ownerId);
      final doc = await userRef.get();

      if (doc.exists) {
        return List<String>.from(doc.data()?['addedActivity'] ?? []);
      }
      return [];
    } catch (e) {
      throw Exception('get_tabs_error');
    }
  }

  // Método para transpasar los types de un usuario a una familia
  Future<void> transformTypesToFamily(String userId, String idFamily) async {
    try {
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
    } catch (e) {
      throw Exception('transform_types_error');
    }
    deleteTypeFromUser(userId);
  }

  Future<void> deleteTypeFromUser(String userId) async {
    try {
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
    } catch (e) {
      throw Exception('delete_type_from_user_error');
    }
  }
}
