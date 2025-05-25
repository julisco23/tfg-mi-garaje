import 'package:flutter/material.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/view/widgets/utils/elevated_button_utils.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    final AuthProvider loginViewModel = Provider.of<AuthProvider>(context);
    final NavigatorState navigator = Navigator.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: SafeArea(
                child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Form(
                key: signupFormKey,
                child: Column(
                  children: [
                    // Título de la pantalla
                    Center(
                      child: Text(localizations.welcomeTitle,
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    SizedBox(
                        height: AppDimensions.screenHeight(context) * 0.02),
                    Image.asset('assets/images/logo.png', width: 100),
                    SizedBox(
                        height: AppDimensions.screenHeight(context) * 0.02),

                    // Campo de nombre de perfil
                    MiTextFormField(
                      controller: nameController,
                      labelText: localizations.profileName,
                      hintText: localizations.myGarage,
                      validator: (value) {
                        return Validator.validateName(value);
                      },
                    ),
                    SizedBox(
                        height: AppDimensions.screenHeight(context) * 0.025),

                    // Campo de correo electrónico
                    MiTextFormField(
                      controller: emailController,
                      labelText: localizations.email,
                      hintText: 'migaraje@gmail.com',
                      validator: (value) {
                        return Validator.validateEmail(value);
                      },
                    ),
                    SizedBox(
                        height: AppDimensions.screenHeight(context) * 0.025),

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
                    SizedBox(
                        height: AppDimensions.screenHeight(context) * 0.025),

                    // Botón de registro
                    MiButton(
                      text: localizations.register,
                      onPressed: () async {
                        if (signupFormKey.currentState!.validate()) {
                          navigator.pushNamed(RouteNames.loading, arguments: {
                            'onInit': () async {
                              String? response = await loginViewModel.signup(
                                emailController.text,
                                passwordController.text,
                                nameController.text[0].toUpperCase() +
                                    nameController.text.substring(1).trim(),
                              );
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
                    SizedBox(
                        height: AppDimensions.screenHeight(context) * 0.08),

                    // Botón de invitado
                    MiButton(
                      text: localizations.continueAsGuest,
                      onPressed: () async {
                        navigator.pushNamed(RouteNames.loading, arguments: {
                          'onInit': () async {
                            String? message =
                                await loginViewModel.signInAnonymously();

                            if (message != null) {
                              ToastHelper.show(message);
                            } else {
                              navigator.pushNamedAndRemoveUntil(
                                  RouteNames.home, (route) => false);
                            }
                          }
                        });
                      },
                    ),
                    SizedBox(
                        height: AppDimensions.screenHeight(context) * 0.025),

                    // Botón de Google
                    MiButton(
                      text: localizations.createAccountWithGoogle,
                      onPressed: () async {
                        navigator.pushNamed(RouteNames.loading, arguments: {
                          'onInit': () async {
                            String? response =
                                await loginViewModel.signupWithGoogle();

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
                    SizedBox(
                        height: AppDimensions.screenHeight(context) * 0.025),

                    // Botón de navegación a login
                    MiButton(
                      text: localizations.alreadyHaveAccount,
                      onPressed: () {
                        navigator.pushReplacementNamed(RouteNames.login);
                      },
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    )
                  ],
                ),
              ),
            ))));
  }
}
