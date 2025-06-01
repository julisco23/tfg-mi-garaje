import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/provider/locale_notifier.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectorDialog extends ConsumerWidget {
  const LanguageSelectorDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => const LanguageSelectorDialog(),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider).valueOrNull;
    final localeNotifier = ref.read(localeProvider.notifier);
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            localizations.selectLanguage,
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
            title: localizations.spanish,
            selected: currentLocale?.languageCode == 'es',
            onTap: () {
              localeNotifier.changeLocale(const Locale('es'));
              ToastHelper.show("Idioma cambiado a Español.");
            },
          ),
          _buildOptionTile(
            context,
            title: localizations.english,
            selected: currentLocale?.languageCode == 'en',
            onTap: () {
              localeNotifier.changeLocale(const Locale('en'));
              ToastHelper.show("Language changed to English.");
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
