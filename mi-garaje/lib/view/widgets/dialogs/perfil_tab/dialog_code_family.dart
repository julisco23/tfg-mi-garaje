import 'package:flutter/material.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/shared/constants/validator.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:provider/provider.dart';

class DialogFamilyCode extends StatelessWidget {
  const DialogFamilyCode({
    super.key,
  });

  static Future<String?> show(BuildContext context) async {
    return await showDialog(
            context: context, builder: (context) => DialogFamilyCode());
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Únete a una familia",
                style: Theme.of(context).textTheme.titleLarge),
            IconButton(
              icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: MiTextFormField(
            controller: controller,
            labelText: "Código de familia",
            hintText: "1234AB",
            validator: (value) {
              return Validator.validateFamilyCode(value);
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
                onPressed: () => Navigator.pop(context, null),
              ),
              TextButton(
                child: Text("Aceptar",
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  Provider.of<AuthViewModel>(context, listen: false)
                      .unirseAFamilia(controller.text);
                  Navigator.pop(context, controller.text);
                },
              ),
            ],
          ),
        ],
      );
  }
}
