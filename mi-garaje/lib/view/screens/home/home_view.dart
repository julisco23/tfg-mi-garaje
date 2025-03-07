import 'package:flutter/material.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/view/screens/home/first_car_view.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = AppConstants.tabHome;

  @override
  Widget build(BuildContext context) {
    return Consumer<GarageProvider>(
      builder: (context, garageViewModel, _) {
        return FutureBuilder<bool>(
          future: garageViewModel.hasVehicles(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _loadingScreen(context);
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar vehículos'));
            }

            final hasVehicles = snapshot.data;

            // Si no hay vehículos, pide añadir uno
            if (hasVehicles == null || !hasVehicles) {
              return FirstCar();
            }

            // Si hay vehículos, muestra la pantalla principal
            return Scaffold(
              body: AppConstants.widgetTabs[_selectedIndex](garageViewModel),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                onTap: (indexTab) {
                  setState(() {
                    _selectedIndex = indexTab;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.work_history_outlined),
                    label: 'HistoryTab',
                    activeIcon: Icon(Icons.work_history_rounded),
                    tooltip: "Historial",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    label: 'HomeTab',
                    activeIcon: Icon(Icons.home_rounded),
                    tooltip: "Inicio",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'ProfileTab',
                    activeIcon: Icon(Icons.person_rounded),
                    tooltip: "Perfil",
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _loadingScreen(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Center(
        child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
      ),
    );
  }
}
