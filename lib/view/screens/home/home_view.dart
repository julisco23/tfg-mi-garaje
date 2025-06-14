import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/notifier/garage_notifier.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/screens/error_screen.dart';
import 'package:mi_garaje/view/screens/splash_screen.dart';
import 'package:mi_garaje/view/screens/home/first_car_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int _selectedIndex = AppConstants.tabHome;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final garageAsync = ref.watch(garageProvider);

    return garageAsync.when(
      loading: () => const SplashScreen(),
      error: (err, st) => ErrorScreen(
        errorMessage: err.toString(),
      ),
      data: (garage) {
        if (!garage.isVehicleSelected) {
          return FirstCar();
        }

        return Scaffold(
          body: AppConstants.widgetTabs[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (indexTab) {
              setState(() {
                _selectedIndex = indexTab;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.work_history_outlined),
                label: localizations.history,
                activeIcon: Icon(Icons.work_history_rounded),
                tooltip: localizations.history,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: localizations.home,
                activeIcon: Icon(Icons.home_rounded),
                tooltip: localizations.home,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: localizations.profile,
                activeIcon: Icon(Icons.person_rounded),
                tooltip: localizations.profile,
              ),
            ],
          ),
        );
      },
    );
  }
}
