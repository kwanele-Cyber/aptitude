import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/user.dart';
import 'skill_chip.dart';

class MatchCard extends StatelessWidget {
  final User user;
  final List<String> commonSkills;
  final VoidCallback onConnect;

  const MatchCard({
    super.key,
    required this.user,
    required this.commonSkills,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final initials =
        '${user.firstName.isNotEmpty ? user.firstName[0] : '?'}'
        '${user.lastName.isNotEmpty ? user.lastName[0] : ''}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.title,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                if (user.location.address.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 2),
                      Text(
                        user.location.address,
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: commonSkills
                      .take(3)
                      .map((s) => SkillChip(label: s))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
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
        ],
      ),
    );
  }
}
