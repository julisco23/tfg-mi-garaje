import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/utils/app_localizations_extensions.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:mi_garaje/view/widgets/utils/elevated_button_utils.dart';
import 'package:mi_garaje/data/notifier/auth_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DialogCambioCuenta extends ConsumerStatefulWidget {
  const DialogCambioCuenta({super.key});

  @override
  ConsumerState<DialogCambioCuenta> createState() => _DialogCambioCuentaState();

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogCambioCuenta();
      },
    );
  }
}

class _DialogCambioCuentaState extends ConsumerState<DialogCambioCuenta> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();

  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      insetPadding: EdgeInsets.all(10),
      title: Text(localizations.createAccount,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: profileFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

              // Titulo del dialog
              MiTextFormField(
                controller: nameController,
                labelText: localizations.profileName,
                hintText: 'Mi Garaje',
                validator: (value) {
                  return Validator.validateName(value, localizations);
                },
              ),
              SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

              // Campo de correo electrónico
              MiTextFormField(
                controller: emailController,
                labelText: localizations.email,
                hintText: 'migaraje@gmail.com',
                validator: (value) {
                  return Validator.validateEmail(value, localizations);
                },
              ),
              SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

              // Campo de contraseña
              MiTextFormField(
                controller: passwordController,
                obscureText: obscureText,
                labelText: localizations.password,
                hintText: obscureText ? '******' : localizations.password,
                validator: (value) {
                  return Validator.validatePassword(value, localizations);
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
        SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
        // Botón de crear cuenta
        MiButton(
          text: localizations.createAccount,
          onPressed: () async {
            if (profileFormKey.currentState!.validate()) {
              navigator.pushNamed(RouteNames.loading, arguments: {
                'onInit': () async {
                  try {
                    await ref.read(authProvider.notifier).linkAnonymousAccount(
                        emailController.text,
                        passwordController.text,
                        nameController.text[0].toUpperCase() +
                            nameController.text.substring(1).trim());
                    navigator.pop();
                    navigator.pop();
                  } catch (e) {
                    ToastHelper.show(
                        theme, localizations.getErrorMessage(e.toString()));
                    navigator.pop();
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
