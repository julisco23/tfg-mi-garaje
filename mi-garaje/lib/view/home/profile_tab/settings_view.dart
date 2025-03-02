import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/user.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/shared/widgets/cards/settings_card.dart';
import 'package:mi_garaje/shared/widgets/dialogs/auth/dialog_create_profile.dart';
import 'package:mi_garaje/shared/widgets/dialogs/auth/dialog_edit_profile.dart';
import 'package:mi_garaje/shared/widgets/dialogs/dialog_confirm.dart';
import 'package:mi_garaje/shared/widgets/fluttertoast.dart';
import 'package:mi_garaje/view_model/auth_view_model.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/themes/theme_notifier.dart';

class SettingsView extends StatelessWidget {
  final GarageViewModel garageViewModel;
  const SettingsView({super.key, required this.garageViewModel});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final UserMy user = authViewModel.user!;

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
                  "¿Deseas cambiar a modo ${Provider.of<ThemeNotifier>(context, listen: false).isLightTheme() ? "oscuro?" : "claro?"}"
                );
                if (!confirm) return;

                if (context.mounted) {
                  Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
                }
              },
            ),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.05),
            Text("Cuenta", style: TextStyle(color: Theme.of(context).primaryColor)),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
            user.isAnonymous
              ? SettingCard(
                icon: Icons.person_add_alt_1_rounded,
                title: "Crear cuenta",
                onTap: () {
                  DialogCambioCuenta.show(context, authViewModel);
                },
              )
              : SettingCard(
                icon: Icons.person_rounded,
                title: "Actualizar perfil", 
                onTap: () {
                  DialogEditProfile.show(context, authViewModel);
                }
              ),
            if (!user.isGoogle)
              SettingCard(
                imageUrl: 'assets/images/google.png',
                title: "Continuar con Google",
                onTap: () async {
                  bool confirm = await ConfirmDialog.show(
                    context,
                    "Google",
                    "¿Deseas continuar con Google?"
                  );
                  if (!confirm) return;

                  await authViewModel.linkWithGoogle();

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            if (!user.isAnonymous)
              SettingCard(
                icon: Icons.logout_rounded,
                title: "Cerrar Sesión",
                onTap: () async {
                  bool confirm = await ConfirmDialog.show(
                    context,
                    "Cerrar Sesión", 
                    "¿Deseas cerrar sesión?"
                  );
                  if (!confirm) return;

                  await authViewModel.signout();

                  if (context.mounted) {
                    garageViewModel.cerrarSesion();
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
                  "¿Deseas eliminar tu cuenta?"
                );
                if (!confirm) return;

                String? response = await authViewModel.eliminarCuenta();

                if (context.mounted) {
                  if (response != null) {
                    ToastHelper.show(context, response);
                  }
                  else {
                    garageViewModel.cerrarSesion();
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
