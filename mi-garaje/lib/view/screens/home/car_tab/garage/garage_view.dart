import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/view/widgets/cards/vehicle_card.dart';
import 'package:mi_garaje/view/widgets/dialogs/garage_tab/dialog_add_vehicle.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';

class GarageView extends StatefulWidget {
  const GarageView({super.key});

  @override
  State<GarageView> createState() => _GarageViewState();
}

class _GarageViewState extends State<GarageView> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final GarageProvider garageProvider = context.watch<GarageProvider>();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              DialogAddVehicle.show(context, garageProvider);

              // Desplazarse al final de la lista después de agregar el coche
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController
                      .jumpTo(_scrollController.position.maxScrollExtent);
                }
              });
            },
          ),
        ],
        scrolledUnderElevation: 0,
        title: const Text('Garaje'),
      ),
      body: StreamBuilder<List<Vehicle>>(
        stream: garageProvider.vehiclesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final vehicles = snapshot.data ?? [];

          if (vehicles.isEmpty) {
            return Center(child: Text('No tienes vehículos en el garaje.'));
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 10, left: 7, right: 7, bottom: 10),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final Vehicle vehicle = vehicles[index];

              return Dismissible(
                key: ValueKey(vehicle.getId()), // Utiliza un ID único para cada vehículo
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  // Eliminar el coche
                  await garageProvider.deleteVehicle(vehicle);

                  // Mostrar confirmación
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coche eliminado')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  margin: const EdgeInsets.only(
                      top: 7, left: 7, right: 7, bottom: 7),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Center(child: Icon(Icons.delete)),
                  ),
                ),
                child: VehicleCard(
                  vehicle: vehicle,
                  garageProvider: garageProvider
                ),
              );
            },
          );
        },
      ),
    );
  }
}
