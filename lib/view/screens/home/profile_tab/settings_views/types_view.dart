import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/provider/activity_notifier.dart';
import 'package:mi_garaje/data/provider/auth_notifier.dart';
import 'package:mi_garaje/data/provider/garage_notifier.dart';
import 'package:mi_garaje/data/provider/tab_update_notifier.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/utils/app_localizations_extensions.dart';
import 'package:mi_garaje/view/widgets/cards/types_card.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_confirm.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_name_type.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:mi_garaje/data/provider/global_types_notifier.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TypesView extends ConsumerStatefulWidget {
  final String type;

  const TypesView({super.key, required this.type});

  @override
  ConsumerState<TypesView> createState() => _TypesViewState();
}

class _TypesViewState extends ConsumerState<TypesView> {
  late Future<List<String>> typesFuture;
  late Future<List<String>> removedtypesFuture;
  late List<String> getTypesGlobal;
  bool isActivity = false;
  bool isVehicle = false;
  late TextEditingController controller;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    defineTypes();
  }

  void defineTypes() async {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    isActivity = widget.type == 'Activity';
    isVehicle = widget.type == 'Vehicle';

    try {
      typesFuture =
          ref.read(globalTypesProvider.notifier).getTypes(widget.type);

      if (!isActivity) {
        removedtypesFuture =
            ref.read(globalTypesProvider.notifier).getRemovedTypes(widget.type);
      }

      final globalTypes = ref.read(globalTypesProvider).value!.globalTypes;

      getTypesGlobal = globalTypes[widget.type]!;
    } catch (e) {
      ToastHelper.show(theme, localizations.getErrorMessage(e.toString()));
      typesFuture = Future.value([]);
      removedtypesFuture = Future.value([]);
      getTypesGlobal = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    // Función para agregar nuevos tipos
    Future<void> addType(AsyncValue<AuthState> authState) async {
      try {
        final formattedText = controller.text[0].toUpperCase() +
            controller.text.substring(1).trim();

        await ref
            .read(globalTypesProvider.notifier)
            .addType(formattedText, widget.type);

        if (isActivity) {
          ref.read(tabStateProvider.notifier).newTab(formattedText);
        }

        ToastHelper.show(theme, localizations.typeAdded(controller.text));
        controller.clear();
      } catch (e) {
        ToastHelper.show(theme, localizations.getErrorMessage(e.toString()));
      }
    }

    // Función para eliminar tipos
    Future<void> removeType(
        AsyncValue<AuthState> authState, String typeName) async {
      try {
        await ref
            .read(globalTypesProvider.notifier)
            .removeType(typeName, widget.type);

        if (isActivity) {
          ref.read(tabStateProvider.notifier).removeTab(typeName);
          await ref
              .read(activityProvider.notifier)
              .deleteAllActivities(typeName);
          await ref.read(garageProvider.notifier).refreshGarage();
        } else if (isVehicle) {
          await ref
              .read(garageProvider.notifier)
              .deleteVehicleType(typeName, widget.type);
        } else {
          await ref
              .read(activityProvider.notifier)
              .deleteAllActivities(typeName, type: widget.type);
          await ref.read(garageProvider.notifier).refreshGarage();
        }

        ToastHelper.show(theme, localizations.typeDeleted(typeName));
      } catch (e) {
        ToastHelper.show(theme, localizations.getErrorMessage(e.toString()));
      }
    }

    // Función para editar tipos
    Future<void> editType(
        AsyncValue<AuthState> authState, String oldName, String newName) async {
      try {
        await ref
            .read(globalTypesProvider.notifier)
            .editType(oldName, newName, widget.type);

        if (isActivity) {
          ref.read(tabStateProvider.notifier).editTab(oldName, newName);
          await ref
              .read(activityProvider.notifier)
              .editAllActivities(oldName, newName);
          await ref.read(garageProvider.notifier).refreshGarage();
        } else if (isVehicle) {
          await ref
              .read(garageProvider.notifier)
              .updateVehicleType(oldName, newName, widget.type);
        } else {
          await ref
              .read(activityProvider.notifier)
              .editAllActivities(oldName, newName, type: widget.type);
          await ref.read(garageProvider.notifier).refreshGarage();
        }

        ToastHelper.show(theme, localizations.typeUpdated(newName));
      } catch (e) {
        ToastHelper.show(theme, localizations.getErrorMessage(e.toString()));
      }
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
                    await addType(authState);
                    setState(() {
                      typesFuture = ref
                          .read(globalTypesProvider.notifier)
                          .getTypes(widget.type);
                    });
                    controller.clear();
                  },
                ),
                validator: (value) =>
                    Validator.validateCustomType(value, localizations),
              ),
            ),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<List<String>>(
                      future: typesFuture,
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
                                          theme,
                                          localizations.cannotDeleteLastType(
                                              widget.type));
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
                                  onDismissed: (direction) async {
                                    await removeType(authState, typeItem);
                                    setState(() {
                                      userTypes.remove(typeItem);
                                      removedtypesFuture = ref
                                          .read(globalTypesProvider.notifier)
                                          .getRemovedTypes(widget.type);
                                    });
                                  },
                                  child: TypesCard(
                                    title: localizations.getSubType(typeItem),
                                    icon: Icons.edit,
                                    contains: getTypesGlobal.contains(typeItem),
                                    onPressed: () async {
                                      EditTypeDialog.show(context, typeItem,
                                          (newName) async {
                                        await editType(
                                            authState, typeItem, newName);
                                        setState(() {
                                          typesFuture = ref
                                              .read(
                                                  globalTypesProvider.notifier)
                                              .getTypes(widget.type);
                                        });
                                      });
                                    },
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
                    isActivity ? SizedBox() : _buildDeletedList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FutureBuilder<List<String>> _buildDeletedList() {
    return FutureBuilder<List<String>>(
      future: removedtypesFuture,
      builder: (context, snapshot) {
        final localizations = AppLocalizations.of(context)!;
        final theme = Theme.of(context);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        final removedTypes = snapshot.data ?? [];

        if (removedTypes.isEmpty) {
          return SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, localizations.deleteds),
            SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
            Column(
              children: removedTypes.map((removedItem) {
                return TypesCard(
                  title: localizations.getSubType(removedItem),
                  icon: Icons.restore,
                  onPressed: () async {
                    try {
                      await ref
                          .read(globalTypesProvider.notifier)
                          .reactivateType(removedItem, widget.type);

                      ToastHelper.show(
                          theme, localizations.typeRestored(removedItem));

                      setState(() {
                        typesFuture = ref
                            .read(globalTypesProvider.notifier)
                            .getTypes(widget.type);
                        removedTypes.remove(removedItem);
                      });
                    } catch (e) {
                      ToastHelper.show(
                          theme, localizations.getErrorMessage(e.toString()));
                    }
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
