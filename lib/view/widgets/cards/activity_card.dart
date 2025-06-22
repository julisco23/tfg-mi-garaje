import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/notifier/activity_notifier.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/utils/app_localizations_extensions.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_confirm.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ActivityCard extends ConsumerWidget {
  const ActivityCard({
    super.key,
    required this.activity,
  });

  final Activity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, RouteNames.activity,
            arguments: {"activity": activity});
      },
      onLongPress: () async {
        final result = await ConfirmDialog.show(
            context,
            localizations.deleteType(
                localizations.getSubType(activity.getType, isSingular: true)),
            localizations.confirmDeleteActivity);
        if (!result) return;
        try {
          await ref.read(activityProvider.notifier).deleteActivity(activity);
        } catch (e) {
          ToastHelper.show(theme, localizations.getErrorMessage(e.toString()));
          return;
        }
        ToastHelper.show(
            theme, localizations.activityDeleted(activity.getCustomType));
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
