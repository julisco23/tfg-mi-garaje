import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/data/models/car.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';

class EtiquetaCoche extends StatelessWidget {
  const EtiquetaCoche({
    super.key,
    required this.coche,
  });

  final Car coche;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () {
        context.read<GarageViewModel>().setSelectedCoche(coche);
        Navigator.pop(context);
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(coche.initial, style: TextStyle(color: Color.fromARGB(255, 11, 11, 14))),
              ),
              SizedBox(width: screenHeight * 0.03),
              Text(coche.name),
            ],
          ),
        ),
      ),
    );
  }
}
