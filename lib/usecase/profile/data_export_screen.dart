import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/core/services/data_export_service.dart';

class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  final _exportService = DataExportService();
  String? _jsonData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateExport();
  }

  void _generateExport() async {
    setState(() => _isLoading = true);
    try {
      final report = await _exportService.generateFullReport();
      setState(() => _jsonData = _exportService.formatToJson(report));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard() {
    if (_jsonData == null) return;
    Clipboard.setData(ClipboardData(text: _jsonData!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data report copied to clipboard!'),
        backgroundColor: Color(0xFF22C55E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Text('Export My Data', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_jsonData != null)
            IconButton(
              icon: const Icon(Icons.copy_all, color: Color(0xFF7C3AED)),
              onPressed: _copyToClipboard,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
          : _jsonData == null
              ? _buildErrorState()
              : _buildReportView(),
    );
  }

  Widget _buildReportView() {
    return Column(
      children: [
        _buildInfoBanner(),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                _jsonData!,
                style: const TextStyle(
                  color: Color(0xFF9D6FEF),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF7C3AED), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This report contains your full profile, skill listings, and activity history in a machine-readable format.',
              style: TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text('Error loading report', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _generateExport,
            child: const Text('Try Again', style: TextStyle(color: Color(0xFF7C3AED))),
          ),
        ],
      ),
    );
  }
}
