import 'package:mi_garaje/data/models/family.dart';

class User {
  String? id;
  String? name;
  String? email;
  String? photoURL;
  bool isAnonymous;
  bool isGoogle;
  DateTime creationDate;
  bool isPhotoChanged;
  Family? family;

  User({
    this.id,
    this.name,
    this.email,
    this.photoURL,
    required this.isAnonymous,
    required this.isGoogle,
    required this.creationDate,
    required this.isPhotoChanged,
    this.family,
  });

  // Propiedad calculada para verificar si el usuario tiene una familia
  bool get hasFamily => family != null;

  bool get isPhoto {
    return photoURL != null;
  }

  bool get hasPhotoChanged => isPhotoChanged;

  String get displayName {
    return name ?? email ?? 'user${id!.substring(0, 15)}';
  }

  // Método para convertir el objeto Usuario en un Map (para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'isAnonymous': isAnonymous,
      'isGoogle': isGoogle,
      'creationDate': creationDate.toIso8601String(),
      'isPhotoChanged': isPhotoChanged,
    };
  }

  // Método para crear un objeto Usuario desde un Map (para leer desde Firestore)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      email: map['email'],
      photoURL: map['photoURL'],
      isAnonymous: map['isAnonymous'],
      isGoogle: map['isGoogle'],
      creationDate: DateTime.parse(map['creationDate']),
      isPhotoChanged: map['isPhotoChanged'],
    );
  }

  // toString
  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, isPhoto: $isPhoto, isAnonymous: $isAnonymous, isGoogle: $isGoogle, creationDate: $creationDate}';
  }

  /// Método para unirse a una familia
  void joinFamily(Family family) {
    this.family = family;
  }

  /// Método para salir de la familia
  void leaveFamily() {
    family = null;
  }

  // Método para actualizar el nombre del usuario
  void updateName(String name) {
    this.name = name;
  }

  // Método para actualizar la foto de perfil del usuario
  void updatePhotoURL(String photoURL) {
    this.photoURL = photoURL;
  }
}
