import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/record.dart';
import 'package:mi_garaje/data/models/repair.dart';
import 'package:mi_garaje/data/models/refuel.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/shared/themes/theme_notifier.dart';
import 'package:mi_garaje/view/home/home_tab_view/dialog_wigdet/dialog_delete_activity.dart';
import 'package:provider/provider.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.carName,
    required this.type,
  });

  final Actividad activity;
  final int type;
  final String carName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        String routeName = "";
        Map<String, dynamic> arguments = {};

        switch (type) {
          case 0:
            routeName = RouteNames.refuel;
            arguments = {
              "refuel": activity as Refuel,
              "carName": carName
            };
            break;
          case 1:
            routeName = RouteNames.repair;
            arguments = {
              "repair": activity as Repair,
              "carName": carName
            };
            break;
          case 2:
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

              // Ícono representando el tipo de actividad
              CircleAvatar(
                backgroundColor:
                    context.read<ThemeNotifier>().currentTheme.primaryColor,
                child: Builder(
                  builder: (context) {
                    IconData? icon;
                    switch (type) {
                      case 0:
                        icon = Icons.local_gas_station_rounded;
                        break;
                      case 1:
                        icon = Icons.build_rounded;
                        break;
                      case 2:
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

              // Precio de la actividad (si lo hay)
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
