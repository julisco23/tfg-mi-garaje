import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/user.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/widgets/cards/vehicle_card.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/data/provider/auth_provider.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';

class Perfil extends StatelessWidget {
  final GarageProvider garageViewModel;
  const Perfil({super.key, required this.garageViewModel});

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
                  arguments: {"garageViewModel": garageViewModel});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileHeader(context),
                SizedBox(height: AppDimensions.screenHeight(context) * 0.05),
                _buildVehicleList(context, garageViewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);
    final UserMy user = viewModel.user!;
    
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blue,
          child: user.isPhoto
              ? user.hasPhotoChanged
                  ? ClipOval(
                      child: Image.memory(
                        base64Decode(user.photoURL!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : ClipOval(
                      child: Image.network(
                        user.photoURL!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                : Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                )
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
    return StreamBuilder<List<Vehicle>>(
      stream: garageViewModel.vehiclesStream,  // Escucha el Stream de vehículos
      builder: (context, snapshot) {
        // Verifica el estado de la conexión
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());  // Mientras se cargan los vehículos
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));  // Si hay un error
        }

        // Si no hay vehículos, muestra un mensaje
        final vehicles = snapshot.data ?? [];
        if (vehicles.isEmpty) {
          return Center(child: Text('No tienes vehículos en el garaje.'));
        }

        // Muestra los vehículos
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
