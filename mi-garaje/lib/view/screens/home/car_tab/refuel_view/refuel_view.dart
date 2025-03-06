import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_garaje/data/models/refuel.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_add_repostaje.dart';
import 'package:mi_garaje/view/widgets/dialogs/car_tab/dialog_delete_activity.dart';
import 'package:mi_garaje/view/widgets/elevated_button_utils.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';

class RefuelView extends StatefulWidget {
  final Refuel refuel;
  final String carName;

  const RefuelView({super.key, required this.refuel, required this.carName});

  @override
  State<RefuelView> createState() => _RefuelViewState();
}

class _RefuelViewState extends State<RefuelView> {
  late Refuel refuel;

  @override
  void initState() {
    super.initState();
    refuel = widget.refuel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: "Volver",
        ),
        title: Text(widget.carName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              DeleteActivityDialog.show(context, refuel);
            },
            tooltip: 'Eliminar',
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
                  // Titulo
                  Row(
                    children: [
                      Icon(
                        Icons.local_gas_station_rounded
                      ),
                      SizedBox(width: AppDimensions.screenWidth(context) * 0.02),
                      Text(
                        refuel.getTpye,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  
                  // Datos del repostaje
                  ListTile(
                    title: Text('Fecha'),
                    subtitle:
                        Text(DateFormat('dd/MM/yyyy').format(refuel.date)),
                  ),
                  ListTile(
                    title: Text('Coste'),
                    subtitle: Text('${refuel.getCost} €'),
                  ),
                  ListTile(
                    title: Text('Precio por litro'),
                    subtitle: Text('${refuel.getPrecioLitros} €'),
                  ),
                  ListTile(
                    title: Text('Litros'),
                    subtitle: Text('${refuel.getLiters.toStringAsFixed(3)} L'),
                  ),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

                  // Botón de edición
                  MiButton(
                    text: "Editar",
                    onPressed: () {
                      DialogAddRefuel.show(
                        context,
                        Provider.of<GarageProvider>(context, listen: false),
                        repostaje: refuel,
                        onRefuelUpdated: (updatedRefuel) {
                          setState(() {
                            refuel = updatedRefuel;
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
