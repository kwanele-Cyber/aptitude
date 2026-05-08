import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/trust/presentation/bloc/trust_bloc.dart';
import 'package:myapp/features/trust/presentation/bloc/trust_event.dart';
import 'package:myapp/features/trust/presentation/bloc/trust_state.dart';

class AppealPage extends StatefulWidget {
  final String userId;
  const AppealPage({super.key, required this.userId});

  @override
  State<AppealPage> createState() => _AppealPageState();
}

class _AppealPageState extends State<AppealPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appeal Trust Score')),
      body: BlocListener<TrustBloc, TrustState>(
        listener: (context, state) {
          if (state is AppealSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Appeal submitted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
          if (state is TrustError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.rate_review_outlined,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Submit an Appeal',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'If you believe your trust score was incorrectly adjusted, '
                  'please explain why and our team will review your case.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for Appeal',
                    hintText:
                        'Explain why your trust score should be reviewed...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide a reason for your appeal';
                    }
                    if (value.trim().length < 20) {
                      return 'Please provide more detail (at least 20 characters)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<TrustBloc, TrustState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is TrustLoading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                context.read<TrustBloc>().add(
                                      SubmitAppealRequested(
                                        userId: widget.userId,
                                        reason: _reasonController.text.trim(),
                                      ),
                                    );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state is TrustLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Submit Appeal'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
