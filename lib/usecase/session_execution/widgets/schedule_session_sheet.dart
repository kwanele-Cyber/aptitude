import 'package:flutter/material.dart';
import 'package:myapp/usecase/session_execution/view_model/session_view_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ScheduleSessionSheet extends StatefulWidget {
  final String agreementId;
  const ScheduleSessionSheet({super.key, required this.agreementId});

  @override
  State<ScheduleSessionSheet> createState() => _ScheduleSessionSheetState();
}

class _ScheduleSessionSheetState extends State<ScheduleSessionSheet> {
  final _titleController = TextEditingController(text: 'Skill Swap Session');
  final _locationController = TextEditingController(text: 'Online');
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 0);
  int _duration = 60;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schedule Session',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),
          _buildTextField('Session Title', _titleController),
          const SizedBox(height: 16),
          _buildDateTimePicker(),
          const SizedBox(height: 16),
          _buildDurationDropdown(),
          const SizedBox(height: 16),
          _buildTextField('Location / Link', _locationController),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirm Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    final dateStr = DateFormat('EEE, MMM d').format(_selectedDate);
    final timeStr = _selectedTime.format(context);

    return Row(
      children: [
        Expanded(
          child: _buildPickerBox('Date', dateStr, Icons.calendar_today, () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          }),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPickerBox('Time', timeStr, Icons.access_time, () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _selectedTime,
            );
            if (picked != null) setState(() => _selectedTime = picked);
          }),
        ),
      ],
    );
  }

  Widget _buildPickerBox(String label, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: const Color(0xFF7C3AED)),
                const SizedBox(width: 8),
                Text(value, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Duration', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<int>(
            value: _duration,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF1A1A2E),
            style: const TextStyle(color: Colors.white),
            items: [30, 60, 90, 120].map((m) {
              return DropdownMenuItem(value: m, child: Text('$m Minutes'));
            }).toList(),
            onChanged: (val) => setState(() => _duration = val!),
          ),
        ),
      ],
    );
  }

  void _submit() async {
    final startTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    await context.read<SessionViewModel>().scheduleSession(
      title: _titleController.text,
      startTime: startTime,
      durationMinutes: _duration,
      location: _locationController.text,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session scheduled successfully!'), backgroundColor: Colors.green),
      );
    }
  }
}

