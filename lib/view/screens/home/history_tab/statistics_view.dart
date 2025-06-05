import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/provider/activity_notifier.dart';
import 'package:mi_garaje/data/provider/garage_notifier.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/utils/statics.dart';
import 'package:mi_garaje/view/widgets/chart/monthly_total_spending_chart.dart';
import 'package:mi_garaje/view/widgets/chart/pie_chart_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StatisticsView extends ConsumerStatefulWidget {
  const StatisticsView({super.key});

  @override
  ConsumerState<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends ConsumerState<StatisticsView> {
  List<Vehicle> vehicles = [];
  Map<String, List<Activity>> vehicleActivities = {};
  Vehicle? selectedVehicle;
  DateTimeRange? selectedDateRange;
  String? selectedActivityType;
  String? selectedSubType;

  late Map<String, dynamic> stats;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVehicles());
  }

  void _loadVehicles() async {
    final vehicles = ref.read(garageProvider).value!.vehicles;

    final Map<String, List<Activity>> activitiesMap = {};

    for (var vehicle in vehicles) {
      try {
        final acts = await ref
            .read(activityProvider.notifier)
            .getActivitiesByVehicle(vehicle.id!);
        activitiesMap[vehicle.id!] = acts;
      } catch (e) {
        activitiesMap[vehicle.id!] = [];
      }
    }

    setState(() {
      this.vehicles = vehicles;
      vehicleActivities = activitiesMap;
      stats = Statics.generateStats(vehicleActivities, selectedVehicle?.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (vehicles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVehicleSelector(localizations),
          SizedBox(height: AppDimensions.screenHeight(context) * 0.025),
          stats['activityCount'] == 0
              ? selectedVehicle == null
                  ? Center(
                      child: Text(localizations.noActivitiesAnyVehicle),
                    )
                  : Center(
                      child: Text(localizations.noActivitiesThisVehicle),
                    )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(localizations),
                    SizedBox(
                        height: AppDimensions.screenHeight(context) * 0.025),
                    _buildCharts()
                  ],
                )
        ],
      ),
    );
  }

  Widget _buildVehicleSelector(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            localizations.vehicle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(width: AppDimensions.screenWidth(context) * 0.02),
          DropdownButton<Vehicle>(
            style: Theme.of(context).textTheme.bodyMedium,
            value: selectedVehicle,
            items: [
              DropdownMenuItem<Vehicle>(
                value: null,
                child: Text(localizations.all),
              ),
              ...vehicles.map((v) => DropdownMenuItem<Vehicle>(
                    value: v,
                    child: Text(v.getNameTittle()),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                selectedVehicle = value;
                stats = Statics.generateStats(
                  vehicleActivities,
                  selectedVehicle?.id,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AppLocalizations localizations) {
    final totalSpent = stats['totalSpent'];
    final activityCount = stats['activityCount'];
    final avgMonthly = stats['avgMonthly'];
    final avgActivity = stats['avgActivity'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompactStat(
              localizations.totalSpent, "${totalSpent.toStringAsFixed(2)} €"),
          _buildCompactStat(
              localizations.numberOfActivities, activityCount.toString()),
          _buildCompactStat(localizations.averageSpentPerActivity,
              "${avgActivity.toStringAsFixed(2)} €"),
          _buildCompactStat(localizations.averageMonthlySpent,
              "${avgMonthly.toStringAsFixed(2)} €"),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonthlyTotalSpendingChart(data: stats["totalSpendingPerMonth"]),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.025),
        PieChartWidget(dataMap: stats["totalPerActivity"]),
      ],
    );
  }
}
