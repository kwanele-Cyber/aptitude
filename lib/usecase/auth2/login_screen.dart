import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:myapp/usecase/auth2/two_factor_verification_screen.dart';
import 'package:myapp/core/error/error_handler.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String getErrorMessage(String error) {
    return ErrorHandler.getMessage(error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              const Color(0xFF7C3AED).withOpacity(0.1),
              const Color(0xFF0F0F1A),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_person_outlined, size: 64, color: Color(0xFF7C3AED)),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign in to continue your skill exchange",
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/auth/forgot'),
                    child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFF7C3AED))),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() => isLoading = true);
                            try {
                              final auth = AuthService();
                              final fUser = await auth.login(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                              
                              if (fUser != null) {
                                final userModel = await auth.getCurrentUserModel();
                                if (userModel != null && userModel.twoFactorEnabled) {
                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TwoFactorVerificationScreen(uid: fUser.uid),
                                      ),
                                    );
                                  }
                                } else {
                                  if (mounted) context.go('/home');
                                }
                              }
                            } catch (e) {
                              showMessage(getErrorMessage(e.toString()));
                            }
                            if (mounted) setState(() => isLoading = false);
                          },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: TextStyle(color: Colors.grey[500])),
                    TextButton(
                      onPressed: () => context.push('/auth/register'),
                      child: const Text("Register", style: TextStyle(color: Color(0xFFEC4899), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
