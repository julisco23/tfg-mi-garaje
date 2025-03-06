import 'package:flutter/material.dart';
import 'package:mi_garaje/view/widgets/cards/types_card.dart';
import 'package:mi_garaje/view/widgets/dialogs/perfil_tab/dialog_name_type.dart';
import 'package:mi_garaje/view/widgets/text_form_field.dart';
import 'package:mi_garaje/data/provider/global_types_view_model.dart';
import 'package:provider/provider.dart';

class TypesView extends StatefulWidget {
  final String type;

  const TypesView({super.key, required this.type});

  @override
  State<TypesView> createState() => _TypesViewState();
}

class _TypesViewState extends State<TypesView> {
  late String add, remove, typeName;
  late Stream<List<String>> typesFuture;
  late Stream<List<String>> removedtypesFuture;
  late List<String> getTypesGlobal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    defineTypes();
  }

  void defineTypes() {
    switch (widget.type) {
      case 'Repostaje':
        add = 'addedRefuelTypes';
        remove = 'removedRefuelTypes';
        typeName = 'refuelTypes';
        break;
      case 'Mantenimiento':
        add = 'addedRepairTypes';
        remove = 'removedRepairTypes';
        typeName = 'repairTypes';
        break;
      case 'Documento':
        add = 'addedRecordTypes';
        remove = 'removedRecordTypes';
        typeName = 'recordTypes';
        break;
    }
    typesFuture = Provider.of<GlobalTypesViewModel>(context).getTypesStream(typeName, add, remove);
    removedtypesFuture = Provider.of<GlobalTypesViewModel>(context).getRemovedTypesStream(add, remove);
    getTypesGlobal = Provider.of<GlobalTypesViewModel>(context).globalTypes[typeName]!;
  }

  @override
  Widget build(BuildContext context) {
    final typeViewModel = Provider.of<GlobalTypesViewModel>(context);
    TextEditingController controller = TextEditingController();

    // Función para agregar nuevos tipos
    void addType() {
      if (controller.text.isNotEmpty) {
        typeViewModel.addType(controller.text, typeName, add, remove);
        controller.clear();
        FocusScope.of(context).unfocus();
      }
    }

    // Función para eliminar tipos
    void removeType(String type) {
      typeViewModel.removeType(type, typeName, add, remove);
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
                onPressed: addType,
              ),
            ),
            SizedBox(height: 16),

            // `SingleChildScrollView` para hacer scroll por ambas listas juntas
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // StreamBuilder para tipos
                    StreamBuilder<List<String>>(
                      stream: typesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        List<String> userTypes = snapshot.data!;

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título 'Tipos' dentro del StreamBuilder
                              _buildSectionTitle(context, 'Tipos'),
                              SizedBox(height: 10),

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
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          color: Colors.red,
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(right: 20.0),
                                          child: Icon(Icons.delete, color: Colors.white),
                                        ),
                                        onDismissed: (direction) => removeType(typeItem),
                                        child: TypesCard(
                                          initialTitle: typeItem,
                                          icon: Icons.edit,
                                          contains: getTypesGlobal.contains(typeItem),
                                          onNameChanged: (newName) => typeViewModel.editType(typeItem, newName, typeName, add, remove),
                                          onPressed: () => EditTypeDialog.show(
                                            context, 
                                            typeItem, 
                                            (newName) => typeViewModel.editType(typeItem, newName, typeName, add, remove)
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 16),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // StreamBuilder para tipos eliminados
                    StreamBuilder<List<String>>(
                      stream: removedtypesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        List<String> removedTypes = snapshot.data!;

                        // Verifica si la lista está vacía
                        if (removedTypes.isEmpty) {
                          return SizedBox();  // Retorna un SizedBox vacío si no hay tipos eliminados
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título 'Eliminados' solo si hay tipos eliminados
                            _buildSectionTitle(context, 'Eliminados'),
                            SizedBox(height: 10),

                            // Lista de tipos eliminados
                            Column(
                              children: removedTypes.map((removedItem) {
                                return TypesCard(
                                  initialTitle: removedItem,
                                  icon: Icons.restore,
                                  onPressed: () => typeViewModel.reactivateType(removedItem, typeName, add, remove),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    )
                  ],  
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
