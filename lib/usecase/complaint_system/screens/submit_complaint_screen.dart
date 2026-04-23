import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class SubmitComplaintScreen extends StatefulWidget {
  final String? prefilledUserId;
  final String? prefilledUserName;

  const SubmitComplaintScreen({
    super.key,
    this.prefilledUserId,
    this.prefilledUserName,
  });

  @override
  State<SubmitComplaintScreen> createState() =>
      _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState
    extends State<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  String? _selectedViolation;
  bool _submitting = false;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledUserId != null) {
      _userIdCtrl.text = widget.prefilledUserId!;
    }
    _descriptionCtrl.addListener(() {
      setState(() => _charCount = _descriptionCtrl.text.length);
    });
  }

  @override
  void dispose() {
    _userIdCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedViolation == null) {
      _showError('Please select a violation type');
      return;
    }
    setState(() => _submitting = true);
    try {
      await ApiService.submitComplaint(
        reportedUserId: _userIdCtrl.text.trim(),
        violationType: _selectedViolation!,
        description: _descriptionCtrl.text.trim(),
      );
      if (mounted) {
        _showSuccess();
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppTheme.flaggedColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 8),
        Text('Complaint submitted successfully'),
      ]),
      backgroundColor: AppTheme.resolvedColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a Violation'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.pendingColor
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.pendingColor
                        .withValues(alpha: 0.4)),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline,
                    color: AppTheme.pendingColor, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Please only report genuine violations. '
                    'False reports may result in action '
                    'against your account.',
                    style: TextStyle(
                        color: AppTheme.pendingColor,
                        fontSize: 12),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 28),
            const Text('Reported User',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _userIdCtrl,
              style: const TextStyle(
                  color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: widget.prefilledUserName ??
                    'Enter user ID or username',
                prefixIcon: const Icon(Icons.person_search,
                    color: AppTheme.textSecondary),
              ),
              validator: (v) => v == null || v.isEmpty
                  ? 'Please enter the user ID'
                  : null,
            ),
            const SizedBox(height: 24),
            const Text('Violation Type',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
            const SizedBox(height: 12),
            ...ViolationType.types
                .map((type) => _violationOption(type)),
            const SizedBox(height: 24),
            const Text('Description',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
            const SizedBox(height: 4),
            const Text(
                'Provide details to help our admin team '
                'investigate',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descriptionCtrl,
              style: const TextStyle(
                  color: AppTheme.textPrimary),
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText:
                    'Describe what happened in detail...',
                alignLabelWithHint: true,
                counterText: '',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please provide a description';
                }
                if (v.trim().length < 20) {
                  return 'Please provide at least 20 characters';
                }
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text('$_charCount / 500',
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11)),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2))
                    : const Icon(Icons.send_rounded,
                        size: 18),
                label: Text(_submitting
                    ? 'Submitting...'
                    : 'Submit Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.flaggedColor,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _violationOption(Map<String, dynamic> type) {
    final isSelected = _selectedViolation == type['value'];
    return GestureDetector(
      onTap: () =>
          setState(() => _selectedViolation = type['value']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryPurple.withValues(alpha: 0.2)
              : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightPurple
                : AppTheme.dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(type['icon'],
                style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type['label'],
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(type['description'],
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppTheme.lightPurple
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightPurple
                      : AppTheme.dividerColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check,
                      size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}