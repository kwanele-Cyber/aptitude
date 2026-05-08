import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_bloc.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_event.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_state.dart';

class ReportDialog extends StatefulWidget {
  final String reportedUserId;
  final String reportedUserName;

  const ReportDialog({
    super.key,
    required this.reportedUserId,
    required this.reportedUserName,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String reportedUserId,
    required String reportedUserName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ReportDialog(
        reportedUserId: reportedUserId,
        reportedUserName: reportedUserName,
      ),
    );
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedReason = 'Harassment';
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  static const _reasons = [
    'Harassment',
    'Spam',
    'Inappropriate Content',
    'Fake Profile',
    'Scam',
    'Offensive Behavior',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    if (authState is! AuthAuthenticated) return;

    setState(() => _isSubmitting = true);

    context.read<DisputeBloc>().add(
          ReportUserRequested(
            reporterId: authState.userEntity.id,
            reporterName: authState.userEntity.name,
            reportedUserId: widget.reportedUserId,
            reportedUserName: widget.reportedUserName,
            reason: _selectedReason,
            description: _descriptionController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DisputeBloc, DisputeState>(
      listener: (context, state) {
        setState(() => _isSubmitting = false);
        if (state is DisputeReported) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted successfully')),
          );
        } else if (state is DisputeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: AlertDialog(
        title: const Text('Report User'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reporting: ${widget.reportedUserName}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedReason,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(),
                  ),
                  items: _reasons
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedReason = v);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Provide details about the issue...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please provide a description';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit Report'),
          ),
        ],
      ),
    );
  }
}
