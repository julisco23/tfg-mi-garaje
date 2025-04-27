import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/provider/activity_provider.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/data/provider/image_cache_provider.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/dialogs/garage_tab/dialog_add_vehicle.dart';
import 'package:provider/provider.dart';

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
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              vehicle.photo != null
                  ? CircleAvatar(
                      radius: 25,
                      backgroundImage: Provider.of<ImageCacheProvider>(context)
                          .getImage("vehicle", vehicle.id!, vehicle.photo!))
                  : CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 25,
                      child: Text(
                        vehicle.getInitial(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
              SizedBox(width: AppDimensions.screenHeight(context) * 0.015),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vehicle.name != null && vehicle.name!.isNotEmpty) ...[
                      Text(
                        vehicle.name!,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (vehicle.model != null && vehicle.model!.isNotEmpty)
                        Text(
                          "${vehicle.brand} - ${vehicle.model}",
                          style: TextStyle(color: Colors.grey[700]),
                        )
                      else
                        Text(
                          vehicle.brand,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                    ] else ...[
                      Text(
                        vehicle.brand,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        vehicle.model ?? '',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ]
                  ],
                ),
              ),
              Text(
                vehicle.getVehicleType(),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
