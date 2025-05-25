import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/provider/activity_provider.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/exceptions/garage_exception.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/utils/app_localizations_extensions.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_confirm.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final ActivityProvider activityProvider = context.read<ActivityProvider>();
    final GarageProvider garageProvider = context.read<GarageProvider>();
    final AuthProvider authProvider = context.read<AuthProvider>();
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, RouteNames.activity,
            arguments: {"activity": activity});
      },
      onLongPress: () async {
        final result = await ConfirmDialog.show(
            context,
            '${localizations.delete} ${activity.getType}',
            localizations.confirmDeleteActivity);
        if (!result) return;
        try {
          await activityProvider.deleteActivity(
              garageProvider.id, authProvider.id, authProvider.type, activity);
        } on GarageException catch (e) {
          ToastHelper.show(e.message);
          return;
        }
        ToastHelper.show(localizations.activityDeleted(activity.getCustomType));
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
                backgroundColor: Theme.of(context).primaryColor,
                child: Builder(
                  builder: (context) {
                    IconData? icon;
                    switch (activity.activityType) {
                      case ActivityType.fuel:
                        icon = Icons.local_gas_station_rounded;
                        break;
                      case ActivityType.repair:
                        icon = Icons.build_rounded;
                        break;
                      case ActivityType.record:
                        icon = Icons.description_rounded;
                        break;
                      case ActivityType.custom:
                        icon = Icons.star_rounded;
                        break;
                    }
                    return Icon(
                      icon,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 30,
                    );
                  },
                ),
              ),
              SizedBox(width: AppDimensions.screenWidth(context) * 0.04),

              // Información de la actividad
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localizations.getSubType(activity.getType)),
                    SizedBox(
                        height: AppDimensions.screenHeight(context) * 0.005),
                    Text(
                      DateFormat('dd/MM/yyyy').format(activity.date),
                      style: Theme.of(context).textTheme.labelSmall,
                    )
                  ],
                ),
              ),

              // Precio de la actividad
              if (activity.isCost)
                Text(
                  '${activity.getCost}€',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              SizedBox(width: AppDimensions.screenWidth(context) * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
