import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/refuel.dart';
import 'package:mi_garaje/data/provider/activity_provider.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/image_cache_provider.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_delete_activity.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_add_activity.dart';
import 'package:mi_garaje/view/widgets/utils/elevated_button_utils.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';

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
    final ActivityProvider activityProvider = Provider.of<ActivityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(activity.getType),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async{
              bool result = await DeleteActivityDialog.show(context, activity);

              if (result && context.mounted) {
                activityProvider.deleteActivity(
                  context.read<GarageProvider>().id,
                  context.read<AuthProvider>().id,
                  context.read<AuthProvider>().type,
                  activity,
                );
                Navigator.pop(context);
              }
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
                    title: Text('Fecha'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(activity.date)),
                  ),

                  // Coste
                  if (activity.getCost != null) ...[
                    ListTile(
                      title: Text('Coste'),
                      subtitle: Text('${activity.getCost} €'),
                    ),
                  ],

                  if (activity is Refuel) ...[
                    ListTile(
                      title: Text('Precio por litro'),
                      subtitle: Text('${(activity as Refuel).getPrecioLitros} €'),
                    ),
                    ListTile(
                      title: Text('Litros'),
                      subtitle: Text('${(activity as Refuel).getLiters.toStringAsFixed(3)} L'),
                    ),
                  ],

                  // Detalles
                  if (activity.getDetails != null &&
                      activity.getDetails!.isNotEmpty) ...[
                    ListTile(
                      title: Text('Descripción'),
                      subtitle: Text(activity.getDetails!),
                    ),
                  ],

                  // Foto
                  if (activity.isPhoto) ...[
                    ListTile(
                      title: Text('Imagen'),
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
                                  Image(image: Provider.of<ImageCacheProvider>(context).getImage("activity", activity.getDate.toIso8601String(), activity.getPhoto!)),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image(image: Provider.of<ImageCacheProvider>(context).getImage("activity", activity.getDate.toIso8601String(), activity.getPhoto!)),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.05),

                  // Botón de edición
                  MiButton(
                    text: "Editar",
                    onPressed: () {
                      DialogAddActivity.show(
                        context,
                        activity: activity,
                        onActivityUpdated: (updatedActivity) {
                          setState(() {
                            activity = updatedActivity;
                          });
                        },
                      );
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
