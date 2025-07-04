import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/utils/app_localizations_extensions.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:mi_garaje/data/notifier/auth_notifier.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/view/widgets/utils/elevated_button_utils.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  bool obscureText = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Form(
              key: loginFormKey,
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Mi Garaje',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),

                  Image.asset('assets/images/logo.png',
                      height: AppDimensions.screenHeight(context) * 0.2),

                  // Campo de correo electrónico
                  MiTextFormField(
                    controller: emailController,
                    labelText: localizations.email,
                    hintText: 'migaraje@gmail.com',
                    validator: (value) {
                      return Validator.validateEmail(value, localizations);
                    },
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.025),

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
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.025),

                  // Botón de inicio de sesión
                  MiButton(
                    text: localizations.signIn,
                    onPressed: () async {
                      if (loginFormKey.currentState!.validate()) {
                        navigator.pushNamed(RouteNames.loading, arguments: {
                          'onInit': () async {
                            try {
                              await ref.read(authProvider.notifier).signin(
                                    emailController.text,
                                    passwordController.text,
                                  );

                              navigator.pushNamedAndRemoveUntil(
                                  RouteNames.home, (route) => false);
                            } catch (e) {
                              ToastHelper.show(theme,
                                  localizations.getErrorMessage(e.toString()));
                              navigator.pop();
                            }
                          }
                        });
                      }
                    },
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.15),

                  // Botón de Google
                  MiButton(
                    text: localizations.signInWithGoogle,
                    onPressed: () async {
                      navigator.pushNamed(RouteNames.loading, arguments: {
                        'onInit': () async {
                          try {
                            await ref
                                .read(authProvider.notifier)
                                .signInWithGoogle();

                            navigator.pushNamedAndRemoveUntil(
                                RouteNames.home, (route) => false);
                          } catch (e) {
                            ToastHelper.show(theme,
                                localizations.getErrorMessage(e.toString()));
                            navigator.pop();
                          }
                        }
                      });
                    },
                    imagen: 'assets/images/google.png',
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.025),

                  // Botón navegación a registro
                  MiButton(
                    text: localizations.createAccount,
                    onPressed: () {
                      navigator.pushReplacementNamed(RouteNames.signup);
                    },
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
