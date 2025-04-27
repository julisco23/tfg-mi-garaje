import 'package:flutter/material.dart';
import 'package:mi_garaje/data/provider/activity_provider.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/view/widgets/cards/settings_card.dart';
import 'package:mi_garaje/view/widgets/dialogs/auth/dialog_create_profile.dart';
import 'package:mi_garaje/view/widgets/dialogs/auth/dialog_edit_profile.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_code_family.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_confirm.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/themes/theme_notifier.dart';

class SettingsView extends StatelessWidget {
  final GarageProvider garageViewModel;
  const SettingsView({super.key, required this.garageViewModel});

  @override
  Widget build(BuildContext context) {
    final AuthProvider authViewModel = context.read<AuthProvider>();
    final GlobalTypesViewModel globalTypesProvider =
        context.read<GlobalTypesViewModel>();
    final ActivityProvider activityProvider = context.read<ActivityProvider>();
    final NavigatorState navigator = Navigator.of(context);

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
            authViewModel.user!.isAnonymous
                ? SettingCard(
                    icon: Icons.person_add_alt_1_rounded,
                    title: "Crear cuenta",
                    onTap: () async {
                      await DialogCambioCuenta.show(context, authViewModel);

                      ToastHelper.show("Cuenta creada.");
                    },
                  )
                : SettingCard(
                    icon: Icons.person_rounded,
                    title: "Actualizar perfil",
                    onTap: () async {
                      await DialogEditProfile.show(context);

                      ToastHelper.show("Cuenta actualizada.");
                    },
                  ),
            if (!authViewModel.user!.isGoogle)
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

                  navigator.pushNamed(RouteNames.loading, arguments: {
                    'onInit': () async {
                      await authViewModel.linkWithGoogle();
                      navigator.pop();

                      ToastHelper.show("Cuenta vinculada con Google.");
                      //TODO: posible segundo pop
                    }
                  });
                },
              ),
            if (!authViewModel.user!.isAnonymous)
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

                  navigator.pushNamed(
                    RouteNames.loading,
                    arguments: {
                      'onInit': () async {
                        await authViewModel.signout();
                        garageViewModel.cerrarSesion();

                        navigator.pushNamedAndRemoveUntil(
                            RouteNames.login, (route) => false);
                        ToastHelper.show("Sesión cerrada.");
                      }
                    },
                  );
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

                navigator.pushNamed(
                  RouteNames.loading,
                  arguments: {
                    'onInit': () async {
                      await garageViewModel.eliminarCuenta(authViewModel.id,
                          authViewModel.type, authViewModel.user!.hasFamily);
                      await authViewModel.eliminarCuenta();

                      navigator.pushNamedAndRemoveUntil(
                          RouteNames.login, (route) => false);

                      ToastHelper.show("Cuenta eliminada.");
                    }
                  },
                );
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

                //TODO: Implementar cambio de tema

                ToastHelper.show("Funcionalidad no disponible.");

                //Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
                //ToastHelper.show("Tema cambiado.");
              },
            ),
            SettingCard(
              icon: Icons.language_rounded,
              title: "Cambiar idioma",
              onTap: () {
                //TODO: Implementar cambio de idioma

                ToastHelper.show("Funcionalidad no disponible.");
                //ToastHelper.show("Idioma cambiado.");
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
                //TODO: Implementar notificaciones
                ToastHelper.show("Funcionalidad no disponible.");
              },
            ),
            SettingCard(
              icon: Icons.alarm_rounded,
              title: "Alertas personalizadas",
              onTap: () {
                //TODO: Implementar alertas personalizadas
                ToastHelper.show("Funcionalidad no disponible.");
              },
            ),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

            // SECCIÓN: PERSONALIZACIÓN
            _buildSectionTitle(context, "Personalización"),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
            SettingCard(
                icon: Icons.local_gas_station_rounded,
                title: "Tipos de repostaje",
                onTap: () {
                  navigator.pushNamed(RouteNames.types,
                      arguments: {"type": "Refuel"});
                }),
            SettingCard(
                icon: Icons.build_rounded,
                title: "Tipos de mantenimiento",
                onTap: () {
                  navigator.pushNamed(RouteNames.types,
                      arguments: {"type": "Repair"});
                }),
            SettingCard(
                icon: Icons.description_rounded,
                title: "Tipos de documentos",
                onTap: () {
                  navigator.pushNamed(RouteNames.types,
                      arguments: {"type": "Record"});
                }),
            SettingCard(
                icon: Icons.commute_rounded,
                title: "Tipos de vehículos",
                onTap: () {
                  navigator.pushNamed(RouteNames.types,
                      arguments: {"type": "Vehicle"});
                }),
            SettingCard(
                icon: Icons.star_rounded,
                title: "Nueva actividad",
                onTap: () {
                  navigator.pushNamed(RouteNames.types,
                      arguments: {"type": "Activity"});
                }),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

            // SECCIÓN: FAMILIA
            _buildSectionTitle(context, "Familia"),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
            if (!authViewModel.user!.hasFamily) ...[
              SettingCard(
                icon: Icons.group_add_rounded,
                title: "Crear familia",
                onTap: () async {
                  bool confirm = await ConfirmDialog.show(
                    context,
                    "Crear familia",
                    "¿Deseas crear una familia y transferir tus datos? Si aceptas se eliminarán tus datos actuales.",
                  );
                  if (!confirm) return;

                  navigator.pushNamed(RouteNames.loading, arguments: {
                    'onInit': () async {
                      await authViewModel.convertirEnFamilia();
                      await garageViewModel.convertToFamily(
                          authViewModel.user!.id!,
                          authViewModel.user!.idFamily!);
                      await globalTypesProvider.convertToFamily(
                          authViewModel.user!.id!,
                          authViewModel.user!.idFamily!);

                      navigator.pushNamedAndRemoveUntil(
                          RouteNames.home, (route) => false);
                      ToastHelper.show("Familia creada.");
                    }
                  });
                },
              ),
              SettingCard(
                icon: Icons.group_rounded,
                title: "Unirse a una familia",
                onTap: () async {
                  bool isFamily = await DialogFamilyCode.show(context);
                  if (!isFamily) return;

                  navigator.pushNamed(RouteNames.loading, arguments: {
                    'onInit': () async {
                      await garageViewModel.joinFamily(authViewModel.user!.id!,
                          authViewModel.user!.idFamily!);
                      await globalTypesProvider
                          .joinFamily(authViewModel.user!.id!);

                      navigator.pushNamedAndRemoveUntil(
                          RouteNames.home, (route) => false);

                      ToastHelper.show("Unido a la familia.");
                    }
                  });
                },
              )
            ] else ...[
              SettingCard(
                icon: Icons.group_rounded,
                title: "Actualizar familia",
                onTap: () {
                  DialogEditProfile.show(context, isFamily: true);
                },
              ),
              SettingCard(
                icon: Icons.exit_to_app_rounded,
                title: "Salir de la familia",
                onTap: () async {
                  bool confirm = await ConfirmDialog.show(
                    context,
                    "Abandonar",
                    "¿Deseas salir de la familia? Si eres el único miembro, la familia se eliminará.",
                  );

                  if (!confirm) return;

                  navigator.pushNamed(
                    RouteNames.loading,
                    arguments: {
                      'onInit': () async {
                        await authViewModel.salirDeFamilia();
                        await garageViewModel.leaveFamily(authViewModel.id,
                            authViewModel.type, authViewModel.isLastMember);
                        await globalTypesProvider.initializeUser(
                            authViewModel.id, authViewModel.type);
                        activityProvider.clearActivities();

                        navigator.pushNamedAndRemoveUntil(
                            RouteNames.home, (route) => false);

                        ToastHelper.show("Familia abandonada.");
                      }
                    },
                  );
                },
              ),
            ],
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

            // SECCIÓN: SOPORTE Y AYUDA
            _buildSectionTitle(context, "Soporte y Ayuda"),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
            SettingCard(
              icon: Icons.help_rounded,
              title: "Prreguntas frecuentes",
              onTap: () {
                //TODO: Implementar preguntas frecuentes
                ToastHelper.show("Funcionalidad no disponible.");
              },
            ),
            SettingCard(
              icon: Icons.feedback_rounded,
              title: "Enviar comentarios",
              onTap: () {
                //TODO: Implementar comentarios
                ToastHelper.show("Funcionalidad no disponible.");
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
      style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold),
    );
  }
}
