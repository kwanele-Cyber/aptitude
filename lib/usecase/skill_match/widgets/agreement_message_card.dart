import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/agreement.dart';
import 'package:myapp/core/data/repositories/agreement_repository.dart';

class AgreementMessageCard extends StatelessWidget {
  final String agreementId;
  final bool isMe;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const AgreementMessageCard({
    super.key,
    required this.agreementId,
    required this.isMe,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final repo = AgreementRepository();

    return FutureBuilder<Agreement?>(
      future: repo.getAgreement(agreementId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 50);
        final agreement = snapshot.data!;
        final isPending = agreement.status == AgreementStatus.pending;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isMe ? const Color(0xFF7C3AED).withOpacity(0.5) : Colors.white10,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.handshake_outlined, color: Color(0xFF7C3AED), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    isMe ? 'Proposal Sent' : 'New Swap Proposal',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Spacer(),
                  _buildStatusChip(agreement.status),
                ],
              ),
              const SizedBox(height: 12),
              _buildTermRow(Icons.swap_horiz, '${agreement.offerSkillId} ↔ ${agreement.requestSkillId}'),
              _buildTermRow(Icons.event_repeat, '${agreement.sessionsCount} sessions, ${agreement.frequency}'),
              _buildTermRow(Icons.timer_outlined, '${agreement.minutesPerSession} mins each'),
              
              if (!isMe && isPending) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: onReject,
                        child: const Text('Decline', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Accept', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }
}
