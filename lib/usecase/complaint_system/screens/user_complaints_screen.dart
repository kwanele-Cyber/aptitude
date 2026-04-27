import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'submit_complaint_screen.dart';
import 'complaint_detail_screen.dart';

class UserComplaintsScreen extends StatefulWidget {
  const UserComplaintsScreen({super.key});

  @override
  State<UserComplaintsScreen> createState() =>
      _UserComplaintsScreenState();
}

class _UserComplaintsScreenState
    extends State<UserComplaintsScreen> {
  List<Complaint> _complaints = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _complaints = await ApiService.getMyComplaints();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    const SubmitComplaintScreen()),
          );
          if (result == true) _load();
        },
        backgroundColor: AppTheme.flaggedColor,
        icon: const Icon(Icons.flag_rounded,
            color: Colors.white),
        label: const Text('Report Violation',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.lightPurple,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppTheme.lightPurple))
            : _error != null
                ? _errorView()
                : _complaints.isEmpty
                    ? _emptyView()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            16, 16, 16, 100),
                        itemCount: _complaints.length,
                        itemBuilder: (_, i) => ComplaintCard(
                          complaint: _complaints[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ComplaintDetailScreen(
                                complaint: _complaints[i],
                                isAdmin: false,
                              ),
                            ),
                          ),
                        ),
                      ),
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: const Icon(Icons.shield_outlined,
                size: 40, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          const Text('No Reports Yet',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(
              'You haven\'t submitted any violation reports',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              color: AppTheme.flaggedColor, size: 48),
          const SizedBox(height: 12),
          Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: _load,
              child: const Text('Retry')),
        ],
      ),
    );
  }
}