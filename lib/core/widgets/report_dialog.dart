import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/report_model.dart';
import 'package:myapp/core/data/repositories/report_repository.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class ReportDialog extends StatefulWidget {
  final String reportedUserId;
  final String? context;
  final String? title;

  const ReportDialog({
    super.key,
    required this.reportedUserId,
    this.context,
    this.title,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  ReportReason _selectedReason = ReportReason.spam;
  final _descriptionController = TextEditingController();
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title ?? 'Report User',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Help us understand what is happening. Your report is anonymous.',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            const SizedBox(height: 24),
            const Text('Reason', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ReportReason>(
                  value: _selectedReason,
                  dropdownColor: const Color(0xFF1A1A2E),
                  isExpanded: true,
                  items: ReportReason.values.map((reason) {
                    return DropdownMenuItem(
                      value: reason,
                      child: Text(
                        _getReasonLabel(reason),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedReason = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Description', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Provide more details...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444), // Red for danger/report
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReasonLabel(ReportReason reason) {
    switch (reason) {
      case ReportReason.spam: return 'Spam';
      case ReportReason.harassment: return 'Harassment';
      case ReportReason.inappropriateContent: return 'Inappropriate Content';
      case ReportReason.fraud: return 'Fraud / Scam';
      case ReportReason.other: return 'Other';
    }
  }

  void _submit() async {
    setState(() => _submitting = true);
    try {
      final auth = AuthService();
      final me = await auth.getCurrentUser();
      if (me == null) return;

      final report = ReportModel(
        id: const Uuid().v4(),
        reporterId: me.uid,
        reportedUserId: widget.reportedUserId,
        reason: _selectedReason,
        description: _descriptionController.text,
        timestamp: DateTime.now(),
        context: widget.context,
      );

      await ReportRepository().submitReport(report);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you. We will review your report shortly.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
