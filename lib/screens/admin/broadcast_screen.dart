import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final NotificationService _notificationService = NotificationService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Broadcast'), backgroundColor: Colors.deepPurple),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Enter message' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSending ? null : _sendBroadcast,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, minimumSize: const Size(double.infinity, 50)),
                child: _isSending ? const CircularProgressIndicator(color: Colors.white) : const Text('Send Broadcast', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendBroadcast() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);
    try {
      await _notificationService.sendBroadcastNotification(
        title: _titleController.text,
        body: _bodyController.text,
        type: 'announcement',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Broadcast sent!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }
}
