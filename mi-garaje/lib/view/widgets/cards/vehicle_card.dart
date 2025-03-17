import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/provider/image_cache_provider.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/dialogs/garage_tab/dialog_add_vehicle.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:provider/provider.dart';

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
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: !widget.profile ? () async {
        await widget.garageProvider.setSelectedVehicle(widget.vehicle);
        if (context.mounted){
          Navigator.pop(context);
        }
      } : null,
      onLongPress: !widget.profile ? () {
        DialogAddVehicle.show(
          context, 
          widget.garageProvider,
          vehicle: widget.vehicle, 
          onVehicleUpdated: (updatedVehicle) {
            setState(() {
              
            });
          }
        );
      } : null,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              widget.vehicle.photo != null
                  ? CircleAvatar(
                      radius: 25,
                      backgroundImage: Provider.of<ImageCacheProvider>(context).getImage("vehicle", widget.vehicle.id!, widget.vehicle.photo!)
                    )
                  : CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 25,
                      child: Text(
                        widget.vehicle.getInitial(),
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
              SizedBox(width: AppDimensions.screenHeight(context) * 0.015),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.vehicle.name != null && widget.vehicle.name!.isNotEmpty) ...[
                      Text(
                        widget.vehicle.name!,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (widget.vehicle.model != null && widget.vehicle.model!.isNotEmpty)
                        Text(
                          "${widget.vehicle.brand} - ${widget.vehicle.model}",
                          style: TextStyle(color: Colors.grey[700]),
                        )
                      else
                        Text(
                          widget.vehicle.brand,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                    ] else ...[
                      Text(
                        widget.vehicle.brand,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.vehicle.model ?? '',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ]
                  ],
                ),
              ),
              Text(
                widget.vehicle.getVehicleType(),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
