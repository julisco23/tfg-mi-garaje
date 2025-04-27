class GarageException implements Exception {
  final String code;
  GarageException(this.code);

  String get message {
    switch (code) {
      case 'garage_not_found':
        return 'Garage not found';
      case 'vehicle_not_found':
        return 'Vehicle not found';
      case 'user_not_found':
        return 'User not found';
      case 'invalid_credentials':
        return 'Invalid credentials';
      default:
        return 'An unknown error occurred';
    }
  }
}
