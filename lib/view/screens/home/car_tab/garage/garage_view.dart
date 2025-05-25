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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GarageView extends StatefulWidget {
  const GarageView({super.key});

  @override
  State<GarageView> createState() => _GarageViewState();
}

class _GarageViewState extends State<GarageView> {
  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.read<AuthProvider>();
    final localizations = AppLocalizations.of(context)!;

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
        title: Text(localizations.garage),
      ),
      body: Consumer<GarageProvider>(builder: (context, garageProvider, child) {
        final vehicles = garageProvider.vehicles;

        return RefreshIndicator(
          onRefresh: () async {
            await garageProvider.refreshGarage(
                authProvider.id, authProvider.type);
          },
          child: ListView.builder(
            padding:
                const EdgeInsets.only(top: 10, left: 7, right: 7, bottom: 10),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final Vehicle vehicle = vehicles[index];

              return Dismissible(
                key: ValueKey(vehicle.hashCode),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  if (vehicles.length == 1) {
                    ToastHelper.show(localizations.cannotDeleteLastVehicle);
                    return false;
                  }
                  return await ConfirmDialog.show(
                    context,
                    localizations.deleteVehicle,
                    localizations.confirmDeleteVehicle,
                  );
                },
                onDismissed: (direction) async {
                  try {
                    await garageProvider.deleteVehicle(
                        authProvider.id, authProvider.type, vehicle);
                    ToastHelper.show('${vehicle.getVehicleType()} ${localizations.deleted}');
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
          ),
        );
      }),
    );
  }
}
