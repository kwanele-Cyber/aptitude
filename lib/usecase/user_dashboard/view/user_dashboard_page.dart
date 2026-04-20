import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SkillExchangeLanding extends StatelessWidget {
  const SkillExchangeLanding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            _buildStats(),
            _buildFeatures(),
            _buildHowItWorks(),
            _buildMobileFeatures(),
            _buildSocialProof(),
            _buildCTA(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A4D8F), Color(0xFF2563A6)],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF4ECDC4), size: 14),
                SizedBox(width: 8),
                Text("Powered by Claude AI", style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Trade Skills,\nNot Money",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Learn guitar, teach coding, grow together with AI-powered skill matching",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
          ),
          const SizedBox(height: 32),
          
          // App Mockup
          _buildAppMockup(),

          const SizedBox(height: 32),
          
          // Buttons
          _buildDownloadButton(
            icon: Icons.apple,
            label: "App Store",
            subLabel: "Download on the",
          ),
          const SizedBox(height: 12),
          _buildDownloadButton(
            icon: Icons.play_arrow,
            label: "Google Play",
            subLabel: "Get it on",
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Try Web Demo →", style: TextStyle(color: Colors.white70)),
          )
        ],
      ),
    );
  }

  Widget _buildAppMockup() {
    return Container(
      width: 240,
      height: 380,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
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
                  gradient: LinearGradient(colors: [Color(0xFF1A4D8F), Color(0xFF2563A6)]),
                ),
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Skill Exchange", style: TextStyle(color: Colors.white, fontSize: 14)),
                    Text("Find your match", style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _buildMockItem("Sarah Chen", "Guitar Lessons", "98%"),
                    const SizedBox(height: 8),
                    _buildMockItem("David Kim", "Web Development", "92%"),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMockItem(String name, String skill, String match) {
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
            child: Text(name[0], style: const TextStyle(fontSize: 10, color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text(skill, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Text(match, style: const TextStyle(fontSize: 10, color: Color(0xFF4ECDC4), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDownloadButton({required IconData icon, required String label, required String subLabel}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF1A4D8F), size: 30),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subLabel, style: const TextStyle(fontSize: 10, color: Colors.black54)),
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A4D8F))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(value: "50K+", label: "Users"),
            _StatItem(value: "95%", label: "Match Rate"),
            _StatItem(value: "4.8★", label: "Rating"),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    final features = [
      ["AI-Powered Matching", "Claude AI finds perfect exchange partners instantly", Icons.auto_awesome],
      ["Smart Chat", "AI assistant helps coordinate skill swaps", Icons.message],
      ["Trust Scores", "Verified skills and safety ratings", Icons.verified],
      ["Notifications", "Never miss a match or message", Icons.notifications],
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text("Everything You Need", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ...features.map((f) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE1E4E8)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF3AB9B0)]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(f[2] as IconData, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f[0] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(f[1] as String, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                )
              ],
            ),
          )),
        ],
      ),
    );
  }

  // Simplified CTA for brevity
  Widget _buildCTA() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF1A4D8F), Color(0xFF2563A6)]),
      ),
      child: Column(
        children: [
          const Text("Ready to Start?", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Download now and find your first match", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A4D8F),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Download Free App"),
          )
        ],
      ),
    );
  }

  // Placeholder builders for remaining sections
  Widget _buildHowItWorks() => const SizedBox(height: 40);
  Widget _buildMobileFeatures() => const SizedBox(height: 40);
  Widget _buildSocialProof() => const SizedBox(height: 40);
  Widget _buildFooter() => Container(color: const Color(0xFF1F2937), height: 100);
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A4D8F))),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}