import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Validator {
  static String? validateBrand(String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return '* Marca es obligatoria.';
    }
    return null;
  }

  static String? validateCustomType(
      String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return '* Tipo es obligatorio.';
    }
    return null;
  }

  // Validación de correo electrónico
  static String? validateEmail(String? value, AppLocalizations localizations) {
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
  static String? validatePassword(
      String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return '* Contraseña es obligatoria.';
    }
    if (value.length < 6) {
      return '* La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }

  // Validación del nombre (solo para signup)
  static String? validateName(String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return '* Nombre es obligatorio.';
    }
    return null;
  }

  // Validación de dropdown
  static String? validateDropdown(
      String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return '* Seleccione una opción.';
    }
    return null;
  }

  // Validación COSTE
  static String? validateCost(String? value, AppLocalizations localizations) {
    if (value != null && value.isNotEmpty) {
      if (double.tryParse(value) == null) {
        return '* Introduzca un número válido.';
      }
    }
    return null;
  }

  // Validación coste obligatorio
  static String? validateCostRequired(
      String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return '* Introduzca el coste.';
    }
    if (double.tryParse(value) == null) {
      return '* Introduzca un número válido.';
    }
    return null;
  }

  // Validación coste por litro
  static String? validateCostLi(String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return '* Introduce el precio por litro.';
    }
    if (double.tryParse(value) == null) {
      return '* Introduce un número válido.';
    }
    final regex = RegExp(r'^\d+(\.\d{1,4})?$');

    if (!regex.hasMatch(value)) {
      return '* Como máximo 4 decimales.';
    }
    return null;
  }

  // Validación del nombre de tipo
  static String? validateNameType(
      String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return '* Nombre es obligatorio.';
    }
    return null;
  }

  static String? validateFamilyCode(
      String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      return '* Código de familia es obligatorio.';
    }
    if (value.length != 6) {
      return '* Código de familia inválido.\n  (6 caracteres)';
    }
    return null;
  }
}
