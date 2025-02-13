import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/shared/widgets/input_utils.dart';
import 'package:mi_garaje/shared/widgets/elevated_button_utils.dart';
import 'package:mi_garaje/view_model/auth_view_model.dart';

class DialogCambioCuenta extends StatefulWidget {
  final AuthViewModel viewModel;

  const DialogCambioCuenta({super.key, required this.viewModel});

  @override
  State<DialogCambioCuenta> createState() => _DialogCambioCuentaState();
}

class _DialogCambioCuentaState extends State<DialogCambioCuenta> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Crear cuenta'),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: widget.viewModel.profileFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titulo del dialog
              MiTextFormField(
                controller: widget.viewModel.nameController,
                labelText: 'Nombre en perfil',
                hintText: 'Mi Garaje',
                validator: (value) {
                  return widget.viewModel.validateName(value);
                },
              ),
              SizedBox(height: screenHeight * 0.02),

              // Campo de correo electrónico
              MiTextFormField(
                controller: widget.viewModel.emailController,
                labelText: 'Correo electrónico',
                hintText: 'migaraje@gmail.com',
                validator: (value) {
                  return widget.viewModel.validateEmail(value);
                },
              ),
              SizedBox(height: screenHeight * 0.02),

              // Campo de contraseña
              MiTextFormField(
                controller: widget.viewModel.passwordController,
                obscureText: widget.viewModel.obscureText,
                labelText: 'Contraseña',
                hintText: widget.viewModel.obscureText ? '******' : 'Contraseña',
                validator: (value) {
                  return widget.viewModel.validatePassword(value);
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    widget.viewModel.obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    widget.viewModel.togglePasswordVisibility();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Botón de crear cuenta
        MiButton(
          text: "Crear cuenta",
          onPressed: () async {
            final formState = widget.viewModel.profileFormKey.currentState;
            if (formState != null && formState.validate()) {
              String? response = await widget.viewModel.crearCuenta(
                widget.viewModel.emailController.text,
                widget.viewModel.passwordController.text,
                widget.viewModel.nameController.text,
              );

              if (response != null) {
                Fluttertoast.showToast(
                  msg: response,
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.SNACKBAR,
                  backgroundColor: Theme.of(context).primaryColor,
                );
              } else if (mounted) {
                Provider.of<AuthViewModel>(context, listen: false).limpiarControladores();
                Navigator.pushNamedAndRemoveUntil(
                    context, RouteNames.home, (route) => false);
              }
            }
          },
        ),
      ],
    );
  }
}
