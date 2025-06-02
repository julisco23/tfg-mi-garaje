import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:mi_garaje/data/provider/auth_notifier.dart';
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
                  /*// Título de la pantalla
                  Center(
                    child: Text(
                      'Mi Garaje',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),*/
                  // Título de la pantalla con botón de inicio de sesión
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.circle,
                            color: Colors.transparent), // Icono invisible
                        onPressed: null,
                        enableFeedback: false,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Mi Garaje',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.login),
                        onPressed: () async {
                          navigator.pushNamed(RouteNames.loading, arguments: {
                            'onInit': () async {
                              String? response = await ref
                                  .read(authProvider.notifier)
                                  .signin("juli@gmail.com", "jjjjjj");
                              if (response != null) {
                                ToastHelper.show(response);
                                navigator.pop();
                              } else {
                                navigator.pushNamedAndRemoveUntil(
                                    RouteNames.home, (route) => false);
                              }
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),
                  Image.asset('assets/images/logo.png', width: 150),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                  // Campo de correo electrónico
                  MiTextFormField(
                    controller: emailController,
                    labelText: localizations.email,
                    hintText: 'migaraje@gmail.com',
                    validator: (value) {
                      return Validator.validateEmail(value);
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
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.025),

                  // Botón de inicio de sesión
                  MiButton(
                    text: localizations.signIn,
                    onPressed: () async {
                      if (loginFormKey.currentState!.validate()) {
                        navigator.pushNamed(RouteNames.loading, arguments: {
                          'onInit': () async {
                            String? response = await ref
                                .read(authProvider.notifier)
                                .signin(emailController.text,
                                    passwordController.text);
                            if (response != null) {
                              ToastHelper.show(response);
                              navigator.pop();
                            } else {
                              navigator.pushNamedAndRemoveUntil(
                                  RouteNames.home, (route) => false);
                            }
                          }
                        });
                      }
                    },
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.025),

                  // Olvidar contraseña
                  GestureDetector(
                    onTap: () => ToastHelper.show(
                        localizations.functionalityNotAvailable),
                    child: Text(
                      localizations.forgotPassword,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.13),

                  // Botón de Google
                  MiButton(
                    text: localizations.signInWithGoogle,
                    onPressed: () async {
                      navigator.pushNamed(RouteNames.loading, arguments: {
                        'onInit': () async {
                          String? response = await ref
                              .read(authProvider.notifier)
                              .signInWithGoogle();

                          if (response != null) {
                            ToastHelper.show(response);
                          } else {
                            navigator.pushNamedAndRemoveUntil(
                                RouteNames.home, (route) => false);
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
