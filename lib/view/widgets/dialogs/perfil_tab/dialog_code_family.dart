import 'package:flutter/material.dart';
import 'package:mi_garaje/data/provider/activity_provider.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:provider/provider.dart';

class DialogFamilyCode extends StatelessWidget {
  const DialogFamilyCode({
    super.key,
  });

  static Future<bool> show(BuildContext context) async {
    return await showDialog(
            context: context, builder: (context) => DialogFamilyCode()) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final AuthProvider authProvider = context.read<AuthProvider>();
    final ActivityProvider activityProvider = context.read<ActivityProvider>();
    final GarageProvider garageViewModel = context.read<GarageProvider>();
    final GlobalTypesViewModel globalTypesViewModel =
        context.read<GlobalTypesViewModel>();
    final NavigatorState navigator = Navigator.of(context);

    return AlertDialog(
      insetPadding: EdgeInsets.all(10),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Unirse", style: Theme.of(context).textTheme.titleLarge),
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
            labelText: "Código de familia",
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
              child: Text("Cancelar",
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () => navigator.pop(false),
            ),
            TextButton(
              child: Text("Aceptar",
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                await authProvider.unirseAFamilia(controller.text);
                await garageViewModel.getVehicles(
                    authProvider.id, authProvider.type);
                await activityProvider.loadActivities(
                    garageViewModel.id, authProvider.id, authProvider.type);
                await globalTypesViewModel.initializeUser(
                    authProvider.id, authProvider.type);

                navigator.pop(true);
              },
            ),
          ],
        ),
      ],
    );
  }
}
