import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/provider/activity_provider.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:mi_garaje/data/provider/image_cache_provider.dart';
import 'package:mi_garaje/data/provider/tab_update_notifier.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/view/widgets/cards/activity_card.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_add_activity.dart';
import 'package:provider/provider.dart';

class CarTabView extends StatefulWidget {
  const CarTabView({super.key});

  @override
  State<CarTabView> createState() => _CarTabViewState();
}

class _CarTabViewState extends State<CarTabView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> activityTypes;
  late List<Tab> tabs;
  late List<Widget> tabContents;
  late TabState _tabState;

  @override
  void initState() {
    super.initState();
    _tabState = Provider.of<TabState>(context, listen: false);

    activityTypes = Provider.of<GlobalTypesViewModel>(context, listen: false).getTabsList();
    _tabState.inicializar(activityTypes);

    tabs = _tabState.activityTypes.map((type) => Tab(text: type)).toList();
    tabContents = _tabState.activityTypes.map((type) => _buildTabContent(type)).toList();

    final tabIndex = _tabState.tabIndex;
    _tabController = TabController(length: tabs.length, vsync: this, initialIndex: tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GarageProvider>(
      builder: (context, garageProvider, _) {
        final vehicle = garageProvider.selectedVehicle!;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (vehicle.photo != null)
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: Provider.of<ImageCacheProvider>(context).getImage("vehicle", vehicle.id!, vehicle.photo!),
                  ),
                const SizedBox(width: 10),
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
              tabs: tabs,
              isScrollable: _tabState.isScrollable,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: tabContents,
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "add",
                onPressed: () => _addActivityDialog(garageProvider),
                tooltip: "Añadir actividad",
                child: const Icon(Icons.add_rounded, size: 40),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addActivityDialog(GarageProvider garageProvider) {
    final index = _tabController.index;
    final currentType = _tabState.activityTypes[index];

    DialogAddActivity.show(context, customType: currentType);
  }

  Widget _buildTabContent(String activityType) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, _) {
        final authProvider = context.read<AuthProvider>();

        // Obtén el vehicleId (y ownerId, ownerType) para cargar las actividades
        final vehicle = context.read<GarageProvider>().selectedVehicle;
        final vehicleId = vehicle?.id;
        final ownerId = authProvider.id;
        final ownerType = authProvider.type;

        // Obtén las actividades del ActivityProvider
        List<Activity> activities = activityProvider.getActivities(activityType);

        return RefreshIndicator(
          onRefresh: () async {
            await activityProvider.loadActivities(vehicleId!, ownerId, ownerType);
          },
          child: ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) => ActivityCard(
              activity: activities[index],
              carName: vehicle!.getNameTittle(),
            ),
          ),
        );
      },
    );
  }

}
