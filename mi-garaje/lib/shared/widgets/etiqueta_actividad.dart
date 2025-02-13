import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/option.dart';
import 'package:mi_garaje/view/home/home_tab_view/activity_view.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';

class Etiqueta extends StatelessWidget {
  const Etiqueta({
    super.key,
    required this.nombre,
    required this.inicial,
    required this.fecha,
    required this.opcion,
  });

  final String nombre;
  final String inicial;
  final String fecha;
  final Option opcion;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleActividadScreen(opcion: opcion),
          ),
        );
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Eliminar ${opcion.type.name}'),
              content:
                  Text('¿Estás seguro de que quieres eliminar esta opción?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Provider.of<GarageViewModel>(context, listen: false).eliminarOpcion(opcion);

                    Navigator.pop(context);
                  },
                  child: Text('Eliminar'),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(inicial,
                    style: TextStyle(color: Color.fromARGB(255, 11, 11, 14))),
              ),
              SizedBox(width: screenHeight * 0.03),
              Text(nombre),
              SizedBox(width: screenHeight * 0.03),
              Text(fecha),
            ],
          ),
        ),
      ),
    );
  }
}
