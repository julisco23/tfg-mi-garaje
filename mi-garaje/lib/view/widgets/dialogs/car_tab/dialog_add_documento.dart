import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_garaje/data/models/record.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/constants/validator.dart';
import 'package:mi_garaje/view/widgets/date_form_field.dart';
import 'package:mi_garaje/view/widgets/text_form_field.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:provider/provider.dart';

class DialogAddDocument extends StatefulWidget {
  final GarageProvider viewModel;
  final Record? documento;
  final Function(Record)? onDocumentoUpdated;

  const DialogAddDocument(
      {super.key,
      required this.viewModel,
      this.documento,
      this.onDocumentoUpdated});

  @override
  State<DialogAddDocument> createState() => _DialogAddDocumentState();

  static Future<void> show(BuildContext context, GarageProvider viewModel,
      {Record? documento, Function(Record)? onDocumentoUpdated}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogAddDocument(
            viewModel: viewModel,
            documento: documento,
            onDocumentoUpdated: onDocumentoUpdated);
      },
    );
  }
}

class _DialogAddDocumentState extends State<DialogAddDocument> {
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController costeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  String? selectedTipoDocumento;
  Uint8List? imageBytes;

  late Future<List<String>> _recordTypesFuture;

  @override
  void initState() {
    super.initState();
    // Si estamos editando, pre-poblamos los valores del documento
    if (widget.documento != null) {
      detailsController.text = widget.documento!.details ?? '';
      costeController.text = widget.documento!.cost?.toString() ?? '';
      selectedDate = widget.documento!.date;
      selectedTipoDocumento = widget.documento!.recordType;
      if (widget.documento!.photo != null) {
        imageBytes = base64Decode(widget.documento!.photo!);
      }
    }

    _recordTypesFuture = Provider.of<GlobalTypesViewModel>(context, listen: false).getTypes('recordTypes', 'addedRecordTypes', 'removedRecordTypes');
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
                    widget.documento == null
                        ? 'Añadir Documento'
                        : 'Editar Documento',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.05),

                  // Selector de tipo de repostaje
                  SizedBox(
                    width: double.infinity,
                    child: FutureBuilder<List<String>>(
                      future: _recordTypesFuture,
                      builder: (context, snapshot) {
                        return DropdownButtonFormField<String>(
                      value: selectedTipoDocumento, // Puede ser null al inicio
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
                          selectedTipoDocumento = newValue;
                        });
                      },
                      items: [
                        // Opción por defecto
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text("Tipo de Documento",
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        if (snapshot.connectionState != ConnectionState.waiting)
                              ...snapshot.data!.map<DropdownMenuItem<String>>((String tipo) {
                          return DropdownMenuItem<String>(
                            value: tipo,
                            child: Text(tipo,
                                style: Theme.of(context).textTheme.bodyMedium),
                          );
                        }),
                        if (snapshot.connectionState == ConnectionState.waiting &&
                          selectedTipoDocumento != null)
                          DropdownMenuItem<String>(
                            value: selectedTipoDocumento,
                            child: Text(selectedTipoDocumento!,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                      ],
                      validator: Validator.validateDropdown,
                    );
                      },
                    ),
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
                              widget.documento == null
                                  ? 'Añadir'
                                  : 'Actualizar',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              String? base64Image = imageBytes != null
                                  ? base64Encode(imageBytes!)
                                  : null;

                              final Record record = Record(
                                date: selectedDate!,
                                recordType: selectedTipoDocumento!,
                                photo: base64Image,
                                details: detailsController.text,
                                cost: double.tryParse(costeController.text),
                              );

                              if (widget.documento == null) {
                                // Agregar nuevo documento
                                widget.viewModel.addActivity(record);
                              } else {
                                // Actualizar documento existente
                                record.idActivity =
                                    widget.documento!.idActivity;
                                widget.viewModel.updateActivity(record);
                                widget.onDocumentoUpdated!(record);
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
