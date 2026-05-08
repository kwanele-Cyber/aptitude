import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/agreements/presentation/bloc/agreement_bloc.dart';
import 'package:myapp/features/agreements/presentation/bloc/agreement_event.dart';
import 'package:myapp/features/agreements/presentation/bloc/agreement_state.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';

class CreateAgreementPage extends StatefulWidget {
  final String? partnerId;
  final String? partnerName;
  final String? initiatorSkillId;
  final String? initiatorSkillTitle;
  final String? partnerSkillId;
  final String? partnerSkillTitle;

  const CreateAgreementPage({
    super.key,
    this.partnerId,
    this.partnerName,
    this.initiatorSkillId,
    this.initiatorSkillTitle,
    this.partnerSkillId,
    this.partnerSkillTitle,
  });

  @override
  State<CreateAgreementPage> createState() => _CreateAgreementPageState();
}

class _CreateAgreementPageState extends State<CreateAgreementPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _partnerIdController;
  late final TextEditingController _partnerNameController;
  late final TextEditingController _initiatorSkillTitleController;
  late final TextEditingController _partnerSkillTitleController;
  late final TextEditingController _durationController;
  late final TextEditingController _frequencyController;
  late final TextEditingController _sessionsController;
  late final TextEditingController _notesController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _partnerIdController =
        TextEditingController(text: widget.partnerId ?? '');
    _partnerNameController =
        TextEditingController(text: widget.partnerName ?? '');
    _initiatorSkillTitleController =
        TextEditingController(text: widget.initiatorSkillTitle ?? '');
    _partnerSkillTitleController =
        TextEditingController(text: widget.partnerSkillTitle ?? '');
    _durationController = TextEditingController();
    _frequencyController = TextEditingController();
    _sessionsController = TextEditingController(text: '1');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _partnerIdController.dispose();
    _partnerNameController.dispose();
    _initiatorSkillTitleController.dispose();
    _partnerSkillTitleController.dispose();
    _durationController.dispose();
    _frequencyController.dispose();
    _sessionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isSubmitting = true);

    context.read<AgreementBloc>().add(
          CreateAgreementRequested(
            initiatorId: authState.userEntity.id,
            initiatorName:
                '${authState.userEntity.firstName} ${authState.userEntity.lastName}',
            partnerId: _partnerIdController.text,
            partnerName: _partnerNameController.text,
            initiatorSkillId: widget.initiatorSkillId ?? '',
            initiatorSkillTitle: _initiatorSkillTitleController.text,
            partnerSkillId: widget.partnerSkillId ?? '',
            partnerSkillTitle: _partnerSkillTitleController.text,
            duration: _durationController.text,
            frequency: _frequencyController.text,
            sessionsCount: int.tryParse(_sessionsController.text) ?? 1,
            notes: _notesController.text.isNotEmpty
                ? _notesController.text
                : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AgreementBloc, AgreementState>(
      listener: (context, state) {
        setState(() => _isSubmitting = false);
        if (state is AgreementCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agreement created successfully')),
          );
          context.push('/agreements/${state.agreement.id}');
        } else if (state is AgreementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Agreement'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Partner',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _partnerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Partner Name',
                    hintText: 'Enter the name of your exchange partner',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _partnerIdController,
                  decoration: const InputDecoration(
                    labelText: 'Partner ID',
                    hintText: 'User ID of your exchange partner',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                Text('Skills Exchange',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _initiatorSkillTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Your Skill',
                    hintText: 'What you are offering/requesting',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _partnerSkillTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Partner Skill',
                    hintText: 'What your partner is offering/requesting',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                Text('Terms',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    hintText: 'e.g., 4 weeks, 2 months',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _frequencyController,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    hintText: 'e.g., 1x/week, 2x/week',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sessionsController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Sessions',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final n = int.tryParse(v);
                    if (n == null || n < 1) return 'Must be at least 1';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Notes (optional)',
                    hintText: 'Any special terms or notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.handshake),
                    label: Text(_isSubmitting
                        ? 'Creating...'
                        : 'Create Agreement'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
