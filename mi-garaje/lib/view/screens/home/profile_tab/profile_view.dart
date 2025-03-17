import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/user.dart';
import 'package:mi_garaje/data/provider/image_cache_provider.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/cards/vehicle_card.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';

class Perfil extends StatefulWidget {
  final GarageProvider garageViewModel;
  const Perfil({super.key, required this.garageViewModel});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.settings,
                  arguments: {"garageViewModel": widget.garageViewModel});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileHeader(context),
                  if (widget.garageViewModel.isFamily) ...[
                    SizedBox(height: AppDimensions.screenHeight(context) * 0.05),
                    _buildFamilyList(context),
                  ],
                  SizedBox(height: AppDimensions.screenHeight(context) * 0.05),
                  _buildVehicleList(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await widget.garageViewModel.refreshGarage();
  }

  Widget _buildProfileHeader(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);
    final User user = viewModel.user!;

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

  Widget _buildVehicleList(BuildContext context) {
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
}

Widget _buildFamilyList(BuildContext context) {
  return Consumer<AuthViewModel>(
    builder: (context, viewModel, child) {
      if (viewModel.family == null) {
        return CircularProgressIndicator();
      }
      final members = viewModel.family!.members;

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
            "Código de familia: ${viewModel.family!.code}",
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
    },
  );
}
