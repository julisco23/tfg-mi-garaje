import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/record.dart';
import 'package:mi_garaje/data/models/repair.dart';
import 'package:mi_garaje/data/models/refuel.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/shared/themes/theme_notifier.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_delete_activity.dart';
import 'package:provider/provider.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.carName,
  });

  final Activity activity;
  final String carName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        String routeName;
        Map<String, dynamic> arguments;

        switch (activity.activityType) {
          case ActivityType.refuel:
            routeName = RouteNames.refuel;
            arguments = {
              "refuel": activity as Refuel,
              "carName": carName
            };
            break;
          case ActivityType.repair:
            routeName = RouteNames.repair;
            arguments = {
              "repair": activity as Repair,
              "carName": carName
            };
            break;
          case ActivityType.record:
            routeName = RouteNames.record;
            arguments = {
              "record": activity as Record,
              "carName": carName
            };
            break;
        }

        Navigator.pushNamed(context, routeName, arguments: arguments);
      },
      onLongPress: () {
        DeleteActivityDialog.show(context, activity);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: AppDimensions.screenWidth(context) * 0.01),

              // Ícono del tipo de actividad
              CircleAvatar(
                backgroundColor: context.read<ThemeNotifier>().currentTheme.primaryColor,
                child: Builder(
                  builder: (context) {
                    IconData? icon;
                    switch (activity.activityType) {
                      case ActivityType.refuel:
                        icon = Icons.local_gas_station_rounded;
                        break;
                      case ActivityType.repair:
                        icon = Icons.build_rounded;
                        break;
                      case ActivityType.record:
                        icon = Icons.description_rounded;
                        break;
                    }
                    return Icon(
                      icon,
                      color: context.read<ThemeNotifier>().currentTheme.colorScheme.onPrimary,
                      size: AppDimensions.screenWidth(context) * 0.06,
                    );
                  },
                ),
              ),
              SizedBox(width: AppDimensions.screenWidth(context) * 0.05),

              // Información de la actividad
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.getTpye),
                    SizedBox(height: AppDimensions.screenHeight(context) * 0.005),
                    Text(
                      DateFormat('dd/MM/yyyy').format(activity.date),
                      style: context.read<ThemeNotifier>().currentTheme.textTheme.labelSmall,
                    )
                  ],
                ),
              ),

              // Precio de la actividad
              Text(
                activity.isCost ? '${activity.getCost}€' : '',
                style: context.read<ThemeNotifier>().currentTheme.textTheme.labelMedium,
              ),
              SizedBox(width: AppDimensions.screenWidth(context) * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
