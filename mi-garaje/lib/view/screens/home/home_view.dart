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
  bool _hasVehicles = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final garageViewModel = context.read<GarageProvider>();
    try {
      final result = await garageViewModel.hasVehicles();
      setState(() {
        _hasVehicles = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _loadingScreen(context);
    }

    if (!_hasVehicles) {
      return FirstCar(onVehicleAdded: () {
        setState(() {
          _hasVehicles = true;
        });
      });
    }

    return Scaffold(
      body: AppConstants.widgetTabs[_selectedIndex](context.read<GarageProvider>()),
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
