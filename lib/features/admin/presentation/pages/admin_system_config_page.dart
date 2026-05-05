import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_sidebar.dart';

class AdminSystemConfigPage extends StatefulWidget {
  const AdminSystemConfigPage({super.key});

  @override
  State<AdminSystemConfigPage> createState() => _AdminSystemConfigPageState();
}

class _AdminSystemConfigPageState extends State<AdminSystemConfigPage> {
  bool _isLoading = true;
  bool _hasChanges = false;
  bool _chatSystem = true;
  bool _videoCalls = false;
  bool _geoCheckin = true;
  bool _qrScanner = true;
  bool _e2eEncryption = false;
  bool _trustV2 = false;
  bool _aiMatch = true;
  bool _maintenanceMode = false;
  double _matchRadius = 50;
  double _maxMatchesPerDay = 5;
  double _skillOverlap = 70;
  double _availWeight = 30;
  double _ratingWeight = 20;
  final _excellentMinCtrl = TextEditingController(text: '80');
  final _goodMinCtrl = TextEditingController(text: '60');
  final _fairMinCtrl = TextEditingController(text: '40');
  final _noShowPenaltyCtrl = TextEditingController(text: '-15');
  final _sessionCreditCtrl = TextEditingController(text: '2');
  final _sessionTimeoutCtrl = TextEditingController(text: '15');
  final _reviewEditCtrl = TextEditingController(text: '48');
  final _agreementExpiryCtrl = TextEditingController(text: '90');
  final _maxAgreementsCtrl = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _excellentMinCtrl.dispose();
    _goodMinCtrl.dispose();
    _fairMinCtrl.dispose();
    _noShowPenaltyCtrl.dispose();
    _sessionCreditCtrl.dispose();
    _sessionTimeoutCtrl.dispose();
    _reviewEditCtrl.dispose();
    _agreementExpiryCtrl.dispose();
    _maxAgreementsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isLoading = false);
  }

  void _markChanged() => setState(() => _hasChanges = true);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 720;

    return Scaffold(
      appBar: AdminAppBar(title: 'System Configuration'),
      drawer: isWide ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isWide) const AdminSidebar(),
          const VerticalDivider(width: 1),
          Expanded(child: _buildContent(theme)),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (_hasChanges)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            color: Colors.amber.withValues(alpha: 0.15),
            child: Row(
              children: [
                Icon(Icons.warning_amber, size: 16, color: Colors.amber.shade800),
                const SizedBox(width: 8),
                Text('You have unsaved changes', style: TextStyle(fontSize: 13, color: Colors.amber.shade800, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWarningBanner(theme),
                const SizedBox(height: 24),
                _buildSection(theme, 'Feature Flags', Icons.toggle_on_outlined, _buildFeatureFlags(theme)),
                const SizedBox(height: 24),
                _buildSection(theme, 'Match Parameters', Icons.tune, _buildMatchParams(theme)),
                const SizedBox(height: 24),
                _buildSection(theme, 'Trust Score Thresholds', Icons.shield_outlined, _buildTrustThresholds(theme)),
                const SizedBox(height: 24),
                _buildSection(theme, 'General Settings', Icons.settings_applications, _buildGeneralSettings(theme)),
                const SizedBox(height: 32),
                _buildActionRow(theme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.blue.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Changes take effect immediately. All configuration changes are logged in the audit log.',
              style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, IconData icon, Widget content) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureFlags(ThemeData theme) {
    return Column(
      children: [
        _toggleRow(theme, 'Chat System', _chatSystem, (v) { setState(() => _chatSystem = v); _markChanged(); }),
        _divider(theme),
        _toggleRow(theme, 'Video Calls', _videoCalls, (v) { setState(() => _videoCalls = v); _markChanged(); }),
        _divider(theme),
        _toggleRow(theme, 'Geolocation Check-in', _geoCheckin, (v) { setState(() => _geoCheckin = v); _markChanged(); }),
        _divider(theme),
        _toggleRow(theme, 'QR Code Scanner', _qrScanner, (v) { setState(() => _qrScanner = v); _markChanged(); }),
        _divider(theme),
        _toggleRow(theme, 'End-to-End Encryption', _e2eEncryption, (v) { setState(() => _e2eEncryption = v); _markChanged(); }),
        _divider(theme),
        _toggleRow(theme, 'Trust Score v2', _trustV2, (v) { setState(() => _trustV2 = v); _markChanged(); }),
        _divider(theme),
        _toggleRow(theme, 'AI Match Suggestions', _aiMatch, (v) { setState(() => _aiMatch = v); _markChanged(); }),
      ],
    );
  }

  Widget _toggleRow(ThemeData theme, String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: value ? Colors.green : theme.colorScheme.onSurface.withValues(alpha: 0.3)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Switch.adaptive(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _divider(ThemeData theme) {
    return Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.1));
  }

  Widget _buildMatchParams(ThemeData theme) {
    return Column(
      children: [
        _sliderRow(theme, 'Match Radius (km)', _matchRadius, 1, 200, (v) { setState(() => _matchRadius = v); _markChanged(); }),
        _divider(theme),
        _sliderRow(theme, 'Max Matches per Day', _maxMatchesPerDay, 1, 20, (v) { setState(() => _maxMatchesPerDay = v); _markChanged(); }),
        _divider(theme),
        _sliderRow(theme, 'Skill Overlap Threshold %', _skillOverlap, 0, 100, (v) { setState(() => _skillOverlap = v); _markChanged(); }),
        _divider(theme),
        _sliderRow(theme, 'Availability Match Weight', _availWeight, 0, 100, (v) { setState(() => _availWeight = v); _markChanged(); }),
        _divider(theme),
        _sliderRow(theme, 'Rating Impact Weight', _ratingWeight, 0, 100, (v) { setState(() => _ratingWeight = v); _markChanged(); }),
      ],
    );
  }

  Widget _sliderRow(ThemeData theme, String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 180, child: Text(label, style: const TextStyle(fontSize: 14))),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: max == 100 ? 20 : (max as int).toInt(),
              label: value.round().toString(),
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(value.round().toString(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustThresholds(ThemeData theme) {
    return Column(
      children: [
        _inputRow(theme, 'Excellent Score Min', _excellentMinCtrl),
        _divider(theme),
        _inputRow(theme, 'Good Score Min', _goodMinCtrl),
        _divider(theme),
        _inputRow(theme, 'Fair Score Min', _fairMinCtrl),
        _divider(theme),
        _inputRow(theme, 'No-Show Penalty', _noShowPenaltyCtrl),
        _divider(theme),
        _inputRow(theme, 'Session Credit', _sessionCreditCtrl),
      ],
    );
  }

  Widget _buildGeneralSettings(ThemeData theme) {
    return Column(
      children: [
        _inputRow(theme, 'Session Auto-Cancel (min)', _sessionTimeoutCtrl),
        _divider(theme),
        _inputRow(theme, 'Review Edit Window (hours)', _reviewEditCtrl),
        _divider(theme),
        _inputRow(theme, 'Agreement Expiry (days)', _agreementExpiryCtrl),
        _divider(theme),
        _inputRow(theme, 'Max Agreements/User', _maxAgreementsCtrl),
        _divider(theme),
        _toggleRow(theme, 'Maintenance Mode', _maintenanceMode, (v) { setState(() => _maintenanceMode = v); _markChanged(); }),
      ],
    );
  }

  Widget _inputRow(ThemeData theme, String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 200, child: Text(label, style: const TextStyle(fontSize: 14))),
          SizedBox(
            width: 120,
            child: TextField(
              controller: ctrl,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _markChanged(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: _hasChanges ? () {
              setState(() => _hasChanges = false);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuration saved successfully')));
            } : null,
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Save Configuration'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Restore Defaults?'),
                  content: const Text('This will reset all configuration values to their system defaults.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    FilledButton(onPressed: () { Navigator.pop(ctx); }, child: const Text('Restore')),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.restore, size: 18),
            label: const Text('Restore Defaults'),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        DrawerHeader(decoration: BoxDecoration(color: theme.colorScheme.primary), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
          Icon(Icons.admin_panel_settings, color: Colors.white, size: 40), const SizedBox(height: 8),
          Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ])),
        _drw(Icons.dashboard, 'Dashboard', '/admin'), _drw(Icons.people, 'Users', '/admin/users'),
        _drw(Icons.flag, 'Moderation', '/admin/moderation'), _drw(Icons.gavel, 'Penalties', '/admin/penalties'),
        _drw(Icons.analytics, 'Analytics', '/admin/analytics'), _drw(Icons.settings, 'Config', '/admin/config'),
      ]),
    );
  }

  Widget _drw(IconData icon, String label, String route) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: () { Navigator.pop(context); context.go(route); });
  }
}
