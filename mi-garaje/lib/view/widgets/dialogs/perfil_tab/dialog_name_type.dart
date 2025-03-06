import 'package:flutter/material.dart';

class EditTypeDialog extends StatelessWidget {
  final String initialName;
  final ValueChanged<String> onNameChanged;

  const EditTypeDialog({
    super.key,
    required this.initialName,
    required this.onNameChanged,
  });

  static Future<bool> show(BuildContext context, String title, ValueChanged<String> onNameChanged) async {
    return await showDialog(
          context: context,
          builder: (context) => EditTypeDialog(initialName: title, onNameChanged: onNameChanged)
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: initialName);

    return AlertDialog(
      title: const Text("Editar nombre"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: "Nuevo nombre"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            onNameChanged(controller.text);
            Navigator.pop(context);
          },
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}
