import 'package:flutter/material.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    TextEditingController controller = TextEditingController(text: initialName);

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return AlertDialog(
      insetPadding: EdgeInsets.all(10),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(localizations.changeName, style: Theme.of(context).textTheme.titleLarge),
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: formKey,
          child: MiTextFormField(
            controller: controller,
            labelText: localizations.editType,
            hintText: localizations.newType,
            validator: Validator.validateNameType,
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              child: Text(localizations.cancel,
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(localizations.confirm,
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                onNameChanged(controller.text[0].toUpperCase() +
                    controller.text.substring(1).trim());
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }
}
