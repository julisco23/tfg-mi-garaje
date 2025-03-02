import 'package:flutter/material.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';

class HistoryView extends StatelessWidget {
  final GarageViewModel garageViewModel;
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
