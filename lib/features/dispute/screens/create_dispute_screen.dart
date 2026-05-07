import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// X06 – Create Dispute
/// Raised when a session conflict or agreement violation occurs.
/// The user selects the session involved, the violation type,
/// provides a statement, and submits for admin review.
class CreateDisputeScreen extends StatefulWidget {
  /// Pass in the list of sessions this user was involved in.
  final List<SessionSummary> sessions;

  const CreateDisputeScreen({super.key, required this.sessions});

  @override
  State<CreateDisputeScreen> createState() => _CreateDisputeScreenState();
}

class _CreateDisputeScreenState extends State<CreateDisputeScreen> {
  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _statementController = TextEditingController();

  SessionSummary? _selectedSession;
  String? _selectedViolation;
  DisputeAgainst _disputeAgainst = DisputeAgainst.otherUser;

  final List<String> _violations = [
    'Session Cancellation (No Notice)',
    'Late Arrival (>15 min)',
    'Agreement Not Honoured',
    'Payment Dispute',
    'Unsafe / Uncomfortable Environment',
    'Skill Misrepresentation',
    'Other Violation',
  ];

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isSubmitting = false;
  int _currentStep = 0; // 0 = Session, 1 = Violation, 2 = Statement

  // ── Palette ───────────────────────────────────────────────────────────────
  static const Color _primary   = Color(0xFF5B4FCF);
  static const Color _amber     = Color(0xFFF59E0B);
  static const Color _bg        = Color(0xFFF6F7FB);
  static const Color _card      = Colors.white;

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  bool _canProceed() {
    if (_currentStep == 0) return _selectedSession != null;
    if (_currentStep == 1) return _selectedViolation != null;
    return true;
  }

  void _next() {
    if (!_canProceed()) {
      _showSnack(_currentStep == 0
          ? 'Please select a session.'
          : 'Please select a violation type.');
      return;
    }
    if (_currentStep < 2) setState(() => _currentStep++);
  }

