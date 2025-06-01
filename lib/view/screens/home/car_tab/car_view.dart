import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/provider/activity_provider.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:mi_garaje/data/provider/tab_update_notifier.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/utils/app_localizations_extensions.dart';
import 'package:mi_garaje/view/widgets/cards/activity_card.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_add_activity.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CarTabView extends ConsumerStatefulWidget {
  const CarTabView({super.key});

  @override
  ConsumerState<CarTabView> createState() => _CarTabViewState();
}

class _CarTabViewState extends ConsumerState<CarTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> activityTypes;
  late List<Tab> tabs;
  late List<Widget> tabContents;
  late TabState _tabState;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _tabState = provider.Provider.of<TabState>(context, listen: false);

      activityTypes =
          provider.Provider.of<GlobalTypesViewModel>(context, listen: false)
              .getTabsList();
      _tabState.inicializar(activityTypes);

      tabs = _tabState.activityTypes
          .map((type) =>
              Tab(text: AppLocalizations.of(context)!.getSubType(type)))
          .toList();

      tabContents = _tabState.activityTypes
          .map((type) => _buildTabContent(type))
          .toList();

      final tabIndex = _tabState.tabIndex;
      _tabController = TabController(
          length: tabs.length, vsync: this, initialIndex: tabIndex);

      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return provider.Consumer<GarageProvider>(
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
                    backgroundImage: MemoryImage(
                      base64Decode(vehicle.getPhoto()!),
                    ),
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
                tooltip: localizations.garage,
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
                onPressed: () async => await _addActivityDialog(garageProvider),
                tooltip: localizations.addActivity,
                child: const Icon(Icons.add_rounded, size: 40),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addActivityDialog(GarageProvider garageProvider) async {
    final index = _tabController.index;
    final currentType = _tabState.activityTypes[index];

    await DialogAddActivity.show(context, customType: currentType);
  }

  Widget _buildTabContent(String activityType) {
    final AuthProvider authProvider = context.read<AuthProvider>();
    final vehicle = context.read<GarageProvider>().selectedVehicle!;

    return provider.Consumer<ActivityProvider>(
      builder: (context, activityProvider, _) {
        List<Activity> activities =
            activityProvider.getActivities(activityType);

        return RefreshIndicator(
          onRefresh: () async {
            await activityProvider.loadActivities(
                vehicle.getId, authProvider.id, authProvider.type);
          },
          child: ListView.builder(
            padding:
                const EdgeInsets.only(top: 10, left: 7, right: 7, bottom: 10),
            itemCount: activities.length,
            itemBuilder: (context, index) => ActivityCard(
              activity: activities[index],
              carName: vehicle.getNameTittle(),
            ),
          ),
        );
      },
    );
  }
}
