import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/data/models/car.dart';
import 'package:mi_garaje/shared/widgets/etiqueta_coche.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';

class GarageView extends StatefulWidget {
  const GarageView({super.key});

  @override
  State<GarageView> createState() => _GarageViewState();
}

class _GarageViewState extends State<GarageView> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Mostrar un indicador de carga cuando se añada un coche
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Llamar al método para agregar el coche
              context.read<GarageViewModel>().agregarCoche();

              // Cerrar el indicador de carga
              Navigator.of(context).pop();

              // Desplazarse al final de la lista después de agregar el coche
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                }
              });
            },
          ),
        ],
        scrolledUnderElevation: 0,
        title: const Text('Garaje'),
      ),
      body: Consumer<GarageViewModel>(
        builder: (context, viewModel, _) {
          final coches = viewModel.coches;

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 10, left: 7, right: 7, bottom: 10),
            itemCount: coches.length,
            itemBuilder: (context, index) {
              final Car coche = coches[index];

              return Dismissible(
                key: Key(coche.getId()),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  // Mostrar un indicador de carga al eliminar el coche
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  // Eliminar el coche y cerrar el indicador
                  viewModel.eliminarCoche(coche);
                  Navigator.of(context).pop();

                  // Puedes agregar un mensaje de confirmación si lo deseas
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coche eliminado')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  margin: const EdgeInsets.only(top: 0, left: 7, right: 7, bottom: 10),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Center(child: Icon(Icons.delete)),
                  ),
                ),
                child: EtiquetaCoche(
                  coche: coche,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
