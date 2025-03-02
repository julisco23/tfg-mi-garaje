class Validator {
  // Validación de correo electrónico
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '* Correo electrónico es obligatorio.';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
      return '* Correo electrónico inválido (@).';
    }
    return null;
  }

  // Validación de la contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '* Contraseña es obligatoria.';
    }
    if (value.length < 6) {
      return '* La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }

  // Validación del nombre (solo para signup)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '* Nombre es obligatorio.';
    }
    return null;
  }
}
