import 'package:flutter/material.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/data/provider/tab_update_notifier.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/cards/types_card.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_confirm.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_name_type.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:provider/provider.dart';

class TypesView extends StatefulWidget {
  final String type;

  const TypesView({super.key, required this.type});

  @override
  State<TypesView> createState() => _TypesViewState();
}

class _TypesViewState extends State<TypesView> {
  late Stream<List<String>> typesFuture;
  late Stream<List<String>> removedtypesFuture;
  late List<String> getTypesGlobal;
  bool isActivity = false;
  bool isVehicle = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    defineTypes();
  }

  void defineTypes() {
    isActivity = widget.type == 'Activity';
    isVehicle = widget.type == 'Vehicle';

    print('isActivity: $isActivity');

    typesFuture =
        Provider.of<GlobalTypesViewModel>(context).getTypesStream(widget.type);

    if (!isActivity) {
      removedtypesFuture = Provider.of<GlobalTypesViewModel>(context).getRemovedTypesStream(widget.type);
    }
    getTypesGlobal = Provider.of<GlobalTypesViewModel>(context).globalTypes[widget.type]!;
  }

  @override
  Widget build(BuildContext context) {
    final typeViewModel = Provider.of<GlobalTypesViewModel>(context);
    TextEditingController controller = TextEditingController();

    // Función para agregar nuevos tipos
    void addType() {
      if (controller.text.isNotEmpty) {
        typeViewModel.addType(controller.text, widget.type);
        if (isActivity) {
          Provider.of<TabState>(context, listen: false).newTab(controller.text);
        }
        controller.clear();
        FocusScope.of(context).unfocus();
      }
    }

    // Función para eliminar tipos
    Future<void> removeType(String typeName) async {
      await typeViewModel.removeType(typeName, widget.type);
      if (context.mounted) {
        if (isActivity) {
          Provider.of<TabState>(context, listen: false).removeTab(typeName);
          Provider.of<GarageProvider>(context, listen: false).deleteAllActivities(typeName);
        } else if (isVehicle) {
          Provider.of<GarageProvider>(context, listen: false).deleteVehicleType(typeName, widget.type);
        } else{
          Provider.of<GarageProvider>(context, listen: false).deleteAllActivities(typeName, type: widget.type);
        }
      }
    }

    // Función para editar tipos
    Future<void> editType(String oldName, String newName) async {
      await typeViewModel.editType(oldName, newName, widget.type);
      if (context.mounted) {
        if (isActivity) {
          Provider.of<TabState>(context, listen: false).editTab(oldName, newName);
          print('oldName: $oldName, newName: $newName, type: ${widget.type}');
          Provider.of<GarageProvider>(context, listen: false).editAllActivities(oldName, newName);
        } else if (isVehicle) {
          await Provider.of<GarageProvider>(context, listen: false).updateVehicleType(oldName, newName, widget.type);
        } else {
          Provider.of<GarageProvider>(context, listen: false).editAllActivities(oldName, newName, type: widget.type);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Tipos de ${widget.type}'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de texto para añadir nuevos tipos
            MiTextFormField(
              controller: controller,
              labelText: 'Añadir ${widget.type.toLowerCase()}',
              hintText: widget.type,
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  addType();
                },
              ),
            ),
            SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // StreamBuilder para tipos
                    StreamBuilder<List<String>>(
                      stream: typesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        List<String> userTypes = snapshot.data!;

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título 'Tipos' dentro del StreamBuilder
                              _buildSectionTitle(context, 'Tipos'),
                              SizedBox(
                                  height: AppDimensions.screenHeight(context) *
                                      0.01),

                              // Lista de tipos
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: userTypes.length,
                                    itemBuilder: (context, index) {
                                      String typeItem = userTypes[index];
                                      return Dismissible(
                                        key: Key(typeItem),
                                        direction: (isActivity &&
                                                getTypesGlobal
                                                    .contains(typeItem))
                                            ? DismissDirection.none
                                            : DismissDirection.endToStart,
                                        background: Container(
                                          color: Colors.red,
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(right: 20.0),
                                          child: Icon(Icons.delete,
                                              color: Colors.white),
                                        ),
                                        confirmDismiss: (direction) async {
                                          if (userTypes.length == 1) {
                                            ToastHelper.show(context,
                                                'No puedes eliminar el último ${widget.type}');
                                            return false;
                                          }
                                          return await ConfirmDialog.show(
                                            context,
                                            'Eliminar $typeItem',
                                            isVehicle
                                              ? '¿Estás seguro de que quieres eliminar $typeItem y todos los vehículos asociados?'
                                              : '¿Estás seguro de que quieres eliminar $typeItem y todas las actividades asociadas?',
                                          );
                                        },
                                        onDismissed: (direction) {
                                          removeType(typeItem);
                                        },
                                        child: TypesCard(
                                          initialTitle: typeItem,
                                          icon: Icons.edit,
                                          contains:
                                              getTypesGlobal.contains(typeItem),
                                          onNameChanged: (newName) =>
                                              typeViewModel.editType(typeItem,
                                                  newName, widget.type),
                                          onPressed: () => EditTypeDialog.show(
                                            context,
                                            typeItem,
                                            (newName) =>
                                                editType(typeItem, newName),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(
                                      height:
                                          AppDimensions.screenHeight(context) *
                                              0.02),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    isActivity ? SizedBox() : _buildDeletedList(typeViewModel),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  StreamBuilder<List<String>> _buildDeletedList(
      GlobalTypesViewModel typeViewModel) {
    return StreamBuilder<List<String>>(
      stream: removedtypesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<String> removedTypes = snapshot.data!;

        // Verifica si la lista está vacía
        if (removedTypes.isEmpty) {
          return SizedBox(); // Retorna un SizedBox vacío si no hay tipos eliminados
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título 'Eliminados' solo si hay tipos eliminados
            _buildSectionTitle(context, 'Eliminados'),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),

            // Lista de tipos eliminados
            Column(
              children: removedTypes.map((removedItem) {
                return TypesCard(
                  initialTitle: removedItem,
                  icon: Icons.restore,
                  onPressed: () =>
                      typeViewModel.reactivateType(removedItem, widget.type),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold),
    );
  }
}
