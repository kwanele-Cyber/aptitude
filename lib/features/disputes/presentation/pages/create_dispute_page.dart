import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_bloc.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_event.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_state.dart';

class CreateDisputePage extends StatefulWidget {
  final String? respondentId;
  final String? respondentName;
  final String? agreementId;
  final String? sessionId;

  const CreateDisputePage({
    super.key,
    this.respondentId,
    this.respondentName,
    this.agreementId,
    this.sessionId,
  });

  @override
  State<CreateDisputePage> createState() => _CreateDisputePageState();
}

class _CreateDisputePageState extends State<CreateDisputePage> {
  final _formKey = GlobalKey<FormState>();
  final _respondentIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedReason = 'Agreement Violation';
  bool _isSubmitting = false;

  static const _reasons = [
    'Agreement Violation',
    'No-Show',
    'Incomplete Session',
    'Misconduct',
    'False Claims',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.respondentId != null) {
      _respondentIdController.text = widget.respondentId!;
    }
  }

  @override
  void dispose() {
    _respondentIdController.dispose();
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
          CreateDisputeRequested(
            reporterId: authState.userEntity.id,
            reporterName: authState.userEntity.name,
            respondentId: _respondentIdController.text.trim(),
            reason: _selectedReason,
            description: _descriptionController.text.trim(),
            agreementId: widget.agreementId,
            sessionId: widget.sessionId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DisputeBloc, DisputeState>(
      listener: (context, state) {
        setState(() => _isSubmitting = false);
        if (state is DisputeCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dispute created successfully')),
          );
          Navigator.of(context).pop();
        } else if (state is DisputeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Dispute')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.respondentName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Disputing with: ${widget.respondentName}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                TextFormField(
                  controller: _respondentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Respondent User ID',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: widget.respondentId != null,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter the respondent user ID';
                    }
                    return null;
                  },
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
                    hintText: 'Describe the issue in detail...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please provide a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (widget.agreementId != null)
                  Text(
                    'Related Agreement: ${widget.agreementId}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (widget.sessionId != null)
                  Text(
                    'Related Session: ${widget.sessionId}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.warning_amber),
                  label: Text(_isSubmitting ? 'Submitting...' : 'Submit Dispute'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
