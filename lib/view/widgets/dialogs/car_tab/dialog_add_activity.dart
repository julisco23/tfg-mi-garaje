import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/custom.dart';
import 'package:mi_garaje/data/models/fuel.dart';
import 'package:mi_garaje/data/models/record.dart';
import 'package:mi_garaje/data/models/repair.dart';
import 'package:mi_garaje/data/provider/activity_notifier.dart';
import 'package:mi_garaje/data/provider/global_types_notifier.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/utils/app_localizations_extensions.dart';
import 'package:mi_garaje/view/widgets/utils/date_form_field.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DialogAddActivity extends ConsumerStatefulWidget {
  final Activity? activity;
  final String? customType;
  final Function(Activity)? onActivityUpdated;

  const DialogAddActivity({
    super.key,
    this.customType,
    this.activity,
    this.onActivityUpdated,
  });

  @override
  ConsumerState<DialogAddActivity> createState() => _DialogAddActivityState();

  static Future<void> show(BuildContext context,
      {Activity? activity,
      Function(Activity)? onActivityUpdated,
      String? customType}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogAddActivity(
          activity: activity,
          onActivityUpdated: onActivityUpdated,
          customType: customType,
        );
      },
    );
  }
}

class _DialogAddActivityState extends ConsumerState<DialogAddActivity> {
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
        _loadTypesSafely(customType);
      }

      costController.text = widget.activity!.getCost.toString();
      selectedDate = widget.activity!.getDate;
      selectedType = widget.activity!.getType;

      if (widget.activity is Fuel) {
        costLiterController.text =
            (widget.activity as Fuel).costLiter.toString();
      } else {
        detailsController.text = widget.activity!.getDetails ?? '';
        if (widget.activity!.isPhoto) {
          imageBytes = base64Decode(widget.activity!.getPhoto!);
        }
        if (widget.activity is CustomActivity) {
          activityTypeController.text =
              (widget.activity as CustomActivity).getActivityType;
        }
      }
    } else {
      customType = widget.customType!;
      if (["Fuel", "Repair", "Record"].contains(customType)) {
        _loadTypesSafely(customType);
      } else {
        isCustom = true;
      }
    }
  }

  void _loadTypesSafely(String type) async {
    try {
      final future = ref.read(globalTypesProvider.notifier).getTypes(type);
      setState(() {
        _typesFuture = future;
      });
    } catch (e) {
      setState(() {
        _typesFuture = Future.value([]);
      });
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
    final theme = Theme.of(context);

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
                  // Título
                  Text(
                    widget.activity == null
                        ? localizations.addCustomType(localizations.getSubType(
                            customType.toLowerCase(),
                            isSingular: true))
                        : localizations.editCustomType(localizations.getSubType(
                            customType.toLowerCase(),
                            isSingular: true)),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

                  // Selección de Tipo
                  if (isCustom) ...[
                    MiTextFormField(
                      controller: activityTypeController,
                      labelText: localizations
                          .typeOfCustomType(customType.toLowerCase()),
                      hintText: localizations
                          .typeOfCustomType(customType.toLowerCase()),
                      validator: (value) =>
                          Validator.validateCustomType(value, localizations),
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
                              labelText: localizations.typeOfCustomType(
                                  localizations.getSubType(
                                      customType.toLowerCase(),
                                      isSingular: true)),
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
                                child: Text(
                                    localizations.typeOfCustomType(localizations
                                        .getSubType(customType.toLowerCase(),
                                            isSingular: true)),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ),
                              if (snapshot.connectionState !=
                                  ConnectionState.waiting)
                                ...snapshot.data!.map<DropdownMenuItem<String>>(
                                  (String tipo) {
                                    return DropdownMenuItem<String>(
                                      value: tipo,
                                      child: Text(
                                          localizations.getSubType(tipo),
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
                            validator: (value) => Validator.validateDropdown(
                                value, localizations),
                          );
                        },
                      ),
                    ),
                  ],
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

                  // Fecha
                  DatePickerField(
                    initialDate: selectedDate,
                    onDateSelected: (DateTime? date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

                  // Coste
                  MiTextFormField(
                    controller: costController,
                    labelText: localizations.costE,
                    hintText: '20 €',
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        Validator.validateCostRequired(value, localizations),
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

                  // Campo "Precio por Litro"
                  if (widget.customType == "Fuel" ||
                      widget.activity is Fuel) ...[
                    MiTextFormField(
                      controller: costLiterController,
                      labelText: localizations.pricePerLiterE,
                      hintText: '1.442 €',
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          Validator.validateCostLi(value, localizations),
                    ),
                  ] else ...[
                    // Campo de descripción
                    MiTextFormField(
                      controller: detailsController,
                      labelText: localizations.descriptionOptional,
                      hintText: localizations.documentDescription,
                      maxLines: 5,
                    ),
                    SizedBox(
                        height: AppDimensions.screenHeight(context) * 0.02),

                    // Selector de imagen
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        imageBytes == null
                            ? ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.image),
                                label: Text(localizations.selectImage,
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  iconColor: Colors.white,
                                ),
                              )
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
                                      width:
                                          AppDimensions.screenWidth(context) *
                                              0.02),
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
                  ],
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

                  // Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: TextButton(
                          child: Text(localizations.cancel,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                          onPressed: () => navigator.pop(),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          child: Text(localizations.save,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              Activity newActivity;

                              switch (customType) {
                                case 'Fuel':
                                  newActivity = Fuel(
                                    fuelType: selectedType!,
                                    date: selectedDate!,
                                    cost: num.parse(costController.text),
                                    costLiter:
                                        num.parse(costLiterController.text),
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
                                      type: activityTypeController.text[0]
                                              .toUpperCase() +
                                          activityTypeController.text
                                              .substring(1)
                                              .trim());
                                  break;
                              }

                              try {
                                if (widget.activity == null) {
                                  await ref
                                      .read(activityProvider.notifier)
                                      .addActivity(newActivity);
                                  ToastHelper.show(
                                      theme,
                                      localizations.customTypeAdded(
                                          localizations
                                              .getSubType(customType)));
                                } else {
                                  newActivity.idActivity =
                                      widget.activity!.idActivity;
                                  await ref
                                      .read(activityProvider.notifier)
                                      .updateActivity(newActivity);
                                  await widget.onActivityUpdated
                                      ?.call(newActivity);
                                  ToastHelper.show(
                                      theme,
                                      localizations.customTypeUpdated(
                                          localizations
                                              .getSubType(customType)));
                                }

                                navigator.pop();
                              } catch (e) {
                                ToastHelper.show(
                                    theme,
                                    localizations
                                        .getErrorMessage(e.toString()));
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
