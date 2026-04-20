import 'package:flutter/material.dart';

import './widgets/cta_section.dart';
import './widgets/features_section.dart';
import './widgets/hero_section.dart';
import './widgets/stats_section.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(),
            StatsSection(),
            FeaturesSection(),
            HowItWorksSection(),
            MobileFeaturesSection(),
            SocialProofSection(),
            CtaSection(),
            FooterSection(),
          ],
        ),
      ),
    );
  }
}

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 40);
  }
}

class MobileFeaturesSection extends StatelessWidget {
  const MobileFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 40);
  }
}

class SocialProofSection extends StatelessWidget {
  const SocialProofSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 40);
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFF1F2937), height: 100);
  }
}