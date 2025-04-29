import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String mensaje;

  const ConfirmDialog({super.key, required this.title, required this.mensaje});

  static Future<bool> show(
      BuildContext context, String title, String mensaje) async {
    return await showDialog(
          context: context,
          builder: (context) => ConfirmDialog(title: title, mensaje: mensaje),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.all(10),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mensaje,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              child: Text("Cancelar",
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("Aceptar",
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ],
    );
  }
}
