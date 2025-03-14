import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/custom.dart';
import 'package:mi_garaje/data/models/refuel.dart';
import 'package:mi_garaje/data/models/record.dart';
import 'package:mi_garaje/data/models/repair.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/constants/validator.dart';
import 'package:mi_garaje/view/widgets/utils/date_form_field.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:provider/provider.dart';

class DialogAddActivity extends StatefulWidget {
  final GarageProvider viewModel;
  final Activity? activity;
  final String? customType;
  final Function(Activity)? onActivityUpdated;

  const DialogAddActivity({
    super.key,
    required this.viewModel,
    this.customType,
    this.activity,
    this.onActivityUpdated,
  });

  @override
  State<DialogAddActivity> createState() => _DialogAddActivityState();

  static Future<void> show(BuildContext context, GarageProvider viewModel,
      {Activity? activity,
      Function(Activity)? onActivityUpdated,
      String? customType}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogAddActivity(
          viewModel: viewModel,
          activity: activity,
          onActivityUpdated: onActivityUpdated,
          customType: customType,
        );
      },
    );
  }
}

class _DialogAddActivityState extends State<DialogAddActivity> {
  final TextEditingController costController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController costLiterController = TextEditingController();
  final TextEditingController activityTypeController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  String? selectedType;
  Uint8List? imageBytes;

  late String customType;
  bool isCustom = false;

  late Future<List<String>> _typesFuture;

  @override
  void initState() {
    super.initState();

    if (widget.activity != null) {
      if (widget.activity is CustomActivity) {
        customType = widget.activity!.getType;
        isCustom = true;
      } else {
        customType = widget.activity!.getActivityType;
        print(customType);
        _typesFuture = Provider.of<GlobalTypesViewModel>(context, listen: false).getTypes(customType);
      }
      costController.text = widget.activity!.getCost.toString();
      selectedDate = widget.activity!.getDate;
      selectedType = widget.activity!.getType;

      if (widget.activity is Refuel) {
        costLiterController.text =
            (widget.activity as Refuel).costLiter.toString();
      } else {
        detailsController.text = widget.activity!.getDetails!;
        if (widget.activity!.isPhoto) {
          imageBytes = base64Decode(widget.activity!.getPhoto!);
        }
        if (widget.activity is CustomActivity) {
          activityTypeController.text = (widget.activity as CustomActivity).getActivityType;
        }
      }
    } else {
      customType = widget.customType!;
      if (["Refuel", "Repair", "Record"].contains(widget.customType)) {
        _typesFuture = Provider.of<GlobalTypesViewModel>(context, listen: false).getTypes(customType);
      } else {
        isCustom = true;
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
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.90,
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título
                  Text(
                    widget.activity == null
                        ? 'Añadir ${customType.toLowerCase()}'
                        : 'Editar ${customType.toLowerCase()}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.05),

                  // Selección de Tipo
                  if (isCustom) ...[
                    MiTextFormField(
                      controller: activityTypeController,
                      labelText: 'Tipo de ${customType.toLowerCase()}',
                      hintText: 'tipo del ${customType.toLowerCase()}',
                      validator: Validator.validateCustomType,
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: FutureBuilder<List<String>>(
                        future: _typesFuture,
                        builder: (context, snapshot) {
                          return DropdownButtonFormField<String>(
                            value: selectedType,
                            decoration: InputDecoration(
                              floatingLabelStyle: TextStyle(
                                  color: Theme.of(context).primaryColor),
                              labelText: 'Tipo de ${customType.toLowerCase()}',
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
                                selectedType = newValue;
                              });
                            },
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text("Tipo de Repostaje",
                                    style: Theme.of(context).textTheme.bodyMedium),
                              ),
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
                                  selectedType != null)
                                DropdownMenuItem<String>(
                                  value: selectedType,
                                  child: Text(selectedType!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                ),
                            ],
                            validator: Validator.validateDropdown,
                          );
                        },
                      ),
                    ),
                  ],
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                  // Fecha
                  DatePickerField(
                    initialDate: selectedDate,
                    onDateSelected: (DateTime? date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                  // Coste
                  MiTextFormField(
                    controller: costController,
                    labelText: 'Coste (€)',
                    hintText: '20 €',
                    keyboardType: TextInputType.number,
                    validator: Validator.validateCostRequired,
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),
                  
                  // Campo "Precio por Litro"
                  if (widget.customType == "Refuel" || widget.activity is Refuel) ...[
                    MiTextFormField(
                      controller: costLiterController,
                      labelText: 'Precio por Litro (€)',
                      hintText: '1.442 €',
                      keyboardType: TextInputType.number,
                      validator: Validator.validateCostLi,
                    ),
                  ] else ...[
                    // Campo de descripción
                    MiTextFormField(
                      controller: detailsController,
                      labelText: 'Descripción (opcional)',
                      hintText: 'Descripción del documento',
                      maxLines: 5,
                    ),
                    SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                    // Selector de imagen
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        imageBytes == null
                            ? ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.image),
                                label: const Text('Seleccionar Imagen',
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  iconColor: Colors.white,
                                ),
                              )
                            : Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      imageBytes!,
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          AppDimensions.screenWidth(context) *
                                              0.02),
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
                  ],
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.05),

                  // Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextButton(
                          child: Text('Cancelar',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextButton(
                          child: Text('Guardar',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Activity newActivity;

                              switch (customType) {
                                case 'Refuel':
                                  newActivity = Refuel(
                                    refuelType: selectedType!,
                                    date: selectedDate!,
                                    cost: num.parse(costController.text),
                                    costLiter: num.parse(costLiterController.text),
                                  );
                                  break;
                                case 'Repair':
                                  newActivity = Repair(
                                    repairType: selectedType!,
                                    photo: imageBytes != null
                                        ? base64Encode(imageBytes!)
                                        : null,
                                    date: selectedDate!,
                                    cost: num.parse(costController.text),
                                    details: detailsController.text,
                                  );
                                  break;
                                case 'Record':
                                  newActivity = Record(
                                    recordType: selectedType!,
                                    photo: imageBytes != null
                                        ? base64Encode(imageBytes!)
                                        : null,
                                    date: selectedDate!,
                                    cost: num.parse(costController.text),
                                    details: detailsController.text,
                                  );
                                  break;
                                default:
                                  newActivity = CustomActivity(
                                    date: selectedDate!,
                                    cost: num.parse(costController.text),
                                    details: detailsController.text,
                                    photo: imageBytes != null
                                        ? base64Encode(imageBytes!)
                                        : null,
                                    customType: customType,
                                    type: activityTypeController.text,
                                  );
                                  break;
                              }

                              if (widget.activity == null) {
                                widget.viewModel.addActivity(newActivity);
                              } else {
                                newActivity.idActivity =
                                    widget.activity!.idActivity;
                                widget.viewModel.updateActivity(newActivity);
                                widget.onActivityUpdated?.call(newActivity);
                              }

                              Navigator.pop(context);
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
