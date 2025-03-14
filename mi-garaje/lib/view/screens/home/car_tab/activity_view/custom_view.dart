import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_garaje/data/models/custom.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_delete_activity.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_add_activity.dart';
import 'package:mi_garaje/view/widgets/utils/elevated_button_utils.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'dart:convert';

class CustomView extends StatefulWidget {
  final CustomActivity custom;
  final String carName;

  const CustomView({super.key, required this.custom, required this.carName});

  @override
  State<CustomView> createState() => _CustomViewState();
}

class _CustomViewState extends State<CustomView> {
  late CustomActivity custom;

  @override
  void initState() {
    super.initState();
    custom = widget.custom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(custom.getType),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async{
              bool result = await DeleteActivityDialog.show(context, custom);

              if (result && context.mounted) {
                Provider.of<GarageProvider>(context, listen: false).deleteActivity(custom);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text('Tipo'),
                    subtitle: Text(custom.getActivityType),
                  ),
                  ListTile(
                    title: Text('Fecha'),
                    subtitle:
                        Text(DateFormat('dd/MM/yyyy').format(custom.date)),
                  ),
                  if (custom.getCost != null) ...[
                    ListTile(
                      title: Text('Coste'),
                      subtitle: Text('${custom.getCost} €'),
                    ),
                  ],
                  if (custom.details != null &&
                      custom.details!.isNotEmpty) ...[
                    ListTile(
                      title: Text('Descripción'),
                      subtitle: Text(custom.details!),
                    ),
                  ],
                  if (custom.photo != null) ...[
                    ListTile(
                      title: Text('Imagen'),
                    ),
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
                                    base64Decode(custom.photo!),
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            base64Decode(custom.photo!),
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.05),

                  // Botón de edición
                  MiButton(
                    text: "Editar",
                    onPressed: () {
                      DialogAddActivity.show(
                        context,
                        Provider.of<GarageProvider>(context, listen: false),
                        activity: custom,
                        onActivityUpdated: (updatedCustom) {
                          setState(() {
                            custom = updatedCustom as CustomActivity;
                          });
                        },
                      );
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
