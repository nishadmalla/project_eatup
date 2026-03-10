import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_eatup/core/services/storage/token_service.dart';

// ⚠️ Double-check these import paths match your actual folders!
import 'package:project_eatup/screens/onbording_screen.dart'; 
import 'package:project_eatup/screens/dashboard_screen.dart'; // 👈 Your new Dashboard with the buttons

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // Start the timer to navigate
    _navigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange, 
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }

  Future<void> _navigate() async {
    // Wait for the splash animation to finish (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Instantly grab the token since SharedPreferences is already loaded
    final tokenService = ref.read(tokenServiceProvider);
    final token = tokenService.getToken();

    if (token != null && token.isNotEmpty) {
      // ✅ USER LOGGED IN -> Send to Dashboard (the screen with buttons!)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(), 
        ),
      );
    } else {
      // ❌ NOT LOGGED IN -> Send to Onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}