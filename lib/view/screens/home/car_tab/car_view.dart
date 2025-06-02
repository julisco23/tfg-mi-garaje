import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/provider/activity_notifier.dart';
import 'package:mi_garaje/data/provider/garage_notifier.dart';
import 'package:mi_garaje/data/provider/global_types_notifier.dart';
import 'package:mi_garaje/data/provider/tab_update_notifier.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/utils/app_localizations_extensions.dart';
import 'package:mi_garaje/view/screens/error_screen.dart';
import 'package:mi_garaje/view/widgets/cards/activity_card.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_add_activity.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CarTabView extends ConsumerStatefulWidget {
  const CarTabView({super.key});

  @override
  ConsumerState<CarTabView> createState() => _CarTabViewState();
}

class _CarTabViewState extends ConsumerState<CarTabView>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _initController(List<String> activityTypes, int initialIndex) {
    _tabController?.dispose();
    _tabController = TabController(
      length: activityTypes.length,
      vsync: this,
      initialIndex: initialIndex <= 0
          ? 0
          : initialIndex.clamp(0, activityTypes.length - 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final globalTypesAsync = ref.watch(globalTypesProvider);
    final garage = ref.watch(garageProvider).value;

    if (globalTypesAsync.isLoading ||
        garage == null ||
        garage.selectedVehicle == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final activityTypes = globalTypesAsync.value?.tabs ?? [];

    // Inicializa TabStateProvider y TabController si aún no están
    final tabState = ref.watch(tabStateProvider);
    final tabNotifier = ref.read(tabStateProvider.notifier);

    if (tabState.activityTypes.isEmpty && activityTypes.isNotEmpty) {
      Future.microtask(() {
        tabNotifier.inicializar(activityTypes);
        setState(() {
          _initController(activityTypes, tabState.tabIndex);
        });
      });
    }

    // Si el número de tabs cambió, reinicializa el controller
    if (_tabController == null ||
        _tabController!.length != tabState.activityTypes.length) {
      _initController(tabState.activityTypes, tabState.tabIndex);
    }

    final vehicle = garage.selectedVehicle!;
    final tabs = tabState.activityTypes
        .map((type) => Tab(text: localizations.getSubType(type)))
        .toList();

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
          isScrollable: tabState.isScrollable,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabState.activityTypes
            .map((type) => _buildTabContent(type, vehicle.getNameTittle()))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add",
        onPressed: () async {
          final index = _tabController!.index;
          final currentType = tabState.activityTypes[index];
          await DialogAddActivity.show(context, customType: currentType);
        },
        tooltip: localizations.addActivity,
        child: const Icon(Icons.add_rounded, size: 40),
      ),
    );
  }

  Widget _buildTabContent(String activityType, String carName) {
    final activityState = ref.watch(activityProvider);

    return activityState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorScreen(errorMessage: error.toString()),
      data: (data) {
        final activities = data.activities
            .where((a) => a.getCustomType == activityType)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(activityProvider);
          },
          child: ListView.builder(
            padding:
                const EdgeInsets.only(top: 10, left: 7, right: 7, bottom: 10),
            itemCount: activities.length,
            itemBuilder: (context, index) => ActivityCard(
              activity: activities[index],
              carName: carName,
            ),
          ),
        );
      },
    );
  }
}
