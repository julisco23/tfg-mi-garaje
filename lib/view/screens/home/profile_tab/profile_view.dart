import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_garaje/data/models/user.dart';
import 'package:mi_garaje/data/provider/image_cache_provider.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/cards/vehicle_card.dart';
import 'package:mi_garaje/view/widgets/utils/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Perfil extends StatelessWidget {
  const Perfil({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final GarageProvider garageProvider = context.watch<GarageProvider>();
    final localizations = AppLocalizations.of(context)!;

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
          await garageProvider.refreshGarage(
              authProvider.id, authProvider.type);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileHeader(context, authProvider),
                SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
                if (authProvider.isFamily) ...[
                  _buildFamilyList(context, authProvider, localizations),
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
                ],
                _buildVehicleList(localizations),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthProvider authProvider) {
    final User user = authProvider.user!;

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
                            Image(
                                image: Provider.of<ImageCacheProvider>(context)
                                    .getImage("user", user.id!, user.photoURL!,
                                        isNetwork: !user.hasPhotoChanged)),
                          ],
                        ),
                      );
                    },
                  )
                : null;
          },
          child: CircleAvatar(
              radius: 50,
              backgroundImage: user.isPhoto
                  ? Provider.of<ImageCacheProvider>(context).getImage(
                      "user", user.id!, user.photoURL!,
                      isNetwork: !user.hasPhotoChanged)
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
          authProvider.user!.displayName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildVehicleList(AppLocalizations localizations) {
    return Consumer<GarageProvider>(
      builder: (context, garageProvider, child) {
        final vehicles = garageProvider.vehicles;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.myVehicles,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
      },
    );
  }

  Widget _buildFamilyList(BuildContext context, AuthProvider authProvider,
      AppLocalizations localizations) {
    if (authProvider.family == null) {
      return CircularProgressIndicator();
    }
    final members = authProvider.family!.members;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.myFamily,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        Row(
          children: [
            Text(
              authProvider.family!.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: AppDimensions.screenWidth(context) * 0.015),
            InkWell(
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: authProvider.family!.code));
                ToastHelper.show("Código de familia copiado al portapapeles");
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
                      "${localizations.code} ${authProvider.family!.code}",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: members?.length ?? 0,
            itemBuilder: (context, index) {
              final member = members![index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: SizedBox(
                    width: 120,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                            radius: 35,
                            backgroundImage: member.isPhoto
                                ? member.hasPhotoChanged
                                    ? Provider.of<ImageCacheProvider>(context)
                                        .getImage("user", member.id!,
                                            member.photoURL!)
                                    : NetworkImage(member.photoURL!)
                                : null,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: member.isPhoto
                                ? null
                                : Icon(
                                    Icons.person,
                                    size: 50,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  )),
                        SizedBox(
                            height: AppDimensions.screenHeight(context) * 0.02),
                        Text(
                          member.displayName,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          textWidthBasis: TextWidthBasis.longestLine,
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
