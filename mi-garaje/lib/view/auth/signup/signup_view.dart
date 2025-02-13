import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/shared/widgets/elevated_button_utils.dart';
import 'package:mi_garaje/shared/widgets/input_utils.dart';
import 'package:mi_garaje/view_model/auth_view_model.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
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
                key: loginViewModel.signupFormKey,
                child: Column(
                  children: [
                    // Título de la pantalla
                    Center(
                      child: Text('Bienvenido a Mi Garaje',
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Image.asset('assets/images/logo.png', width: 100),
                    SizedBox(height: screenHeight * 0.02),

                    // Campo de nombre de perfil
                    MiTextFormField(
                      controller: loginViewModel.nameController,
                      labelText: 'Nombre en perfil',
                      hintText: 'Mi Garaje',
                      validator: (value) {
                        return loginViewModel.validateName(value);
                      },
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Campo de correo electrónico
                    MiTextFormField(
                      controller: loginViewModel.emailController,
                      labelText: 'Correo electrónico',
                      hintText: 'migaraje@gmail.com',
                      validator: (value) {
                        return loginViewModel.validateEmail(value);
                      },
                    ),
                    SizedBox(height: screenHeight * 0.025),

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

                    // Botón de registro
                    MiButton(
                      text: "Registarse",
                      onPressed: () async {
                        if (loginViewModel.signupFormKey.currentState!.validate()) {
                          String? response = await loginViewModel.signup(
                            loginViewModel.emailController.text,
                            loginViewModel.passwordController.text,
                            loginViewModel.nameController.text,
                          );

                          if (response != null) {
                              Fluttertoast.showToast(
                              msg: response,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.SNACKBAR,
                              backgroundColor: Theme.of(context).primaryColor,
                            );
                          } else if (mounted) {
                            loginViewModel.limpiarControladores();
                            Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (route) => false);
                          }
                        }
                      },
                    ),
                    SizedBox(height: screenHeight * 0.08),

                    // Botón de invitado
                    MiButton(
                      text: "Continuar como invitado",
                      onPressed: () async {
                        String? message = await loginViewModel.signInAnonymously();

                        if (message != null) {
                          Fluttertoast.showToast(
                            msg: message,
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.SNACKBAR,
                            backgroundColor: Theme.of(context).primaryColor,
                          );
                        } else if (mounted) {  
                          loginViewModel.limpiarControladores();
                          Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (route) => false);
                        }
                      },
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Botón de Google  
                    MiButton(
                      text: "Crear cuenta con Google",
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
                          loginViewModel.limpiarControladores();
                          Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (route) => false);
                        }
                      },
                      imagen: 'assets/images/google.png',
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Botón de navegación a login
                    MiButton(
                      text: "Ya tengo cuenta",
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, RouteNames.login);
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
