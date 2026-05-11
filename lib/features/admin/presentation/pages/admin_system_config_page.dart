import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/utils/responsive_utils.dart';
import 'package:myapp/features/admin/domain/entities/admin_entities.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_event.dart';
import 'package:myapp/features/admin/presentation/bloc/admin_state.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_sidebar.dart';

class AdminSystemConfigPage extends StatefulWidget {
  const AdminSystemConfigPage({super.key});

  @override
  State<AdminSystemConfigPage> createState() => _AdminSystemConfigPageState();
}

class _AdminSystemConfigPageState extends State<AdminSystemConfigPage> {
  bool _hasChanges = false;
  late Map<String, bool> _featureFlags;
  late Map<String, double> _matchParams;
  late Map<String, int> _trustThresholds;
  late Map<String, int> _generalSettings;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<AdminBloc>().add(AdminLoadConfig());
  }

  void _initLocalState(SystemConfigEntity config) {
    _featureFlags = Map.from(config.featureFlags);
    _matchParams = Map.from(config.matchParams);
    _trustThresholds = Map.from(config.trustThresholds);
    _generalSettings = Map.from(config.generalSettings);
    _hasChanges = false;
  }

  void _markChanged() => setState(() => _hasChanges = true);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      appBar: const AdminAppBar(title: 'System Configuration'),
      drawer: isDesktop ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isDesktop) const AdminSidebar(),
          const VerticalDivider(width: 1),
          Expanded(
            child: BlocConsumer<AdminBloc, AdminState>(
              listener: (context, state) {
                if (state is AdminConfigLoaded) {
                  _initLocalState(state.config);
                }
              },
              builder: (context, state) {
                if (state is AdminConfigLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AdminError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: _loadData, child: const Text('Retry')),
                      ],
                    ),
                  );
                }
                if (state is! AdminConfigLoaded && state is! AdminLoading) {
                  // Fallback for initial state before loading starts
                  return const SizedBox();
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
              },
            ),
          ),
        ],
      ),
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
    final keys = _featureFlags.keys.toList();
    return Column(
      children: keys.asMap().entries.map((entry) {
        final key = entry.value;
        final isLast = entry.key == keys.length - 1;
        return Column(
          children: [
            _toggleRow(theme, _formatKey(key), _featureFlags[key] ?? false, (v) {
              setState(() => _featureFlags[key] = v);
              _markChanged();
            }),
            if (!isLast) _divider(theme),
          ],
        );
      }).toList(),
    );
  }

  String _formatKey(String key) {
    final result = key.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}');
    return result[0].toUpperCase() + result.substring(1);
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
    final keys = _matchParams.keys.toList();
    return Column(
      children: keys.asMap().entries.map((entry) {
        final key = entry.value;
        final isLast = entry.key == keys.length - 1;
        return Column(
          children: [
            _sliderRow(theme, _formatKey(key), _matchParams[key] ?? 0.0, 0, 100, (v) {
              setState(() => _matchParams[key] = v);
              _markChanged();
            }),
            if (!isLast) _divider(theme),
          ],
        );
      }).toList(),
    );
  }

  Widget _sliderRow(ThemeData theme, String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ResponsiveUtils.isMobile(context)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14)),
                Row(
                  children: [
                    Expanded(child: Slider(value: value, min: min, max: max, divisions: 100, label: value.round().toString(), onChanged: onChanged)),
                    SizedBox(width: 40, child: Text(value.round().toString(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.primary))),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                SizedBox(width: 180, child: Text(label, style: const TextStyle(fontSize: 14))),
                Expanded(child: Slider(value: value, min: min, max: max, divisions: 100, label: value.round().toString(), onChanged: onChanged)),
                SizedBox(width: 40, child: Text(value.round().toString(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.primary))),
              ],
            ),
    );
  }

  Widget _buildTrustThresholds(ThemeData theme) {
    final keys = _trustThresholds.keys.toList();
    return Column(
      children: keys.asMap().entries.map((entry) {
        final key = entry.value;
        final isLast = entry.key == keys.length - 1;
        return Column(
          children: [
            _inputRow(theme, _formatKey(key), _trustThresholds[key]?.toString() ?? '0', (v) {
              final val = int.tryParse(v);
              if (val != null) {
                _trustThresholds[key] = val;
                _markChanged();
              }
            }),
            if (!isLast) _divider(theme),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildGeneralSettings(ThemeData theme) {
    final keys = _generalSettings.keys.toList();
    return Column(
      children: keys.asMap().entries.map((entry) {
        final key = entry.value;
        final isLast = entry.key == keys.length - 1;
        return Column(
          children: [
            _inputRow(theme, _formatKey(key), _generalSettings[key]?.toString() ?? '0', (v) {
              final val = int.tryParse(v);
              if (val != null) {
                _generalSettings[key] = val;
                _markChanged();
              }
            }),
            if (!isLast) _divider(theme),
          ],
        );
      }).toList(),
    );
  }

  Widget _inputRow(ThemeData theme, String label, String value, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ResponsiveUtils.isMobile(context)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 4),
                TextField(
                  controller: TextEditingController(text: value)..selection = TextSelection.fromPosition(TextPosition(offset: value.length)),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
                ),
              ],
            )
          : Row(
              children: [
                SizedBox(width: 200, child: Text(label, style: const TextStyle(fontSize: 14))),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: TextEditingController(text: value)..selection = TextSelection.fromPosition(TextPosition(offset: value.length)),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: onChanged,
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
            onPressed: _hasChanges
                ? () {
                    final config = SystemConfigEntity(
                      featureFlags: _featureFlags,
                      matchParams: _matchParams,
                      trustThresholds: _trustThresholds,
                      generalSettings: _generalSettings,
                    );
                    context.read<AdminBloc>().add(AdminSaveConfig(config: config));
                    setState(() => _hasChanges = false);
                  }
                : null,
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
                    FilledButton(
                      onPressed: () {
                        context.read<AdminBloc>().add(AdminRestoreConfig());
                        Navigator.pop(ctx);
                      },
                      child: const Text('Restore'),
                    ),
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
          const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40), const SizedBox(height: 8),
          const Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
