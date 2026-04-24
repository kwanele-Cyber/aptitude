import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/usecase/sessions/session_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SessionSchedulingPage extends StatefulWidget {
  final String agreementId;

  const SessionSchedulingPage({super.key, required this.agreementId});

  @override
  State<SessionSchedulingPage> createState() => _SessionSchedulingPageState();
}

class _SessionSchedulingPageState extends State<SessionSchedulingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  double _duration = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Session', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F2027),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _titleController,
                  label: 'Session Title',
                  hint: 'e.g., Python Basics: Intro to Functions',
                  validator: (v) => v!.isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 24),
                _buildDateTimePicker(),
                const SizedBox(height: 24),
                _buildDurationPicker(),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _notesController,
                  label: 'Notes (Optional)',
                  hint: 'Topics to cover, meeting link, etc.',
                  maxLines: 3,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Schedule Session', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: _buildPickerCard(
            label: 'Date',
            value: DateFormat('MMM dd, yyyy').format(_selectedDate),
            icon: Icons.calendar_today,
            onTap: _pickDate,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPickerCard(
            label: 'Time',
            value: _selectedTime.format(context),
            icon: Icons.access_time,
            onTap: _pickTime,
          ),
        ),
      ],
    );
  }

  Widget _buildPickerCard({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, color: Colors.blueAccent, size: 16),
                const SizedBox(width: 8),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Duration (Hours)', style: TextStyle(color: Colors.white70, fontSize: 14)),
        Slider(
          value: _duration,
          min: 0.5,
          max: 4.0,
          divisions: 7,
          label: '$_duration hrs',
          activeColor: Colors.blueAccent,
          onChanged: (v) => setState(() => _duration = v),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0.5h', style: TextStyle(color: Colors.white38, fontSize: 12)),
            Text('$_duration hours', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Text('4.0h', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(context: context, initialTime: _selectedTime);
    if (time != null) setState(() => _selectedTime = time);
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final startTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await context.read<SessionViewModel>().scheduleSession(
            agreementId: widget.agreementId,
            title: _titleController.text,
            startTime: startTime,
            duration: _duration,
            notes: _notesController.text,
          );

      if (mounted) context.pop();
    }
  }
}
