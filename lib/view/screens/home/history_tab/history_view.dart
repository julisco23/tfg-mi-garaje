import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/notifier/garage_notifier.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/view/screens/home/history_tab/statistics_view.dart';
import 'package:mi_garaje/view/screens/home/history_tab/vehicle_history_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HistoryView extends ConsumerStatefulWidget {
  const HistoryView({super.key});

  @override
  ConsumerState<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<HistoryView>
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

    final vehicle = ref.watch(garageProvider).value!.selectedVehicle!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (vehicle.photo != null)
              CircleAvatar(
                radius: 20,
                backgroundImage: MemoryImage(base64Decode(vehicle.getPhoto()!)),
              ),
            SizedBox(width: AppDimensions.screenWidth(context) * 0.02),
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
          StatisticsView(),
        ],
      ),
    );
  }
}
