import 'package:flutter/material.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/widgets/text_form_field.dart';
import 'package:mi_garaje/view_model/auth_view_model.dart';

class DialogEditProfile extends StatefulWidget {
  final AuthViewModel viewModel;

  const DialogEditProfile({super.key, required this.viewModel});

  @override
  State<DialogEditProfile> createState() => _DialogEditProfileState();

  static Future<void> show(BuildContext context, AuthViewModel viewModel) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DialogEditProfile(viewModel: viewModel);
      },
    );
  }
}

class _DialogEditProfileState extends State<DialogEditProfile> {
  late TextEditingController nombreController;
  final GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nombreController =
        TextEditingController(text: widget.viewModel.usuario.displayName);
  }

  @override
  void dispose() {
    nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Actualizar perfil',
              style: Theme.of(context).textTheme.titleLarge),
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
            key: profileFormKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              MiTextFormField(
                controller: nombreController,
                labelText: 'Nombre en perfil',
                hintText: 'Mi Garaje',
                validator: (value) {
                  return widget.viewModel.validateName(value);
                },
              ),
              SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
            ])),
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
              child: Text("Guardar",
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () async {
                final formState = profileFormKey.currentState;
                if (formState != null && formState.validate()) {
                  String nuevoNombre = nombreController.text.trim();
                  await widget.viewModel.actualizarProfile(nuevoNombre);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
