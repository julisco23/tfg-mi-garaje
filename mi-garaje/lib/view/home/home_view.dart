import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/view/home/first_car_view.dart';
import 'package:mi_garaje/view/home/history_tab/history_view.dart';
import 'package:mi_garaje/view/home/profile_tab/profile_view.dart';
import 'package:mi_garaje/view/home/home_tab/home_view.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final List<Widget> _widgetOptions = [
    HistoryView(),
    HomeTabView(),
    Perfil(),
  ];

  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();

    _loadCoches();
  }

  Future<void> _loadCoches() async {
    final garageViewModel =
        Provider.of<GarageViewModel>(context, listen: false);

    if (!garageViewModel.isVehiclesCargados) {
      print("Cargando coches...");
      await garageViewModel.loadVehicles();
    }

    if (mounted) {
      setState(() {
        garageViewModel.toggleLoadingVehicles();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GarageViewModel>(
      builder: (context, garageViewModel, _) {
        if (garageViewModel.isLoadingVehicles) {
          return Container(
            color: Theme.of(context).colorScheme.onPrimary,
            child: Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            ),
          );
        }

        if (garageViewModel.isEmpty) {
          return FirstCar(viewModel: garageViewModel);
        }

        return Scaffold(
          body: _widgetOptions[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
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
  }
}
