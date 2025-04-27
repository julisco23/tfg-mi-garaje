import 'package:flutter/material.dart';
import 'package:mi_garaje/shared/constants/validator.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';

class EditTypeDialog extends StatelessWidget {
  final String initialName;
  final ValueChanged<String> onNameChanged;

  const EditTypeDialog({
    super.key,
    required this.initialName,
    required this.onNameChanged,
  });

  static Future<bool> show(BuildContext context, String title,
      ValueChanged<String> onNameChanged) async {
    return await showDialog(
            context: context,
            builder: (context) => EditTypeDialog(
                initialName: title, onNameChanged: onNameChanged)) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: initialName);

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: const Text("Cambiar nombre del tipo"),
      content: Form(
        key: formKey,
        child: MiTextFormField(
          controller: controller,
          labelText: "Editar tipo",
          hintText: "Nuevo tipo",
          validator: (value) {
            return Validator.validateNameType(value);
          },
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              child: Text("Cancelar",
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Aceptar",
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                onNameChanged(controller.text);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }
}
