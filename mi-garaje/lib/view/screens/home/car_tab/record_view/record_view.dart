import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_garaje/data/models/record.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_add_documento.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_delete_activity.dart';
import 'package:mi_garaje/view/widgets/elevated_button_utils.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'dart:convert';

class RecordView extends StatefulWidget {
  final Record record;
  final String carName;

  const RecordView({super.key, required this.record, required this.carName});

  @override
  State<RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  late Record record;

  @override
  void initState() {
    super.initState();
    record = widget.record;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.carName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async{
              bool result = await DeleteActivityDialog.show(context, record);

              if (result && context.mounted) {
                Provider.of<GarageProvider>(context, listen: false).deleteActivity(record);
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
                  Row(
                    children: [
                      Icon(
                        Icons.description_rounded,
                      ),
                      SizedBox(width: AppDimensions.screenWidth(context) * 0.02),
                      Text(
                        record.getTpye,
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
                        Text(DateFormat('dd/MM/yyyy').format(record.date)),
                  ),
                  if (record.getCost != null) ...[
                    ListTile(
                      title: Text('Coste'),
                      subtitle: Text('${record.getCost} €'),
                    ),
                  ],
                  if (record.details != null &&
                      record.details!.isNotEmpty) ...[
                    ListTile(
                      title: Text('Descripción'),
                      subtitle: Text(record.details!),
                    ),
                  ],
                  if (record.photo != null) ...[
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
                                    base64Decode(record.photo!),
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
                            base64Decode(record.photo!),
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
                        DialogAddDocument.show(
                          context,
                          Provider.of<GarageProvider>(context, listen: false),
                          documento: record,
                          onDocumentoUpdated: (updatedDocumento) {
                            setState(() {
                              record = updatedDocumento;
                            });
                          },
                        );
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
