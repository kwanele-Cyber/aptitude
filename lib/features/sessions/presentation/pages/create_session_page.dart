import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/core/validators/validators.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_bloc.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_event.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_state.dart';

class CreateSessionPage extends StatefulWidget {
  final String matchId;
  final String skillId;
  final String skillTitle;
  final String initiatorId;
  final String participantId;
  final String participantName;

  const CreateSessionPage({
    super.key,
    required this.matchId,
    required this.skillId,
    required this.skillTitle,
    required this.initiatorId,
    required this.participantId,
    required this.participantName,
  });

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);
  SessionFormat _format = SessionFormat.online;
  CancellationPolicy _cancellationPolicy = CancellationPolicy.moderate;
  RecurrencePattern _recurrencePattern = RecurrencePattern.none;
  final _locationController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  final _notesController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  bool _remindersEnabled = true;

  @override
  void dispose() {
    _locationController.dispose();
    _meetingLinkController.dispose();
    _notesController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final start = _combineDateAndTime(_selectedDate, _startTime);
    final end = _combineDateAndTime(_selectedDate, _endTime);

    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int? maxParticipants;
    if (_maxParticipantsController.text.trim().isNotEmpty) {
      maxParticipants = int.tryParse(_maxParticipantsController.text.trim());
    }

    context.read<SessionBloc>().add(
          CreateSessionRequested(
            matchId: widget.matchId,
            skillId: widget.skillId,
            skillTitle: widget.skillTitle,
            initiatorId: widget.initiatorId,
            participantId: widget.participantId,
            participantName: widget.participantName,
            scheduledStart: start,
            scheduledEnd: end,
            format: _format,
            cancellationPolicy: _cancellationPolicy,
            location:
                _format == SessionFormat.inPerson
                    ? _locationController.text.trim()
                    : null,
            meetingLink:
                _format == SessionFormat.online
                    ? _meetingLinkController.text.trim()
                    : null,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            recurrencePattern: _recurrencePattern,
            maxParticipants: maxParticipants,
            remindersEnabled: _remindersEnabled,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Session')),
      body: BlocListener<SessionBloc, SessionState>(
        listener: (context, state) {
          if (state is SessionCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, state.session);
          }
          if (state is SessionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<SessionBloc, SessionState>(
          builder: (context, state) {
            final isLoading = state is SessionLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Session with ${widget.participantName}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Skill: ${widget.skillTitle}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // Date
                    InkWell(
                      onTap: isLoading ? null : _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Start Time
                    InkWell(
                      onTap: isLoading ? null : () => _pickTime(isStart: true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(_startTime.format(context)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // End Time
                    InkWell(
                      onTap: isLoading ? null : () => _pickTime(isStart: false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(_endTime.format(context)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Format
                    DropdownButtonFormField<SessionFormat>(
                      initialValue: _format,
                      decoration: const InputDecoration(
                        labelText: 'Format',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: SessionFormat.online,
                          child: Text('Online'),
                        ),
                        DropdownMenuItem(
                          value: SessionFormat.inPerson,
                          child: Text('In Person'),
                        ),
                      ],
                      onChanged:
                          isLoading ? null : (v) {
                            if (v != null) setState(() => _format = v);
                          },
                    ),
                    const SizedBox(height: 16),

                    // Location or Meeting Link
                    if (_format == SessionFormat.inPerson)
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          hintText: 'e.g., Library Room 201',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => Validators.nonEmpty(v, fieldName: 'Location'),
                        enabled: !isLoading,
                      ),
                    if (_format == SessionFormat.online)
                      TextFormField(
                        controller: _meetingLinkController,
                        decoration: const InputDecoration(
                          labelText: 'Meeting Link',
                          hintText: 'e.g., https://zoom.us/j/...',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !isLoading,
                      ),
                    if (_format == SessionFormat.online)
                      const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'Any preparation or agenda...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Cancellation Policy
                    DropdownButtonFormField<CancellationPolicy>(
                      initialValue: _cancellationPolicy,
                      decoration: const InputDecoration(
                        labelText: 'Cancellation Policy',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: CancellationPolicy.flexible,
                          child: Text('Flexible - cancel anytime'),
                        ),
                        DropdownMenuItem(
                          value: CancellationPolicy.moderate,
                          child: Text('Moderate - 24h notice'),
                        ),
                        DropdownMenuItem(
                          value: CancellationPolicy.strict,
                          child: Text('Strict - 48h notice'),
                        ),
                      ],
                      onChanged:
                          isLoading ? null : (v) {
                            if (v != null) {
                              setState(() => _cancellationPolicy = v);
                            }
                          },
                    ),
                    const SizedBox(height: 16),

                    // Recurrence
                    DropdownButtonFormField<RecurrencePattern>(
                      initialValue: _recurrencePattern,
                      decoration: const InputDecoration(
                        labelText: 'Recurrence',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: RecurrencePattern.none,
                          child: Text('One-time session'),
                        ),
                        DropdownMenuItem(
                          value: RecurrencePattern.weekly,
                          child: Text('Weekly'),
                        ),
                        DropdownMenuItem(
                          value: RecurrencePattern.biweekly,
                          child: Text('Bi-weekly'),
                        ),
                        DropdownMenuItem(
                          value: RecurrencePattern.monthly,
                          child: Text('Monthly'),
                        ),
                      ],
                      onChanged:
                          isLoading ? null : (v) {
                            if (v != null) setState(() => _recurrencePattern = v);
                          },
                    ),
                    const SizedBox(height: 16),

                    // Max Participants
                    TextFormField(
                      controller: _maxParticipantsController,
                      decoration: const InputDecoration(
                        labelText: 'Max Participants (optional)',
                        hintText: 'Leave empty for 1-on-1',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Reminders toggle
                    SwitchListTile(
                      title: const Text('Enable Session Reminders'),
                      subtitle: const Text(
                        'Get notified 24h and 1h before the session',
                      ),
                      value: _remindersEnabled,
                      onChanged: isLoading ? null : (v) {
                        setState(() => _remindersEnabled = v);
                      },
                    ),
                    _SessionQualityPrediction(
                      recurrence: _recurrencePattern,
                      cancellationPolicy: _cancellationPolicy,
                      format: _format,
                      remindersEnabled: _remindersEnabled,
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Schedule Session'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SessionQualityPrediction extends StatelessWidget {
  final RecurrencePattern recurrence;
  final CancellationPolicy cancellationPolicy;
  final SessionFormat format;
  final bool remindersEnabled;

  const _SessionQualityPrediction({
    required this.recurrence,
    required this.cancellationPolicy,
    required this.format,
    required this.remindersEnabled,
  });

  int _computeQuality() {
    int score = 65;
    if (recurrence != RecurrencePattern.none) score += 15;
    if (remindersEnabled) score += 10;
    if (cancellationPolicy == CancellationPolicy.flexible) score += 5;
    if (cancellationPolicy == CancellationPolicy.strict) score -= 5;
    if (format == SessionFormat.online) score += 5;
    return score.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quality = _computeQuality();
    final isHigh = quality >= 70;
    final isMedium = quality >= 45;

    final color = isHigh
        ? const Color(0xFF2E7D32)
        : isMedium
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                'Predicted Session Quality',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$quality%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: quality / 100,
              backgroundColor: color.withValues(alpha: 0.12),
              color: color,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          if (recurrence == RecurrencePattern.none)
            _TipRow(
              icon: Icons.refresh,
              text: 'Recurring sessions have 85% completion vs 60% for one-off',
              theme: theme,
            ),
          if (!remindersEnabled)
            _TipRow(
              icon: Icons.notifications_off,
              text: 'Enabling reminders increases attendance by 20%',
              theme: theme,
            ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final ThemeData theme;

  const _TipRow({
    required this.icon,
    required this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
