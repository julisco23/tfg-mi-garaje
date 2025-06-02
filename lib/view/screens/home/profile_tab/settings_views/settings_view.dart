import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/provider/activity_notifier.dart';
import 'package:mi_garaje/data/provider/global_types_notifier.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/shared/utils/mapper_csv.dart';
import 'package:mi_garaje/utils/export_utils.dart';
import 'package:mi_garaje/view/widgets/cards/settings_card.dart';
import 'package:mi_garaje/view/widgets/dialogs/auth/dialog_create_profile.dart';
import 'package:mi_garaje/view/widgets/dialogs/auth/dialog_edit_profile.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_code_family.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_confirm.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/language_selector_dialog.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/theme_selector_dialog.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:mi_garaje/data/provider/auth_notifier.dart';
import 'package:mi_garaje/data/provider/garage_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NavigatorState navigator = Navigator.of(context);
    final localizations = AppLocalizations.of(context)!;

    final authState = ref.watch(authProvider);
    final user = authState.value?.user;

    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(localizations.settings),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECCIÓN: CUENTA
            _buildSectionTitle(context, localizations.account),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
            user.isAnonymous
                ? SettingCard(
                    icon: Icons.person_add_alt_1_rounded,
                    title: localizations.createAccount,
                    onTap: () async {
                      await DialogCambioCuenta.show(context);
                    },
                  )
                : SettingCard(
                    icon: Icons.person_rounded,
                    title: localizations.updateProfile,
                    onTap: () async {
                      await DialogEditProfile.show(context);
                    },
                  ),
            if (!user.isGoogle)
              SettingCard(
                imageUrl: 'assets/images/google.png',
                title: localizations.continueWithGoogle,
                onTap: () async {
                  bool confirm = await ConfirmDialog.show(
                    context,
                    "Google",
                    localizations.confirmContinueWithGoogle,
                  );
                  if (!confirm) return;

                  navigator.pushNamed(RouteNames.loading, arguments: {
                    'onInit': () async {
                      await ref.read(authProvider.notifier).linkWithGoogle();
                      navigator.pop();
                      ToastHelper.show("Cuenta vinculada con Google.");
                    }
                  });
                },
              ),
            if (!user.isAnonymous)
              SettingCard(
                icon: Icons.logout_rounded,
                title: localizations.logout,
                onTap: () async {
                  bool confirm = await ConfirmDialog.show(
                    context,
                    localizations.logout,
                    localizations.confirmLogout,
                  );
                  if (!confirm) return;

                  navigator.pushNamed(
                    RouteNames.loading,
                    arguments: {
                      'onInit': () async {
                        await ref.read(authProvider.notifier).signout();
                        ref.read(garageProvider.notifier).cerrarSesion();

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
              title: localizations.deleteAccount,
              onTap: () async {
                bool confirm = await ConfirmDialog.show(
                  context,
                  localizations.deleteAccount,
                  localizations.confirmDeleteAccount,
                );
                if (!confirm) return;

                navigator.pushNamed(
                  RouteNames.loading,
                  arguments: {
                    'onInit': () async {
                      await ref.read(garageProvider.notifier).eliminarCuenta();
                      await ref.read(authProvider.notifier).eliminarCuenta();

                      navigator.pushNamedAndRemoveUntil(
                          RouteNames.login, (route) => false);

                      ToastHelper.show("Cuenta eliminada.");
                    }
                  },
                );
              },
            ),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

            // SECCIÓN: FAMILIA
            _buildSectionTitle(context, localizations.family),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
            if (!user.hasFamily) ...[
              SettingCard(
                icon: Icons.group_add_rounded,
                title: localizations.createFamily,
                onTap: () async {
                  bool confirm = await ConfirmDialog.show(
                    context,
                    localizations.createFamily,
                    localizations.confirmCreateFamily,
                  );
                  if (!confirm) return;

                  navigator.pushNamed(RouteNames.loading, arguments: {
                    'onInit': () async {
                      await ref
                          .read(authProvider.notifier)
                          .convertirEnFamilia();
                      await ref
                          .read(garageProvider.notifier)
                          .convertToFamily(user.idFamily!);
                      await ref
                          .read(globalTypesProvider.notifier)
                          .convertToFamily();

                      navigator.pushNamedAndRemoveUntil(
                          RouteNames.home, (route) => false);
                      ToastHelper.show("Familia creada.");
                    }
                  });
                },
              ),
              SettingCard(
                icon: Icons.group_rounded,
                title: localizations.joinFamily,
                onTap: () async {
                  bool isFamily = await DialogFamilyCode.show(context);
                  if (!isFamily) return;

                  navigator.pushNamed(RouteNames.loading, arguments: {
                    'onInit': () async {
                      await ref
                          .read(garageProvider.notifier)
                          .joinFamily(user.idFamily!);
                      await ref.read(globalTypesProvider.notifier).joinFamily();

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
                title: localizations.updateFamily,
                onTap: () {
                  DialogEditProfile.show(context, isFamily: true);
                },
              ),
              SettingCard(
                icon: Icons.exit_to_app_rounded,
                title: localizations.leaveFamily,
                onTap: () async {
                  bool confirm = await ConfirmDialog.show(
                    context,
                    localizations.leave,
                    localizations.confirmLeaveFamily,
                  );

                  if (!confirm) return;

                  navigator.pushNamed(
                    RouteNames.loading,
                    arguments: {
                      'onInit': () async {
                        await ref.read(authProvider.notifier).salirDeFamilia();
                        await ref.read(garageProvider.notifier).leaveFamily();
                        ref.read(activityProvider.notifier).clearActivities();

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

            // SECCIÓN: PERSONALIZACIÓN
            _buildSectionTitle(context, localizations.customization),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
            SettingCard(
                icon: Icons.local_gas_station_rounded,
                title: localizations.fuelTypes,
                onTap: () {
                  navigator
                      .pushNamed(RouteNames.types, arguments: {"type": "Fuel"});
                }),
            SettingCard(
                icon: Icons.build_rounded,
                title: localizations.maintenanceTypes,
                onTap: () {
                  navigator.pushNamed(RouteNames.types,
                      arguments: {"type": "Repair"});
                }),
            SettingCard(
                icon: Icons.description_rounded,
                title: localizations.recordTypes,
                onTap: () {
                  navigator.pushNamed(RouteNames.types,
                      arguments: {"type": "Record"});
                }),
            SettingCard(
                icon: Icons.commute_rounded,
                title: localizations.vehicleTypes,
                onTap: () {
                  navigator.pushNamed(RouteNames.types,
                      arguments: {"type": "Vehicle"});
                }),
            SettingCard(
                icon: Icons.star_rounded,
                title: localizations.newActivity,
                onTap: () {
                  navigator.pushNamed(RouteNames.types,
                      arguments: {"type": "Activity"});
                }),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

            // SECCIÓN: APARIENCIA
            _buildSectionTitle(context, localizations.appearance),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
            SettingCard(
              icon: Icons.color_lens,
              title: localizations.changeTheme,
              onTap: () async {
                await ThemeSelectorDialog.show(context);
              },
            ),
            SettingCard(
              icon: Icons.language_rounded,
              title: localizations.changeLanguage,
              onTap: () async {
                await LanguageSelectorDialog.show(context);
              },
            ),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

            _buildSectionTitle(context, localizations.data),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
            SettingCard(
              icon: Icons.table_chart,
              title: localizations.exportData,
              onTap: () async {
                bool confirm = await ConfirmDialog.show(
                  context,
                  localizations.exportData,
                  localizations.confirmExportData,
                );
                if (!confirm) return;

                final vehicles = ref.read(garageProvider).value!.vehicles;

                final Map<String, List<Activity>> activitiesMap = {};

                for (var vehicle in vehicles) {
                  final acts = await ref
                      .read(activityProvider.notifier)
                      .getActivitiesByVehicle(vehicle.id!);
                  activitiesMap[vehicle.id!] = acts;
                }
                try {
                  await exportToCSV(exportAllCarsWithActivitiesToCSV(
                    vehicles,
                    activitiesMap,
                  ));
                  ToastHelper.show("Datos exportados.");
                } on Exception catch (e) {
                  return ToastHelper.show(e.toString());
                }
              },
            ),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

            // SECCIÓN: SOPORTE Y AYUDA
            _buildSectionTitle(context, localizations.supportAndHelp),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
            SettingCard(
              icon: Icons.help_rounded,
              title: localizations.faq,
              onTap: () {
                //TODO: Implementar preguntas frecuentes
                ToastHelper.show(localizations.functionalityNotAvailable);
              },
            ),
            SettingCard(
              icon: Icons.feedback_rounded,
              title: localizations.sendFeedback,
              onTap: () {
                //TODO: Implementar comentarios
                ToastHelper.show(localizations.functionalityNotAvailable);
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
