import 'package:flutter/material.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/data/provider/image_cache_provider.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/view/screens/home/history_tab/statistics_view.dart';
import 'package:mi_garaje/view/screens/home/history_tab/vehicle_history_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
                    backgroundImage: context
                        .read<ImageCacheProvider>()
                        .getImage("vehicle", vehicle.id!, vehicle.photo!),
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
              tabs: [
                Tab(text: localizations.history),
                Tab(text: localizations.statistics),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              VehicleHistoryView(
                vehicle: vehicle,
              ),
              StatisticsView(garageProvider: garageProvider),
            ],
          ),
        );
      },
    );
  }
}
