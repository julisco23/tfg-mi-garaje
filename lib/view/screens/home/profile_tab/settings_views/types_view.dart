import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/notifier/activity_notifier.dart';
import 'package:mi_garaje/data/notifier/garage_notifier.dart';
import 'package:mi_garaje/data/notifier/tab_update_notifier.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/utils/app_localizations_extensions.dart';
import 'package:mi_garaje/view/widgets/cards/types_card.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_confirm.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_name_type.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:mi_garaje/data/notifier/global_types_notifier.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TypesView extends ConsumerStatefulWidget {
  final String type;

  const TypesView({super.key, required this.type});

  @override
  ConsumerState<TypesView> createState() => _TypesViewState();
}

class _TypesViewState extends ConsumerState<TypesView> {
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
    isActivity = widget.type == 'Activity';
    isVehicle = widget.type == 'Vehicle';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final globalTypes = ref.watch(globalTypesProvider);

    // Función para agregar nuevos tipos
    Future<void> addType() async {
      try {
        final formattedText = controller.text[0].toUpperCase() +
            controller.text.substring(1).trim();

        await ref
            .read(globalTypesProvider.notifier)
            .addType(formattedText, widget.type);

        if (isActivity) {
          ref.read(tabStateProvider.notifier).newTab(formattedText);
        }

        ToastHelper.show(theme,
            localizations.typeAdded(localizations.getSubType(formattedText)));
        controller.clear();
      } catch (e) {
        ToastHelper.show(theme, localizations.getErrorMessage(e.toString()));
      }
    }

    // Función para eliminar tipos
    Future<void> removeType(String typeName) async {
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

        ToastHelper.show(theme,
            localizations.typeDeleted(localizations.getSubType(typeName)));
      } catch (e) {
        ToastHelper.show(theme, localizations.getErrorMessage(e.toString()));
      }
    }

    // Función para editar tipos
    Future<void> editType(String oldName, String newName) async {
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

        ToastHelper.show(theme,
            localizations.typeUpdated(localizations.getSubType(newName)));
      } catch (e) {
        ToastHelper.show(theme, localizations.getErrorMessage(e.toString()));
      }
    }

    return globalTypes.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text(localizations.getErrorMessage(error.toString())),
        ),
      ),
      data: (state) {
        final userTypes = state.userTypes(widget.type);

        final sortedUserTypes = [...userTypes]..sort();

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
                // Campo para agregar tipo nuevo
                Form(
                  key: formKey,
                  child: MiTextFormField(
                    controller: controller,
                    labelText: localizations.addCustomType(localizations
                        .getSubType(widget.type, isSingular: true)),
                    hintText: localizations
                        .getSubType(widget.type, isSingular: true)
                        .replaceFirstMapped(
                            RegExp(r'^.'), (m) => m.group(0)!.toUpperCase()),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        await addType();
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
                        _buildSectionTitle(
                            context,
                            localizations.typesOfCustomType(localizations
                                .getSubType(widget.type, isSingular: true))),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sortedUserTypes.length,
                          itemBuilder: (context, index) {
                            final typeItem = sortedUserTypes[index];

                            return Dismissible(
                              key: Key(typeItem),
                              direction: (isActivity &&
                                      state.isGlobalType(widget.type, typeItem))
                                  ? DismissDirection.none
                                  : DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20.0),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                if (userTypes.length == 1) {
                                  ToastHelper.show(
                                      theme,
                                      localizations.cannotDeleteLastType(
                                          localizations
                                              .getSubType(widget.type)));
                                  return false;
                                }
                                if (ref
                                    .watch(garageProvider)
                                    .value!
                                    .areAllVehiclesOfType(typeItem)) {
                                  ToastHelper.show(
                                      theme,
                                      localizations.cannotDeleteLastType(
                                          localizations
                                              .getSubType(widget.type)));
                                  return false;
                                }
                                return await ConfirmDialog.show(
                                  context,
                                  localizations.deleteType(localizations
                                      .getSubType(typeItem, isSingular: true)),
                                  isVehicle
                                      ? localizations.confirmDeleteTypeVehicle(
                                          localizations.getSubType(typeItem,
                                              isSingular: true))
                                      : localizations.confirmDeleteTypeActivity(
                                          localizations.getSubType(typeItem,
                                              isSingular: true)),
                                );
                              },
                              onDismissed: (_) async {
                                await removeType(typeItem);
                              },
                              child: TypesCard(
                                title: localizations.getSubType(typeItem),
                                icon: Icons.edit,
                                contains:
                                    state.isGlobalType(widget.type, typeItem),
                                onPressed: () async {
                                  await EditTypeDialog.show(context, typeItem,
                                      (newName) async {
                                    await editType(typeItem, newName);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildDeletedList(state.userRemovedTypes(widget.type)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeletedList(List<String> removedTypes) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (removedTypes.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, localizations.deleteds),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        SizedBox(
          child: ListView.builder(
            key: ValueKey(removedTypes.length),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: removedTypes.length,
            itemBuilder: (context, index) {
              final removedItem = removedTypes[index];
              return TypesCard(
                title: localizations.getSubType(removedItem),
                icon: Icons.restore,
                onPressed: () async {
                  try {
                    await ref
                        .read(globalTypesProvider.notifier)
                        .reactivateType(removedItem, widget.type);

                    ToastHelper.show(
                        theme,
                        localizations.typeRestored(
                            localizations.getSubType(removedItem)));
                  } catch (e) {
                    ToastHelper.show(
                        theme, localizations.getErrorMessage(e.toString()));
                  }
                },
              );
            },
          ),
        )
      ],
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
