import 'package:flutter/material.dart';

import './mock_item.dart';

class AppMockup extends StatelessWidget {
  const AppMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 380,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 80,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A4D8F), Color(0xFF2563A6)],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Skill Exchange",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      "Find your match",
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: const [
                    MockItem(
                        name: "Sarah Chen",
                        skill: "Guitar Lessons",
                        match: "98%"),
                    SizedBox(height: 8),
                    MockItem(
                        name: "David Kim",
                        skill: "Web Development",
                        match: "92%"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}