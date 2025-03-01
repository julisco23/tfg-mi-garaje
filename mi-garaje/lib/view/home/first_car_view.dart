import 'package:flutter/material.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/widgets/elevated_button_utils.dart';
import 'package:mi_garaje/shared/widgets/dialogs/garage_tab/dialog_add_vehicle.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';

class FirstCar extends StatelessWidget {
  const FirstCar({super.key, required this.viewModel});

  final GarageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Necesitas añadir un coche para continuar',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.screenHeight(context) * 0.05),
              MiButton(
                text: 'Añadir coche',
                onPressed: () async {
                  DialogAddVehicle.show(context, viewModel);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}