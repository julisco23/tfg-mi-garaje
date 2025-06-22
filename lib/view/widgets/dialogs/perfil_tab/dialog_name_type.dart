import 'package:flutter/material.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditTypeDialog extends StatefulWidget {
  final String initialName;
  final ValueChanged<String> onNameChanged;

  const EditTypeDialog({
    super.key,
    required this.initialName,
    required this.onNameChanged,
  });

  static Future<bool> show(
    BuildContext context,
    String title,
    ValueChanged<String> onNameChanged,
  ) async {
    return await showDialog(
          context: context,
          builder: (context) => EditTypeDialog(
            initialName: title,
            onNameChanged: onNameChanged,
          ),
        ) ??
        false;
  }

  @override
  State<EditTypeDialog> createState() => _EditTypeDialogState();
}

class _EditTypeDialogState extends State<EditTypeDialog> {
  late TextEditingController controller;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      title: Text(
        localizations.changeName,
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: Form(
            key: formKey,
            child: MiTextFormField(
              controller: controller,
              labelText: localizations.editType,
              hintText: localizations.newType,
              validator: (value) =>
                  Validator.validateNameType(value, localizations),
            ),
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                localizations.cancel,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                widget.onNameChanged(
                  controller.text[0].toUpperCase() +
                      controller.text.substring(1).trim(),
                );
                Navigator.pop(context);
              },
              child: Text(
                localizations.confirm,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
