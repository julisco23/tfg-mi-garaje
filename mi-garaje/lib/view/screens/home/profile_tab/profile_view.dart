import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/user.dart';
import 'package:mi_garaje/data/provider/image_cache_provider.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/cards/vehicle_card.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';

class Perfil extends StatelessWidget {  // Puedes cambiar a StatelessWidget si no necesitas mantener estado
  const Perfil({super.key});

  @override
  Widget build(BuildContext context) {
    // Accedemos a los providers solo una vez
    final authProvider = context.read<AuthProvider>();
    final garageViewModel = context.read<GarageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.settings,
                  arguments: {"garageViewModel": garageViewModel});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshData(authProvider, garageViewModel),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileHeader(context, authProvider),
                  if (authProvider.isFamily) ...[
                    SizedBox(height: AppDimensions.screenHeight(context) * 0.05),
                    _buildFamilyList(context, authProvider),
                  ],
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.05),
                  _buildVehicleList(context, garageViewModel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData(AuthProvider authProvider, GarageProvider garageViewModel) async {
    await garageViewModel.refreshGarage(authProvider.id, authProvider.type);
  }

  Widget _buildProfileHeader(BuildContext context, AuthProvider authProvider) {
    final User user = authProvider.user!;

    return Column(
      children: [
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
                        Image(image: Provider.of<ImageCacheProvider>(context).getImage("user", user.id!, user.photoURL!, isNetwork: !user.hasPhotoChanged)),
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
                  ? Provider.of<ImageCacheProvider>(context).getImage("user", user.id!, user.photoURL!, isNetwork: !user.hasPhotoChanged)
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

  Widget _buildVehicleList(BuildContext context, GarageProvider garageViewModel) {
    return Consumer<GarageProvider>(
      builder: (context, garageViewModel, child) {
        final vehicles = garageViewModel.vehicles;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mis vehículos",
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
                  vehicle: vehicle,
                  profile: true,
                  garageProvider: garageViewModel,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFamilyList(BuildContext context, AuthProvider authProvider) {
    if (authProvider.family == null) {
      return CircularProgressIndicator();
    }
    final members = authProvider.family!.members;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mi familia",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        Text(
          "Código de familia: ${authProvider.family!.code}",
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
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: SizedBox(
                    width: 120,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: member.isPhoto
                              ? member.hasPhotoChanged
                                  ? Provider.of<ImageCacheProvider>(context).getImage("user", member.id!, member.photoURL!)
                                  : NetworkImage(member.photoURL!)
                              : null,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: member.isPhoto
                              ? null
                              : Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                )),
                        SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
                        Text(
                          member.displayName,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
