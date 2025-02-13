import 'package:intl/intl.dart';
import 'package:mi_garaje/data/models/option_type.dart';

class Option {
  String? id;
  String name;
  String initial;
  String date;
  OptionType type;

  void setId(String id) {
    this.id = id;
  }

  Option({
    this.id,
    required this.name,
    required this.initial,
    required this.type,
  }) : date = DateFormat('dd/MM/yyyy').format(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'initial': initial,
      'date': date,
      'type': type.name,
    };
  }

  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      id: map['id'] as String,
      name: map['name'] as String,
      initial: map['initial'] as String,
      type: OptionType.fromString(map['type'] as String)
    )..date = map['date'] as String;
  }

}