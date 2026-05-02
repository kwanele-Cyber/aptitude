import 'package:flutter/material.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:myapp/core/data/models/user.dart';

class TwoFactorSetupScreen extends StatefulWidget {
  final User userData;
  const TwoFactorSetupScreen({super.key, required this.userData});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  late bool _enabled;
  final _pinController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _enabled = widget.userData.twoFactorEnabled;
    if (_enabled) {
      _pinController.text = widget.userData.twoFactorPin ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Text('Two-Factor Authentication', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enable 2FA', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Secure your account with a PIN', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                Switch(
                  value: _enabled,
                  onChanged: (val) => setState(() => _enabled = val),
                  activeColor: const Color(0xFF7C3AED),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_enabled) ...[
              const Text('Set 6-Digit PIN', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 12),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  counterStyle: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFF7C3AED), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Two-Factor Authentication adds an extra layer of security to your account by requiring a PIN upon login.',
              style: TextStyle(color: Colors.grey[300], fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  void _save() async {
    if (_enabled && _pinController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be exactly 6 digits')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final userRepo = UserRepository();
      await userRepo.update(widget.userData.uid, {
        'twoFactorEnabled': _enabled,
        'twoFactorPin': _enabled ? _pinController.text : null,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Security settings updated'), backgroundColor: Color(0xFF10B981)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
