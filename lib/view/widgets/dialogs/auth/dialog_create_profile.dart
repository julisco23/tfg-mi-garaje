import 'package:flutter/material.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/constants/validator.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:mi_garaje/view/widgets/utils/elevated_button_utils.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class DialogCambioCuenta extends StatefulWidget {
  const DialogCambioCuenta({super.key});

  @override
  State<DialogCambioCuenta> createState() => _DialogCambioCuentaState();

  static Future<void> show(
      BuildContext context, AuthProvider authViewModel) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogCambioCuenta();
      },
    );
  }
}

class _DialogCambioCuentaState extends State<DialogCambioCuenta> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();

  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.read<AuthProvider>();
    final NavigatorState navigator = Navigator.of(context);

    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Crear cuenta', style: Theme.of(context).textTheme.titleLarge),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titulo del dialog
              MiTextFormField(
                controller: nameController,
                labelText: 'Nombre en perfil',
                hintText: 'Mi Garaje',
                validator: (value) {
                  return Validator.validateName(value);
                },
              ),
              SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

              // Campo de correo electrónico
              MiTextFormField(
                controller: emailController,
                labelText: 'Correo electrónico',
                hintText: 'migaraje@gmail.com',
                validator: (value) {
                  return Validator.validateEmail(value);
                },
              ),
              SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

              // Campo de contraseña
              MiTextFormField(
                controller: passwordController,
                obscureText: obscureText,
                labelText: 'Contraseña',
                hintText: obscureText ? '******' : 'Contraseña',
                validator: (value) {
                  return Validator.validatePassword(value);
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Botón de crear cuenta
        MiButton(
          text: "Crear cuenta",
          onPressed: () async {
            if (profileFormKey.currentState!.validate()) {
              navigator.pushNamed(RouteNames.loading, arguments: {
                'onInit': () async {
                  String? response = await authProvider.crearCuenta(
                      emailController.text,
                      passwordController.text,
                      nameController.text[0].toUpperCase() +
                          nameController.text.substring(1).trim());
                  if (response != null) {
                    ToastHelper.show(response);
                  } else {
                    navigator.pushNamedAndRemoveUntil(
                        RouteNames.home, (route) => false);
                  }
                }
              });
            }
          },
        ),
      ],
    );
  }
}
