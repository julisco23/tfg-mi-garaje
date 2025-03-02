import 'package:flutter/material.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/constants/validator.dart';
import 'package:mi_garaje/shared/widgets/fluttertoast.dart';
import 'package:mi_garaje/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/shared/widgets/elevated_button_utils.dart';
import 'package:mi_garaje/shared/widgets/text_form_field.dart';

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
                  // Título de la pantalla
                  Center(
                    child: Text(
                      'Mi Garaje',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
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
                            Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (route) => false);
                          }
                        }
                      }
                    },
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.025),

                  // Olvidar contraseña
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        content: Text("Funcionalidad no implementada"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("Cerrar"),
                          ),
                        ],
                      ),
                    ),
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
