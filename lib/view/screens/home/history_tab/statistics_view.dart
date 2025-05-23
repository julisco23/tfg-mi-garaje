import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/provider/activity_provider.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/shared/utils/statics.dart';
import 'package:mi_garaje/view/widgets/chart/monthly_total_spending_chart.dart';
import 'package:mi_garaje/view/widgets/chart/pie_chart_widget.dart';
import 'package:provider/provider.dart';

class StatisticsView extends StatefulWidget {
  final GarageProvider garageProvider;
  const StatisticsView({super.key, required this.garageProvider});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  List<Vehicle> vehicles = [];
  Map<String, List<Activity>> vehicleActivities = {};
  Vehicle? selectedVehicle;
  DateTimeRange? selectedDateRange;
  String? selectedActivityType;
  String? selectedSubType;

  late ActivityProvider activityProvider;
  late AuthProvider authProvider;
  late Map<String, dynamic> stats;

  @override
  void initState() {
    super.initState();
    activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    _loadVehicles();
  }

  void _loadVehicles() async {
    final vehicles = widget.garageProvider.vehicles;

    final Map<String, List<Activity>> activitiesMap = {};

    for (var vehicle in vehicles) {
      final acts = await activityProvider.getActivitiesByVehicle(
        vehicle.id!,
        authProvider.id,
        authProvider.type,
      );
      activitiesMap[vehicle.id!] = acts;
    }

    setState(() {
      this.vehicles = vehicles;
      vehicleActivities = activitiesMap;
      stats = Statics.generateStats(vehicleActivities, selectedVehicle?.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVehicleSelector(),
          const SizedBox(height: 16),
          stats['activityCount'] == 0
              ? selectedVehicle == null
                  ? const Center(
                      child: Text(
                          "No tienes actividades en ningun vehículo. Crea una actividad."),
                    )
                  : const Center(
                      child: Text(
                          "No tienes actividades en este vehículo. Crea una actividad."),
                    )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 24),
                    _buildCharts()
                  ],
                )
        ],
      ),
    );
  }

  Widget _buildVehicleSelector() {
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
            "Vehículo:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<Vehicle>(
            style: Theme.of(context).textTheme.bodyMedium,
            value: selectedVehicle,
            items: [
              DropdownMenuItem<Vehicle>(
                value: null,
                child: Text("Todos"),
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

  Widget _buildSummaryCard() {
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
              "Gasto total: ", "${totalSpent.toStringAsFixed(2)} €"),
          _buildCompactStat(
              "Número de actividades: ", activityCount.toString()),
          _buildCompactStat("Gasto medio por actividad: ",
              "${avgActivity.toStringAsFixed(2)} €"),
          _buildCompactStat(
              "Gasto medio mensual: ", "${avgMonthly.toStringAsFixed(2)} €"),
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
        const SizedBox(height: 24),
        PieChartWidget(dataMap: stats["totalPerActivity"]),
      ],
    );
  }
}
