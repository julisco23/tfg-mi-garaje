import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/data/models/option.dart';
import 'package:mi_garaje/shared/widgets/elevated_button_utils.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';

class DetalleActividadScreen extends StatelessWidget {
  final Option opcion;

  const DetalleActividadScreen({super.key, required this.opcion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(opcion.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Provider.of<GarageViewModel>(context, listen: false)
                  .eliminarOpcion(opcion);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nombre: ${opcion.name}"),
            SizedBox(height: 16),
            Text("Inicial: ${opcion.initial}"),
            SizedBox(height: 16),
            Text("Fecha: ${opcion.date}"),
            SizedBox(height: 16),
            MiButton(
              text: "Editar",
              onPressed: () {
                _editarActividad(context, opcion);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editarActividad(BuildContext context, Option opcion) {
    // Crear un controlador para los campos de texto (para el nombre, fecha, etc.)
    TextEditingController nombreController =
        TextEditingController(text: opcion.name);
    TextEditingController fechaController =
        TextEditingController(text: opcion.date);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar actividad'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Campo de nombre
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                  ),
                ),
                SizedBox(height: 10),
                // Campo de fecha
                TextField(
                  controller: fechaController,
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Lógica para actualizar la opción con los nuevos valores
                String nuevoNombre = nombreController.text;
                String nuevaFecha = fechaController.text;

                // Actualizar la opción en el modelo (aquí se podría llamar a un método de tu viewModel)
                opcion.name = nuevoNombre;
                opcion.date = nuevaFecha;

                // Notificar a los listeners para que la UI se actualice
                Provider.of<GarageViewModel>(context, listen: false).updateOption(opcion);

                Navigator.pop(context); // Cerrar el diálogo después de guardar
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
