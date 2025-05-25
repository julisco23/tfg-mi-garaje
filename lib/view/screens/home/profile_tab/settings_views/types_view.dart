import 'package:flutter/material.dart';
import 'package:mi_garaje/data/provider/activity_provider.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:mi_garaje/data/provider/tab_update_notifier.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/utils/app_localizations_extensions.dart';
import 'package:mi_garaje/view/widgets/cards/types_card.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_confirm.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_name_type.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    final AuthProvider authProvider = context.read<AuthProvider>();
    final GlobalTypesViewModel typeViewModel =
        context.read<GlobalTypesViewModel>();

    typesFuture = typeViewModel.getTypesStream(
        authProvider.id, authProvider.type, widget.type);

    if (!isActivity) {
      removedtypesFuture = typeViewModel.getRemovedTypesStream(
          authProvider.id, authProvider.type, widget.type);
    }
    getTypesGlobal = typeViewModel.globalTypes[widget.type]!;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final GlobalTypesViewModel typeViewModel =
        context.read<GlobalTypesViewModel>();
    final AuthProvider authProvider = context.read<AuthProvider>();
    final TabState tabState = context.read<TabState>();
    final ActivityProvider activityProvider = context.read<ActivityProvider>();
    final GarageProvider garageProvider = context.watch<GarageProvider>();
    final localizations = AppLocalizations.of(context)!;

    // Función para agregar nuevos tipos
    Future<void> addType() async {
      FocusScope.of(context).unfocus();

      await typeViewModel.addType(
          authProvider.id,
          authProvider.type,
          controller.text[0].toUpperCase() +
              controller.text.substring(1).trim(),
          widget.type);
      if (isActivity) {
        tabState.newTab(controller.text);
      }

      ToastHelper.show('${controller.text} añadido');

      controller.clear();
    }

    // Función para eliminar tipos
    Future<void> removeType(String typeName) async {
      await typeViewModel.removeType(
          authProvider.id, authProvider.type, typeName, widget.type);

      if (isActivity) {
        tabState.removeTab(typeName);
        await activityProvider.deleteAllActivities(
            authProvider.id, authProvider.type, typeName);
        await garageProvider.refreshGarage(authProvider.id, authProvider.type);
      } else if (isVehicle) {
        await garageProvider.deleteVehicleType(
            authProvider.id, authProvider.type, typeName, widget.type);
      } else {
        await activityProvider.deleteAllActivities(
            authProvider.id, authProvider.type, typeName,
            type: widget.type);
        await garageProvider.refreshGarage(authProvider.id, authProvider.type);
      }

      ToastHelper.show('$typeName eliminado');
    }

    // Función para editar tipos
    Future<void> editType(String oldName, String newName) async {
      await typeViewModel.editType(
          authProvider.id, authProvider.type, oldName, newName, widget.type);

      if (isActivity) {
        tabState.editTab(oldName, newName);
        await activityProvider.editAllActivities(
            authProvider.id, authProvider.type, oldName, newName);
        await garageProvider.refreshGarage(authProvider.id, authProvider.type);
      } else if (isVehicle) {
        await garageProvider.updateVehicleType(
            authProvider.id, authProvider.type, oldName, newName, widget.type);
      } else {
        await activityProvider.editAllActivities(
            authProvider.id, authProvider.type, oldName, newName);
        await garageProvider.refreshGarage(authProvider.id, authProvider.type);
      }

      ToastHelper.show('$newName actualizado');
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(localizations.typesOfCustomType(
              localizations.getSubType(widget.type, isSingular: true))),
          centerTitle: true,
          scrolledUnderElevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de texto para añadir nuevos tipos
            Form(
              key: formKey,
              child: MiTextFormField(
                controller: controller,
                labelText: localizations.addCustomType(
                    localizations.getSubType(widget.type, isSingular: true)),
                hintText: localizations
                        .getSubType(widget.type, isSingular: true)[0]
                        .toUpperCase() +
                    localizations
                        .getSubType(widget.type, isSingular: true)
                        .substring(1),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    await addType();
                  },
                ),
                validator: Validator.validateCustomType,
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

                        userTypes.sort((a, b) => a.compareTo(b));

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título 'Tipos' dentro del StreamBuilder
                            _buildSectionTitle(
                                context,
                                localizations.typesOfCustomType(
                                    localizations.getSubType(widget.type,
                                        isSingular: true))),
                            SizedBox(
                                height:
                                    AppDimensions.screenHeight(context) * 0.01),

                            // Lista de tipos
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: userTypes.length,
                              itemBuilder: (context, index) {
                                String typeItem = userTypes[index];
                                return Dismissible(
                                  key: Key(typeItem),
                                  direction: (isActivity &&
                                          getTypesGlobal.contains(typeItem))
                                      ? DismissDirection.none
                                      : DismissDirection.endToStart,
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.only(right: 20.0),
                                    child:
                                        Icon(Icons.delete, color: Colors.white),
                                  ),
                                  confirmDismiss: (direction) async {
                                    if (userTypes.length == 1) {
                                      ToastHelper.show(
                                          'No puedes eliminar el último ${widget.type}');
                                      return false;
                                    }
                                    return await ConfirmDialog.show(
                                      context,
                                      localizations.deleteType(
                                          localizations.getSubType(typeItem,
                                              isSingular: true)),
                                      isVehicle
                                          ? localizations
                                              .confirmDeleteTypeVehicle(
                                                  localizations.getSubType(
                                                      typeItem,
                                                      isSingular: true))
                                          : localizations
                                              .confirmDeleteTypeActivity(
                                                  localizations.getSubType(
                                                      typeItem,
                                                      isSingular: true)),
                                    );
                                  },
                                  onDismissed: (direction) {
                                    removeType(typeItem);
                                  },
                                  child: TypesCard(
                                    title: localizations.getSubType(typeItem),
                                    icon: Icons.edit,
                                    contains: getTypesGlobal.contains(typeItem),
                                    onNameChanged: (newName) =>
                                        typeViewModel.editType(
                                            authProvider.id,
                                            authProvider.type,
                                            typeItem,
                                            newName,
                                            widget.type),
                                    onPressed: () => EditTypeDialog.show(
                                      context,
                                      typeItem,
                                      (newName) => editType(typeItem, newName),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                                height:
                                    AppDimensions.screenHeight(context) * 0.02),
                          ],
                        );
                      },
                    ),

                    isActivity
                        ? SizedBox()
                        : _buildDeletedList(typeViewModel, authProvider),
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
      GlobalTypesViewModel typeViewModel, AuthProvider authProvider) {
    return StreamBuilder<List<String>>(
      stream: removedtypesFuture,
      builder: (context, snapshot) {
        final localizations = AppLocalizations.of(context)!;

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
            _buildSectionTitle(context, localizations.deleteds),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),

            // Lista de tipos eliminados
            Column(
              children: removedTypes.map((removedItem) {
                return TypesCard(
                  title: localizations.getSubType(removedItem),
                  icon: Icons.restore,
                  onPressed: () async {
                    await typeViewModel.reactivateType(authProvider.id,
                        authProvider.type, removedItem, widget.type);
                    ToastHelper.show('$removedItem restaurado');
                  },
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
