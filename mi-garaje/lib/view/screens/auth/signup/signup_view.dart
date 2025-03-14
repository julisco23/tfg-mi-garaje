import 'package:flutter/material.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/constants/validator.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/view/widgets/utils/elevated_button_utils.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';

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
    final loginViewModel = Provider.of<AuthViewModel>(context);

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
                    child: Text('Bienvenido a Mi Garaje',
                    style: Theme.of(context).textTheme.titleLarge),
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
                  Image.asset('assets/images/logo.png', width: 100),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

                  // Campo de nombre de perfil
                  MiTextFormField(
                    controller: nameController,
                    labelText: 'Nombre en perfil',
                    hintText: 'Mi Garaje',
                    validator: (value) {
                      return Validator.validateName(value);
                    },
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.025),

                  // Campo de correo electrónico
                  MiTextFormField(
                    controller: emailController,
                    labelText: 'Correo electrónico',
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
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.025),

                  // Botón de registro
                  MiButton(
                    text: "Registarse",
                    onPressed: () async {
                      if (signupFormKey.currentState!
                          .validate()) {
                        String? response = await loginViewModel.signup(
                          emailController.text,
                          passwordController.text,
                          nameController.text,
                        );
                        if (context.mounted) {
                          if (response != null) {
                            ToastHelper.show(context, response);
                          } else {
                            await Provider.of<GlobalTypesViewModel>(context, listen: false).initializeUser(loginViewModel.id);
                            Provider.of<GarageProvider>(context, listen: false).initializeUser(loginViewModel.id);
                            Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (route) => false);
                          }
                        }
                      }
                    },
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.08),

                  // Botón de invitado
                  MiButton(
                    text: "Continuar como invitado",
                    onPressed: () async {
                      String? message = await loginViewModel.signInAnonymously();

                      if (context.mounted) {
                        if (message != null) {
                          ToastHelper.show(context, message);
                        } else {
                          await Provider.of<GlobalTypesViewModel>(context, listen: false).initializeUser(loginViewModel.id);
                          Provider.of<GarageProvider>(context, listen: false).initializeUser(loginViewModel.id);
                          Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (route) => false);
                        }
                      }
                    },
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.025),

                  // Botón de Google
                  MiButton(
                    text: "Crear cuenta con Google",
                    onPressed: () async {
                      String? response = await loginViewModel.signupWithGoogle();

                      if (context.mounted) {
                        if (response != null) {
                          ToastHelper.show(context, response);
                        } else if (mounted) {
                          await Provider.of<GlobalTypesViewModel>(context, listen: false).initializeUser(loginViewModel.id);
                          Provider.of<GarageProvider>(context, listen: false).initializeUser(loginViewModel.id);
                          Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (route) => false);
                        }
                      }
                    },
                    imagen: 'assets/images/google.png',
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.025),

                  // Botón de navegación a login
                  MiButton(
                    text: "Ya tengo cuenta",
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, RouteNames.login);
                    },
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  )
                ],
              ),
            ),
          )
        )
      )
    );
  }
}
