import 'package:mi_garaje/data/models/vehicle.dart';

class UserMy {
  String? id;
  String? name;
  String? email;
  String? photoURL;
  bool isAnonymous;
  bool isGoogle;
  DateTime creationDate;
  bool isPhotoChanged;
  List<Vehicle> vehiculos = [];

  Map<int, List<String>> typesCreated = {
    0: [],
    1: [],
    2: [],
  };
  Map<int, List<int>> typesDeleted = {
    0: [],
    1: [],
    2: [],
  };

  UserMy({
    this.id,
    this.name,
    this.email,
    this.photoURL,
    required this.isAnonymous,
    required this.isGoogle,
    required this.creationDate,
    required this.isPhotoChanged,
  });

  bool get isPhoto {
    return photoURL != null;
  }

  bool get hasPhotoChanged => isPhotoChanged;

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
  factory UserMy.fromMap(Map<String, dynamic> map) {
    return UserMy(
      name: map['name'],
      email: map['email'],
      photoURL: map['photoURL'],
      isAnonymous: map['isAnonymous'],
      isGoogle: map['isGoogle'],
      creationDate: DateTime.parse(map['creationDate']),
      isPhotoChanged: map['isPhotoChanged'],
    );
  }

  // Método para actualizar el nombre del usuario
  void updateName(String name) {
    this.name = name;
  }

  // Método para actualizar la foto de perfil del usuario
  void updatePhotoURL(String photoURL) {
    this.photoURL = photoURL;
  }

  // Método para añadir un vehículo a la lista de vehículos del usuario
  void addVehicle(Vehicle vehicle) {
    vehiculos.add(vehicle);
  }

  // Método para eliminar un vehículo de la lista de vehículos del usuario
  void deleteVehicle(Vehicle vehicle) {
    vehiculos.remove(vehicle);
  }

  // Método para actualizar un vehículo de la lista de vehículos del usuario
  void updateVehicle(Vehicle vehicle) {
    vehiculos[vehiculos.indexWhere((element) => element.id == vehicle.id)] = vehicle;
  }

  // Método para añadir un tipo de actividad creado por el usuario
  void addTypeCreated(int type, String name) {
    typesCreated[type]!.add(name);
  }

  // Método para eliminar un tipo de actividad creado por el usuario
  void deleteTypeCreated(int type, String name) {
    typesCreated[type]!.remove(name);
  }

  // Método para añadir un tipo de actividad eliminado por el usuario
  void addTypeDeleted(int type, int id) {
    typesDeleted[type]!.add(id);
  }

  // Método para eliminar un tipo de actividad eliminado por el usuario
  void deleteTypeDeleted(int type, int id) {
    typesDeleted[type]!.remove(id);
  }
}
