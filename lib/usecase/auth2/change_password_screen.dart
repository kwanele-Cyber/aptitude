import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  bool isLoading = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> changePassword() async {
    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user!.email!;

      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: oldPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPasswordController.text.trim());

      showMessage("Password updated successfully");
      if (mounted) context.pop();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        showMessage("Old password is incorrect");
      } else if (e.code == 'weak-password') {
        showMessage("New password is too weak");
      } else {
        showMessage("Error: ${e.message}");
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Old Password"),
            ),
            SizedBox(height: 15),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "New Password"),
            ),
            SizedBox(height: 30),

            ElevatedButton(
              onPressed: isLoading ? null : changePassword,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Update Password"),
            ),
          ],
        ),
      ),
    );
  }
}