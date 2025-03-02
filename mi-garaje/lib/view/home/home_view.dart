import 'package:flutter/material.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/view/home/first_car_view.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = AppConstants.tabHome;

  @override
  void initState() {
    super.initState();

    _loadCoches();
  }

  void _loadCoches() async {
  final garageViewModel = Provider.of<GarageViewModel>(context, listen: false);

  if (!garageViewModel.isLoaded) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await garageViewModel.loadVehicles();
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Consumer<GarageViewModel>(
      builder: (context, garageViewModel, _) {
        if (!garageViewModel.isLoaded) {
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
  }
}
