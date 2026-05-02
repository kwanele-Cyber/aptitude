import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/agreement.dart';
import 'package:myapp/core/data/repositories/agreement_repository.dart';
import 'package:myapp/usecase/session_execution/view_model/session_view_model.dart';
import 'package:myapp/usecase/session_execution/widgets/schedule_session_sheet.dart';
import 'package:myapp/usecase/session_execution/widgets/session_list_sheet.dart';
import 'package:provider/provider.dart';

class AgreementMessageCard extends StatelessWidget {
  final String agreementId;
  final bool isMe;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;
  final Function(int sessionsCount, int minutesPerSession, String frequency)?
  onModify;

  const AgreementMessageCard({
    super.key,
    required this.agreementId,
    required this.isMe,
    this.onAccept,
    this.onReject,
    this.onCancel,
    this.onModify,
  });

  Future<void> _showModifyDialog(
    BuildContext context,
    Agreement agreement,
  ) async {
    final sessionsCtrl = TextEditingController(
      text: agreement.sessionsCount.toString(),
    );
    final minutesCtrl = TextEditingController(
      text: agreement.minutesPerSession.toString(),
    );
    final frequencyCtrl = TextEditingController(text: agreement.frequency);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modify Agreement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sessionsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Sessions'),
            ),
            TextField(
              controller: minutesCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Minutes/Session'),
            ),
            TextField(
              controller: frequencyCtrl,
              decoration: const InputDecoration(labelText: 'Frequency'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final sessions =
                  int.tryParse(sessionsCtrl.text) ?? agreement.sessionsCount;
              final minutes =
                  int.tryParse(minutesCtrl.text) ?? agreement.minutesPerSession;
              final frequency = frequencyCtrl.text.trim().isEmpty
                  ? agreement.frequency
                  : frequencyCtrl.text.trim();
              onModify?.call(sessions, minutes, frequency);
              Navigator.pop(context);
            },
            child: const Text('Submit Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, Agreement agreement) async {
    final isAccepted = agreement.status == AgreementStatus.accepted;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAccepted ? 'Cancel Agreement?' : 'Cancel Proposal?'),
        content: Text(
          isAccepted
              ? 'This will terminate the agreement and stop new sessions from being scheduled.'
              : 'This will withdraw the pending proposal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            onPressed: () {
              onCancel?.call();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Cancel Agreement'),
          ),
        ],
      ),
    );
  }

  Future<void> _showScheduling(BuildContext context, String aid) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => SessionViewModel(agreementId: aid),
        child: ScheduleSessionSheet(agreementId: aid),
      ),
    );
  }

  Future<void> _showSessionList(BuildContext context, String aid) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => SessionViewModel(agreementId: aid),
        child: SessionListSheet(agreementId: aid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = AgreementRepository();

    return FutureBuilder<Agreement?>(
      future: repo.getAgreement(agreementId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 50);
        final agreement = snapshot.data!;
        final isPending = agreement.status == AgreementStatus.pending;
        final isAccepted = agreement.status == AgreementStatus.accepted;
        final isTerminal =
            agreement.status == AgreementStatus.rejected ||
            agreement.status == AgreementStatus.completed ||
            agreement.status == AgreementStatus.cancelled;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isMe
                  ? const Color(0xFF7C3AED).withOpacity(0.5)
                  : Colors.white10,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.handshake_outlined,
                    color: Color(0xFF7C3AED),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isMe ? 'Proposal Sent' : 'New Swap Proposal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(agreement.status),
                ],
              ),
              const SizedBox(height: 12),
              _buildTermRow(
                Icons.swap_horiz,
                '${agreement.offerSkillId} ↔ ${agreement.requestSkillId}',
              ),
              _buildTermRow(
                Icons.event_repeat,
                '${agreement.sessionsCount} sessions, ${agreement.frequency}',
              ),
              _buildTermRow(
                Icons.timer_outlined,
                '${agreement.minutesPerSession} mins each',
              ),

              if (isAccepted) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showScheduling(context, agreement.id),
                    icon: const Icon(Icons.calendar_month, size: 16),
                    label: const Text('Schedule Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showSessionList(context, agreement.id),
                    icon: const Icon(Icons.list_alt, size: 16),
                    label: const Text('View Scheduled Sessions'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => _confirmCancel(context, agreement),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 16,
                      color: Colors.redAccent,
                    ),
                    label: const Text('Cancel Agreement'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],

              if (!isMe && isPending) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: onReject,
                        child: const Text(
                          'Decline',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (isMe && isPending) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _confirmCancel(context, agreement),
                      icon: const Icon(
                        Icons.cancel_outlined,
                        size: 14,
                        color: Colors.redAccent,
                      ),
                      label: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showModifyDialog(context, agreement),
                      icon: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.amber,
                      ),
                      label: const Text(
                        'Modify Terms',
                        style: TextStyle(color: Colors.amber, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
              if (isTerminal) ...[
                const SizedBox(height: 10),
                Text(
                  _terminalStatusText(agreement.status),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTermRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[300], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(AgreementStatus status) {
    Color color = Colors.orange;
    if (status == AgreementStatus.accepted) color = Colors.green;
    if (status == AgreementStatus.rejected) color = Colors.red;
    if (status == AgreementStatus.cancelled) color = Colors.redAccent;
    if (status == AgreementStatus.completed) color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _terminalStatusText(AgreementStatus status) {
    switch (status) {
      case AgreementStatus.rejected:
        return 'This proposal was declined.';
      case AgreementStatus.completed:
        return 'This agreement has been completed.';
      case AgreementStatus.cancelled:
        return 'This agreement was cancelled.';
      case AgreementStatus.pending:
      case AgreementStatus.accepted:
        return '';
    }
  }
}
