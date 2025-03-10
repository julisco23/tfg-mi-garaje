import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class GlobalTypesService {
  static Map<String, List<String>> _datos = {};

  // Carga los tipos desde el JSON
  static Future<void> loadTypes() async {
    final String response = await rootBundle.loadString('assets/json/types.json');
    final Map<String, dynamic> data = json.decode(response);

    _datos = {
      "tipos_repostaje": List<String>.from(data["tipos_repostaje"]),
      "tipos_mantenimiento": List<String>.from(data["tipos_mantenimiento"]),
      "tipos_documentos": List<String>.from(data["tipos_documentos"]),
      "tipos_vehiculo": List<String>.from(data["tipos_vehiculo"]),
      "tipos_actividad": List<String>.from(data["tipos_actividad"]),
    };
  }

  /// Obtener los tipos cargados
  static List<String> getTypes(String tipo) {
    return _datos[tipo] ?? [];
  }
}
