import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// X08 – Appeal Decision
/// Allows a user to request a review of an admin's dispute resolution.
/// Only available when dispute status is [resolved] or [dismissed].
/// Users provide grounds for appeal + optional new evidence.
class AppealDecisionScreen extends StatefulWidget {
  final AppealDisputeDetail dispute;

  const AppealDecisionScreen({super.key, required this.dispute});

  @override
  State<AppealDecisionScreen> createState() => _AppealDecisionScreenState();
}

class _AppealDecisionScreenState extends State<AppealDecisionScreen> {
  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _groundsController = TextEditingController();
  final _newEvidenceNoteController = TextEditingController();

  AppealGround? _selectedGround;
  final List<File> _newEvidenceImages = [];
  final ImagePicker _picker = ImagePicker();

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isSubmitting = false;
  bool _agreedToTerms = false;

  // ── Palette ───────────────────────────────────────────────────────────────
  static const Color _primary = Color(0xFF5B4FCF);
  static const Color _amber   = Color(0xFFF59E0B);

  static const Color _bg      = Color(0xFFF6F7FB);

  // ── Appeal grounds ────────────────────────────────────────────────────────
  final List<_GroundOption> _grounds = [
    _GroundOption(
      ground: AppealGround.newEvidence,
      label: 'New Evidence Available',
      description: 'I have new proof that was not considered.',
      icon: Icons.add_photo_alternate_rounded,
      color: Color(0xFF5B4FCF),
    ),
    _GroundOption(
      ground: AppealGround.proceduralError,
      label: 'Procedural Error',
      description: 'The review process was not followed correctly.',
      icon: Icons.rule_rounded,
      color: Color(0xFFF59E0B),
    ),
    _GroundOption(
      ground: AppealGround.biasedDecision,
      label: 'Biased / Unfair Decision',
      description: 'The resolution was not impartial.',
      icon: Icons.balance_rounded,
      color: Color(0xFFEF4444),
    ),
    _GroundOption(
      ground: AppealGround.misrepresentedFacts,
      label: 'Facts Misrepresented',
      description: 'Key facts were inaccurate or ignored.',
      icon: Icons.find_in_page_rounded,
      color: Color(0xFF10B981),
    ),
  ];

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _showSnack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _pickImage() async {
    if (_newEvidenceImages.length >= 3) {
      _showSnack('Maximum 3 images allowed.');
      return;
    }
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _newEvidenceImages.add(File(picked.path)));
  }

  void _removeImage(int i) =>
      setState(() => _newEvidenceImages.removeAt(i));

  Future<void> _submitAppeal() async {
    if (_selectedGround == null) {
      _showSnack('Please select the grounds for your appeal.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _showSnack('Please confirm you understand the appeal policy.');
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: Replace with your DisputeRepository call, e.g.:
    // await DisputeRepository.submitAppeal(
    //   disputeId        : widget.dispute.id,
    //   ground           : _selectedGround!,
    //   grounds          : _groundsController.text.trim(),
    //   newEvidenceNote  : _newEvidenceNoteController.text.trim(),
    //   newEvidenceFiles : _newEvidenceImages,
    // );
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);
    if (!mounted) return;

    _showSnack('Appeal submitted. A senior reviewer will assess within 5 business days.');
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _groundsController.dispose();
    _newEvidenceNoteController.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Appeal Decision',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Original decision banner ──────────────────────────────
            _OriginalDecisionBanner(dispute: widget.dispute),
            const SizedBox(height: 24),

            // ── Appeal window warning ─────────────────────────────────
            _AppealWindowBanner(daysRemaining: widget.dispute.appealDaysRemaining),
            const SizedBox(height: 24),

            // ── Grounds selection ─────────────────────────────────────
            _label('Grounds for Appeal *'),
            const SizedBox(height: 10),
            ..._grounds.map((g) => _GroundCard(
                  option: g,
                  isSelected: _selectedGround == g.ground,
                  onTap: () => setState(() => _selectedGround = g.ground),
                )),
            const SizedBox(height: 20),

            // ── Written grounds ───────────────────────────────────────
            _label('Explain Your Grounds *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _groundsController,
              maxLines: 6,
              maxLength: 600,
              decoration: _inputDeco(
                hint:
                    'Describe clearly why the decision should be reviewed. '
                    'Reference specific facts, timelines, or evidence…',
              ),
              validator: (v) {
                if (v == null || v.trim().length < 40) {
                  return 'Please provide at least 40 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── New evidence ──────────────────────────────────────────
            _label('New Evidence (optional)'),
            const SizedBox(height: 4),
            Text(
              'Only attach evidence that was NOT included in the original dispute.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 10),
            _EvidencePickerRow(
              images: _newEvidenceImages,
              onAdd: _pickImage,
              onRemove: _removeImage,
            ),
            const SizedBox(height: 14),
            if (_newEvidenceImages.isNotEmpty) ...[
              TextFormField(
                controller: _newEvidenceNoteController,
                maxLines: 3,
                maxLength: 300,
                decoration: _inputDeco(
                    hint: 'Briefly describe what this new evidence shows…'),
              ),
              const SizedBox(height: 20),
            ],

            // ── Policy checkbox ───────────────────────────────────────
            _PolicyCheckbox(
              agreed: _agreedToTerms,
              onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
              primary: _primary,
            ),
            const SizedBox(height: 28),

            // ── Submit ────────────────────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAppeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _amber,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Submit Appeal',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87),
      );

  InputDecoration _inputDeco({required String hint}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// Original Decision Banner
// ═══════════════════════════════════════════════════════════════════════════

class _OriginalDecisionBanner extends StatelessWidget {
  final AppealDisputeDetail dispute;
  const _OriginalDecisionBanner({required this.dispute});

  Color get _outcomeColor {
    switch (dispute.outcome) {
      case DisputeOutcomeType.favourComplainant: return const Color(0xFF10B981);
      case DisputeOutcomeType.favourRespondent:  return const Color(0xFFEF4444);
      case DisputeOutcomeType.dismissed:         return const Color(0xFF5B4FCF);
    }
  }

  String get _outcomeLabel {
    switch (dispute.outcome) {
      case DisputeOutcomeType.favourComplainant: return 'Ruled: Favour Complainant';
      case DisputeOutcomeType.favourRespondent:  return 'Ruled: Favour Respondent';
      case DisputeOutcomeType.dismissed:         return 'Dismissed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gavel_rounded,
                  color: Colors.black54, size: 16),
              const SizedBox(width: 8),
              const Text('Original Decision',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.black54)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _outcomeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _outcomeColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _outcomeLabel,
                  style: TextStyle(
                      color: _outcomeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(dispute.sessionTitle,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            'Resolved on ${dispute.resolvedDate}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              dispute.resolutionNote,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Appeal Window Banner
// ═══════════════════════════════════════════════════════════════════════════

class _AppealWindowBanner extends StatelessWidget {
  final int daysRemaining;
  const _AppealWindowBanner({required this.daysRemaining});

  @override
  Widget build(BuildContext context) {
    final isUrgent = daysRemaining <= 2;
    final color = isUrgent ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isUrgent ? Icons.timer_rounded : Icons.hourglass_top_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                children: [
                  const TextSpan(text: 'Appeal window closes in '),
                  TextSpan(
                    text: '$daysRemaining day${daysRemaining == 1 ? '' : 's'}',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: color),
                  ),
                  const TextSpan(
                      text:
                          '. Appeals are only accepted within 7 days of resolution.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Ground Card
// ═══════════════════════════════════════════════════════════════════════════

class _GroundCard extends StatelessWidget {
  final _GroundOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _GroundCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? option.color.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? option.color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: option.color.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? option.color.withValues(alpha: 0.15)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                option.icon,
                color: isSelected ? option.color : Colors.grey.shade400,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isSelected
                          ? Colors.black87
                          : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.description,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              color: isSelected ? option.color : Colors.grey.shade300,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Evidence Picker Row
// ═══════════════════════════════════════════════════════════════════════════

class _EvidencePickerRow extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _EvidencePickerRow({
    required this.images,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...images.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(e.value,
                          width: 90, height: 90, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => onRemove(e.key),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          if (images.length < 3)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: Colors.grey.shade400, size: 28),
                    const SizedBox(height: 4),
                    Text('Add Photo',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 10)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Policy Checkbox
// ═══════════════════════════════════════════════════════════════════════════

class _PolicyCheckbox extends StatelessWidget {
  final bool agreed;
  final ValueChanged<bool?> onChanged;
  final Color primary;

  const _PolicyCheckbox({
    required this.agreed,
    required this.onChanged,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: agreed ? primary.withValues(alpha: 0.4) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: agreed,
              onChanged: onChanged,
              activeColor: primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'I understand that appeals are final. Frivolous or bad-faith '
              'appeals may result in penalties. I confirm all information '
              'provided is truthful.',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Data models & enums
// ═══════════════════════════════════════════════════════════════════════════

enum AppealGround {
  newEvidence,
  proceduralError,
  biasedDecision,
  misrepresentedFacts,
}

enum DisputeOutcomeType {
  favourComplainant,
  favourRespondent,
  dismissed,
}

class _GroundOption {
  final AppealGround ground;
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const _GroundOption({
    required this.ground,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class AppealDisputeDetail {
  final String id;
  final String sessionTitle;
  final String resolvedDate;
  final String resolutionNote;
  final DisputeOutcomeType outcome;
  final int appealDaysRemaining;

  const AppealDisputeDetail({
    required this.id,
    required this.sessionTitle,
    required this.resolvedDate,
    required this.resolutionNote,
    required this.outcome,
    required this.appealDaysRemaining,
  });
}