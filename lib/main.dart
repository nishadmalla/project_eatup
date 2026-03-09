import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_eatup/core/services/hive/hive_service.dart';
import 'package:project_eatup/screens/splash_screen.dart';
import 'package:project_eatup/theme/button_theme.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  runApp(ProviderScope(
    overrides: [
      hiveServiceProvider.overrideWithValue(hiveService),
    ],
    child: const MyApp()));
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
