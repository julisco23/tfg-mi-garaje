import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/shared/themes/theme_notifier.dart';
import 'package:mi_garaje/shared/widgets/dialog_cuenta_nueva.dart';
import 'package:mi_garaje/shared/widgets/elevated_button_utils.dart';
import 'package:mi_garaje/view_model/auth_view_model.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';

class Perfil extends StatelessWidget {
  const Perfil({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Mi Perfil', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: screenHeight * 0.02),
                  Text(viewModel.nombreUsuario),
                  SizedBox(height: screenHeight * 0.4),
                  MiButton(
                    text: "Cambiar tema de la aplicación",
                    onPressed: () async {
                      final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
                      themeNotifier.toggleTheme();
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  viewModel.esAnonimo
                      ? _botonCrearCuenta(context, viewModel)
                      : _botonCerrarSesion(context, viewModel),
                  SizedBox(height: screenHeight * 0.02),
                  MiButton(
                    text: "Eliminar cuenta",
                    onPressed: () async {
                      String? response = await viewModel.eliminarCuenta();
                      if (response != null) {
                        Fluttertoast.showToast(
                          msg: response,
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.SNACKBAR,
                          backgroundColor: Theme.of(context).primaryColor,
                        );
                      } else {
                        if (context.mounted) {
                          Provider.of<GarageViewModel>(context, listen: false).cerrarSesion();
                          Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (route) => false);
                        }
                      }
                    },
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonCrearCuenta(BuildContext context, AuthViewModel viewModel) {
    return MiButton(
      text: "Crear cuenta",
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return DialogCambioCuenta(
              viewModel: viewModel,
            );
          },
        );
      },
    );
  }

  Widget _botonCerrarSesion(BuildContext context, AuthViewModel viewModel) {
    return MiButton(
      text: "Cerrar sesión",
      onPressed: () async {
        String? response = await viewModel.signout();

        if (response != null) {
          Fluttertoast.showToast(
            msg: response,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.SNACKBAR,
            backgroundColor: Theme.of(context).primaryColor,
          );
        } else {
          if (context.mounted) {
            Provider.of<GarageViewModel>(context, listen: false).cerrarSesion();
            Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (route) => false);
          }
        }
      },
    );
  }
}
