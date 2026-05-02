import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/usecase/skill_match/skill_details_screen.dart';
import 'package:myapp/usecase/profile/public_profile_screen.dart';
import 'skill_chip.dart';

import 'package:myapp/core/data/models/match_result.dart';

class MatchCard extends StatelessWidget {
  final MatchResult result;
  final VoidCallback onConnect;
  final VoidCallback onReject;
  final VoidCallback onIgnore;
  final VoidCallback onSave;

  const MatchCard({
    super.key,
    required this.result,
    required this.onConnect,
    required this.onReject,
    required this.onIgnore,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final user = result.peer;
    final initials =
        '${user.firstName.isNotEmpty ? user.firstName[0] : '?'}'
        '${user.lastName.isNotEmpty ? user.lastName[0] : ''}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: result.isReciprocal 
              ? const Color(0xFF7C3AED).withOpacity(0.5) 
              : Colors.white.withOpacity(0.06),
          width: result.isReciprocal ? 2 : 1,
        ),
      ),
            child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push('/profile/${user.uid}'),
            child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (result.isReciprocal)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.sync, size: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (result.isReciprocal) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SWAP',
                            style: TextStyle(
                              color: Color(0xFF22C55E),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.title,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  
                  // Match Reason / Context
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      result.isReciprocal 
                          ? 'Reciprocal: ${result.matchingOffers.first.skillName} ↔ ${result.matchingRequests.first.skillName}'
                          : 'Offers: ${result.matchingOffers.first.skillName}',
                      style: const TextStyle(
                        color: Color(0xFF9D6FEF),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: result.matchingOffers
                        .map((o) => SkillChip(
                          label: o.skillName,
                          onTap: () => context.push('/skill/${o.sid}?name=${Uri.encodeComponent(o.skillName)}'),
                        ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                GestureDetector(
                  onTap: onConnect,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Connect',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: onIgnore,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 20),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(color: Colors.white30, fontSize: 10),
                  ),
                ),
                const SizedBox(height: 4),
                IconButton(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, color: Colors.white10, size: 14),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Dismiss permanently',
                ),
              ],
            ),
          ],
        ),
      ),
          Positioned(
            top: -10,
            right: -10,
            child: IconButton(
              onPressed: onSave,
              icon: const Icon(Icons.bookmark_border, color: Colors.white24, size: 20),
              tooltip: 'Save for later',
            ),
          ),
        ],
      ),
    );
  }
}
