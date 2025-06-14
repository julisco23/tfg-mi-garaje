import 'package:flutter/material.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_code_family.dart';
import 'package:mi_garaje/view/widgets/utils/elevated_button_utils.dart';
import 'package:mi_garaje/view/widgets/dialogs/garage_tab/dialog_add_vehicle.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FirstCar extends StatefulWidget {
  const FirstCar({super.key});

  @override
  State<FirstCar> createState() => _FirstCarState();
}

class _FirstCarState extends State<FirstCar> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.needaddVehicle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.screenHeight(context) * 0.05),
              MiButton(
                text: localizations.addVehicle,
                onPressed: () async {
                  await DialogAddVehicle.show(context);
                },
              ),
              SizedBox(height: AppDimensions.screenHeight(context) * 0.1),
              Text(
                localizations.orJoinFamily,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.screenHeight(context) * 0.05),
              MiButton(
                text: localizations.joinFamily,
                onPressed: () async {
                  await DialogFamilyCode.show(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
