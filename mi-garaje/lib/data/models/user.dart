import 'package:mi_garaje/data/models/vehicle.dart';

class UserMy {
  String id;
  String name;
  String email;
  String? photoURL;  // Profile photo URL (optional)
  DateTime creationDate;
  List<Vehicle> vehicles;  // List of vehicles associated with the user

  // Constructor
  UserMy({
    required this.id,
    required this.name,
    required this.email,
    this.photoURL,
    required this.creationDate,
    required this.vehicles,  // Initialize the list of vehicles
  });

  // Method to convert the User object into a Map to save in Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'creationDate': creationDate.toIso8601String(),
      'vehicles': vehicles.map((vehicle) => vehicle.toMap()).toList(),  // Convert the list of vehicles to a map
    };
  }

  // Method to create a User from a Map (for reading data from Firestore)
  factory UserMy.fromMap(Map<String, dynamic> map) {
    var vehiclesList = (map['vehicles'] as List)
        .map((vehicleMap) => Vehicle.fromMap(vehicleMap))
        .toList();

    return UserMy(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      photoURL: map['photoURL'],
      creationDate: DateTime.parse(map['creationDate']),
      vehicles: vehiclesList,
    );
  }

  void setId(String id) {
    this.id = id;
  }
}
