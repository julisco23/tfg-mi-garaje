import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/fuel.dart';
import 'package:mi_garaje/data/provider/activity_provider.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/image_cache_provider.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/exceptions/garage_exception.dart';
import 'package:mi_garaje/utils/app_localizations_extensions.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_add_activity.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_confirm.dart';
import 'package:mi_garaje/view/widgets/utils/elevated_button_utils.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ActivityView extends StatefulWidget {
  final Activity activity;

  const ActivityView({super.key, required this.activity});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  late Activity activity;

  @override
  void initState() {
    super.initState();
    activity = widget.activity;
  }

  @override
  Widget build(BuildContext context) {
    final ActivityProvider activityProvider = context.read<ActivityProvider>();
    final AuthProvider authProvider = context.read<AuthProvider>();
    final GarageProvider garageProvider = context.read<GarageProvider>();
    final ImageCacheProvider imageCacheProvider =
        context.read<ImageCacheProvider>();
    final NavigatorState navigator = Navigator.of(context);
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.getSubType(activity.getType)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final bool result = await ConfirmDialog.show(
                  context,
                  '${localizations.delete} ${activity.getType}',
                  localizations.confirmDeleteActivity);

              if (!result) return;

              try {
                await activityProvider.deleteActivity(garageProvider.id,
                    authProvider.id, authProvider.type, activity);
              } on GarageException catch (e) {
                ToastHelper.show(e.message);
                return;
              }

              navigator.pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fecha
                  ListTile(
                    title: Text(localizations.date),
                    subtitle:
                        Text(DateFormat('dd/MM/yyyy').format(activity.date)),
                  ),

                  // Coste
                  if (activity.getCost != null) ...[
                    ListTile(
                      title: Text(localizations.cost),
                      subtitle: Text('${activity.getCost} €'),
                    ),
                  ],

                  if (activity is Fuel) ...[
                    ListTile(
                      title: Text(localizations.pricePerLiter),
                      subtitle: Text('${(activity as Fuel).getPrecioLitros} €'),
                    ),
                    ListTile(
                      title: Text(localizations.liters),
                      subtitle: Text(
                          '${(activity as Fuel).getLiters.toStringAsFixed(3)} L'),
                    ),
                  ],

                  // Detalles
                  if (activity.getDetails != null &&
                      activity.getDetails!.isNotEmpty) ...[
                    ListTile(
                      title: Text(localizations.detail),
                      subtitle: Text(activity.getDetails!),
                    ),
                  ],

                  // Foto
                  if (activity.isPhoto) ...[
                    ListTile(
                      title: Text(localizations.image),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image(
                                      image: imageCacheProvider.getImage(
                                          "activity",
                                          activity.getDate.toIso8601String(),
                                          activity.getPhoto!)),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image(
                              image: imageCacheProvider.getImage(
                                  "activity",
                                  activity.getDate.toIso8601String(),
                                  activity.getPhoto!)),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.05),

                  // Botón de edición
                  MiButton(
                      text: localizations.edit,
                      onPressed: () async {
                        await DialogAddActivity.show(
                          context,
                          activity: activity,
                          onActivityUpdated: (updatedActivity) {
                            setState(() {
                              activity = updatedActivity;
                            });
                          },
                        );
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
