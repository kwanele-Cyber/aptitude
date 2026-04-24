import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/usecase/agreements/agreement_viewmodel.dart';
import 'package:myapp/usecase/auth/auth_viewmodel.dart';
import 'package:myapp/core/models/agreement_model.dart';
import 'package:intl/intl.dart';

class AgreementListPage extends StatefulWidget {
  const AgreementListPage({super.key});

  @override
  State<AgreementListPage> createState() => _AgreementListPageState();
}

class _AgreementListPageState extends State<AgreementListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        context.read<AgreementViewModel>().loadAgreements(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AgreementViewModel>();
    final currentUserId = context.read<AuthViewModel>().user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Agreements'),
        backgroundColor: const Color(0xFF0F2027),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : viewModel.error != null
                ? Center(child: Text(viewModel.error!, style: const TextStyle(color: Colors.redAccent)))
                : _buildAgreementList(viewModel.agreements, currentUserId),
      ),
    );
  }

  Widget _buildAgreementList(List<AgreementModel> agreements, String currentUserId) {
    if (agreements.isEmpty) {
      return const Center(
        child: Text(
          'No agreements found.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agreements.length,
      itemBuilder: (context, index) {
        final agreement = agreements[index];
        return _buildAgreementCard(agreement, currentUserId);
      },
    );
  }

  Widget _buildAgreementCard(AgreementModel agreement, String currentUserId) {
    final viewModel = context.read<AgreementViewModel>();
    final isMentor = agreement.mentorId == currentUserId;
    
    // Check if the current user is the "receiver" of the pending agreement
    // (Agreement is pending and was created by the peer)
    // Actually, currently we don't track who created it, but usually the mentor proposes it.
    // Let's assume for now any pending agreement can be acted upon if you are part of it.
    // In a real app, you'd track 'proposedBy'.
    
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isMentor ? 'Mentoring Session' : 'Learning Session',
                  style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                ),
                _buildStatusChip(agreement.status),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${agreement.mentorSkill} for ${agreement.learnerSkill}',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Frequency: ${agreement.frequency}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Duration: ${agreement.duration} hrs',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            if (agreement.status == AgreementStatus.pending) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => viewModel.declineAgreement(agreement.id),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Decline', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => viewModel.acceptAgreement(agreement.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Accept', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final peerId = isMentor ? agreement.learnerId : agreement.mentorId;
                    context.push('/agreements/counter/${agreement.id}', extra: agreement);
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Make Counter Offer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.cyanAccent,
                    side: const BorderSide(color: Colors.cyanAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => context.push('/agreements/history/${agreement.id}'),
              icon: const Icon(Icons.history, size: 16, color: Colors.white60),
              label: const Text('View Negotiation History', style: TextStyle(color: Colors.white60, fontSize: 12)),
            ),
            if (agreement.status == AgreementStatus.accepted) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _showCancelConfirmation(context, viewModel, agreement.id),
                  icon: const Icon(Icons.cancel, size: 16, color: Colors.redAccent),
                  label: const Text('Cancel Agreement', style: TextStyle(color: Colors.redAccent)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.redAccent, width: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, AgreementViewModel viewModel, String agreementId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text('Cancel Agreement?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to terminate this agreement? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Agreement', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.cancelAgreement(agreementId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(AgreementStatus status) {
    Color color;
    switch (status) {
      case AgreementStatus.pending:
        color = Colors.orangeAccent;
        break;
      case AgreementStatus.accepted:
        color = Colors.greenAccent;
        break;
      case AgreementStatus.declined:
        color = Colors.redAccent;
        break;
      case AgreementStatus.completed:
        color = Colors.blueAccent;
        break;
      case AgreementStatus.canceled:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
