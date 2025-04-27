import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/provider/activity_provider.dart';
import 'package:mi_garaje/view/widgets/cards/activity_card.dart';
import 'package:provider/provider.dart';

class VehicleHistoryList extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleHistoryList({super.key, required this.vehicle});

  Map<String, List<Activity>> _groupActivitiesByMonth(
      List<Activity> activities) {
    Map<String, List<Activity>> groupedActivities = {};

    for (var activity in activities) {
      String monthYear = DateFormat('MMMM yyyy').format(activity.date);

      if (groupedActivities.containsKey(monthYear)) {
        groupedActivities[monthYear]!.add(activity);
      } else {
        groupedActivities[monthYear] = [activity];
      }
    }

    groupedActivities.forEach((key, value) {
      value.sort((a, b) => b.date.compareTo(a.date));
    });

    return groupedActivities;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, _) {
        List<Activity> activities = activityProvider.activities;

        final groupedActivities = _groupActivitiesByMonth(activities);

        final List<String> keys = groupedActivities.keys.toList();
        keys.sort((a, b) {
          DateTime dateA = DateFormat('MMMM yyyy').parse(a);
          DateTime dateB = DateFormat('MMMM yyyy').parse(b);
          return dateB.compareTo(dateA);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: keys.length,
          itemBuilder: (context, index) {
            String monthYear = keys[index];
            List<Activity> monthActivities = groupedActivities[monthYear]!;

            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Línea continua vertical + nodos
                    Column(
                      children: [
                        // Nodo del mes
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Línea entre mes y primera actividad
                        Container(
                          width: 2,
                          height: 22,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Card del mes
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        monthYear,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                // Ahora las actividades
                ...monthActivities.map((activity) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nodo de actividad
                      Column(
                        children: [
                          Container(
                            width: 2,
                            height: 30,
                            color: Colors.grey.shade300,
                          ),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.blueAccent, width: 2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 23,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Card de la actividad
                      Expanded(
                        child: ActivityCard(
                          activity: activity,
                          carName: vehicle.getNameTittle(),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 10),
              ],
            );
          },
        );
      },
    );
  }
}
