import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/data/provider/locale_notifier.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectorDialog extends StatelessWidget {
  const LanguageSelectorDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => LanguageSelectorDialog(),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localizations.selectLanguage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(localizations.spanish),
            onTap: () {
              localeNotifier.changeLocale(const Locale('es'));
              Navigator.pop(context);
              ToastHelper.show("Idioma cambiado a Español.");
            },
          ),
          ListTile(
            title: Text(localizations.english),
            onTap: () {
              localeNotifier.changeLocale(const Locale('en'));
              Navigator.pop(context);
              ToastHelper.show("Language changed to English.");
            },
          ),
        ],
      ),
    );
  }
}
