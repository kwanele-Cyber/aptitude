import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/usecase/agreements/agreement_viewmodel.dart';
import 'package:myapp/core/models/agreement_model.dart';
import 'package:myapp/usecase/sessions/session_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AgreementHistoryPage extends StatefulWidget {
  final String agreementId;
  const AgreementHistoryPage({super.key, required this.agreementId});

  @override
  State<AgreementHistoryPage> createState() => _AgreementHistoryPageState();
}

class _AgreementHistoryPageState extends State<AgreementHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgreementViewModel>().loadHistory(widget.agreementId);
      context.read<SessionViewModel>().loadSessionsForAgreement(widget.agreementId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AgreementViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Negotiation Tree'),
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
        child: viewModel.isLoadingHistory
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : viewModel.error != null
                ? Center(child: Text(viewModel.error!, style: const TextStyle(color: Colors.redAccent)))
                : _buildHistoryTree(viewModel.history),
      ),
    );
  }

  Widget _buildHistoryTree(List<AgreementModel> history) {
    if (history.isEmpty) {
      return const Center(
        child: Text('No history found.', style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildLatestAgreement(history.first),
        const SizedBox(height: 32),
        _buildSessionsSection(context),
        const SizedBox(height: 32),
        const Text('Negotiation History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildHistoryList(history),
      ],
    );
  }

  Widget _buildNode(AgreementModel agreement, int version) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: agreement.status == AgreementStatus.accepted 
              ? Colors.greenAccent.withOpacity(0.5) 
              : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Version $version',
                style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              _buildStatusIndicator(agreement.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${agreement.mentorSkill} ↔ ${agreement.learnerSkill}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${agreement.frequency} • ${agreement.duration}h',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMM dd, HH:mm').format(agreement.createdAt),
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      height: 30,
      width: 2,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildStatusIndicator(AgreementStatus status) {
    IconData icon;
    Color color;
    switch (status) {
      case AgreementStatus.pending:
        icon = Icons.hourglass_empty;
        color = Colors.orangeAccent;
        break;
      case AgreementStatus.accepted:
        icon = Icons.check_circle;
        color = Colors.greenAccent;
        break;
      case AgreementStatus.declined:
        icon = Icons.cancel;
        color = Colors.redAccent;
        break;
      case AgreementStatus.completed:
        icon = Icons.done_all;
        color = Colors.blueAccent;
        break;
      case AgreementStatus.canceled:
        icon = Icons.cancel_outlined;
        color = Colors.grey;
        break;
    }
    return Icon(icon, color: color, size: 16);
  }

  Widget _buildLatestAgreement(AgreementModel agreement) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Agreement', style: TextStyle(color: Colors.white70, fontSize: 14)),
              _buildStatusIndicator(agreement.status),
            ],
          ),
          const SizedBox(height: 16),
          Text('${agreement.learnerSkill} ↔ ${agreement.mentorSkill}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${agreement.frequency} • ${agreement.duration} hrs/session', style: const TextStyle(color: Colors.white70)),
          if (agreement.status == AgreementStatus.accepted) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/sessions/schedule/${widget.agreementId}'),
                icon: const Icon(Icons.add_task),
                label: const Text('Schedule New Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionsSection(BuildContext context) {
    final sessionViewModel = context.watch<SessionViewModel>();
    if (sessionViewModel.sessions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Scheduled Sessions', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...sessionViewModel.sessions.map((s) => _buildSessionCard(s)),
      ],
    );
  }

  Widget _buildSessionCard(dynamic session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.event, color: Colors.blueAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(DateFormat('MMM dd, hh:mm a').format(session.startTime), style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Text('${session.duration}h', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<AgreementModel> history) {
    return Column(
      children: history.map((agreement) {
        final index = history.indexOf(agreement);
        final isLast = index == history.length - 1;
        return Column(
          children: [
            _buildNode(agreement, history.length - index),
            if (!isLast) _buildConnector(),
          ],
        );
      }).toList(),
    );
  }
}
