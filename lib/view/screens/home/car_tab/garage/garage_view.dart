import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/shared/exceptions/garage_exception.dart';
import 'package:mi_garaje/view/widgets/cards/vehicle_card.dart';
import 'package:mi_garaje/view/widgets/dialogs/garage_tab/dialog_add_vehicle.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_confirm.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';

class GarageView extends StatefulWidget {
  const GarageView({super.key});

  @override
  State<GarageView> createState() => _GarageViewState();
}

class _GarageViewState extends State<GarageView> {
  @override
  Widget build(BuildContext context) {
    final GarageProvider garageProvider = context.watch<GarageProvider>();
    final AuthProvider authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () async {
              await DialogAddVehicle.show(context);
            },
          ),
        ],
        scrolledUnderElevation: 0,
        title: const Text('Garaje'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await garageProvider.refreshGarage(
              authProvider.id, authProvider.type);
        },
        child: Consumer<GarageProvider>(
          builder: (context, garageProvider, child) {
            final vehicles = garageProvider.vehicles;
            vehicles.sort((a, b) {
              return a.getNameTittle().compareTo(b.getNameTittle());
            });

            return ListView.builder(
              padding:
                  const EdgeInsets.only(top: 10, left: 7, right: 7, bottom: 10),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final Vehicle vehicle = vehicles[index];

                return Dismissible(
                  key: ValueKey(vehicle.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    if (vehicles.length == 1) {
                      ToastHelper.show('No puedes eliminar el último vehículo');
                      return false;
                    }
                    return await ConfirmDialog.show(
                      context,
                      'Eliminar vehículo',
                      '¿Estás seguro de que quieres eliminar este vehículo y todas sus actividades?',
                    );
                  },
                  onDismissed: (direction) async {
                    try {
                      await garageProvider.deleteVehicle(
                          authProvider.id, authProvider.type, vehicle);
                      ToastHelper.show('${vehicle.getVehicleType()} eliminado');
                    } on GarageException catch (e) {
                      ToastHelper.show(e.message);
                    }
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
                  child: Column(
                    children: [
                      VehicleCard(vehicle: vehicle),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
