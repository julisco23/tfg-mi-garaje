import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_add_repostaje.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_add_documento.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_add_mantenimiento.dart';
import 'package:mi_garaje/view/widgets/cards/activity_card.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:provider/provider.dart';

class CarTabView extends StatefulWidget {
  const CarTabView({super.key});

  @override
  State<CarTabView> createState() => _CarTabViewState();
}

class _CarTabViewState extends State<CarTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final tabIndex = Provider.of<GarageProvider>(context, listen: false).tabIndex;
    _tabController = TabController(length: 3, initialIndex: tabIndex, vsync: this);
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<GarageProvider>(
      builder: (context, garageProvider, _) {
        final vehicle = garageProvider.selectedVehicle;

        if (vehicle == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Sin vehículo seleccionado"),
            ),
            body: Center(
              child: Text('Por favor selecciona un vehículo en el garaje.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (vehicle.photo != null) ...[
                  CircleAvatar(
                      radius: 20,
                      backgroundImage: MemoryImage(base64Decode(vehicle.photo!)),
                    ),
                ],
                SizedBox(width: 10),
                Text(vehicle.getNameTittle()),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.garage_rounded),
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.garage);
                },
                tooltip: "Garaje",
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              onTap: (index) {
                  garageProvider.tabIndex = index;
                },
              tabs: [
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Text('Repostajes'),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Text('Arreglos'),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Text('Facturas'),
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent(vehicle.getActivities(ActivityType.refuel),
                  vehicle.getNameTittle()),
              _buildTabContent(vehicle.getActivities(ActivityType.repair),
                  vehicle.getNameTittle()),
              _buildTabContent(vehicle.getActivities(ActivityType.record),
                  vehicle.getNameTittle()),
            ],
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "reload",
                onPressed: garageProvider.loadActivities, 
                tooltip: "Recargar", 
                child: const Icon(Icons.refresh_rounded, size: 40)
              ),
              SizedBox(width: AppDimensions.screenWidth(context) * 0.01),
              FloatingActionButton(
                heroTag: "add",
                onPressed: () {
                  switch (_tabController.index) {
                    case AppConstants.tabHistory:
                      DialogAddRefuel.show(context, garageProvider);
                      break;
                    case AppConstants.tabHome:
                      DialogAddRepair.show(context, garageProvider);
                      break;
                    case AppConstants.tabProfile:
                      DialogAddDocument.show(context, garageProvider);
                      break;
                  }
                },
                tooltip: "Añadir actividad",
                child: const Icon(Icons.add_rounded, size: 40),
              ),
            ],
          ),
        );
      },
    );
  }

  // Conenido de los tabs
  Widget _buildTabContent(List<Activity> activities, String carName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: AppDimensions.screenHeight(context) * 0.007),
        Expanded(
          child: ListView.builder(
            itemCount: activities.length + 1,
            itemBuilder: (context, index) {
              if (index == activities.length) {
                return SizedBox(
                    height: AppDimensions.screenHeight(context) * 0.09);
              }

              return ActivityCard(
                activity: activities[index],
                carName: carName,
              );
            },
          ),
        ),
      ],
    );
  }
}
