import 'package:flutter/material.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/constants/validator.dart';
import 'package:mi_garaje/view/widgets/toastFlutter/fluttertoast.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/view/widgets/elevated_button_utils.dart';
import 'package:mi_garaje/view/widgets/text_form_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool obscureText = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
    
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<AuthViewModel>(context);

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
                        icon: Icon(Icons.circle, color: Colors.transparent), // Icono invisible
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
                        onPressed: () async{
                          String? response = await loginViewModel.signin(
                            "juli@gmail.com",
                            "jjjjjj",
                          );
                          if (context.mounted) {
                            if (response != null) {
                              ToastHelper.show(context, response);
                            } else {
                              Provider.of<GarageProvider>(context, listen: false).initializeUser(loginViewModel.id);
                              await Provider.of<GlobalTypesViewModel>(context, listen: false).initializeUser(loginViewModel.id);
                              Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (route) => false);
                            }
                          }
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
                        obscureText
                            ? Icons.visibility_off
                            : Icons.visibility,
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
                    text: "Iniciar sesión",
                    onPressed: () async {
                      if (loginFormKey.currentState!.validate()) {
                        String? response = await loginViewModel.signin(
                          emailController.text,
                          passwordController.text,
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
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.025),

                  // Olvidar contraseña
                  GestureDetector(
                    onTap: () => ToastHelper.show(context, "Funcionalidad no disponible."),
                    child: Text(
                      "¿Has olvidado la contraseña?",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.13),

                  // Botón de Google
                  MiButton(
                    text: "Inicia sesión con Google",
                    onPressed: () async {
                      String? response = await loginViewModel.signInWithGoogle();

                      if (context.mounted) {
                        if (response != null) {
                          ToastHelper.show(context, response);
                        } else {
                          Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (route) => false);
                        }
                      }
                    },
                    imagen: 'assets/images/google.png',
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.025),

                  // Botón navegación a registro
                  MiButton(
                    text: "Crear cuenta",
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, RouteNames.signup);
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
