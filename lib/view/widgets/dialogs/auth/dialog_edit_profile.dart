import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/utils/validator.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:mi_garaje/view/widgets/utils/text_form_field.dart';
import 'package:mi_garaje/data/provider/auth_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DialogEditProfile extends ConsumerStatefulWidget {
  final bool isFamily;

  const DialogEditProfile({super.key, required this.isFamily});

  @override
  ConsumerState<DialogEditProfile> createState() => _DialogEditProfileState();

  static Future<void> show(BuildContext context, {bool isFamily = false}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DialogEditProfile(isFamily: isFamily);
      },
    );
  }
}

class _DialogEditProfileState extends ConsumerState<DialogEditProfile> {
  late TextEditingController nameController;
  final GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();

  String? imageBase64;

  late bool isPhotoChanged;
  late String accountType;

  @override
  void initState() {
    super.initState();

    final authState = ref.read(authProvider);
    if (widget.isFamily) {
      nameController =
          TextEditingController(text: authState.valueOrNull!.family!.name);
      accountType = "familia";
    } else {
      nameController =
          TextEditingController(text: authState.valueOrNull!.user!.name);
      if (authState.valueOrNull!.isPhotoURL) {
        imageBase64 = authState.valueOrNull!.user!.photoURL!;
      }
      isPhotoChanged = authState.valueOrNull!.user!.hasPhotoChanged;
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
    final NavigatorState navigator = Navigator.of(context);
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      insetPadding: EdgeInsets.all(10),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              widget.isFamily
                  ? localizations.updateFamily
                  : localizations.updateProfile,
              style: Theme.of(context).textTheme.titleLarge),
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
                labelText: localizations.accountName(accountType),
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
                            label: Text(localizations.selectImage,
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
                                            !isPhotoChanged
                                                ? Image.memory(
                                                    base64Decode(imageBase64!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl: imageBase64!,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: !isPhotoChanged
                                      ? Image.memory(
                                          base64Decode(imageBase64!),
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: imageBase64!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                ),
                              ),
                              SizedBox(
                                  width: AppDimensions.screenHeight(context) *
                                      0.05),
                              Expanded(
                                child: Text(
                                  localizations.imageLoaded,
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
              child: Text(localizations.cancel,
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () => navigator.pop(),
            ),
            TextButton(
              child: Text(localizations.save,
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () async {
                if (profileFormKey.currentState!.validate()) {
                  navigator.pushNamed(RouteNames.loading, arguments: {
                    'onInit': () async {
                      String? response;
                      if (widget.isFamily) {
                        response = await ref
                            .read(authProvider.notifier)
                            .actualizarFamilia(
                                nameController.text[0].toUpperCase() +
                                    nameController.text.substring(1).trim());
                      } else {
                        response = await ref
                            .read(authProvider.notifier)
                            .actualizarProfile(
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
