import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/invite.dart';
import 'skill_chip.dart';

class InviteCard extends StatelessWidget {
  final Invite invite;
  final bool isReceived;
  final Function(InviteStatus status) onStatusUpdate;

  const InviteCard({
    super.key,
    required this.invite,
    required this.isReceived,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final name = isReceived ? invite.fromName : invite.toName;
    final status = invite.status;
    final commonSkills = invite.commonSkills;

    Color statusColor = Colors.orange;
    if (status == InviteStatus.accepted) statusColor = Colors.green;
    if (status == InviteStatus.rejected) statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.name.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (commonSkills.isNotEmpty)
                Text(
                  '${commonSkills.length} common skills',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
            ],
          ),
          if (commonSkills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: commonSkills
                  .take(3)
                  .map((s) => SkillChip(label: s))
                  .toList(),
            ),
          ],
          if (isReceived && status == InviteStatus.pending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onStatusUpdate(InviteStatus.rejected),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onStatusUpdate(InviteStatus.accepted),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
