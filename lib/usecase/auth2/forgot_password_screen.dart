import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isLoading = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> resetPassword() async {
    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      showMessage("Password reset email sent!");
      if (mounted) context.pop();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showMessage("No user found with this email");
      } else if (e.code == 'invalid-email') {
        showMessage("Invalid email address");
      } else {
        showMessage("Error: ${e.message}");
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.lock_reset, size: 80, color: Colors.blue),
            SizedBox(height: 20),

            Text(
              "Enter your email to reset password",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: isLoading ? null : resetPassword,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Send Reset Email"),
            ),
          ],
        ),
      ),
    );
  }
}