import 'package:mi_garaje/data/models/option.dart';
import 'package:mi_garaje/data/models/option_type.dart';

class Car {
  String? id;
  String name;
  String initial;

  List<Option> options = [];

  Car({
    this.id,
    required this.name,
    required this.initial,
  });

  void addOption(Option option) {
    options.add(option);
  }

  void setId(String id) {
    this.id = id;
  }

  String getId() {
    return id!;
  }

  String getName() {
    return name;
  }

  String getInitial() {
    return initial;
  }

  void removeOption(Option option) {
    options.remove(option);
  }

  void updateOption(Option option) {
    final index = options.indexWhere((element) => element.id == option.id);
    options[index] = option;
  }

  List<Option> getOptions(OptionType type) {
    
    List<Option> filteredOptions = [];

    // Recorre las opciones en la lista
    options.forEach((option) {
      if (option.type == type) {
        filteredOptions.add(option);
      }
    });

    return filteredOptions;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'initial': initial,
    };
  }

  /// Crear una instancia de `Car` desde un mapa de Firestore
  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      name: map['name'] as String,
      initial: map['initial'] as String,
    );
  }

}
