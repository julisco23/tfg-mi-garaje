import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final loginViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Form(
              key: loginViewModel.loginFormKey,
              child: Column(
                children: [
                  // Título de la pantalla
                  Center(
                    child: Text(
                      'Mi Garaje',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Image.asset('assets/images/logo.png', width: 150),
                  SizedBox(height: screenHeight * 0.03),

                  // Campo de correo electrónico
                  MiTextFormField(
                    controller: loginViewModel.emailController,
                    labelText: 'Correo electrónico',
                    hintText: 'migaraje@gmail.com',
                    validator: (value) {
                      return loginViewModel.validateEmail(value);
                    },
                  ),
                  SizedBox(height: 20),

                  // Campo de contraseña
                  MiTextFormField(
                    controller: loginViewModel.passwordController,
                    obscureText: loginViewModel.obscureText,
                    labelText: 'Contraseña',
                    hintText: loginViewModel.obscureText ? '******' : 'Contraseña',
                    validator: (value) {
                      return loginViewModel.validatePassword(value);
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        loginViewModel.obscureText
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => loginViewModel.togglePasswordVisibility(),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),

                  // Botón de inicio de sesión
                  MiButton(
                    text: "Iniciar sesión",
                    onPressed: () async {
                      if (loginViewModel.loginFormKey.currentState!.validate()) {
                        String? response = await loginViewModel.signin(
                          loginViewModel.emailController.text,
                          loginViewModel.passwordController.text,
                        );

                        if (response != null) {
                          Fluttertoast.showToast(
                            msg: response,
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.SNACKBAR,
                            backgroundColor: Theme.of(context).primaryColor,
                          );
                        } else if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (route) => false);
                        }
                      }
                    },
                  ),
                  SizedBox(height: screenHeight * 0.025),

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
                  SizedBox(height: screenHeight * 0.13),

                  // Botón de Google
                  MiButton(
                    text: "Inicia sesión con Google",
                    onPressed: () async {
                      String? response = await loginViewModel.signInWithGoogle();
                      if (response != null) {
                        Fluttertoast.showToast(
                          msg: response,
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.SNACKBAR,
                          backgroundColor: Theme.of(context).primaryColor,
                        );
                      } else if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (route) => false);
                      }
                    },
                    imagen: 'assets/images/google.png',
                  ),
                  SizedBox(height: screenHeight * 0.025),

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
