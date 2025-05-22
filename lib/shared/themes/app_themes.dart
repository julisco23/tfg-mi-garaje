import 'package:flutter/material.dart';

class AppThemes {
  static final oscuro = Color.fromARGB(255, 11, 11, 14);
  static final blanco = Colors.white;
  static final blancoTransparente = const Color.fromARGB(175, 255, 255, 255);
  static final azul = const Color.fromARGB(255, 33, 149, 243);
  static final azulClaro = const Color.fromARGB(255, 119, 190, 248);
  static final gris = Colors.grey[600];

  static final verde = Colors.green[700];
  static final rojo = Colors.red[500];

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
    dividerColor: blancoTransparente,
    colorScheme: ColorScheme(
      brightness: Brightness.light, // Define si el tema es claro o oscuro
      primary: azul, // El color primario
      onPrimary: blanco, // El color de los elementos sobre el color primario
      secondary: azulClaro, // El color secundario
      onSecondary:
          blanco, // El color de los elementos sobre el color secundario
      error: Colors.red, // El color para mensajes de error
      onError: Colors.grey, // El color de los elementos sobre el color de error
      surface: Colors.grey[
          300]!, // El color de la superficie (generalmente para tarjetas, etc.)
      onSurface: gris!, // El color de los elementos sobre la superficie
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
          color: azul, fontSize: 28), // Titulo login/register/titulos dialog
      titleMedium: TextStyle(color: oscuro, fontSize: 30), // Titulos dialog
      titleSmall: TextStyle(color: Colors.amber),
      bodyLarge: TextStyle(color: oscuro),
      bodyMedium: TextStyle(color: oscuro, fontSize: 18),
      bodySmall: TextStyle(color: oscuro, fontSize: 14),
      labelLarge: TextStyle(color: oscuro, fontSize: 20),
      labelMedium:
          TextStyle(color: azul, fontSize: 16, fontWeight: FontWeight.bold),
      labelSmall: TextStyle(color: gris, fontSize: 14),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle:
          TextStyle(color: oscuro, fontSize: 16, fontWeight: FontWeight.bold),
      subtitleTextStyle: TextStyle(color: oscuro, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
          borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14)),
      labelStyle: TextStyle(color: Colors.grey),
      hintStyle: TextStyle(color: Colors.grey),
      counterStyle: TextStyle(color: Colors.grey),
      errorStyle: TextStyle(color: Colors.red),
      suffixIconColor: Colors.grey,
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
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white54,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: Colors.white, // Color del indicador
          width: 3, // Grosor fino para un look elegante
        ),
        insets: EdgeInsets.symmetric(vertical: 5), // Margen elegante
      ),
      labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      unselectedLabelStyle:
          TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      dividerColor: Colors.transparent,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: azul, foregroundColor: blancoTransparente),
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

  static ThemeData darkTheme = ThemeData(
    typography: Typography.material2018(),
    brightness: Brightness.dark,
    primaryColor: azul,
    scaffoldBackgroundColor: oscuro,
    appBarTheme: AppBarTheme(
      backgroundColor: oscuro,
      iconTheme: IconThemeData(color: blanco, size: 40),
      titleTextStyle: TextStyle(color: blanco, fontSize: 20),
    ),
    dividerColor: blancoTransparente,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: azul,
      onPrimary: blanco,
      secondary: azulClaro,
      onSecondary: blanco,
      error: Colors.red,
      onError: blanco,
      surface: Color(0xFF1E1E1E),
      onSurface: blanco,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: blanco, fontSize: 28),
      titleMedium: TextStyle(color: blanco, fontSize: 30),
      titleSmall: TextStyle(color: azulClaro),
      bodyLarge: TextStyle(color: blanco),
      bodyMedium: TextStyle(color: blanco, fontSize: 18),
      bodySmall: TextStyle(color: blanco, fontSize: 14),
      labelLarge: TextStyle(color: blanco, fontSize: 20),
      labelMedium: TextStyle(
          color: azulClaro, fontSize: 16, fontWeight: FontWeight.bold),
      labelSmall: TextStyle(color: gris, fontSize: 14),
    ),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      titleTextStyle:
          TextStyle(color: blanco, fontSize: 16, fontWeight: FontWeight.bold),
      subtitleTextStyle: TextStyle(color: blanco, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2A2A2A),
      border: OutlineInputBorder(
          borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14)),
      labelStyle: TextStyle(color: Colors.grey[300]),
      hintStyle: TextStyle(color: Colors.grey),
      counterStyle: TextStyle(color: Colors.grey),
      errorStyle: TextStyle(color: Colors.red),
      suffixIconColor: Colors.grey[300],
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
      backgroundColor: Color(0xFF1C1C1E),
      titleTextStyle: TextStyle(color: blanco, fontSize: 20),
      contentTextStyle: TextStyle(color: blanco),
    ),
    cardTheme: CardTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Color(0xFF2E2E2E),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: oscuro,
      selectedItemColor: azulClaro,
      unselectedItemColor: gris,
      selectedIconTheme: IconThemeData(size: 30),
      unselectedIconTheme: IconThemeData(size: 30),
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: blanco,
      unselectedLabelColor: Colors.white54,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: blanco, width: 3),
        insets: EdgeInsets.symmetric(vertical: 5),
      ),
      labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      unselectedLabelStyle:
          TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      dividerColor: Colors.transparent,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: azul,
      foregroundColor: blancoTransparente,
    ),
    dividerTheme: DividerThemeData(
      color: blancoTransparente,
      thickness: 0.5,
      space: 0,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black54,
      headerBackgroundColor: azul,
      headerForegroundColor: blanco,
      cancelButtonStyle: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(azulClaro),
      ),
      confirmButtonStyle: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(azulClaro),
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
        return oscuro;
      }),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return blanco;
        }
        return azulClaro;
      }),
      todayBorder: BorderSide(color: azul, width: 2),
    ),
  );
}
