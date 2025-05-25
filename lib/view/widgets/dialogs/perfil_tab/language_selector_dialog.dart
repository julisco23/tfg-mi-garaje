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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            localizations.selectLanguage,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(localizations.spanish),
            onTap: () {
              Navigator.pop(context);
              localeNotifier.changeLocale(const Locale('es'));
              ToastHelper.show("Idioma cambiado a Español.");
            },
          ),
          ListTile(
            title: Text(localizations.english),
            onTap: () {
              Navigator.pop(context);
              localeNotifier.changeLocale(const Locale('en'));
              ToastHelper.show("Language changed to English.");
            },
          ),
        ],
      ),
    );
  }
}
