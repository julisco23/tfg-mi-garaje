import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/provider/auth_notifier.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DialogFamilyCode extends ConsumerWidget {
  const DialogFamilyCode({
    super.key,
  });

  static Future<bool> show(BuildContext context) async {
    return await showDialog(
            context: context, builder: (context) => DialogFamilyCode()) ??
        false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final NavigatorState navigator = Navigator.of(context);
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      insetPadding: EdgeInsets.all(10),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(localizations.join,
              style: Theme.of(context).textTheme.titleLarge),
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
            onPressed: () {
              navigator.pop(false);
            },
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: formKey,
          child: MiTextFormField(
            controller: controller,
            labelText: localizations.familyCode,
            hintText: "1234AB",
            validator: Validator.validateFamilyCode,
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
              onPressed: () => navigator.pop(false),
            ),
            TextButton(
              child: Text(localizations.confirm,
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                await ref
                    .read(authProvider.notifier)
                    .unirseAFamilia(controller.text);

                navigator.pop(true);
              },
            ),
          ],
        ),
      ],
    );
  }
}
