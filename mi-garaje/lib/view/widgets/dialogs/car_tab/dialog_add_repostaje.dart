import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/refuel.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/constants/validator.dart';
import 'package:mi_garaje/view/widgets/date_form_field.dart';
import 'package:mi_garaje/view/widgets/text_form_field.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:provider/provider.dart';

class DialogAddRefuel extends StatefulWidget {
  final GarageProvider viewModel;
  final Refuel? repostaje;
  final Function(Refuel)? onRefuelUpdated;

  const DialogAddRefuel(
      {super.key,
      required this.viewModel,
      this.repostaje,
      this.onRefuelUpdated});

  @override
  State<DialogAddRefuel> createState() => _DialogAddRefuelState();

  static Future<void> show(BuildContext context, GarageProvider viewModel,
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
  String? selectedTipoRepostaje;

  late Future<List<String>> _refuelTypesFuture;

  @override
  void initState() {
    super.initState();
    // Si estamos editando, pre-poblamos los valores del documento
    if (widget.repostaje != null) {
      costeController.text = widget.repostaje!.getCost.toString();
      selectedDate = widget.repostaje!.date;
      selectedTipoRepostaje = widget.repostaje!.refuelType;
      precioLitroController.text = widget.repostaje!.costLiter.toString();
    }

    // Cargamos los tipos de repostaje
    _refuelTypesFuture = Provider.of<GlobalTypesViewModel>(context, listen: false)
        .getTypes('refuelTypes', 'addedRefuelTypes', 'removedRefuelTypes');
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
                    widget.repostaje == null
                        ? 'Añadir Repostaje'
                        : 'Editar Repostaje',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.05),

                  // Selector de tipo de repostaje
                  SizedBox(
                    width: double.infinity,
                    child: FutureBuilder<List<String>>(
                      future: _refuelTypesFuture,
                      builder: (context, snapshot) {
                        return DropdownButtonFormField<String>(
                          value: selectedTipoRepostaje,
                          decoration: InputDecoration(
                            floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
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
                              selectedTipoRepostaje = newValue;
                            });
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text("Tipo de Repostaje",
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ),
                            if (snapshot.connectionState != ConnectionState.waiting)
                              ...snapshot.data!.map<DropdownMenuItem<String>>(
                                (String tipo) {
                                  return DropdownMenuItem<String>(
                                    value: tipo,
                                    child: Text(tipo, style: Theme.of(context).textTheme.bodyMedium),
                                  );
                                },
                              ),
                            if (snapshot.connectionState == ConnectionState.waiting &&
                                selectedTipoRepostaje != null)
                              DropdownMenuItem<String>(
                                value: selectedTipoRepostaje,
                                child: Text(selectedTipoRepostaje!,
                                    style: Theme.of(context).textTheme.bodyMedium),
                              ),
                          ],
                          validator: Validator.validateDropdown,
                        );
                      },
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
                    keyboardType: TextInputType.number,
                    validator: Validator.validateCostRequired,
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.03),

                  // Precio por Litro
                  MiTextFormField(
                    controller: precioLitroController,
                    labelText: 'Precio por Litro (€)',
                    hintText: '1.442 €',
                    keyboardType: TextInputType.number,
                    validator: Validator.validateCostLi,
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.1),

                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12)),
                          child: Text('Cancelar', style: TextStyle(color: Theme.of(context).primaryColor)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      SizedBox(width: AppDimensions.screenWidth(context) * 0.05),
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12)),
                          child: Text('Añadir', style: TextStyle(color: Theme.of(context).primaryColor)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final double coste = double.parse(costeController.text);
                              final double precioLitro = double.parse(precioLitroController.text);

                              final Refuel activity = Refuel(
                                refuelType: selectedTipoRepostaje!,
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
