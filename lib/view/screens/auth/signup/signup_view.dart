import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/utils/app_localizations_extensions.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/view/widgets/utils/elevated_button_utils.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:mi_garaje/data/provider/auth_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupView extends ConsumerStatefulWidget {
  const SignupView({super.key});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
                    Image.asset('assets/images/logo.png',
                        height: AppDimensions.screenHeight(context) * 0.2),

                    // Campo de nombre de perfil
                    MiTextFormField(
                      controller: nameController,
                      labelText: localizations.profileName,
                      hintText: localizations.myGarage,
                      validator: (value) {
                        return Validator.validateName(value, localizations);
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
                        return Validator.validateEmail(value, localizations);
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
                    SizedBox(
                        height: AppDimensions.screenHeight(context) * 0.025),

                    // Botón de registro
                    MiButton(
                      text: localizations.register,
                      onPressed: () async {
                        if (signupFormKey.currentState!.validate()) {
                          navigator.pushNamed(RouteNames.loading, arguments: {
                            'onInit': () async {
                              try {
                                await ref.read(authProvider.notifier).signup(
                                      emailController.text,
                                      passwordController.text,
                                      nameController.text[0].toUpperCase() +
                                          nameController.text
                                              .substring(1)
                                              .trim(),
                                    );

                                navigator.pushNamedAndRemoveUntil(
                                    RouteNames.home, (route) => false);
                              } catch (e) {
                                ToastHelper.show(
                                    theme,
                                    localizations
                                        .getErrorMessage(e.toString()));
                                navigator.pop();
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
                            try {
                              await ref
                                  .read(authProvider.notifier)
                                  .signupAnonymously();

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
                    ),
                    SizedBox(
                        height: AppDimensions.screenHeight(context) * 0.025),

                    // Botón de Google
                    MiButton(
                      text: localizations.createAccountWithGoogle,
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
