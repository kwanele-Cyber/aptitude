import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/session.dart';
import 'package:myapp/usecase/session_execution/view_model/session_view_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ScheduleSessionSheet extends StatefulWidget {
  final String agreementId;
  final Session? session;
  const ScheduleSessionSheet({
    super.key,
    required this.agreementId,
    this.session,
  });

  @override
  State<ScheduleSessionSheet> createState() => _ScheduleSessionSheetState();
}

class _ScheduleSessionSheetState extends State<ScheduleSessionSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _duration;
  late SessionFormat _format;
  late int _capacity;
  late bool _remindDayBefore;
  late bool _remindHourBefore;
  late bool _calendarSyncEnabled;
  bool _isRecurring = false;
  int _occurrences = 4;

  bool get _isEditing => widget.session != null;

  @override
  void initState() {
    super.initState();
    final session = widget.session;
    _titleController = TextEditingController(
      text: session?.title ?? 'Skill Swap Session',
    );
    _locationController = TextEditingController(
      text: session?.location ?? 'Online',
    );
    final initialStart =
        session?.startTime ?? DateTime.now().add(const Duration(days: 1));
    _selectedDate = initialStart;
    _selectedTime = TimeOfDay.fromDateTime(initialStart);
    _duration = session?.durationMinutes ?? 60;
    _format = session?.format ?? SessionFormat.online;
    _capacity = session?.capacity ?? 2;
    final reminders = session?.reminderOffsetsMinutes ?? const [1440, 60];
    _remindDayBefore = reminders.contains(1440);
    _remindHourBefore = reminders.contains(60);
    _calendarSyncEnabled = session?.calendarSyncEnabled ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'Update Session' : 'Schedule Session',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField('Session Title', _titleController),
            const SizedBox(height: 16),
            _buildDateTimePicker(),
            const SizedBox(height: 16),
            _buildDurationDropdown(),
            const SizedBox(height: 16),
            _buildFormatDropdown(),
            const SizedBox(height: 16),
            _buildCapacityStepper(),
            const SizedBox(height: 16),
            _buildTextField('Location / Link', _locationController),
            const SizedBox(height: 16),
            _buildReminderOptions(),
            const SizedBox(height: 16),
            _buildCalendarOption(),
            if (!_isEditing) ...[
              const SizedBox(height: 16),
              _buildRecurringOptions(),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Save Changes' : 'Confirm Schedule',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
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
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
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
          child: _buildPickerBox(
            'Date',
            dateStr,
            Icons.calendar_today,
            () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
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

  Widget _buildPickerBox(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
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
              color: Colors.white.withValues(alpha: 0.05),
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
        Text(
          'Duration',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
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

  Widget _buildFormatDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Format', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<SessionFormat>(
            value: _format,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF1A1A2E),
            style: const TextStyle(color: Colors.white),
            items: SessionFormat.values.map((format) {
              return DropdownMenuItem(
                value: format,
                child: Text(_formatLabel(format)),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _format = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCapacityStepper() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Capacity',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ),
        IconButton(
          onPressed: _capacity > 1
              ? () => setState(() => _capacity -= 1)
              : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: Colors.white70,
        ),
        Text(
          '$_capacity',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => setState(() => _capacity += 1),
          icon: const Icon(Icons.add_circle_outline),
          color: Colors.white70,
        ),
      ],
    );
  }

  Widget _buildReminderOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminders',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        CheckboxListTile(
          value: _remindDayBefore,
          onChanged: (value) =>
              setState(() => _remindDayBefore = value ?? true),
          activeColor: const Color(0xFF7C3AED),
          contentPadding: EdgeInsets.zero,
          title: const Text(
            '24 hours before',
            style: TextStyle(color: Colors.white),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          value: _remindHourBefore,
          onChanged: (value) =>
              setState(() => _remindHourBefore = value ?? true),
          activeColor: const Color(0xFF7C3AED),
          contentPadding: EdgeInsets.zero,
          title: const Text(
            '1 hour before',
            style: TextStyle(color: Colors.white),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildCalendarOption() {
    return SwitchListTile(
      value: _calendarSyncEnabled,
      onChanged: (value) => setState(() => _calendarSyncEnabled = value),
      activeThumbColor: const Color(0xFF7C3AED),
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'Calendar export enabled',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildRecurringOptions() {
    return Column(
      children: [
        SwitchListTile(
          value: _isRecurring,
          onChanged: (value) => setState(() => _isRecurring = value),
          activeThumbColor: const Color(0xFF7C3AED),
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Repeat weekly',
            style: TextStyle(color: Colors.white),
          ),
        ),
        if (_isRecurring)
          Row(
            children: [
              Expanded(
                child: Text(
                  'Occurrences',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ),
              IconButton(
                onPressed: _occurrences > 2
                    ? () => setState(() => _occurrences -= 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.white70,
              ),
              Text(
                '$_occurrences',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _occurrences += 1),
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.white70,
              ),
            ],
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

    final reminders = <int>[
      if (_remindDayBefore) 1440,
      if (_remindHourBefore) 60,
    ];
    final viewModel = context.read<SessionViewModel>();

    if (_isEditing) {
      await viewModel.updateSessionDetails(
        session: widget.session!,
        title: _titleController.text,
        startTime: startTime,
        durationMinutes: _duration,
        location: _locationController.text,
        format: _format,
        reminderOffsetsMinutes: reminders,
        calendarSyncEnabled: _calendarSyncEnabled,
        capacity: _capacity,
      );
    } else if (_isRecurring) {
      await viewModel.scheduleRecurringSessions(
        title: _titleController.text,
        firstStartTime: startTime,
        durationMinutes: _duration,
        location: _locationController.text,
        format: _format,
        occurrences: _occurrences,
        reminderOffsetsMinutes: reminders,
        calendarSyncEnabled: _calendarSyncEnabled,
        capacity: _capacity,
      );
    } else {
      await viewModel.scheduleSession(
        title: _titleController.text,
        startTime: startTime,
        durationMinutes: _duration,
        location: _locationController.text,
        format: _format,
        reminderOffsetsMinutes: reminders,
        calendarSyncEnabled: _calendarSyncEnabled,
        capacity: _capacity,
      );
    }

    if (mounted) {
      final error = viewModel.errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
        );
        return;
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Session updated' : 'Session scheduled'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatLabel(SessionFormat format) {
    switch (format) {
      case SessionFormat.online:
        return 'Online';
      case SessionFormat.inPerson:
        return 'In person';
      case SessionFormat.hybrid:
        return 'Hybrid';
    }
  }
}
