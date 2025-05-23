import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class DialogEditProfile extends StatefulWidget {
  final bool isFamily;

  const DialogEditProfile({super.key, required this.isFamily});

  @override
  State<DialogEditProfile> createState() => _DialogEditProfileState();

  static Future<void> show(BuildContext context, {bool isFamily = false}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DialogEditProfile(isFamily: isFamily);
      },
    );
  }
}

class _DialogEditProfileState extends State<DialogEditProfile> {
  late TextEditingController nameController;
  final GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();

  String? imageBase64;

  late bool isPhotoChanged;
  late String accountType;

  @override
  void initState() {
    final AuthProvider authProvider = context.read<AuthProvider>();
    super.initState();
    if (widget.isFamily) {
      nameController = TextEditingController(text: authProvider.family!.name);
      accountType = "familia";
    } else {
      nameController = TextEditingController(text: authProvider.user!.name);
      if (authProvider.isPhotoURL) {
        imageBase64 = authProvider.user!.photoURL!;
      }
      isPhotoChanged = authProvider.user!.isPhotoChanged;
      accountType = "perfil";
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String base64String =
          await pickedFile.readAsBytes().then((value) => base64Encode(value));
      setState(() {
        imageBase64 = base64String;
        isPhotoChanged = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final NavigatorState navigator = Navigator.of(context);

    return AlertDialog(
      insetPadding: EdgeInsets.all(10),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Actualizar', style: Theme.of(context).textTheme.titleLarge),
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
            onPressed: () {
              navigator.pop();
            },
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
            key: profileFormKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              MiTextFormField(
                controller: nameController,
                labelText: 'Nombre en $accountType',
                hintText: 'Mi Garaje',
                validator: Validator.validateName,
              ),
              if (!widget.isFamily) ...[
                SizedBox(height: AppDimensions.screenHeight(context) * 0.02),

                // Selector de imagen
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    imageBase64 == null
                        ? ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text('Seleccionar Imagen',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                                iconColor: Colors.white),
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
                                              base64Decode(imageBase64!),
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
                                    child: isPhotoChanged
                                        ? Image.memory(
                                            base64Decode(imageBase64!),
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            imageBase64!,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          )),
                              ),
                              SizedBox(
                                  width: AppDimensions.screenHeight(context) *
                                      0.05),
                              Expanded(
                                child: Text(
                                  'Imagen cargada',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    imageBase64 = null;
                                  });
                                },
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                              ),
                            ],
                          ),
                  ],
                ),
              ],
            ])),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              child: Text("Cancelar",
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () => navigator.pop(),
            ),
            TextButton(
              child: Text("Guardar",
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () async {
                if (profileFormKey.currentState!.validate()) {
                  navigator.pushNamed(RouteNames.loading, arguments: {
                    'onInit': () async {
                      String? response;
                      if (widget.isFamily) {
                        response = await authProvider.actualizarFamilia(
                            nameController.text[0].toUpperCase() +
                                nameController.text.substring(1).trim());
                      } else {
                        response = await authProvider.actualizarProfile(
                            nameController.text[0].toUpperCase() +
                                nameController.text.substring(1).trim(),
                            imageBase64,
                            isPhotoChanged);
                      }
                      if (response != null) {
                        ToastHelper.show(response);
                      } else {
                        navigator.pushNamedAndRemoveUntil(
                            RouteNames.home, (route) => false);
                      }
                    }
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
