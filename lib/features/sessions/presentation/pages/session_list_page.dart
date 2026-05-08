import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_bloc.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_event.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_state.dart';

class SessionListPage extends StatefulWidget {
  final String userId;

  const SessionListPage({super.key, required this.userId});

  @override
  State<SessionListPage> createState() => _SessionListPageState();
}

class _SessionListPageState extends State<SessionListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<SessionBloc>().add(
          GetUserSessionsRequested(userId: widget.userId),
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sessions'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: BlocListener<SessionBloc, SessionState>(
        listener: (context, state) {
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
            if (state is SessionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            List<SessionEntity> allSessions = [];
            if (state is UserSessionsLoaded) {
              allSessions = state.sessions;
            }

            final now = DateTime.now();
            final upcoming = allSessions
                .where((s) =>
                    s.status == SessionStatus.scheduled ||
                    s.status == SessionStatus.confirmed)
                .where((s) => s.scheduledEnd.isAfter(now))
                .toList();
            final past = allSessions
                .where((s) =>
                    s.status == SessionStatus.completed ||
                    s.status == SessionStatus.inProgress ||
                    s.status == SessionStatus.noShow ||
                    (s.status == SessionStatus.scheduled &&
                        s.scheduledEnd.isBefore(now)))
                .toList();
            final cancelled = allSessions
                .where((s) => s.status == SessionStatus.cancelled)
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildSessionList(context, upcoming, 'No upcoming sessions'),
                _buildSessionList(context, past, 'No past sessions'),
                _buildSessionList(context, cancelled, 'No cancelled sessions'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSessionList(
      BuildContext context, List<SessionEntity> sessions, String emptyMsg) {
    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            emptyMsg,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SessionBloc>().add(
              GetUserSessionsRequested(userId: widget.userId),
            );
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text(
                session.skillTitle,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('with ${session.participantName}'),
                  Text(
                    '${session.scheduledStart.month}/${session.scheduledStart.day} '
                    '${session.scheduledStart.hour}:${session.scheduledStart.minute.toString().padLeft(2, '0')} - '
                    '${session.scheduledEnd.hour}:${session.scheduledEnd.minute.toString().padLeft(2, '0')}'),
                ],
              ),
              trailing: Chip(
                label: Text(
                  _statusLabel(session.status),
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
                backgroundColor: _statusColor(session.status),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              isThreeLine: true,
              onTap: () {
                context.push('/sessions/${widget.userId}/detail', extra: session);
              },
            ),
          );
        },
      ),
    );
  }
}
