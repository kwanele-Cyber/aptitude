import 'package:flutter/material.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:myapp/usecase/skill_match/home_screen.dart';

class TwoFactorVerificationScreen extends StatefulWidget {
  final String uid;
  const TwoFactorVerificationScreen({super.key, required this.uid});

  @override
  State<TwoFactorVerificationScreen> createState() => _TwoFactorVerificationScreenState();
}

class _TwoFactorVerificationScreenState extends State<TwoFactorVerificationScreen> {
  final _pinController = TextEditingController();
  bool _verifying = false;
  String? _error;

  void _verify() async {
    if (_pinController.text.length != 6) return;

    setState(() {
      _verifying = true;
      _error = null;
    });

    try {
      final auth = AuthService();
      final isValid = await auth.verify2FAPin(widget.uid, _pinController.text);

      if (isValid) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        setState(() => _error = 'Invalid security PIN');
      }
    } catch (e) {
      setState(() => _error = 'Verification failed: $e');
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_person_outlined, size: 80, color: Color(0xFF7C3AED)),
              const SizedBox(height: 32),
              const Text(
                'Security Check',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your 6-digit PIN to continue',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (val) {
                  if (val.length == 6) _verify();
                },
                style: const TextStyle(color: Colors.white, fontSize: 32, letterSpacing: 12),
                decoration: InputDecoration(
                  counterText: '',
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[800]!)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF7C3AED))),
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 48),
              if (_verifying)
                const CircularProgressIndicator(color: Color(0xFF7C3AED))
              else
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
