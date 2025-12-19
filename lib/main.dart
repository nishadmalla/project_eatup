import 'package:flutter/material.dart';
import 'package:project_eatup/screens/splash_screen.dart';
import 'package:project_eatup/theme/button_theme.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',

        // 🔹 GLOBAL BUTTON THEME
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppButtonTheme.primaryButton,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
