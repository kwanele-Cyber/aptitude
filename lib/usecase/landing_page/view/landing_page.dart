import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Landing Page")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to chat/general
            context.push('/chat/general');
          },
          child: const Text("Go to Chat"),
        ),
      ),
    );
  }
}

