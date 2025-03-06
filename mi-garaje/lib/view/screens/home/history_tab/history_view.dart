import 'package:flutter/material.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';

class HistoryView extends StatelessWidget {
  final GarageProvider garageViewModel;
  const HistoryView({
    super.key,
    required this.garageViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historial"),
      ),
      body: Center(
        child: Text('Más información próximamente'),
      ),
    );
  }
}
