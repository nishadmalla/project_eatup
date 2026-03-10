import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_eatup/core/api/api_config.dart';
import 'package:project_eatup/features/auth/presentation/state/auth_state.dart';
import 'package:project_eatup/features/auth/presentation/view_model/auth_view_model.dart';
 // ✅ Ensuring config is available

import 'signin_screen.dart';
import '../../../../widgets/app_text_field.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // ✅ Your ViewModel should use ApiConfig.baseUrl for the registration request
      await ref.read(authViewModelProvider.notifier).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (prev, next) {
      if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? "Registration Failed"),
            backgroundColor: Colors.red,
          ),
        );
      } else if (next.status == AuthStatus.registered) {
        // Success Debug Log for physical device
        debugPrint('🎉 REGISTRATION SUCCESS via ${ApiConfig.baseUrl}');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration Successful! Please Login."),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ Uses pushReplacement so user can't "Go Back" to Sign Up after success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade900,
              Colors.grey.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please sign up to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AppTextField(
                            label: 'NAME',
                            hintText: 'Full Name',
                            controller: _nameController,
                            prefixIcon: Icons.person_outline,
                            validator: (value) =>
                                value!.isEmpty ? 'Enter full name' : null,
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            label: 'EMAIL',
                            hintText: 'example@gmail.com',
                            controller: _emailController,
                            prefixIcon: Icons.email_outlined,
                            validator: (value) =>
                                value!.isEmpty ? 'Enter email' : null,
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            label: 'PASSWORD',
                            hintText: '•••••••••',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Enter password' : null,
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            label: 'RE-TYPE PASSWORD',
                            hintText: '•••••••••',
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() =>
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Confirm your password";
                              }
                              if (value != _passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: authState.status == AuthStatus.loading
                                  ? null
                                  : _register,
                              child: authState.status == AuthStatus.loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text('SIGN UP'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignInScreen()),
                              );
                            },
                            child: const Text(
                              'Already have an account? Sign In',
                              style: TextStyle(color: Colors.orange),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}