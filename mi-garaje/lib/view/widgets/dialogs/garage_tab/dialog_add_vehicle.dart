import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/utils/elevated_button_utils.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:provider/provider.dart';

class DialogAddVehicle extends StatefulWidget {
  final GarageProvider viewModel;
  final Vehicle? vehicle;
  final Function(Vehicle)? onVehicleUpdated;

  const DialogAddVehicle({
    super.key,
    required this.viewModel,
    this.vehicle,
    this.onVehicleUpdated,
  });

  @override
  State<DialogAddVehicle> createState() => _DialogAddVehicleState();

  static Future<void> show(BuildContext context, GarageProvider viewModel,
      {Vehicle? vehicle, Function(Vehicle)? onVehicleUpdated}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogAddVehicle(
          viewModel: viewModel,
          vehicle: vehicle,
          onVehicleUpdated: onVehicleUpdated,
        );
      },
    );
  }
}

class _DialogAddVehicleState extends State<DialogAddVehicle> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedVehicleType;
  Uint8List? imageBytes;

  late Future<List<String>> _vehiclesTypes;

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

    _vehiclesTypes = Provider.of<GlobalTypesViewModel>(context, listen: false)
        .getTypes('Vehicle');
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
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.90,
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.vehicle == null
                        ? 'Añadir Vehículo'
                        : 'Editar Vehículo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.05),

                  // Campo de nombre (opcional)
                  MiTextFormField(
                    controller: nameController,
                    labelText: 'Nombre (opcional)',
                    hintText: 'Mi coche',
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                  // Selector de tipo de vehículo
                  SizedBox(
                    width: double.infinity,
                    child: FutureBuilder<List<String>>(
                      future: _vehiclesTypes,
                      builder: (context, snapshot) {
                        return DropdownButtonFormField<String>(
                            value: selectedVehicleType,
                            decoration: InputDecoration(
                              floatingLabelStyle: TextStyle(
                                  color: Theme.of(context).primaryColor),
                              labelText: 'Tipo de Vehículo',
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
                              // Opción por defecto
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text("Tipo de Vehiculo",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ),
                              // Opciones de tipos cargadas dinámicamente
                              if (snapshot.connectionState !=
                                  ConnectionState.waiting)
                                ...snapshot.data!.map<DropdownMenuItem<String>>(
                                  (String tipo) {
                                    return DropdownMenuItem<String>(
                                      value: tipo,
                                      child: Text(tipo,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                    );
                                  },
                                ),
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting &&
                                  selectedVehicleType != null)
                                DropdownMenuItem<String>(
                                  value: selectedVehicleType,
                                  child: Text(selectedVehicleType!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                ),
                            ]);
                      },
                    ),
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                  // Campo de marca
                  MiTextFormField(
                    controller: brandController,
                    labelText: 'Marca',
                    hintText: 'Renault',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '* La marca es obligatoria.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                  // Campo de modelo
                  MiTextFormField(
                    controller: modelController,
                    labelText: 'Modelo (opcional)',
                    hintText: 'Clio',
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                  // Selector de imagen
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imageBytes == null
                          ? MiButton(
                              text: 'Seleccionar Imagen',
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
                                    'Imagen cargada',
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
                          child: Text('Cancelar',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      SizedBox(
                          width: AppDimensions.screenWidth(context) * 0.05),
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12)),
                          child: Text(
                              widget.vehicle == null ? 'Añadir' : 'Actualizar',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final Vehicle vehicle = Vehicle(
                                name: nameController.text.isEmpty
                                    ? null
                                    : nameController.text,
                                brand: brandController.text,
                                model: modelController.text.isEmpty
                                    ? null
                                    : modelController.text,
                                photo: imageBytes != null
                                    ? base64Encode(imageBytes!)
                                    : null,
                                vehicleType: selectedVehicleType!,
                              );

                              if (widget.vehicle == null) {
                                // Añadir vehículo
                                widget.viewModel.addVehicle(vehicle);
                                if (context.mounted) {
                                  ToastHelper.show(context, 'Vehículo añadido');
                                }
                              } else {
                                // Actualizar vehículo
                                vehicle.id = widget.vehicle!.id;
                                widget.viewModel.updateVehicle(vehicle);
                                widget.onVehicleUpdated!(vehicle);
                              }

                              Navigator.of(context).pop();
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
