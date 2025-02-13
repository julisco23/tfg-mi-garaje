import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/data/models/car.dart';
import 'package:mi_garaje/data/models/option.dart';
import 'package:mi_garaje/data/models/option_type.dart';
import 'package:mi_garaje/shared/widgets/etiqueta_actividad.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({
    super.key,
  });

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Consumer<GarageViewModel>(
      builder: (context, provider, _) {
        final coche = provider.selectedCoche;

        // Guardar las opciones de cada tipo de manera invertida previamente para evitar hacerlo en el builder
        final repostajes = coche!.getOptions(OptionType.repostajes).reversed.toList();
        final mantenimientos = coche.getOptions(OptionType.mantenimientos).reversed.toList();
        final facturas = coche.getOptions(OptionType.facturas).reversed.toList();

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: AppBar(
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: const Text('Repostajes'))),
                  Tab(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: const Text('Arreglos'))),
                  Tab(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: const Text('Facturas'))),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent(repostajes, screenHeight),
              _buildTabContent(mantenimientos, screenHeight),
              _buildTabContent(facturas, screenHeight),
            ],
          ),
          floatingActionButton: Row(
            spacing: 16,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  final tabIndex = _tabController.index;
                  provider.agregarOpcion(
                    Option(
                      name: 'Rápido',
                      initial: 'R',
                      type: OptionType.values[tabIndex],
                    ),
                  );
                },
                child: const Icon(Icons.fast_forward_rounded),
              ),
              FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  final tabIndex = _tabController.index;
                  _agregarOpcion(context, coche, tabIndex);
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        );
      },
    );
  }

  // Extraemos el contenido de cada pestaña a un método reutilizable para evitar duplicación
  Widget _buildTabContent(List<Option> opciones, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: screenHeight * 0.007),
        Expanded(
          child: ListView.builder(
            itemCount: opciones.length + 1,
            itemBuilder: (context, index) {
              if (index == opciones.length) {
                return SizedBox(height: screenHeight * 0.09);
              }

              return Etiqueta(
                nombre: opciones[index].name,
                inicial: opciones[index].initial,
                fecha: opciones[index].date,
                opcion: opciones[index],
              );
            },
          ),
        ),
      ],
    );
  }

  // Método para agregar una opción con un diálogo
  void _agregarOpcion(BuildContext context, Car coche, int tabIndex) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Agregar Opción', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nombre de la Opción',
              labelStyle: TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                final String nombreOpcion = controller.text.trim();
                if (nombreOpcion.isNotEmpty) {
                  final nuevaOpcion = Option(
                    name: nombreOpcion,
                    initial: nombreOpcion[0].toUpperCase(),
                    type: OptionType.values[tabIndex],
                  );
                  context.read<GarageViewModel>().agregarOpcion(nuevaOpcion);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Agregar', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }
}
