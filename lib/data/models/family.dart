import 'package:mi_garaje/data/models/vehicle.dart';
import 'user.dart';

class Family {
  String? id;
  String? photoURL;
  DateTime? creationDate;
  String code;
  List<User>? members;
  List<Vehicle>? sharedVehicles;

  Family({
    this.id,
    required this.code,
    this.photoURL,
    this.creationDate,
    this.members,
    this.sharedVehicles,
  }) {
    creationDate = creationDate ?? DateTime.now();
  }

  // Añadir todos los miembros de la familia
  void addMembers(List<User> newMembers) {
    members = newMembers;
  }

  /// Comprobar si la familia tiene foto
  bool get hasPhoto => photoURL != null;

  /// Método para actualizar la foto de la familia
  void updatePhoto(String newPhotoURL) {
    photoURL = newPhotoURL;
  }

  /// Convertir la familia en un mapa para Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photoURL': photoURL,
      'creationDate': creationDate!.toIso8601String(),
      'code': code,
    };
  }

  /// Crear una familia desde un mapa (Firestore)
  factory Family.fromMap(Map<String, dynamic> map, String familyId) {
    return Family(
      id: familyId,
      photoURL: map['photoURL'],
      creationDate: DateTime.parse(map['creationDate']),
      code: map['code'],
    );
  }
}
