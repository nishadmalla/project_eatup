import 'package:flutter/material.dart';

class AppButtonTheme {
  AppButtonTheme._(); // private constructor

  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
    elevation: 0,
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    ),
  );
}