  void _back() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // TODO: Replace with your DisputeRepository call, e.g.:
    // await DisputeRepository.createDispute(
    //   sessionId    : _selectedSession!.id,
    //   violationType: _selectedViolation!,
    //   against      : _disputeAgainst,
    //   statement    : _statementController.text.trim(),
    // );
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);
    if (!mounted) return;

    _showSnack('Dispute submitted. An admin will review within 48 hours.');
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _statementController.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0.5,
        leading: BackButton(
          color: Colors.black87,
          onPressed: _currentStep > 0 ? _back : () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Dispute',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Step ${_currentStep + 1}/3',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Progress bar ────────────────────────────────────────────────
          _StepProgressBar(currentStep: _currentStep, totalSteps: 3),

          // ── Step content ────────────────────────────────────────────────
          Expanded(
            child: Form(
              key: _formKey,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStep(),
              ),
            ),
          ),

          // ── Bottom nav ──────────────────────────────────────────────────
          _BottomNav(
            currentStep: _currentStep,
            isSubmitting: _isSubmitting,
            onNext: _next,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _StepSession(
          key: const ValueKey(0),
          sessions: widget.sessions,
          selected: _selectedSession,
          onSelect: (s) => setState(() => _selectedSession = s),
        );
      case 1:
        return _StepViolation(
          key: const ValueKey(1),
          violations: _violations,
          selected: _selectedViolation,
          disputeAgainst: _disputeAgainst,
          onSelectViolation: (v) => setState(() => _selectedViolation = v),
          onChangeAgainst: (a) => setState(() => _disputeAgainst = a),
          amber: _amber,
          primary: _primary,
        );
      case 2:
      default:
        return _StepStatement(
          key: const ValueKey(2),
          controller: _statementController,
          session: _selectedSession!,
          violation: _selectedViolation!,
          primary: _primary,
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step 1 – Select Session
// ═══════════════════════════════════════════════════════════════════════════

class _StepSession extends StatelessWidget {
  final List<SessionSummary> sessions;
  final SessionSummary? selected;
  final ValueChanged<SessionSummary> onSelect;

  const _StepSession({
    super.key,
    required this.sessions,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      children: [
        const _StepHeader(
          icon: Icons.calendar_today_rounded,
          title: 'Select Session',
          subtitle: 'Which session is this dispute about?',
        ),
        const SizedBox(height: 20),
        if (sessions.isEmpty)
          const Center(
            child: Text(
              'No sessions found.',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ...sessions.map((s) => _SessionTile(
                session: s,
                isSelected: selected?.id == s.id,
                onTap: () => onSelect(s),
              )),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  final SessionSummary session;
  final bool isSelected;
  final VoidCallback onTap;

  const _SessionTile({
    required this.session,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF5B4FCF) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF5B4FCF).withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF5B4FCF).withValues(alpha: 0.12)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.videocam_rounded,
                color: isSelected
                    ? const Color(0xFF5B4FCF)
                    : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${session.otherPartyName}  •  ${session.dateLabel}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF5B4FCF), size: 22),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step 2 – Select Violation
// ═══════════════════════════════════════════════════════════════════════════

enum DisputeAgainst { otherUser, platform }

class _StepViolation extends StatelessWidget {
  final List<String> violations;
  final String? selected;
  final DisputeAgainst disputeAgainst;
  final ValueChanged<String> onSelectViolation;
  final ValueChanged<DisputeAgainst> onChangeAgainst;
  final Color amber;
  final Color primary;

  const _StepViolation({
    super.key,
    required this.violations,
    required this.selected,
    required this.disputeAgainst,
    required this.onSelectViolation,
    required this.onChangeAgainst,
    required this.amber,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      children: [
        const _StepHeader(
          icon: Icons.gavel_rounded,
          title: 'Violation Type',
          subtitle: 'What agreement or policy was violated?',
        ),
        const SizedBox(height: 16),

        // Against toggle
        _AgainstToggle(
          value: disputeAgainst,
          onChange: onChangeAgainst,
          primary: primary,
        ),
        const SizedBox(height: 20),

        // Violation list
        ...violations.map((v) {
          final isSelected = v == selected;
          return GestureDetector(
            onTap: () => onSelectViolation(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? amber.withValues(alpha: 0.10) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? amber : Colors.grey.shade200,
                  width: isSelected ? 1.8 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? amber : Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      v,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 13,
                        color:
                            isSelected ? Colors.black87 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _AgainstToggle extends StatelessWidget {
  final DisputeAgainst value;
  final ValueChanged<DisputeAgainst> onChange;
  final Color primary;

  const _AgainstToggle({
    required this.value,
    required this.onChange,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: DisputeAgainst.values.map((opt) {
          final isSelected = opt == value;
          final label =
              opt == DisputeAgainst.otherUser ? 'Other User' : 'Platform';
          final icon = opt == DisputeAgainst.otherUser
              ? Icons.person_rounded
              : Icons.business_rounded;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChange(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected ? primary : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? primary : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step 3 – Statement
// ═══════════════════════════════════════════════════════════════════════════

class _StepStatement extends StatelessWidget {
  final TextEditingController controller;
  final SessionSummary session;
  final String violation;
  final Color primary;

  const _StepStatement({
    super.key,
    required this.controller,
    required this.session,
    required this.violation,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      children: [
        const _StepHeader(
          icon: Icons.edit_note_rounded,
          title: 'Your Statement',
          subtitle:
              'Provide a clear account of what happened. Be factual and specific.',
        ),
        const SizedBox(height: 16),

        // Summary chip row
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SummaryChip(label: session.title, icon: Icons.event_rounded),
            _SummaryChip(label: violation, icon: Icons.warning_rounded),
          ],
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: controller,
          maxLines: 8,
          maxLength: 800,
          decoration: InputDecoration(
            hintText:
                'e.g. "On 5 May 2026, the session was cancelled 10 minutes before start with no prior notice. I had already…"',
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: primary, width: 1.5),
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().length < 30) {
              return 'Statement must be at least 30 characters.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Tips card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Tips for a strong statement',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...[
                'Include exact dates and times.',
                'Attach screenshots or evidence if available.',
                'Avoid personal attacks — stick to facts.',
              ].map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 5, color: primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SummaryChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared widgets
// ═══════════════════════════════════════════════════════════════════════════

class _StepHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _StepHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF5B4FCF).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              Icon(icon, color: const Color(0xFF5B4FCF), size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepProgressBar({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final done = i <= currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: done
                          ? const Color(0xFF5B4FCF)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                if (i < totalSteps - 1) const SizedBox(width: 6),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentStep;
  final bool isSubmitting;
  final VoidCallback onNext;
  final AsyncCallback onSubmit;

  const _BottomNav({
    required this.currentStep,
    required this.isSubmitting,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep == 2;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isSubmitting ? null : (isLast ? onSubmit : onNext),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5B4FCF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  isLast ? 'Submit Dispute' : 'Continue',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Data model (replace with your actual model / Firestore document)
// ═══════════════════════════════════════════════════════════════════════════

class SessionSummary {
  final String id;
  final String title;
  final String otherPartyName;
  final String dateLabel;

  const SessionSummary({
    required this.id,
    required this.title,
    required this.otherPartyName,
    required this.dateLabel,
  });
}