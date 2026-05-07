import 'package:flutter/material.dart';

/// X07 – Resolve Dispute
/// Admin-mediated resolution screen. Admins see both sides of the dispute,
/// can add a resolution note, and mark the dispute as resolved or dismissed.
/// Regular users see a read-only view of the dispute status and resolution.
class ResolveDisputeScreen extends StatefulWidget {
  final DisputeDetail dispute;
  final bool isAdmin;

  const ResolveDisputeScreen({
    super.key,
    required this.dispute,
    required this.isAdmin,
  });

  @override
  State<ResolveDisputeScreen> createState() => _ResolveDisputeScreenState();
}

class _ResolveDisputeScreenState extends State<ResolveDisputeScreen>
    with SingleTickerProviderStateMixin {
  // ── Tabs (admin only) ──────────────────────────────────────────────────
  late final TabController _tabController;

  // ── Admin form ─────────────────────────────────────────────────────────
  final _resolutionController = TextEditingController();
  DisputeOutcome? _selectedOutcome;
  bool _isSubmitting = false;

  // ── Palette ────────────────────────────────────────────────────────────
  static const Color _primary  = Color(0xFF5B4FCF);
  static const Color _green    = Color(0xFF10B981);
  static const Color _red      = Color(0xFFEF4444);
  static const Color _amber    = Color(0xFFF59E0B);
  static const Color _bg       = Color(0xFFF6F7FB);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isAdmin ? 3 : 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _resolutionController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  Color _statusColor(DisputeStatus s) {
    switch (s) {
      case DisputeStatus.open:      return _amber;
      case DisputeStatus.inReview:  return _primary;
      case DisputeStatus.resolved:  return _green;
      case DisputeStatus.dismissed: return _red;
    }
  }

  String _statusLabel(DisputeStatus s) {
    switch (s) {
      case DisputeStatus.open:      return 'Open';
      case DisputeStatus.inReview:  return 'In Review';
      case DisputeStatus.resolved:  return 'Resolved';
      case DisputeStatus.dismissed: return 'Dismissed';
    }
  }

  Future<void> _submitResolution() async {
    if (_selectedOutcome == null) {
      _showSnack('Please select an outcome.');
      return;
    }
    if (_resolutionController.text.trim().length < 20) {
      _showSnack('Resolution note must be at least 20 characters.');
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: Replace with your DisputeRepository call, e.g.:
    // await DisputeRepository.resolveDispute(
    //   disputeId      : widget.dispute.id,
    //   outcome        : _selectedOutcome!,
    //   resolutionNote : _resolutionController.text.trim(),
    // );
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);
    if (!mounted) return;

    _showSnack('Dispute resolved. Both parties will be notified.');
    Navigator.pop(context, true);
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final d = widget.dispute;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Dispute Details',
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
            child: _StatusBadge(
              label: _statusLabel(d.status),
              color: _statusColor(d.status),
            ),
          ),
        ],
        bottom: widget.isAdmin
            ? TabBar(
                controller: _tabController,
                labelColor: _primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: _primary,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Evidence'),
                  Tab(text: 'Resolve'),
                ],
              )
            : null,
      ),
      body: widget.isAdmin
          ? TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(dispute: d, statusColor: _statusColor(d.status)),
                _EvidenceTab(dispute: d),
                _ResolveTab(
                  resolutionController: _resolutionController,
                  selectedOutcome: _selectedOutcome,
                  isSubmitting: _isSubmitting,
                  onSelectOutcome: (o) =>
                      setState(() => _selectedOutcome = o),
                  onSubmit: _submitResolution,
                  green: _green,
                  red: _red,
                  primary: _primary,
                ),
              ],
            )
          : _UserView(dispute: d, statusColor: _statusColor(d.status)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tab 1 – Overview
// ═══════════════════════════════════════════════════════════════════════════

class _OverviewTab extends StatelessWidget {
  final DisputeDetail dispute;
  final Color statusColor;

  const _OverviewTab({required this.dispute, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    final d = dispute;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Parties ────────────────────────────────────────────────────
        _SectionTitle('Parties Involved'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _PartyCard(
                label: 'Complainant',
                name: d.complainantName,
                color: const Color(0xFF5B4FCF),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: _PartyCard(
                label: 'Respondent',
                name: d.respondentName,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Session ────────────────────────────────────────────────────
        _SectionTitle('Session'),
        const SizedBox(height: 10),
        _InfoCard(children: [
          _InfoRow(icon: Icons.event_rounded,     label: 'Session', value: d.sessionTitle),
          _InfoRow(icon: Icons.calendar_today,    label: 'Date',    value: d.sessionDate),
          _InfoRow(icon: Icons.warning_rounded,   label: 'Violation', value: d.violationType),
          _InfoRow(icon: Icons.access_time_rounded, label: 'Filed', value: d.filedDate),
        ]),
        const SizedBox(height: 20),

        // ── Complainant statement ──────────────────────────────────────
        _SectionTitle('Complainant Statement'),
        const SizedBox(height: 10),
        _StatementCard(text: d.complainantStatement, color: const Color(0xFF5B4FCF)),
        const SizedBox(height: 20),

        // ── Respondent statement ───────────────────────────────────────
        _SectionTitle('Respondent Statement'),
        const SizedBox(height: 10),
        d.respondentStatement != null
            ? _StatementCard(
                text: d.respondentStatement!,
                color: const Color(0xFFEF4444),
              )
            : _EmptyState(message: 'Respondent has not submitted a statement yet.'),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tab 2 – Evidence
// ═══════════════════════════════════════════════════════════════════════════

class _EvidenceTab extends StatelessWidget {
  final DisputeDetail dispute;
  const _EvidenceTab({required this.dispute});

  @override
  Widget build(BuildContext context) {
    final allEvidence = dispute.evidenceUrls;
    return allEvidence.isEmpty
        ? Center(
            child: _EmptyState(message: 'No evidence files were attached.'),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: allEvidence.length,
            itemBuilder: (context, i) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  allEvidence[i],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image_rounded,
                        color: Colors.grey),
                  ),
                ),
              );
            },
          );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tab 3 – Resolve (admin only)
// ═══════════════════════════════════════════════════════════════════════════

enum DisputeOutcome { favourComplainant, favourRespondent, mutuallyDismissed }

class _ResolveTab extends StatelessWidget {
  final TextEditingController resolutionController;
  final DisputeOutcome? selectedOutcome;
  final bool isSubmitting;
  final ValueChanged<DisputeOutcome> onSelectOutcome;
  final VoidCallback onSubmit;
  final Color green;
  final Color red;
  final Color primary;

  const _ResolveTab({
    required this.resolutionController,
    required this.selectedOutcome,
    required this.isSubmitting,
    required this.onSelectOutcome,
    required this.onSubmit,
    required this.green,
    required this.red,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Outcome selection ──────────────────────────────────────────
        _SectionTitle('Resolution Outcome'),
        const SizedBox(height: 12),
        ..._outcomeOptions(green, red, primary),

        const SizedBox(height: 24),

        // ── Resolution note ────────────────────────────────────────────
        _SectionTitle('Admin Resolution Note'),
        const SizedBox(height: 10),
        TextFormField(
          controller: resolutionController,
          maxLines: 6,
          maxLength: 600,
          decoration: InputDecoration(
            hintText:
                'Summarise your findings and the basis for this decision…',
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
        ),
        const SizedBox(height: 16),

        // ── Notify toggle hint ─────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: green.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: green.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.notifications_active_outlined,
                  color: green, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Both parties will be notified via push notification and email once you submit.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // ── Submit ─────────────────────────────────────────────────────
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
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
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Finalise Resolution',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _outcomeOptions(Color green, Color red, Color primary) {
    final options = [
      (
        DisputeOutcome.favourComplainant,
        'Rule in favour of Complainant',
        Icons.thumb_up_rounded,
        green,
      ),
      (
        DisputeOutcome.favourRespondent,
        'Rule in favour of Respondent',
        Icons.thumb_down_rounded,
        red,
      ),
      (
        DisputeOutcome.mutuallyDismissed,
        'Dismiss (Insufficient Evidence)',
        Icons.remove_circle_outline_rounded,
        primary,
      ),
    ];

    return options.map((opt) {
      final (outcome, label, icon, color) = opt;
      final isSelected = selectedOutcome == outcome;
      return GestureDetector(
        onTap: () => onSelectOutcome(outcome),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: isSelected ? color : Colors.grey.shade400,
                  size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: 13,
                    color: isSelected ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: color, size: 20),
            ],
          ),
        ),
      );
    }).toList();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// User (read-only) view
// ═══════════════════════════════════════════════════════════════════════════

class _UserView extends StatelessWidget {
  final DisputeDetail dispute;
  final Color statusColor;

  const _UserView({required this.dispute, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    final d = dispute;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Status timeline
        _StatusTimeline(status: d.status),
        const SizedBox(height: 20),

        _SectionTitle('Your Dispute'),
        const SizedBox(height: 10),
        _InfoCard(children: [
          _InfoRow(icon: Icons.event_rounded,   label: 'Session',   value: d.sessionTitle),
          _InfoRow(icon: Icons.warning_rounded, label: 'Violation', value: d.violationType),
          _InfoRow(icon: Icons.access_time,     label: 'Filed',     value: d.filedDate),
        ]),
        const SizedBox(height: 20),

        _SectionTitle('Your Statement'),
        const SizedBox(height: 10),
        _StatementCard(
            text: d.complainantStatement,
            color: const Color(0xFF5B4FCF)),
        const SizedBox(height: 20),

        if (d.resolutionNote != null) ...[
          _SectionTitle('Admin Resolution'),
          const SizedBox(height: 10),
          _StatementCard(
              text: d.resolutionNote!,
              color: const Color(0xFF10B981)),
        ],
      ],
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final DisputeStatus status;
  const _StatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (DisputeStatus.open,      'Filed',     Icons.flag_rounded),
      (DisputeStatus.inReview,  'In Review', Icons.manage_search_rounded),
      (DisputeStatus.resolved,  'Resolved',  Icons.check_circle_rounded),
    ];

    final currentIndex = steps.indexWhere((s) => s.$1 == status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final i = entry.key;
          final (_, label, icon) = entry.value;
          final done = i <= currentIndex;
          final color = done ? const Color(0xFF5B4FCF) : Colors.grey.shade300;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: color.withOpacity(0.15),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: done
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: done ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 22),
                      color: i < currentIndex
                          ? const Color(0xFF5B4FCF)
                          : Colors.grey.shade200,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared small widgets
// ═══════════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: Colors.black54,
          letterSpacing: 0.3,
        ),
      );
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      );
}

class _PartyCard extends StatelessWidget {
  final String label;
  final String name;
  final Color color;
  const _PartyCard(
      {required this.label, required this.name, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      );
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(children: children),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade400),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 12)),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      );
}

class _StatementCard extends StatelessWidget {
  final String text;
  final Color color;
  const _StatementCard({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 13, height: 1.6, color: Colors.black87),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(message,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// Data models (replace with your Firestore / API models)
// ═══════════════════════════════════════════════════════════════════════════

enum DisputeStatus { open, inReview, resolved, dismissed }

class DisputeDetail {
  final String id;
  final String sessionTitle;
  final String sessionDate;
  final String violationType;
  final String filedDate;
  final String complainantName;
  final String respondentName;
  final String complainantStatement;
  final String? respondentStatement;
  final List<String> evidenceUrls;
  final DisputeStatus status;
  final String? resolutionNote;

  const DisputeDetail({
    required this.id,
    required this.sessionTitle,
    required this.sessionDate,
    required this.violationType,
    required this.filedDate,
    required this.complainantName,
    required this.respondentName,
    required this.complainantStatement,
    this.respondentStatement,
    required this.evidenceUrls,
    required this.status,
    this.resolutionNote,
  });
}