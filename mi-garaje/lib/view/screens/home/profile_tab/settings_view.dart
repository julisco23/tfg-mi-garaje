import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/user.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/view/widgets/cards/settings_card.dart';
import 'package:mi_garaje/view/widgets/dialogs/auth/dialog_create_profile.dart';
import 'package:mi_garaje/view/widgets/dialogs/auth/dialog_edit_profile.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_confirm.dart';
import 'package:mi_garaje/view/widgets/toastFlutter/fluttertoast.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/themes/theme_notifier.dart';

class SettingsView extends StatelessWidget {
  final GarageProvider garageViewModel;
  const SettingsView({super.key, required this.garageViewModel});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final User user = authViewModel.user!;

    return Scaffold(
      appBar: AppBar(
        title: Text("Ajustes"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECCIÓN: CUENTA
            _buildSectionTitle(context, "Cuenta"),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
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
                    },
                  ),
            if (!user.isGoogle)
              SettingCard(
                imageUrl: 'assets/images/google.png',
                title: "Continuar con Google",
                onTap: () async {
                  bool confirm = await ConfirmDialog.show(
                    context,
                    "Google",
                    "¿Deseas continuar con Google?",
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
                    "¿Deseas cerrar sesión?",
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
                  "¿Deseas eliminar tu cuenta?",
                );
                if (!confirm) return;

                String? response = await authViewModel.eliminarCuenta();

                if (context.mounted) {
                  if (response != null) {
                    ToastHelper.show(context, response);
                  } else {
                    garageViewModel.cerrarSesion();
                    Navigator.pushNamedAndRemoveUntil(
                      context, RouteNames.login, (route) => false);
                  }
                }
              },
            ),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

            // SECCIÓN: APARIENCIA
            _buildSectionTitle(context, "Apariencia"),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
            SettingCard(
              icon: Icons.color_lens,
              title: "Cambiar tema",
              onTap: () async {
                bool confirm = await ConfirmDialog.show(
                  context,
                  "Cambiar tema",
                  "¿Deseas cambiar a modo ${Provider.of<ThemeNotifier>(context, listen: false).isLightTheme() ? "oscuro?" : "claro?"}?",
                );
                if (!confirm) return;

                if (context.mounted) {
                  //ToastHelper.show(context, "Funcionalidad no disponible.")
                  Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
                }
              },
            ),
            SettingCard(
              icon: Icons.language_rounded,
              title: "Cambiar idioma",
              onTap: () {
                ToastHelper.show(context, "Funcionalidad no disponible.");
              },
            ),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

            // SECCIÓN: NOTIFICACIONES
            _buildSectionTitle(context, "Notificaciones"),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
            SettingCard(
              icon: Icons.notifications_active_rounded,
              title: "Activar/Desactivar",
              onTap: () {
                ToastHelper.show(context, "Funcionalidad no disponible.");
              },
            ),
            SettingCard(
              icon: Icons.alarm_rounded,
              title: "Alertas personalizadas",
              onTap: () {
                ToastHelper.show(context, "Funcionalidad no disponible.");
              },
            ),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

            // SECCIÓN: PERSONALIZACIÓN
            _buildSectionTitle(context, "Personalización"),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
            SettingCard(
              icon: Icons.add_rounded, 
              title: "Tipos de repostaje", 
              onTap: () {
                Navigator.pushNamed(context, RouteNames.types, arguments: {"type": "Repostaje"});
              }
            ),
            SettingCard(
              icon: Icons.add_rounded, 
              title: "Tipos de mantenimiento", 
              onTap: () {
              Navigator.pushNamed(context, RouteNames.types, arguments: {"type": "Mantenimiento"});
              }
            ),
            SettingCard(
              icon: Icons.add_rounded, 
              title: "Tipos de documentos",
              onTap: () {
                Navigator.pushNamed(context, RouteNames.types, arguments: {"type": "Documento"});
              }
            ),
            SettingCard(
              icon: Icons.add_rounded, 
              title: "Tipos de vehículos", 
              onTap: () {
                Navigator.pushNamed(context, RouteNames.types, arguments: {"type": "Vehicle"});
              }
            ),
            SettingCard(
              icon: Icons.add_rounded, 
              title: "Nueva actividad", 
              onTap: () {
                Navigator.pushNamed(context, RouteNames.types, arguments: {"type": "Activity"});
              }
            ),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

            // SECCIÓN: FAMILIA
            _buildSectionTitle(context, "Familia"),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
            SettingCard(
              icon: Icons.group_add_rounded,
              title: "Crear una familia",
              onTap: () {
                ToastHelper.show(context, "Funcionalidad no disponible.");
              },
            ),
            SettingCard(
              icon: Icons.group_rounded,
              title: "Unirse a una familia",
              onTap: () {
                ToastHelper.show(context, "Funcionalidad no disponible.");
              },
            ),
            SettingCard(
              icon: Icons.history_rounded,
              title: "Últimos movimientos",
              onTap: () {
                ToastHelper.show(context, "Funcionalidad no disponible.");
              },
            ),
            SettingCard(
              icon: Icons.exit_to_app_rounded,
              title: "Salir de la familia",
              onTap: () {
                ToastHelper.show(context, "Funcionalidad no disponible.");
              },
            ),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

            // SECCIÓN: SOPORTE Y AYUDA
            _buildSectionTitle(context, "Soporte y Ayuda"),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
            SettingCard(
              icon: Icons.help_rounded,
              title: "Prreguntas frecuentes",
              onTap: () {
                ToastHelper.show(context, "Funcionalidad no disponible.");
              },
            ),
            SettingCard(
              icon: Icons.feedback_rounded,
              title: "Enviar comentarios",
              onTap: () {
                ToastHelper.show(context, "Funcionalidad no disponible.");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
