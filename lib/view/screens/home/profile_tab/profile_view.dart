import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/models/user.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/cards/vehicle_card.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/data/notifier/auth_notifier.dart';
import 'package:mi_garaje/data/notifier/garage_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Perfil extends ConsumerWidget {
  const Perfil({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(localizations.myProfile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.settings,
                  arguments: {"garageViewModel": garageProvider});
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(garageProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileHeader(context, authState),
                SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
                if (authState.valueOrNull!.isFamily) ...[
                  _buildFamilyList(context, authState, localizations),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
                ],
                _buildVehicleList(localizations, ref, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, AsyncValue<AuthState> authState) {
    final User user = authState.valueOrNull!.user!;

    return Column(
      children: [
        SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
        GestureDetector(
          onTap: () {
            user.isPhoto
                ? showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            !user.hasPhotoChanged
                                ? CachedNetworkImage(
                                    imageUrl: user.photoURL!,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  )
                                : Image(
                                    image: MemoryImage(
                                        base64Decode(user.photoURL!)),
                                  )
                          ],
                        ),
                      );
                    },
                  )
                : null;
          },
          child: CircleAvatar(
              radius: 50,
              backgroundImage: (user.isPhoto)
                  ? (user.hasPhotoChanged
                      ? MemoryImage(base64Decode(user.photoURL!))
                          as ImageProvider
                      : CachedNetworkImageProvider(user.photoURL!)
                          as ImageProvider)
                  : null,
              backgroundColor: Theme.of(context).primaryColor,
              child: user.isPhoto
                  ? null
                  : Icon(
                      Icons.person,
                      size: 50,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
        Text(
          user.displayName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildVehicleList(
      AppLocalizations localizations, WidgetRef ref, BuildContext context) {
    final vehicles = ref.watch(garageProvider).value!.vehicles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              localizations.myVehicles,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Text(
              vehicles.length == 1
                  ? localizations.vehicle(vehicles.length)
                  : localizations.vehicles(vehicles.length),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
              ),
            ),
            SizedBox(width: AppDimensions.screenWidth(context) * 0.01),
          ],
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            return VehicleCard(
              key: ValueKey(vehicle.hashCode),
              vehicle: vehicle,
              profile: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildFamilyList(
    BuildContext context,
    AsyncValue<AuthState> authState,
    AppLocalizations localizations,
  ) {
    final family = authState.value!.user!.family!;
    final currentUserId = authState.value!.user!.id;
    final theme = Theme.of(context);

    // Filtrar miembros para excluir al usuario actual
    final filteredMembers =
        family.members?.where((m) => m.id != currentUserId).toList() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              localizations.myFamily,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: AppDimensions.screenWidth(context) * 0.015),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: family.code));
                ToastHelper.show(theme, localizations.familyCodeCopied);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Text(
                      "${localizations.code} ${family.code}",
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            if (family.members!.length > 1)
              Text(
                localizations.members(family.members!.length),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18,
                ),
              ),
            SizedBox(width: AppDimensions.screenWidth(context) * 0.01),
          ],
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        if (filteredMembers.isNotEmpty)
          SizedBox(
            height: AppDimensions.screenHeight(context) * 0.2,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredMembers.length,
              itemBuilder: (context, index) {
                final member = filteredMembers[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: SizedBox(
                      width: AppDimensions.screenWidth(context) * 0.35,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundImage: (member.isPhoto)
                                ? (member.hasPhotoChanged
                                    ? MemoryImage(
                                            base64Decode(member.photoURL!))
                                        as ImageProvider
                                    : CachedNetworkImageProvider(
                                        member.photoURL!) as ImageProvider)
                                : null,
                            backgroundColor: theme.primaryColor,
                            child: member.isPhoto
                                ? null
                                : Icon(
                                    Icons.person,
                                    size: 50,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                          ),
                          SizedBox(
                              height:
                                  AppDimensions.screenHeight(context) * 0.02),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              member.displayName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textWidthBasis: TextWidthBasis.longestLine,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
