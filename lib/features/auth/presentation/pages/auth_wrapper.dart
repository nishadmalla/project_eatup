import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ⚠️ Make sure these import paths match your project structure!
import 'package:project_eatup/features/auth/presentation/pages/signin_screen.dart';
import 'package:project_eatup/screens/dashboard_screen.dart';
import 'package:project_eatup/core/services/storage/token_service.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Access your TokenService
    final tokenService = ref.read(tokenServiceProvider);
    
    // 2. Grab the saved token
    final token = tokenService.getToken();

    // 3. Traffic Director: Where should the user go?
    if (token != null && token.isNotEmpty) {
      print("✅ Persistent Login: Token found! Routing to Dashboard.");
      return const DashboardScreen();
    } else {
      print("❌ Persistent Login: No token. Routing to Sign In.");
      return const SignInScreen();
    }
  }
}