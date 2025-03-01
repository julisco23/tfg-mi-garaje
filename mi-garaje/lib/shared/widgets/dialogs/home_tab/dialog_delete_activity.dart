import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';

class DeleteActivityDialog extends StatelessWidget {
  final Activity activity;

  const DeleteActivityDialog({
    super.key,
    required this.activity,
  });

  static Future<void> show(BuildContext context, Activity activity) {
    return showDialog(
      context: context,
      builder: (context) => DeleteActivityDialog(activity: activity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          'Eliminar ${activity.getTpye}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      content: const Text(
        '¿Estás seguro de que quieres eliminar la actividad?',
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
            TextButton(
              onPressed: () {
                Provider.of<GarageViewModel>(context, listen: false).deleteActivity(activity);
                Navigator.pop(context);
              },
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }
}
