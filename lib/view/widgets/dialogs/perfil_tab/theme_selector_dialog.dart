import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/provider/theme_notifier.dart';
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

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            localizations.changeTheme,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
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
                  localizations.themeChangedTo(localizations.ligth));
            },
          ),
          _buildOptionTile(
            context,
            title: localizations.darkMode,
            selected: themeMode == ThemeMode.dark,
            onTap: () async {
              await themeNotifier.setDarkMode();
              ToastHelper.show(
                  localizations.themeChangedTo(localizations.dark));
            },
          ),
          _buildOptionTile(
            context,
            title: localizations.systemMode,
            selected: themeMode == ThemeMode.system,
            onTap: () async {
              await themeNotifier.setSystemMode();
              ToastHelper.show(
                  localizations.themeChangedTo(localizations.system));
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
      title: Text(title),
      trailing: selected
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
      onTap: selected ? null : onTap,
    );
  }
}
