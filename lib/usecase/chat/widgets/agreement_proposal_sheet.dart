import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/agreement.dart';
import 'package:myapp/core/data/models/chat_channel.dart';
import 'package:uuid/uuid.dart';

class AgreementProposalSheet extends StatefulWidget {
  final String channelId;
  final String myId;
  final String peerId;
  final List<String> commonSkills;
  final Function(Agreement agreement) onPropose;

  const AgreementProposalSheet({
    super.key,
    required this.channelId,
    required this.myId,
    required this.peerId,
    required this.commonSkills,
    required this.onPropose,
  });

  @override
  State<AgreementProposalSheet> createState() => _AgreementProposalSheetState();
}

class _AgreementProposalSheetState extends State<AgreementProposalSheet> {
  late String _offerSkill;
  late String _requestSkill;
  int _sessions = 5;
  int _minutes = 60;
  String _frequency = 'Weekly';

  @override
  void initState() {
    super.initState();
    _offerSkill = widget.commonSkills.isNotEmpty ? widget.commonSkills[0] : 'Skill A';
    _requestSkill = widget.commonSkills.length > 1 ? widget.commonSkills[1] : 'Skill B';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Propose Swap Agreement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 24),
            
            // Skill Pairing
            Row(
              children: [
                Expanded(
                  child: _buildFieldLabel('I will teach'),
                ),
                const Icon(Icons.sync, color: Color(0xFF7C3AED), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFieldLabel('You will teach'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSkillSelector(_offerSkill, (val) => setState(() => _offerSkill = val!)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSkillSelector(_requestSkill, (val) => setState(() => _requestSkill = val!)),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            _buildFieldLabel('Number of Sessions'),
            Slider(
              value: _sessions.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              activeColor: const Color(0xFF7C3AED),
              label: '$_sessions sessions',
              onChanged: (val) => setState(() => _sessions = val.toInt()),
            ),
            
            const SizedBox(height: 12),
            _buildFieldLabel('Minutes per Session'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [30, 45, 60, 90, 120].map((m) {
                final selected = _minutes == m;
                return GestureDetector(
                  onTap: () => setState(() => _minutes = m),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF7C3AED) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$m m', style: TextStyle(color: selected ? Colors.white : Colors.grey)),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final agreement = Agreement(
                    id: const Uuid().v4(),
                    channelId: widget.channelId,
                    proposerId: widget.myId,
                    receiverId: widget.peerId,
                    offerSkillId: _offerSkill,
                    requestSkillId: _requestSkill,
                    sessionsCount: _sessions,
                    minutesPerSession: _minutes,
                    frequency: _frequency,
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                  );
                  widget.onPropose(agreement);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Send Proposal', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12));
  }

  Widget _buildSkillSelector(String current, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.commonSkills.contains(current) ? current : null,
          dropdownColor: const Color(0xFF1A1A2E),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          isExpanded: true,
          hint: const Text('Select', style: TextStyle(color: Colors.white24)),
          items: widget.commonSkills.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
