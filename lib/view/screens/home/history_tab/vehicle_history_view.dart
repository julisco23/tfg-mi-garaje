import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/provider/activity_notifier.dart';
import 'package:mi_garaje/view/widgets/cards/activity_card.dart';

class VehicleHistoryView extends ConsumerWidget {
  final Vehicle vehicle;

  const VehicleHistoryView({super.key, required this.vehicle});

  Map<String, List<Activity>> _groupActivitiesByMonth(
      List<Activity> activities, String local) {
    Map<String, List<Activity>> groupedActivities = {};

    for (var activity in activities) {
      String monthYear = DateFormat('MMMM yyyy', local).format(activity.date);

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
  Widget build(BuildContext context, WidgetRef ref) {
    List<Activity> activities = ref.watch(activityProvider).value!.activities;
    final local = Localizations.localeOf(context).languageCode;

    final groupedActivities = _groupActivitiesByMonth(activities, local);

    final List<String> keys = groupedActivities.keys.toList();
    keys.sort((a, b) {
      DateTime dateA = DateFormat('MMMM yyyy', local).parse(a);
      DateTime dateB = DateFormat('MMMM yyyy', local).parse(b);
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
                Column(
                  children: [
                    SizedBox(
                      height: 14,
                    ),
                    // Nodo del mes
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Línea entre mes y primera actividad
                    Container(
                      width: 2,
                      height: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Card del mes
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    monthYear[0].toUpperCase() + monthYear.substring(1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      (activity == monthActivities.last)
                          ? SizedBox()
                          : Container(
                              width: 2,
                              height: 24,
                              color: Theme.of(context).colorScheme.primary,
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
  }
}
