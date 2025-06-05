import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/utils/app_localizations_extensions.dart';
import 'package:mi_garaje/view/widgets/cards/vehicle_card.dart';
import 'package:mi_garaje/view/widgets/dialogs/garage_tab/dialog_add_vehicle.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_confirm.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:mi_garaje/data/provider/garage_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GarageView extends ConsumerWidget {
  const GarageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final garageState = ref.watch(garageProvider);
    final theme = Theme.of(context);

    final vehicles = garageState.value!.vehicles;

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
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(garageProvider);
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
                  ToastHelper.show(
                      theme, localizations.cannotDeleteLastVehicle);
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
                  await ref
                      .read(garageProvider.notifier)
                      .deleteVehicle(vehicle);
                  ToastHelper.show(theme,
                      '${vehicle.getVehicleType()} ${localizations.deleted}');
                } catch (e) {
                  ToastHelper.show(
                      theme, localizations.getErrorMessage(e.toString()));
                }
              },
              background: Container(
                color: Colors.red,
                margin: const EdgeInsets.all(7),
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
      ),
    );
  }
}
