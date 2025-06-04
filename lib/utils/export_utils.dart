import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> exportToCSV(List<List<String>> data) async {
  if (kIsWeb) {
    print("En web no funciona la exportación a CSV");
  } else {
    final dir = await getExternalStorageDirectory();

    if (dir == null) {
      throw Exception('No se pudo obtener el directorio de almacenamiento');
    }

    String csv = const ListToCsvConverter().convert(data);
    final path = "${dir.path}/mi_garaje.csv";
    final file = File(path);

    await file.writeAsString(csv);

    final params = ShareParams(
      text: 'Exportación CSV desde Mi Garaje',
      files: [XFile(file.path)],
    );

    await SharePlus.instance.share(params);
  }
}
