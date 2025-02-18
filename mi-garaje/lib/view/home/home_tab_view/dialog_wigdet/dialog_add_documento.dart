import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_garaje/data/models/record.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/widgets/date_form_field.dart';
import 'package:mi_garaje/shared/widgets/text_form_field.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';

class DialogAddDocument extends StatefulWidget {
  final GarageViewModel viewModel;
  final Record? documento;
  final Function(Record)? onDocumentoUpdated;

  const DialogAddDocument(
      {super.key,
      required this.viewModel,
      this.documento,
      this.onDocumentoUpdated});

  @override
  State<DialogAddDocument> createState() => _DialogAddDocumentState();

  static Future<void> show(BuildContext context, GarageViewModel viewModel,
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
  RecordType? selectedTipoDocumento;
  Uint8List? imageBytes;

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
                      ? 'Añadir nuevo Documento'
                      : 'Editar Documento',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppDimensions.screenHeight(context) * 0.05),

                // Selector de tipo de documento
                SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<RecordType>(
                    value: selectedTipoDocumento,
                    decoration: InputDecoration(
                      floatingLabelStyle:
                          TextStyle(color: Theme.of(context).primaryColor),
                      labelText: 'Tipo de Documento',
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
                    onChanged: (RecordType? newValue) {
                      setState(() {
                        selectedTipoDocumento = newValue;
                      });
                    },
                    items: RecordType.values.map((tipo) {
                      return DropdownMenuItem<RecordType>(
                        value: tipo,
                        child: Text(tipo.getName,
                            style: Theme.of(context).textTheme.bodyMedium),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return '* Seleccione el tipo de mantenimiento.';
                      }
                      return null;
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
                  labelText: 'Coste (€)',
                  hintText: '20 €',
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return '* Introduzca un número válido.';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                // Campo de descripción
                MiTextFormField(
                  controller: detailsController,
                  labelText: 'Descripción',
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
                              const SizedBox(width: 10),
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
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
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
                    SizedBox(width: AppDimensions.screenWidth(context) * 0.05),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12)),
                        child: Text(
                            widget.documento == null ? 'Añadir' : 'Actualizar',
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
    );
  }
}
