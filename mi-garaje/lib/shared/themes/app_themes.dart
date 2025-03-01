import 'package:flutter/material.dart';

class AppThemes {
  static final oscuro = Color.fromARGB(255, 11, 11, 14);
  static final blanco = Colors.white;
  static final blancoTransparente = const Color.fromARGB(175, 255, 255, 255);
  static final azul = const Color.fromARGB(255, 33, 149, 243);
  static final azulClaro = const Color.fromARGB(255, 119, 190, 248);
  static final gris = Colors.grey[600];
  static final verde = Colors.green[700];

  // Tema Claro
  static ThemeData lightTheme = ThemeData(
    typography: Typography.material2018(),
    brightness: Brightness.light,
    primaryColor: azul,
    scaffoldBackgroundColor: blanco,
    appBarTheme: AppBarTheme(
      backgroundColor: azul,
      iconTheme: IconThemeData(color: blanco, size: 40),
      titleTextStyle: TextStyle(color: blanco, fontSize: 20),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: azul, fontSize: 30), // Titulo login/register/titulos dialog
      titleMedium: TextStyle(color: oscuro, fontSize: 30), // Titulos dialog
      titleSmall: TextStyle(color: Colors.amber),
      bodyLarge: TextStyle(color: oscuro),
      bodyMedium: TextStyle(color: oscuro, fontSize: 18),
      bodySmall: TextStyle(color: oscuro, fontSize: 14),
      labelLarge: TextStyle(color: oscuro, fontSize: 20),
      labelMedium: TextStyle(color: verde, fontSize: 16),
      labelSmall: TextStyle(color: gris, fontSize: 14),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: TextStyle(color: oscuro, fontSize: 16, fontWeight: FontWeight.bold),
      subtitleTextStyle: TextStyle(color: oscuro, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
          borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: azul,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: Size(double.infinity, 60),
        elevation: 0,
        textStyle: TextStyle(color: blanco, fontSize: 16),
      ),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor: blanco,
    ),
    cardTheme: CardTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: azulClaro,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: azul,
      selectedItemColor: blanco,
      unselectedItemColor: blanco,
      selectedIconTheme: IconThemeData(size: 30),
      unselectedIconTheme: IconThemeData(size: 30),
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: blanco,
      unselectedLabelColor: blanco,
      indicator: BoxDecoration(
        color: const Color.fromARGB(50, 255, 255, 255),
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: azul,
      foregroundColor: blancoTransparente
    ),
    dividerTheme: DividerThemeData(
      color: blanco,
      thickness: 0.5,
      space: 0,
    ),

    datePickerTheme: DatePickerThemeData(
      backgroundColor: blanco,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black54,
      headerBackgroundColor: azul,
      headerForegroundColor: blanco,
      cancelButtonStyle: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(azul),
      ),
      confirmButtonStyle: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(azul),
      ),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return azul;
        }
        return null;
      }),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return blanco;
        }
        return null;
      }),
      todayBackgroundColor: WidgetStateProperty.resolveWith((states) { 
        if (states.contains(WidgetState.selected)) {
          return azul;
        }
        return blanco;
      }),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) { 
        if (states.contains(WidgetState.selected)) {
          return blanco;
        }
        return azul;
      }),
      todayBorder: BorderSide(color: azul, width: 2),
    ),



  );




  // Tema Oscuro
  static ThemeData darkTheme = ThemeData(
    typography: Typography.material2018(),
    brightness: Brightness.dark,
    primaryColor: blanco,
    scaffoldBackgroundColor: oscuro,
    appBarTheme: AppBarTheme(
      backgroundColor: oscuro,
      iconTheme: IconThemeData(color: blanco, size: 40),
      titleTextStyle: TextStyle(color: blanco, fontSize: 30),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: blanco, fontSize: 30),
      titleMedium: TextStyle(color: blanco),
      titleSmall: TextStyle(color: blanco),
      bodyLarge: TextStyle(color: blanco),
      bodyMedium: TextStyle(color: blanco, fontSize: 18),
      labelLarge: TextStyle(color: blanco, fontSize: 20),
      labelMedium: TextStyle(color: blanco, fontSize: 16),
      labelSmall: TextStyle(color: blanco, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
          borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: blanco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: Size(double.infinity, 60),
        elevation: 0,
        textStyle: TextStyle(color: oscuro, fontSize: 16),
      ),
    ),
    cardTheme: CardTheme(
      margin: EdgeInsets.only(top: 0, left: 7, right: 7, bottom: 10),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: blanco,
      unselectedItemColor: blanco,
      selectedIconTheme: IconThemeData(size: 30),
      unselectedIconTheme: IconThemeData(size: 30),
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: blanco,
      unselectedLabelColor: blanco,
      indicator: BoxDecoration(
        color: const Color.fromARGB(50, 255, 255, 255),
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color.fromARGB(175, 255, 255, 255),
      foregroundColor: oscuro,
    ),
  );
}
