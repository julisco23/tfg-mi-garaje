import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class GlobalTypesService {
  static Map<String, List<String>> _data = {};

  // Carga los tipos desde el JSON
  static Future<void> loadTypes() async {
    final String response =
        await rootBundle.loadString('assets/json/types.json');
    final Map<String, dynamic> data = json.decode(response);

    _data = {
      "Fuel": List<String>.from(data["fuel_types"]),
      "Repair": List<String>.from(data["repair_types"]),
      "Record": List<String>.from(data["record_types"]),
      "Vehicle": List<String>.from(data["vehicle_types"]),
      "Activity": List<String>.from(data["activity_types"]),
    };
  }

  // Obtener los tipos cargados
  static Map<String, List<String>> getTypes() {
    return _data;
  }
}
