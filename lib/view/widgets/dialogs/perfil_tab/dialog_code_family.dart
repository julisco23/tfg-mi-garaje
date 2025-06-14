import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/notifier/auth_notifier.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/utils/app_localizations_extensions.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DialogFamilyCode extends ConsumerWidget {
  const DialogFamilyCode({super.key});

  static Future<void> show(BuildContext context) async {
    return await showDialog<void>(
      context: context,
      builder: (context) => DialogFamilyCode(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final navigator = Navigator.of(context);
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewInsets = MediaQuery.of(context).viewInsets;
          return Padding(
            padding: EdgeInsets.only(
              bottom: viewInsets.bottom > 0 ? viewInsets.bottom : 16,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        localizations.join,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(
                          height: AppDimensions.screenHeight(context) * 0.02),
                      MiTextFormField(
                        controller: controller,
                        labelText: localizations.familyCode,
                        hintText: "1234AB",
                        validator: (value) =>
                            Validator.validateFamilyCode(value, localizations),
                      ),
                      SizedBox(
                          height: AppDimensions.screenHeight(context) * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            onPressed: () => navigator.pop(),
                            child: Text(
                              localizations.cancel,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                navigator
                                    .pushNamed(RouteNames.loading, arguments: {
                                  'onInit': () async {
                                    try {
                                      await ref
                                          .read(authProvider.notifier)
                                          .joinFamily(
                                              controller.text.toUpperCase());

                                      navigator.pop();
                                      navigator.pop();
                                    } catch (e) {
                                      ToastHelper.show(
                                        theme,
                                        localizations
                                            .getErrorMessage(e.toString()),
                                      );
                                      navigator.pop();
                                    }
                                  }
                                });
                              }
                            },
                            child: Text(
                              localizations.confirm,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
