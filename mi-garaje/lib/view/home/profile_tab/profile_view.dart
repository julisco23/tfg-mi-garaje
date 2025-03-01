import 'package:flutter/material.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/shared/widgets/cards/vehicle_card.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/view_model/auth_view_model.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';

class Perfil extends StatelessWidget {
  const Perfil({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);
    final garageViewModel = Provider.of<GarageViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.settings,
                  arguments: {"viewModel": viewModel});
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
                _buildProfileHeader(context, viewModel),
                SizedBox(height: AppDimensions.screenHeight(context) * 0.05),
                _buildVehicleList(context, garageViewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthViewModel viewModel) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade300,
          child: viewModel.esGoogle
              ? ClipOval(
                  child: Image.network(
                    viewModel.usuario.photoURL!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey.shade600,
                ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
        Text(
          viewModel.nombreUsuario,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildVehicleList(
      BuildContext context, GarageViewModel garageViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Mis vehículos",
            style: TextStyle(color: Theme.of(context).primaryColor)),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.02),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: garageViewModel.coches.length,
          itemBuilder: (context, index) {
            final vehicle = garageViewModel.coches[index];
            return VehicleCard(
              vehicle: vehicle,
              profile: true,
            );
          },
        ),
      ],
    );
  }
}
