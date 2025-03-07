import 'package:flutter/material.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/elevated_button_utils.dart';
import 'package:mi_garaje/view/widgets/dialogs/garage_tab/dialog_add_vehicle.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:provider/provider.dart';

class FirstCar extends StatefulWidget {
  const FirstCar({super.key});

  @override
  State<FirstCar> createState() => _FirstCarState();
}

class _FirstCarState extends State<FirstCar> {
  late GarageProvider viewModel;

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<GarageProvider>(context, listen: false);
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