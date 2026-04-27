import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool acceptTerms = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String getErrorMessage(String error) {
    if (error.contains("email-already-in-use")) {
      return "This email is already registered";
    } else if (error.contains("weak-password")) {
      return "Password is too weak";
    } else if (error.contains("invalid-email")) {
      return "Invalid email format";
    } else {
      return "Registration failed";
    }
  }

  bool validateFields() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showMessage("Please fill in all fields");
      return false;
    }

    if (!emailController.text.contains("@") ||
        !emailController.text.contains(".")) {
      showMessage("Enter a valid email");
      return false;
    }

    if (passwordController.text.length < 6) {
      showMessage("Password must be at least 6 characters");
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showMessage("Passwords do not match");
      return false;
    }

    if (!acceptTerms) {
      showMessage("You must accept terms");
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(labelText: "First Name"),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(labelText: "Last Name"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),

              SizedBox(height: 10),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              SizedBox(height: 10),

              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword =
                        !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),

              SizedBox(height: 15),

              Row(
                children: [
                  Checkbox(
                    value: acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        acceptTerms = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: Text("I agree to Terms & Conditions"),
                  )
                ],
              ),

              SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                  if (!validateFields()) return;

                  setState(() => isLoading = true);

                  try {
                    final authService = AuthService();

                    final user = await authService.register(
                      firstName: firstNameController.text.trim(),
                      lastName: lastNameController.text.trim(),
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );

                    if (user != null) {
                      showMessage("Account created successfully");
                      if (mounted) context.pop();
                    }
                  } catch (e) {
                    showMessage(getErrorMessage(e.toString()));
                  }

                  setState(() => isLoading = false);
                },
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}