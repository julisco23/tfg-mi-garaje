import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_garaje/data/models/custom.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/constants/validator.dart';
import 'package:mi_garaje/view/widgets/date_form_field.dart';
import 'package:mi_garaje/view/widgets/text_form_field.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';

class DialogAddActivity extends StatefulWidget {
  final GarageProvider viewModel;
  final CustomActivity? custom;
  final String? customType;
  final Function(CustomActivity)? onCustomUpdated;

  const DialogAddActivity(
      {super.key,
      required this.viewModel,
      this.custom,
      this.onCustomUpdated, 
      this.customType
    }
  );

  @override
  State<DialogAddActivity> createState() => _DialogAddActivityState();

  static Future<void> show(BuildContext context, GarageProvider viewModel,
      {CustomActivity? custom, Function(CustomActivity)? onCustomUpdated, String? customType}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogAddActivity(
            viewModel: viewModel,
            custom: custom,
            onCustomUpdated: onCustomUpdated, 
            customType: customType,);
      },
    );
  }
}

class _DialogAddActivityState extends State<DialogAddActivity> {
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController costeController = TextEditingController();
  final TextEditingController activityTypeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  Uint8List? imageBytes;

  late String customType;

  @override
  void initState() {
    super.initState();
    // Si estamos editando, pre-poblamos los valores del documento
    if (widget.custom != null) {
      detailsController.text = widget.custom!.details ?? '';
      costeController.text = widget.custom!.cost?.toString() ?? '';
      activityTypeController.text = widget.custom!.title;
      selectedDate = widget.custom!.date;
      if (widget.custom!.photo != null) {
        imageBytes = base64Decode(widget.custom!.photo!);
      }
    } 

    customType = widget.customType ?? widget.custom!.customType;
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
                    widget.custom == null
                        ? 'Añadir Documento'
                        : 'Editar Documento',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.05),

                  // Selector de tipo de actividad
                  MiTextFormField(
                    controller: activityTypeController, 
                    labelText: 'Tipo de ${customType.toLowerCase()}',
                    hintText: 'Descripción del ${customType.toLowerCase()}',
                    validator: Validator.validateCustomType,
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                  // Selector de fecha
                  DatePickerField(
                    initialDate: selectedDate,
                    onDateSelected: (DateTime? date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                  // Coste en Dinero
                  MiTextFormField(
                    controller: costeController,
                    labelText: 'Coste (€) (opcional)',
                    hintText: '20 €',
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: Validator.validateCost,
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

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
                                SizedBox(width: AppDimensions.screenWidth(context) * 0.02),
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
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.1),

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
                              widget.custom == null
                                  ? 'Añadir'
                                  : 'Actualizar',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              String? base64Image = imageBytes != null
                                  ? base64Encode(imageBytes!)
                                  : null;

                              final CustomActivity custom = CustomActivity(
                                customType: customType,
                                date: selectedDate!,
                                title: activityTypeController.text,
                                photo: base64Image,
                                details: detailsController.text,
                                cost: num.tryParse(costeController.text),
                              );

                              if (widget.custom == null) {
                                // Agregar nuevo documento
                                widget.viewModel.addActivity(custom);
                              } else {
                                // Actualizar documento existente
                                custom.idActivity = widget.custom!.idActivity;
                                widget.viewModel.updateActivity(custom);
                                widget.onCustomUpdated!(custom);
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
