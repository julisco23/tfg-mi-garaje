import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/shared/widgets/cards/settings_card.dart';
import 'package:mi_garaje/shared/widgets/dialogs/auth/dialog_create_profile.dart';
import 'package:mi_garaje/shared/widgets/dialogs/auth/dialog_edit_profile.dart';
import 'package:mi_garaje/shared/widgets/dialogs/dialog_confirm.dart';
import 'package:mi_garaje/view_model/auth_view_model.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/themes/theme_notifier.dart';

class SettingsView extends StatelessWidget {
  final AuthViewModel viewModel;

  const SettingsView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajustes"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Personalización", style: TextStyle(color: Theme.of(context).primaryColor)),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
            SettingCard(
              icon: Icons.color_lens,
              title: "Cambiar tema",
              onTap: () async {
                bool confirm = await ConfirmDialog.show(
                          context,
                          "Cambiar tema",
                          "¿Deseas cambiar a modo ${Provider.of<ThemeNotifier>(context, listen: false).isLightTheme()
                                  ? "oscuro?"
                                  : "claro?"}");
                if (!confirm) return;

                Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
              },
            ),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.05),
            Text("Cuenta", style: TextStyle(color: Theme.of(context).primaryColor)),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
            viewModel.esAnonimo
                ? Container()
                : SettingCard(
                    icon: Icons.person_rounded,
                    title: "Actualizar perfil", onTap: () {
                    DialogEditProfile.show(context, viewModel);

                  }),
            viewModel.esGoogle
                ? Container()
                : SettingCard(
                    imageUrl: 'assets/images/google.png',
                    title: "Continuar con Google",
                    onTap: () async {
                      bool confirm = await ConfirmDialog.show(
                          context,
                          "Google",
                          "¿Deseas continuar con Google?");
                      if (!confirm) return;

                      await viewModel.signInWithGoogle();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
            viewModel.esAnonimo
                ? SettingCard(
                    icon: Icons.person_add_alt_1_rounded,
                    title: "Crear cuenta",
                    onTap: () {
                      DialogCambioCuenta.show(context, viewModel);
                    },
                  )
                : SettingCard(
                    icon: Icons.logout_rounded,
                    title: "Cerrar Sesión",
                    onTap: () async {
                      bool confirm = await ConfirmDialog.show(context,
                          "Cerrar Sesión", "¿Deseas cerrar sesión?");
                      if (!confirm) return;

                      await viewModel.signout();
                      if (context.mounted) {
                        Provider.of<GarageViewModel>(context, listen: false)
                            .cerrarSesion();
                        Navigator.pushNamedAndRemoveUntil(
                            context, RouteNames.login, (route) => false);
                      }
                    },
                  ),
            SettingCard(
              icon: Icons.delete_rounded,
              title: "Eliminar Cuenta",
              onTap: () async {
                bool confirm = await ConfirmDialog.show(
                    context,
                    "Eliminar Cuenta",
                    "¿Deseas eliminar tu cuenta?");
                if (!confirm) return;

                await Provider.of<GarageViewModel>(context, listen: false).deleteGarage();
                String? response = await viewModel.eliminarCuenta();
                if (response != null) {
                  Fluttertoast.showToast(
                    msg: response,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.SNACKBAR,
                    backgroundColor: Theme.of(context).primaryColor,
                  );
                }
                else {
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RouteNames.login, (route) => false);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
