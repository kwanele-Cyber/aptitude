import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/session.dart';
import 'package:myapp/usecase/session_execution/view_model/session_view_model.dart';
import 'package:myapp/usecase/session_execution/widgets/rating_dialog.dart';
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
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

  Widget _buildSessionCard(BuildContext context, Session session, SessionViewModel viewModel) {
    final dateStr = DateFormat('EEE, MMM d').format(session.startTime);
    final timeStr = DateFormat('jm').format(session.startTime);
    final isCompleted = session.status == SessionStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCompleted ? Colors.green.withOpacity(0.3) : Colors.transparent),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '$dateStr at $timeStr (${session.durationMinutes} min)',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF7C3AED)),
                  const SizedBox(width: 4),
                  Text(
                    session.location,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          if (!isCompleted)
            IconButton(
              onPressed: () => viewModel.completeSession(session),
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              tooltip: 'Complete',
            )
          else if (!session.isRated)
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
              icon: const Icon(Icons.star_outline, size: 16, color: Colors.amber),
              label: const Text('Rate', style: TextStyle(color: Colors.amber, fontSize: 12)),
            )
          else
            const Icon(Icons.check_circle, color: Colors.green, size: 24),
        ],
      ),
    );
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

