import 'package:flutter/material.dart';

class MockItem extends StatelessWidget {
  final String name;
  final String skill;
  final String match;
  const MockItem(
      {super.key, required this.name, required this.skill, required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE1E4E8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF4ECDC4),
            child: Text(
              name[0],
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  skill,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            match,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF4ECDC4),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}