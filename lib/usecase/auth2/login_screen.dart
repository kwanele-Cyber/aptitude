import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_service.dart';

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
                  bool success=false;

                  try {
                    final auth = AuthService();

                    final user = await auth.login(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );

                    if (user != null) {
                      success = true;
                      showMessage("Login successful");
                    }
                  } catch (e) {
                    showMessage(getErrorMessage(e.toString()));
                  }

                  setState(() => isLoading = false);    
                  if(success){
                      if (mounted) {
                        // ignore: use_build_context_synchronously
                        context.go('/home');
                      } else {
                        throw GoException("faild to navigate to home becase context is not mounted");
                      }
                  }              
                },
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Login"),
              ),

              SizedBox(height: 10),

              TextButton(
                onPressed: () => context.push('/auth/forgot'),
                child: Text("Forgot Password?"),
              ),

              TextButton(
                onPressed: () => context.push('/auth/register'),
                child: Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}