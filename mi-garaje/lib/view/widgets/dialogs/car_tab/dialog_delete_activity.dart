import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/activity.dart';

class DeleteActivityDialog extends StatelessWidget {
  final Activity activity;

  const DeleteActivityDialog({
    super.key,
    required this.activity,
  });

  static Future<bool> show(BuildContext context, Activity activity) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => DeleteActivityDialog(activity: activity),
    ) ??
    false;
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
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar', style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }
}
