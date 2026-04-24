import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
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
    if (error.contains("user-not-found")) {
      return "No account found with this email";
    } else if (error.contains("wrong-password")) {
      return "Incorrect password";
    } else if (error.contains("invalid-email")) {
      return "Invalid email format";
    } else {
      return "Login failed. Try again";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: Colors.blue),
              SizedBox(height: 20),

              Text(
                "Welcome Back",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 30),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 15),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                  setState(() => isLoading = true);

                  try {
                    final auth = AuthService();

                    final user = await auth.login(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );

                    if (user != null) {
                      showMessage("Login successful");
                    }
                  } catch (e) {
                    showMessage(getErrorMessage(e.toString()));
                  }

                  setState(() => isLoading = false);
                },
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Login"),
              ),

              SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Text("Forgot Password?"),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegisterScreen(),
                    ),
                  );
                },
                child: Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}