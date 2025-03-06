import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_garaje/data/models/repair.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/constants/validator.dart';
import 'package:mi_garaje/view/widgets/date_form_field.dart';
import 'package:mi_garaje/view/widgets/text_form_field.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:provider/provider.dart';

class DialogAddRepair extends StatefulWidget {
  final GarageProvider viewModel;
  final Repair? mantenimiento;
  final Function(Repair)? onRepairUpdated;

  const DialogAddRepair(
      {super.key,
      required this.viewModel,
      this.mantenimiento,
      this.onRepairUpdated});

  @override
  State<DialogAddRepair> createState() => _DialogAddRepairState();

  static Future<void> show(BuildContext context, GarageProvider viewModel,
      {Repair? mantenimiento, Function(Repair)? onRepairUpdated}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogAddRepair(
            viewModel: viewModel,
            mantenimiento: mantenimiento,
            onRepairUpdated: onRepairUpdated);
      },
    );
  }
}

class _DialogAddRepairState extends State<DialogAddRepair> {
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController costeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  String? selectedTipoMantenimiento;
  Uint8List? imageBytes;

  late List<String> _repairTypesFuture;

  @override
  void initState() {
    super.initState();
    // Si estamos editando, pre-poblamos los valores del documento
    if (widget.mantenimiento != null) {
      detailsController.text = widget.mantenimiento!.details ?? '';
      costeController.text = widget.mantenimiento!.cost?.toString() ?? '';
      selectedDate = widget.mantenimiento!.date;
      selectedTipoMantenimiento = widget.mantenimiento!.repairType;
      if (widget.mantenimiento!.photo != null) {
        imageBytes = base64Decode(widget.mantenimiento!.photo!);
      }
    }

    _repairTypesFuture = Provider.of<GlobalTypesViewModel>(context, listen: false).globalTypes["repairTypes"]!;
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
                    widget.mantenimiento == null
                        ? 'Añadir Mantenimiento'
                        : 'Editar Mantenimiento',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.05),

                  // Selector de tipo de repostaje
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      value: selectedTipoMantenimiento,
                      decoration: InputDecoration(
                        floatingLabelStyle: TextStyle(
                            color: Theme.of(context).primaryColor),
                        labelText: 'Tipo de Repostaje',
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
                          selectedTipoMantenimiento = newValue;
                        });
                      },
                      items: [
                        // Opción por defecto
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text("Tipo de Repostaje",
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        // Opciones de tipos cargadas dinámicamente
                        ..._repairTypesFuture.map<DropdownMenuItem<String>>((String tipo) {
                          return DropdownMenuItem<String>(
                            value: tipo,
                            child: Text(tipo,
                                style: Theme.of(context).textTheme.bodyMedium),
                          );
                        }),
                      ],
                      validator: Validator.validateDropdown,
                    ),
                  ),
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

                  // Coste en Dinero
                  MiTextFormField(
                    controller: costeController,
                    labelText: 'Coste (€)',
                    hintText: '20 €',
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    validator: Validator.validateCostRequired,
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                  // Campo de descripción
                  MiTextFormField(
                    controller: detailsController,
                    labelText: 'Descripción (opcional)',
                    hintText: 'Descripción del mantenimiento',
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
                                  iconColor: Colors.white),
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
                                    width: AppDimensions.screenHeight(context) *
                                        0.05),
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
                          child: Text('Añadir',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final double? coste =
                                  double.tryParse(costeController.text);

                              String? base64Image = imageBytes != null
                                  ? base64Encode(imageBytes!)
                                  : null;

                              final Repair repair = Repair(
                                date: selectedDate!,
                                repairType: selectedTipoMantenimiento!,
                                photo: base64Image,
                                cost: coste,
                                details: detailsController.text,
                              );

                              if (widget.mantenimiento == null) {
                                // Agregar nuevo documento
                                widget.viewModel.addActivity(repair);
                              } else {
                                // Actualizar documento existente
                                repair.idActivity =
                                    widget.mantenimiento!.idActivity;
                                widget.viewModel.updateActivity(repair);
                                widget.onRepairUpdated!(repair);
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
