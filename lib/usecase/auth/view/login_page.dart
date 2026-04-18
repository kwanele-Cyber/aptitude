import 'package:flutter/material.dart';
import 'package:myapp/usecase/auth/view/login_view_model.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, loginViewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Login'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: loginViewModel.emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    controller: loginViewModel.passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  if (loginViewModel.isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: () async {
                        bool success = await loginViewModel.login();
                        if (success) {
                          // Navigate to home page or show success message
                        } else {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loginViewModel.errorMessage ?? 'An unknown error occurred.'),
                            ),
                          );
                        }
                      },
                      child: const Text('Login'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
