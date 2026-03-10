import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_eatup/core/api/api_config.dart';
import 'package:project_eatup/core/services/hive/hive_service.dart';
import 'package:project_eatup/screens/splash_screen.dart';
import 'package:project_eatup/theme/button_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_eatup/core/services/storage/token_service.dart';

// ✅ Add a provider for your Base URL so other services can read it
final baseUrlProvider = Provider<String>((ref) => ApiConfig.baseUrl);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppButtonTheme.primaryButton,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}