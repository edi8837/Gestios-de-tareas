import 'package:flutter/material.dart';
import 'task_list_screen.dart';
import 'task_chart_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GestionTareas',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Establecer una fuente general
        // ignore: prefer_const_constructors
        appBarTheme: AppBarTheme(
          color: const Color.fromARGB(255, 44, 132, 209), // Color personalizado para la AppBar
          elevation: 4, toolbarTextStyle: TextTheme(
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).bodyMedium, titleTextStyle: TextTheme(
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).titleLarge,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueAccent, // Color para los botones
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Bordes redondeados en los botones
          ),
          textTheme: ButtonTextTheme.primary, // Color del texto en los botones
        ),
        cardTheme: CardTheme(
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordes redondeados en las tarjetas
          ),
        ), colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: Colors.blueAccent),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => TaskListScreen(),
        '/stats': (context) => TaskChartScreen(),
      },
    );
  }
}

