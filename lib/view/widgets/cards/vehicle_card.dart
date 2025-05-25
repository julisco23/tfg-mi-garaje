import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/provider/activity_provider.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/data/provider/image_cache_provider.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/utils/app_localizations_extensions.dart';
import 'package:mi_garaje/view/widgets/dialogs/garage_tab/dialog_add_vehicle.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VehicleCard extends StatefulWidget {
  const VehicleCard({super.key, required this.vehicle, this.profile = false});

  final Vehicle vehicle;
  final bool profile;

  @override
  State<VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<VehicleCard> {
  late Vehicle vehicle;

  @override
  void initState() {
    super.initState();
    vehicle = widget.vehicle;
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.read<AuthProvider>();
    final ActivityProvider activityProvider = context.read<ActivityProvider>();
    final GarageProvider garageProvider = context.read<GarageProvider>();
    final NavigatorState navigator = Navigator.of(context);
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return InkWell(
      onTap: !widget.profile
          ? () async {
              await garageProvider.setSelectedVehicle(vehicle);
              await activityProvider.loadActivities(
                  vehicle.id!, authProvider.id, authProvider.type);

              navigator.pop();
            }
          : null,
      onLongPress: !widget.profile
          ? () async {
              await DialogAddVehicle.show(context, vehicle: vehicle,
                  onVehicleChanged: (updatedVehicle) {
                setState(() {
                  vehicle = updatedVehicle!;
                });
              });
            }
          : null,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              vehicle.photo != null
                  ? CircleAvatar(
                      backgroundImage: Provider.of<ImageCacheProvider>(context)
                          .getImage("vehicle", vehicle.id!, vehicle.photo!))
                  : CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        vehicle.getInitial(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
              SizedBox(width: AppDimensions.screenHeight(context) * 0.04),

              // Información del vehículo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vehicle.name != null && vehicle.name!.isNotEmpty) ...[
                      Text(vehicle.name!),
                      SizedBox(
                          height: AppDimensions.screenHeight(context) * 0.005),
                      if (vehicle.model != null && vehicle.model!.isNotEmpty)
                        Text(
                          "${vehicle.brand} - ${vehicle.model}",
                          style: Theme.of(context).textTheme.labelSmall,
                        )
                      else
                        Text(
                          vehicle.brand,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                    ] else ...[
                      Text(
                        vehicle.brand,
                      ),
                      SizedBox(
                          height: AppDimensions.screenHeight(context) * 0.005),
                      Text(
                        vehicle.model ?? '',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ]
                  ],
                ),
              ),

              // Tipo de vehículo
              Text(
                localizations.getSubType(vehicle.getVehicleType()),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(width: AppDimensions.screenWidth(context) * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
