import 'package:flutter/material.dart';
import 'package:myapp/usecase/auth/view/register_view_model.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<RegisterViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: authViewModel.displayNameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            TextField(
              controller: authViewModel.emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: authViewModel.passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: authViewModel.photoURLController,
              decoration: const InputDecoration(labelText: 'Photo URL'),
            ),
            TextField(
              controller: authViewModel.skillsController,
              decoration: const InputDecoration(
                labelText: 'Skills (comma-separated)',
              ),
            ),
            TextField(
              controller: authViewModel.interestsController,
              decoration: const InputDecoration(
                labelText: 'Interests (comma-separated)',
              ),
            ),
            TextField(
              controller: authViewModel.bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
            TextField(
              controller: authViewModel.locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 20),
            if (authViewModel.isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () async {
                  bool success = await authViewModel.signup();
                  if (success) {
                    // Navigate to home page or show success message
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          authViewModel.errorMessage ??
                              'An unknown error occurred.',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Register'),
              ),
          ],
        ),
      ),
    );
  }
}
