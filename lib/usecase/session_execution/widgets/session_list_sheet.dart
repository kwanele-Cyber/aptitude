import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/session.dart';
import 'package:myapp/usecase/session_execution/view_model/session_view_model.dart';
import 'package:myapp/usecase/session_execution/widgets/rating_dialog.dart';
import 'package:myapp/usecase/session_execution/widgets/schedule_session_sheet.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SessionListSheet extends StatefulWidget {
  final String agreementId;
  const SessionListSheet({super.key, required this.agreementId});

  @override
  State<SessionListSheet> createState() => _SessionListSheetState();
}

class _SessionListSheetState extends State<SessionListSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionViewModel>().loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SessionViewModel>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Scheduled Sessions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: viewModel.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                  )
                : viewModel.sessions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: viewModel.sessions.length,
                    itemBuilder: (context, index) {
                      final session = viewModel.sessions[index];
                      return _buildSessionCard(context, session, viewModel);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    Session session,
    SessionViewModel viewModel,
  ) {
    final dateStr = DateFormat('EEE, MMM d').format(session.startTime);
    final timeStr = DateFormat('jm').format(session.startTime);
    final isCompleted = session.status == SessionStatus.completed;
    final isCancelled = session.status == SessionStatus.cancelled;
    final isScheduled = session.status == SessionStatus.scheduled;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.3)
              : isCancelled
              ? Colors.redAccent.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            session.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildStatusChip(session.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dateStr at $timeStr (${session.durationMinutes} min)',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatLabel(session.format)} • ${session.attendeeIds.length}/${session.capacity} seats',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Color(0xFF7C3AED),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            session.location,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (session.reminderOffsetsMinutes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Reminders: ${_reminderLabel(session.reminderOffsetsMinutes)}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                    if (session.waitlistUserIds.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${session.waitlistUserIds.length} waiting',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            alignment: WrapAlignment.end,
            children: [
              if (isScheduled) ...[
                IconButton(
                  onPressed: () =>
                      _showEditSession(context, session, viewModel),
                  icon: const Icon(Icons.edit_calendar, color: Colors.white70),
                  tooltip: 'Update',
                ),
                IconButton(
                  onPressed: () => _confirmCancel(context, session, viewModel),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: Colors.redAccent,
                  ),
                  tooltip: 'Cancel',
                ),
                IconButton(
                  onPressed: () => viewModel.completeSession(session),
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  tooltip: 'Complete',
                ),
                if (session.isFull)
                  TextButton.icon(
                    onPressed: () => viewModel.joinWaitlist(session),
                    icon: const Icon(Icons.hourglass_bottom, size: 16),
                    label: const Text('Waitlist'),
                    style: TextButton.styleFrom(foregroundColor: Colors.amber),
                  ),
                if (session.calendarSyncEnabled)
                  IconButton(
                    onPressed: () =>
                        _showCalendarInvite(context, session, viewModel),
                    icon: const Icon(
                      Icons.calendar_month,
                      color: Color(0xFF60A5FA),
                    ),
                    tooltip: 'Calendar',
                  ),
              ],
              if (isCompleted && !session.isRated)
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ChangeNotifierProvider.value(
                        value: viewModel,
                        child: RatingDialog(session: session),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.star_outline,
                    size: 16,
                    color: Colors.amber,
                  ),
                  label: const Text(
                    'Rate',
                    style: TextStyle(color: Colors.amber, fontSize: 12),
                  ),
                )
              else if (isCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showEditSession(
    BuildContext context,
    Session session,
    SessionViewModel viewModel,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider.value(
        value: viewModel,
        child: ScheduleSessionSheet(
          agreementId: widget.agreementId,
          session: session,
        ),
      ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    Session session,
    SessionViewModel viewModel,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Session?'),
        content: const Text(
          'Sessions can only be cancelled more than 2 hours before they start.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            onPressed: () async {
              await viewModel.cancelSession(session);
              if (context.mounted) Navigator.pop(context);
              final error = viewModel.errorMessage;
              if (context.mounted && error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Cancel Session'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCalendarInvite(
    BuildContext context,
    Session session,
    SessionViewModel viewModel,
  ) {
    final invite = viewModel.buildCalendarInvite(session);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calendar Invite'),
        content: SingleChildScrollView(child: SelectableText(invite)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(SessionStatus status) {
    final color = switch (status) {
      SessionStatus.scheduled => const Color(0xFF60A5FA),
      SessionStatus.completed => Colors.green,
      SessionStatus.cancelled => Colors.redAccent,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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

  String _reminderLabel(List<int> offsets) {
    final labels = <String>[
      if (offsets.contains(1440)) '24h',
      if (offsets.contains(60)) '1h',
    ];
    return labels.isEmpty ? 'none' : labels.join(', ');
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text(
            'No sessions scheduled yet',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
