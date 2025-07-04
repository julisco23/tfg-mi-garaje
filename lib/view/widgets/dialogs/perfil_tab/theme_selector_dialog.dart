import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/notifier/theme_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';

class ThemeSelectorDialog extends ConsumerWidget {
  const ThemeSelectorDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const ThemeSelectorDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider).valueOrNull;
    final themeNotifier = ref.read(themeProvider.notifier);
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(localizations.changeTheme,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOptionTile(
            context,
            title: localizations.lightMode,
            selected: themeMode == ThemeMode.light,
            onTap: () async {
              await themeNotifier.setLightMode();
              ToastHelper.show(
                  theme, localizations.themeChangedTo(localizations.ligth));
            },
          ),
          _buildOptionTile(
            context,
            title: localizations.darkMode,
            selected: themeMode == ThemeMode.dark,
            onTap: () async {
              await themeNotifier.setDarkMode();
              ToastHelper.show(
                  theme, localizations.themeChangedTo(localizations.dark));
            },
          ),
          _buildOptionTile(
            context,
            title: localizations.systemMode,
            selected: themeMode == ThemeMode.system,
            onTap: () async {
              await themeNotifier.setSystemMode();
              ToastHelper.show(
                  theme, localizations.themeChangedTo(localizations.system));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      trailing: selected
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
      onTap: selected ? null : onTap,
    );
  }
}
