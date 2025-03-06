import 'package:flutter/widgets.dart';
import 'package:mi_garaje/view/screens/home/history_tab/history_view.dart';
import 'package:mi_garaje/view/screens/home/car_tab/car_view.dart';
import 'package:mi_garaje/view/screens/home/profile_tab/profile_view.dart';
import 'package:mi_garaje/data/provider/garage_provider.dart';

class AppDimensions {
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
}

class AppConstants {
  static const int tabHistory = 0;
  static const int tabHome = 1;
  static const int tabProfile = 2;

  static const int refuel = 0;
  static const int repair = 1;
  static const int record = 2;

  static final List<Widget Function(GarageProvider)> widgetTabs = [
    (viewModel) => HistoryView(garageViewModel: viewModel),
    (viewModel) => CarTabView(),
    (viewModel) => Perfil(garageViewModel: viewModel),
  ];
}

class UserDefaults {
  static const List<String> repairTypes = [
    "Freno delantero",
    "Freno trasero",
    "Aceite",
    "Filtro de aceite",
    "Filtro de aire",
    "Filtro de combustible",
    "Batería",
    "Neumáticos",
    "Correa de distribución"
  ];

  static const List<String> recordTypes = [
    "ITV",
    "Seguro"
  ];

  static const List<String> refuelTypes = [
    "Gasolina",
    "Diésel",
    "Eléctrico"
  ];
}
