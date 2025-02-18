import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/refuel.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/widgets/date_form_field.dart';
import 'package:mi_garaje/shared/widgets/text_form_field.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';

class DialogAddRefuel extends StatefulWidget {
  final GarageViewModel viewModel;
  final Refuel? repostaje;
  final Function(Refuel)? onRefuelUpdated;

  const DialogAddRefuel(
      {super.key,
      required this.viewModel,
      this.repostaje,
      this.onRefuelUpdated});

  @override
  State<DialogAddRefuel> createState() => _DialogAddRefuelState();

  static Future<void> show(BuildContext context, GarageViewModel viewModel,
      {Refuel? repostaje, Function(Refuel)? onRefuelUpdated}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogAddRefuel(
            viewModel: viewModel,
            repostaje: repostaje,
            onRefuelUpdated: onRefuelUpdated);
      },
    );
  }
}

class _DialogAddRefuelState extends State<DialogAddRefuel> {
  final TextEditingController costeController = TextEditingController();
  final TextEditingController precioLitroController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  RecordType? selectedTipoRepostaje;

  @override
  void initState() {
    super.initState();
    // Si estamos editando, pre-poblamos los valores del documento
    if (widget.repostaje != null) {
      costeController.text = widget.repostaje!.getCost.toString();
      selectedDate = widget.repostaje!.date;
      selectedTipoRepostaje = widget.repostaje!.recordType;
      precioLitroController.text = widget.repostaje!.costLiter.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                const Text(
                  'Añadir Repostaje',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppDimensions.screenHeight(context) * 0.05),

                // Tipo de Combustible
                DropdownButtonFormField<RecordType>(
                  value: selectedTipoRepostaje,
                  decoration: InputDecoration(
                    floatingLabelStyle:
                        TextStyle(color: Theme.of(context).primaryColor),
                    labelText: 'Tipo de Combustible',
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
                      selectedTipoRepostaje = newValue;
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
                      return '* Seleccione el tipo de combustible.';
                    }
                    return null;
                  },
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
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '* Introduce el coste.';
                    }
                    if (double.tryParse(value) == null) {
                      return '* Introduce un número válido.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                // Precio por Litro
                MiTextFormField(
                  controller: precioLitroController,
                  labelText: 'Precio por Litro (€)',
                  hintText: '1.442 €',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '* Introduce el precio por litro.';
                    }
                    if (double.tryParse(value) == null) {
                      return '* Introduce un número válido.';
                    }
                    final regex = RegExp(r'^\d+(\.\d{1,4})?$');

                    if (!regex.hasMatch(value)) {
                      return '* Como máximo 4 decimales.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppDimensions.screenHeight(context) * 0.1),

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12)),
                        child: 
                          Text('Cancelar',
                          style: TextStyle(color: Theme.of(context).primaryColor)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    SizedBox(width: AppDimensions.screenWidth(context) * 0.05),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12)),
                        child: Text('Añadir',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final double coste = double.parse(costeController.text);
                            final double precioLitro = double.parse(precioLitroController.text);

                            final Refuel activity = Refuel(
                              recordType: selectedTipoRepostaje!,
                              date: selectedDate!,
                              cost: coste,
                              costLiter: precioLitro,
                            );

                            if (widget.repostaje == null) {
                              // Agregar nuevo documento
                              widget.viewModel.addActivity(activity);
                            } else {
                              // Actualizar documento existente
                              activity.idActivity = widget.repostaje!.idActivity;
                              widget.viewModel.updateActivity(activity);
                              widget.onRefuelUpdated!(activity);
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
