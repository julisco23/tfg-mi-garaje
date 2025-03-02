import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/widgets/dialogs/home_tab/dialog_add_repostaje.dart';
import 'package:mi_garaje/shared/widgets/dialogs/home_tab/dialog_add_documento.dart';
import 'package:mi_garaje/shared/widgets/dialogs/home_tab/dialog_add_mantenimiento.dart';
import 'package:mi_garaje/shared/widgets/cards/activity_card.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';

class HomeTabView extends StatefulWidget {
  final GarageViewModel garageViewModel;
  const HomeTabView({
    super.key,
    required this.garageViewModel,
  });

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.garageViewModel.selectedVehicle!;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (vehicle.photo != null) ...[
              CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  radius: 20,
                  child: ClipOval(
                    child: Image.memory(
                      base64Decode(vehicle.photo!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ), 
            SizedBox(width: AppDimensions.screenHeight(context) * 0.01),
            ],
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
          tabs: [
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: const Text('Repostajes')
              )
            ),
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: const Text('Arreglos')
              )
            ),
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: const Text('Facturas')
              )
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
            onPressed: () {
              switch (_tabController.index) {
                case AppConstants.tabHistory:
                  DialogAddRefuel.show(context, widget.garageViewModel);
                  break;
                case AppConstants.tabHome:
                  DialogAddRepair.show(context, widget.garageViewModel);
                  break;
                case AppConstants.tabProfile:
                  DialogAddDocument.show(context, widget.garageViewModel);
                  break;
              }
            },
            tooltip: "Añadir actividad",
            child: const Icon(Icons.add_rounded, size: 50),
          ),
        ],
      ),
    );
  }

  // Conenido de los tab
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
