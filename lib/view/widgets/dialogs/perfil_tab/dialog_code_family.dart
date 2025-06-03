import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/provider/auth_notifier.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DialogFamilyCode extends ConsumerWidget {
  final Function(Vehicle?)? onVehicleChanged;

  const DialogFamilyCode({super.key, this.onVehicleChanged});

  static Future<void> show(
    BuildContext context, [
    Function(Vehicle?)? onVehicleChanged,
  ]) async {
    return await showDialog<void>(
      context: context,
      builder: (context) => DialogFamilyCode(
        onVehicleChanged: onVehicleChanged,
      ),
    );
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
              navigator.pop();
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
              onPressed: () => navigator.pop(),
            ),
            TextButton(
              child: Text(localizations.confirm,
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  navigator.pushNamed(RouteNames.loading, arguments: {
                    'onInit': () async {
                      try {
                        await ref
                            .read(authProvider.notifier)
                            .joinFamily(controller.text);

                        if (onVehicleChanged != null) {
                          onVehicleChanged!(null);
                        }

                        navigator.pop();
                        navigator.pop();
                      } catch (e) {
                        ToastHelper.show(
                            e.toString().replaceAll('Exception: ', ''));
                        navigator.pop();
                      }
                    }
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
