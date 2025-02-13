import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/view/home/first_car_view.dart';
import 'package:mi_garaje/view/home/history_tab_view/history_tab_view.dart';
import 'package:mi_garaje/view/home/profile_tab_view/profile_tab_view.dart';
import 'package:mi_garaje/view/home/home_tab_view/home_tab_view.dart';
import 'package:mi_garaje/shared/routes/route_names.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';
import 'package:mi_garaje/view_model/home_tab_view_model.dart';

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

  @override
  void initState() {
    super.initState();

    _loadCoches();
  }

  Future<void> _loadCoches() async {
    final garageViewModel =
        Provider.of<GarageViewModel>(context, listen: false);

    if (!garageViewModel.isCochesCargados) {
      await garageViewModel.loadCoches();
    }

    if (mounted) {
      setState(() {
        garageViewModel.toggleLoadingCars();
      });
    
      Provider.of<HomeTabViewModel>(context, listen: false).resetIndex();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GarageViewModel>(
      builder: (context, garageViewModel, _) {
        if (garageViewModel.isLoadingCars) {
          return Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(color: Colors.blue),
            ),
          );
        }

        if (garageViewModel.isEmpty) {
          return FirstCar(viewModel: garageViewModel);
        }

        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: Text(garageViewModel.selectedCoche!.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.garage_rounded),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.garage,
                  );
                },
              ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(2.0),
              child: SizedBox(),
            ),
          ),
          body: Consumer<HomeTabViewModel>(
            builder: (context, homeViewModel, _) {
              return _widgetOptions[homeViewModel.selectedIndex];
            },
          ),
          bottomNavigationBar: Consumer<HomeTabViewModel>(
            builder: (context, homeViewModel, _) {
              return BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: homeViewModel.selectedIndex,
                onTap: homeViewModel.setSelectedIndex,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.work_history_outlined),
                    label: 'HistoryTab',
                    activeIcon: Icon(Icons.work_history_rounded),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    label: 'HomeTab',
                    activeIcon: Icon(Icons.home_rounded),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'ProfileTab',
                    activeIcon: Icon(Icons.person_rounded),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
