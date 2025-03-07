import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/dialogs/garage_tab/dialog_add_vehicle.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';

class VehicleCard extends StatefulWidget {
  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.garageProvider,
    this.profile = false
  });

  final Vehicle vehicle;
  final bool profile;
  final GarageProvider garageProvider;

  @override
  State<VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<VehicleCard> {
  late Vehicle vehicle;
  late bool profile;

  @override
  void initState() {
    super.initState();
    vehicle = widget.vehicle;
    profile = widget.profile;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (!profile) {
          await widget.garageProvider.setSelectedVehicle(vehicle);
          if (context.mounted){
            Navigator.pop(context);
          }
        }
      },
      onLongPress: () {
        if (!profile) {
          DialogAddVehicle.show(
            context, 
            widget.garageProvider,
            vehicle: vehicle, 
            onVehicleUpdated: (updatedVehicle) {
              setState(() {
                vehicle = updatedVehicle;
              });
            }
          );
        }
      },
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
                      child: ClipOval(
                        child: Image.memory(
                          base64Decode(vehicle.photo!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    )
                  : CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 25,
                      child: Text(
                        vehicle.getInitial(),
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
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
