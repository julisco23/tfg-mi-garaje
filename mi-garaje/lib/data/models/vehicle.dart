class Vehicle {
  String? id;
  String? name;
  String brand;
  String? model;
  String? photo;
  String vehicleType;
  DateTime? creationDate;

  Vehicle({
    this.id,
    this.name,
    required this.brand,
    required this.model,
    this.creationDate,
    this.photo,
    required this.vehicleType,
  }) {
    creationDate = creationDate ?? DateTime.now();
  }

  void setId(String id) {
    this.id = id;
  }

  String getId() {
    return id!;
  }

  String? getName() {
    return name;
  }

  String getBrand() {
    return brand;
  }

  String? getModel() {
    return model;
  }

  String? getPhoto() {
    return photo;
  }

  String getVehicleType() {
    return vehicleType;
  }

  void setVeicleType(String vehicleType) {
    this.vehicleType = vehicleType;
  }

  String getInitial() {
    return name != null && name!.isNotEmpty ? name!.substring(0, 1).toUpperCase() : brand.substring(0, 1).toUpperCase();
  }

  String getNameTittle() {
    return name ?? brand;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'model': model,
      'photo': photo,
      'vehicleType': vehicleType,
      'creationDate': creationDate!.toIso8601String(),
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      name: map['name'] as String?,
      brand: map['brand'] as String,
      model: map['model'] as String?,
      photo: map['photo'] as String?,
      vehicleType: map['vehicleType'],
      creationDate: DateTime.parse(map['creationDate']),
    );
  }

  @override
  String toString() {
    return 'Vehicle{id: $id, brand: $brand, vehicleType: $vehicleType}';
  }
}
