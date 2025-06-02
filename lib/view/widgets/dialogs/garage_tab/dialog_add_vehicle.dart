import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/provider/global_types_notifier.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/shared/exceptions/garage_exception.dart';
import 'package:mi_garaje/utils/app_localizations_extensions.dart';
import 'package:mi_garaje/view/widgets/utils/elevated_button_utils.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:mi_garaje/data/provider/garage_notifier.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DialogAddVehicle extends ConsumerStatefulWidget {
  final Vehicle? vehicle;
  final Function(Vehicle?)? onVehicleChanged;

  const DialogAddVehicle({
    super.key,
    this.vehicle,
    this.onVehicleChanged,
  });

  @override
  ConsumerState<DialogAddVehicle> createState() => _DialogAddVehicleState();

  static Future<void> show(BuildContext context,
      {Vehicle? vehicle, Function(Vehicle?)? onVehicleChanged}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogAddVehicle(
          vehicle: vehicle,
          onVehicleChanged: onVehicleChanged,
        );
      },
    );
  }
}

class _DialogAddVehicleState extends ConsumerState<DialogAddVehicle> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedVehicleType;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();

    if (widget.vehicle != null) {
      nameController.text = widget.vehicle!.name ?? '';
      brandController.text = widget.vehicle!.brand;
      modelController.text = widget.vehicle!.model ?? '';
      selectedVehicleType = widget.vehicle!.vehicleType;
      if (widget.vehicle!.photo != null) {
        imageBytes = base64Decode(widget.vehicle!.photo!);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        imageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Dialog(
      insetPadding: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.vehicle == null
                        ? localizations.addVehicle
                        : localizations.editVehicle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.05),

                  // Campo de nombre (opcional)
                  MiTextFormField(
                    controller: nameController,
                    labelText: localizations.nameOptional,
                    hintText: localizations.myCar,
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                  // Selector de tipo de vehículo
                  SizedBox(
                    width: double.infinity,
                    child: ref.watch(globalTypesProvider).when(
                          data: (_) {
                            return FutureBuilder<List<String>>(
                              future: ref
                                  .read(globalTypesProvider.notifier)
                                  .getTypes('Vehicle'),
                              builder: (context, snapshot) {
                                final isWaiting = snapshot.connectionState ==
                                    ConnectionState.waiting;
                                final types = snapshot.data ?? [];

                                return DropdownButtonFormField<String>(
                                  value: selectedVehicleType,
                                  decoration: InputDecoration(
                                    floatingLabelStyle: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                    labelText: localizations.vehicleType,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    filled: true,
                                  ),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedVehicleType = newValue;
                                    });
                                  },
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: null,
                                      child: Text(
                                        localizations.vehicleType,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                    if (!isWaiting)
                                      ...types.map(
                                        (tipo) => DropdownMenuItem<String>(
                                          value: tipo,
                                          child: Text(
                                            localizations.getSubType(tipo),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ),
                                      ),
                                    if (isWaiting &&
                                        selectedVehicleType != null)
                                      DropdownMenuItem<String>(
                                        value: selectedVehicleType,
                                        child: Text(
                                          selectedVehicleType!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ),
                                  ],
                                  validator: Validator.validateDropdown,
                                );
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Text(
                            "error: $err",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                  ),

                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                  // Campo de marca
                  MiTextFormField(
                    controller: brandController,
                    labelText: localizations.brand,
                    hintText: 'Renault',
                    validator: Validator.validateBrand,
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                  // Campo de modelo
                  MiTextFormField(
                    controller: modelController,
                    labelText: localizations.modelOptional,
                    hintText: 'Clio',
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                  // Selector de imagen
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imageBytes == null
                          ? MiButton(
                              text: localizations.selectImage,
                              onPressed: _pickImage,
                              icon: Icons.image,
                              backgroundColor: Colors.transparent,
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor))
                          : Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.memory(
                                                imageBytes!,
                                                fit: BoxFit.contain,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      imageBytes!,
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    width: AppDimensions.screenWidth(context) *
                                        0.015),
                                Expanded(
                                  child: Text(
                                    localizations.imageLoaded,
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      imageBytes = null;
                                    });
                                  },
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.05),

                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12)),
                          child: Text(localizations.cancel,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                          onPressed: () => navigator.pop(),
                        ),
                      ),
                      SizedBox(
                          width: AppDimensions.screenWidth(context) * 0.05),
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12)),
                          child: Text(
                              widget.vehicle == null
                                  ? localizations.add
                                  : localizations.update,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final Vehicle vehicle = Vehicle(
                                name: nameController.text.isEmpty
                                    ? null
                                    : nameController.text[0].toUpperCase() +
                                        nameController.text.substring(1),
                                brand: brandController.text[0].toUpperCase() +
                                    brandController.text.substring(1),
                                model: modelController.text.isEmpty
                                    ? null
                                    : modelController.text[0].toUpperCase() +
                                        modelController.text.substring(1),
                                photo: imageBytes != null
                                    ? base64Encode(imageBytes!)
                                    : null,
                                vehicleType: selectedVehicleType!,
                              );

                              try {
                                if (widget.vehicle == null) {
                                  // Añadir vehículo
                                  await ref
                                      .read(garageProvider.notifier)
                                      .addVehicle(vehicle);

                                  if (widget.onVehicleChanged != null) {
                                    widget.onVehicleChanged!(null);
                                  }

                                  ToastHelper.show(
                                      '$selectedVehicleType añadido');
                                } else {
                                  // Actualizar vehículo
                                  vehicle.id = widget.vehicle!.id;
                                  await ref
                                      .read(garageProvider.notifier)
                                      .updateVehicle(vehicle);

                                  widget.onVehicleChanged!(vehicle);

                                  ToastHelper.show(
                                      '$selectedVehicleType actualizado');
                                }
                                navigator.pop();
                              } on GarageException catch (e) {
                                ToastHelper.show(e.message);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
