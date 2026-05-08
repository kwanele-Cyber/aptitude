import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/feedback/presentation/widgets/session_review_section.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_material_bloc.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_note_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_bloc.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_event.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_state.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/sessions/presentation/widgets/session_materials_section.dart';
import 'package:myapp/features/sessions/presentation/widgets/session_notes_section.dart';
import 'package:myapp/injection_container.dart' as di;

class SessionDetailPage extends StatefulWidget {
  final SessionEntity session;
  final String userId;

  const SessionDetailPage({
    super.key,
    required this.session,
    required this.userId,
  });

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  late SessionEntity _session;
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  bool get _isInitiator => _session.initiatorId == widget.userId;

  bool get _isParticipant => _session.participantId == widget.userId;

  bool get _onWaitlist => _session.waitlistUserIds.contains(widget.userId);

  String _statusLabel(SessionStatus status) {
    switch (status) {
      case SessionStatus.scheduled:
        return 'Scheduled';
      case SessionStatus.confirmed:
        return 'Confirmed';
      case SessionStatus.inProgress:
        return 'In Progress';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.cancelled:
        return 'Cancelled';
      case SessionStatus.noShow:
        return 'No Show';
    }
  }

  Color _statusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.scheduled:
        return Colors.blue;
      case SessionStatus.confirmed:
        return Colors.green;
      case SessionStatus.inProgress:
        return Colors.orange;
      case SessionStatus.completed:
        return Colors.grey;
      case SessionStatus.cancelled:
        return Colors.red;
      case SessionStatus.noShow:
        return Colors.deepOrange;
    }
  }

  String _formatLabel(SessionFormat format) {
    switch (format) {
      case SessionFormat.online:
        return 'Online';
      case SessionFormat.inPerson:
        return 'In Person';
    }
  }

  String _cancellationPolicyLabel(CancellationPolicy policy) {
    switch (policy) {
      case CancellationPolicy.flexible:
        return 'Flexible - cancel anytime';
      case CancellationPolicy.moderate:
        return 'Moderate - 24h notice required';
      case CancellationPolicy.strict:
        return 'Strict - 48h notice required';
    }
  }

  String _recurrenceLabel(RecurrencePattern pattern) {
    switch (pattern) {
      case RecurrencePattern.none:
        return 'One-time session';
      case RecurrencePattern.daily:
        return 'Daily';
      case RecurrencePattern.weekly:
        return 'Weekly';
      case RecurrencePattern.biweekly:
        return 'Bi-weekly';
      case RecurrencePattern.monthly:
        return 'Monthly';
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }

  void _openCalendarLink() {
    final start = _session.scheduledStart.toIso8601String().replaceAll(
        RegExp(r'[-:]'), '').split('.').first;
    final end = _session.scheduledEnd.toIso8601String().replaceAll(
        RegExp(r'[-:]'), '').split('.').first;

    final uri = Uri.parse(
      'https://www.google.com/calendar/render?action=TEMPLATE'
      '&text=${Uri.encodeComponent('Skill Session: ${_session.skillTitle}')}'
      '&dates=$start/$end'
      '&details=${Uri.encodeComponent(_session.notes ?? 'Skill exchange session')}'
      '&location=${Uri.encodeComponent(_session.location ?? _session.meetingLink ?? '')}',
    );

    launchUrl(uri, mode: LaunchMode.externalApplication).then((success) {
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open calendar.')),
        );
      }
    });
  }

  void _confirmCancel() {
    final restriction = _session.cancellationRestrictionMessage(DateTime.now());
    if (restriction != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(restriction),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Session'),
        content: const Text(
          'Are you sure you want to cancel this session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Go Back'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SessionBloc>().add(
                    CancelSessionRequested(session: _session),
                  );
            },
            child: const Text('Cancel Session', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _verifyAttendance() {
    final code = _codeController.text.trim();
    if (code.isEmpty || code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit code'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    context.read<SessionBloc>().add(
      VerifyAttendanceRequested(
        sessionId: _session.id,
        userId: widget.userId,
        code: code,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Details')),
      body: BlocListener<SessionBloc, SessionState>(
        listener: (context, state) {
          if (state is SessionCancelled) {
            setState(() => _session = state.session);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session cancelled.'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is SessionStarted) {
            setState(() => _session = state.session);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session started!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is SessionCompleted) {
            setState(() => _session = state.session);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session completed!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is SessionUpdated) {
            setState(() => _session = state.session);
          }
          if (state is SessionConfirmed) {
            setState(() => _session = state.session);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session confirmed!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is WaitlistUpdated) {
            setState(() => _session = state.session);
          }
          if (state is SessionReminderToggled) {
            setState(() => _session = state.session);
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
            final isLoading = state is SessionActionLoading;
            final _authState = context.read<AuthBloc>().state;
            final _userName = _authState is AuthAuthenticated
                ? '${_authState.userEntity.firstName} ${_authState.userEntity.lastName}'
                : '';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status chip
                  Center(
                    child: Chip(
                      label: Text(
                        _statusLabel(_session.status),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _statusColor(_session.status),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Skill title
                  Text(
                    _session.skillTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'with ${_session.participantName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),

                  // Details card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailRow(Icons.calendar_today, 'Date',
                              '${_session.scheduledStart.month}/${_session.scheduledStart.day}/${_session.scheduledStart.year}'),
                          const Divider(),
                          _detailRow(Icons.access_time, 'Time',
                              '${_formatTime(_session.scheduledStart)} - ${_formatTime(_session.scheduledEnd)}'),
                          const Divider(),
                          _detailRow(Icons.videocam, 'Format',
                              _formatLabel(_session.format)),
                          if (_session.location != null) ...[
                            const Divider(),
                            _detailRow(Icons.location_on, 'Location',
                                _session.location!),
                          ],
                          if (_session.meetingLink != null) ...[
                            const Divider(),
                            _detailRow(Icons.link, 'Meeting Link',
                                _session.meetingLink!),
                          ],
                          const Divider(),
                          _detailRow(Icons.schedule, 'Duration',
                              '${_session.duration.inMinutes} min'),
                          const Divider(),
                          _detailRow(Icons.gavel, 'Cancellation',
                              _cancellationPolicyLabel(_session.cancellationPolicy)),
                          if (_session.recurrencePattern !=
                              RecurrencePattern.none) ...[
                            const Divider(),
                            _detailRow(Icons.repeat, 'Repeats',
                                _recurrenceLabel(_session.recurrencePattern)),
                          ],
                          if (_session.notes != null &&
                              _session.notes!.isNotEmpty) ...[
                            const Divider(),
                            _detailRow(Icons.notes, 'Notes', _session.notes!),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action buttons - scheduled / confirmed
                  if (_session.status == SessionStatus.scheduled ||
                      _session.status == SessionStatus.confirmed) ...[
                    // Start Session (confirmed + initiator)
                    if (_session.status == SessionStatus.confirmed &&
                        _isInitiator) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<SessionBloc>().add(
                                        StartSessionRequested(
                                            id: _session.id),
                                      );
                                },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Session'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Confirm Session (scheduled + participant)
                    if (_session.status == SessionStatus.scheduled &&
                        _isParticipant) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<SessionBloc>().add(
                                        ConfirmSessionRequested(
                                            id: _session.id),
                                      );
                                },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Confirm Session'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Cancel Session
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _confirmCancel,
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text('Cancel Session',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // In Progress - Verification & Complete
                  if (_session.status == SessionStatus.inProgress) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Attendance Verification',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium),
                            const SizedBox(height: 12),
                            // Code display (initiator only)
                            if (_isInitiator) ...[
                              Row(
                                children: [
                                  const Text('Session Code: '),
                                  Text(
                                    _session.verificationCode ?? '------',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 4,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.refresh),
                                    tooltip: 'Generate new code',
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            context
                                                .read<SessionBloc>()
                                                .add(
                                                  GenerateVerificationCodeRequested(
                                                    sessionId:
                                                        _session.id,
                                                    userId:
                                                        widget.userId,
                                                  ),
                                                );
                                          },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            // Code entry for both
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _codeController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter 6-digit code',
                                      labelText: 'Verification Code',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : _verifyAttendance,
                                  child: const Text('Verify'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Verification status
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                _verificationChip('Initiator',
                                    _session.initiatorVerified),
                                _verificationChip('Participant',
                                    _session.participantVerified),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Complete Session (initiator)
                    if (_isInitiator) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<SessionBloc>().add(
                                        CompleteSessionRequested(
                                            id: _session.id),
                                      );
                                },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Complete Session'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],

                  // Waitlist section
                  if (_session.maxParticipants != null &&
                      _session.maxParticipants! > 0) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Waitlist (${_session.waitlistUserIds.length} / ${_session.maxParticipants})',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    if (_onWaitlist)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<SessionBloc>().add(
                                        LeaveWaitlistRequested(
                                          sessionId: _session.id,
                                          userId: widget.userId,
                                        ),
                                      );
                                },
                          icon: const Icon(Icons.person_remove),
                          label: const Text('Leave Waitlist'),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<SessionBloc>().add(
                                        JoinWaitlistRequested(
                                          sessionId: _session.id,
                                          userId: widget.userId,
                                        ),
                                      );
                                },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Join Waitlist'),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],

                  // Reminder toggle
                  SwitchListTile(
                    title: const Text('Reminders'),
                    subtitle: const Text('24h and 1h before session'),
                    value: _session.remindersEnabled,
                    onChanged: isLoading
                        ? null
                        : (v) {
                            context.read<SessionBloc>().add(
                                  ToggleSessionReminderRequested(
                                    id: _session.id,
                                    enabled: v,
                                  ),
                                );
                          },
                  ),

                  // Edit and Calendar buttons
                  if (_isInitiator &&
                      (_session.status == SessionStatus.scheduled ||
                          _session.status == SessionStatus.confirmed)) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push('/sessions/create', extra: {
                            'matchId': _session.matchId,
                            'skillId': _session.skillId,
                            'skillTitle': _session.skillTitle,
                            'initiatorId': _session.initiatorId,
                            'participantId': _session.participantId,
                            'participantName': _session.participantName,
                          });
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Reschedule'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openCalendarLink,
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Add to Google Calendar'),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Session Feedback ---
                  if (_session.status == SessionStatus.completed)
                    SessionReviewSection(
                      sessionId: _session.id,
                      currentUserId: widget.userId,
                      currentUserName: _userName,
                      otherUserId: _isInitiator
                          ? _session.participantId
                          : _session.initiatorId,
                      otherUserName: _isInitiator
                          ? _session.participantName
                          : 'Your partner',
                    ),

                  // --- Session Materials (E14) ---
                  const Divider(),
                  const SizedBox(height: 16),
                  BlocProvider(
                    create: (_) => di.sl<SessionMaterialBloc>(),
                    child: SessionMaterialsSection(
                      sessionId: _session.id,
                      currentUserId: widget.userId,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Session Notes (E15) ---
                  const Divider(),
                  const SizedBox(height: 16),
                  BlocProvider(
                    create: (_) => di.sl<SessionNoteBloc>(),
                    child: SessionNotesSection(
                      sessionId: _session.id,
                      currentUserId: widget.userId,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _detailRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    ),
  );
}

Widget _verificationChip(String label, bool verified) {
  return Chip(
    avatar: Icon(
      verified ? Icons.check_circle : Icons.circle_outlined,
      size: 16,
      color: verified ? Colors.green : Colors.grey,
    ),
    label: Text(label, style: const TextStyle(fontSize: 12)),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );
}
