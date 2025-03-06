import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/constants/validator.dart';
import 'package:mi_garaje/view/widgets/text_form_field.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';

class DialogEditProfile extends StatefulWidget {
  final AuthViewModel authViewModel;

  const DialogEditProfile({super.key, required this.authViewModel});

  @override
  State<DialogEditProfile> createState() => _DialogEditProfileState();

  static Future<void> show(BuildContext context, AuthViewModel authViewModel) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DialogEditProfile(authViewModel: authViewModel);
      },
    );
  }
}

class _DialogEditProfileState extends State<DialogEditProfile> {
  late TextEditingController nombreController;
  final GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();

  String? imageBase64;

  late bool isPhotoChanged;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.authViewModel.user!.name);
    if (widget.authViewModel.isPhotoURL){
      imageBase64 = widget.authViewModel.user!.photoURL!;
    }
    isPhotoChanged = widget.authViewModel.user!.isPhotoChanged;
  }

  @override
  void dispose() {
    nombreController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
       String base64String = await pickedFile.readAsBytes().then((value) => base64Encode(value));
      setState(() {
        imageBase64 = base64String;
        isPhotoChanged = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Actualizar perfil', style: Theme.of(context).textTheme.titleLarge),
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: profileFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              MiTextFormField(
                controller: nombreController,
                labelText: 'Nombre en perfil',
                hintText: 'Mi Garaje',
                validator: (value) {
                  return Validator.validateName(value);
                },
              ),
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
                      ClipRRect(
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
                        )
                      ),
                      SizedBox(
                        width: AppDimensions.screenHeight(context) * 0.05),
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
                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ]
          )
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              child: Text("Cancelar", style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Guardar",
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () async {
                if (profileFormKey.currentState!.validate()) {
                  String nuevoNombre = nombreController.text.trim();

                  await widget.authViewModel.actualizarProfile(nuevoNombre, imageBase64, isPhotoChanged);

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
