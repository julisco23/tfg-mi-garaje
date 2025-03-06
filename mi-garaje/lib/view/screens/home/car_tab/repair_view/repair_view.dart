import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_garaje/data/models/repair.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_add_mantenimiento.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_delete_activity.dart';
import 'package:mi_garaje/view/widgets/elevated_button_utils.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'dart:convert';

class RepairView extends StatefulWidget {
  final Repair repair;
  final String carName;

  const RepairView({super.key, required this.repair, required this.carName});

  @override
  State<RepairView> createState() => _RepairViewState();
}

class _RepairViewState extends State<RepairView> {
  late Repair repair;

  @override
  void initState() {
    super.initState();
    repair = widget.repair;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.carName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              DeleteActivityDialog.show(context, repair);
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
                  Row(
                    children: [
                      Icon(
                        Icons.build_rounded,
                      ),
                      SizedBox(width: AppDimensions.screenWidth(context) * 0.02),
                      Text(
                        repair.getTpye,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text('Fecha'),
                    subtitle:
                        Text(DateFormat('dd/MM/yyyy').format(repair.date)),
                  ),
                  if (repair.getCost != null) ...[
                    ListTile(
                      title: Text('Coste'),
                      subtitle: Text('${repair.getCost} €'),
                    ),
                  ],
                  if (repair.details != null && repair.details!.isNotEmpty) ...[
                    ListTile(
                      title: Text('Descripción'),
                      subtitle: Text(repair.details!),
                    ),
                  ],
                  if (repair.photo != null) ...[
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
                                    base64Decode(repair.photo!),
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
                            base64Decode(repair.photo!),
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

                  // Botón de edición
                  MiButton(
                    text: "Editar",
                    onPressed: () {
                      DialogAddRepair.show(
                        context,
                        Provider.of<GarageProvider>(context, listen: false),
                        mantenimiento: repair,
                        onRepairUpdated: (updatedDocumento) {
                          setState(() {
                            repair = updatedDocumento;
                          });
                        },
                      );
                    },
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
