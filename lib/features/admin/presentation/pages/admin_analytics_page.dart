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

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  String _dateRange = 'Last 30 Days';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<AdminBloc>().add(AdminLoadAnalytics(dateRange: _dateRange));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      appBar: const AdminAppBar(title: 'Analytics'),
      drawer: isDesktop ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isDesktop) const AdminSidebar(),
          const VerticalDivider(width: 1),
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminAnalyticsLoading) {
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

                final data = state is AdminAnalyticsLoaded ? state.data : const AnalyticsDataEntity();
                return _buildContent(theme, data);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, AnalyticsDataEntity data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeSelector(theme),
          const SizedBox(height: 24),
          _buildOverviewCards(theme, data),
          const SizedBox(height: 24),
          _buildChartSection(theme, 'User Growth', Icons.trending_up, _buildUserGrowthChart(theme, data.userGrowth)),
          const SizedBox(height: 24),
          _buildChartSection(theme, 'Match Success Rate by Category', Icons.handshake, _buildBarChart(theme, data.matchSuccessByCategory)),
          const SizedBox(height: 24),
          _buildChartSection(theme, 'Session Breakdown', Icons.check_circle_outline, _buildSessionBreakdown(theme, data)),
          const SizedBox(height: 24),
          _buildExportRow(theme),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(10)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _dateRange,
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _dateRange = v);
                  _loadData();
                }
              },
              items: ['Last 7 Days', 'Last 30 Days', 'Last 90 Days', 'This Year', 'All Time'].map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.date_range, size: 16),
          label: const Text('Custom Range'),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Refresh'),
        ),
      ],
    );
  }

  Widget _buildOverviewCards(ThemeData theme, AnalyticsDataEntity data) {
    final metrics = [
      _MetricData('New Users', '${data.newUsers}', '+0%', Colors.blue, Icons.person_add),
      _MetricData('Total Matches', '${data.totalMatches}', '+0%', Colors.green, Icons.handshake),
      _MetricData('Sessions Completed', '${data.sessionsCompleted}', '+0%', Colors.orange, Icons.event),
      _MetricData('Avg Rating', data.avgRating.toStringAsFixed(1), '+0%', Colors.purple, Icons.star),
    ];

    if (ResponsiveUtils.isMobile(context)) {
      return Column(
        children: metrics.map((m) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _metricCard(theme, m),
        )).toList(),
      );
    }

    return Row(
      children: metrics.map((m) => Expanded(child: _metricCard(theme, m))).toList(),
    );
  }

  Widget _metricCard(ThemeData theme, _MetricData m) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(m.icon, size: 18, color: m.color),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(m.change, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(m.value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(m.label, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  Widget _buildChartSection(ThemeData theme, String title, IconData icon, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildUserGrowthChart(ThemeData theme, List<double> growthData) {
    if (growthData.isEmpty) {
      return const Center(child: Text('No growth data available'));
    }
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: _LineChartPainter(theme.colorScheme.primary, growthData),
    );
  }

  Widget _buildBarChart(ThemeData theme, Map<String, double> categoryData) {
    if (categoryData.isEmpty) {
      return const Center(child: Text('No category data available'));
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: categoryData.entries.map((e) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 160 * e.value,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ),
              const SizedBox(height: 8),
              Text(e.key, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            ],
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSessionBreakdown(ThemeData theme, AnalyticsDataEntity data) {
    final items = [
      _BreakdownData('Completed', data.sessionCompletionRate, Colors.green),
      _BreakdownData('Cancelled', data.sessionCancelRate, Colors.orange),
      _BreakdownData('No-Show', data.sessionNoShowRate, Colors.red),
      _BreakdownData('Rescheduled', data.sessionRescheduleRate, Colors.blue),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(item.label, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.ratio,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: item.color,
                  minHeight: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 50,
              child: Text('${(item.ratio * 100).round()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: item.color)),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildExportRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download, size: 16), label: const Text('Export as CSV')),
        const SizedBox(width: 12),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf, size: 16), label: const Text('Export as PDF')),
        const SizedBox(width: 12),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.schedule, size: 16), label: const Text('Schedule Report')),
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
        _drw(Icons.dashboard, 'Dashboard', '/admin'),
        _drw(Icons.people, 'Users', '/admin/users'),
        _drw(Icons.flag, 'Moderation', '/admin/moderation'),
        _drw(Icons.gavel, 'Penalties', '/admin/penalties'),
        _drw(Icons.analytics, 'Analytics', '/admin/analytics'),
        _drw(Icons.settings, 'Config', '/admin/config'),
      ]),
    );
  }

  Widget _drw(IconData icon, String label, String route) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: () { Navigator.pop(context); context.go(route); });
  }
}

class _MetricData {
  final String label, value, change;
  final Color color;
  final IconData icon;
  _MetricData(this.label, this.value, this.change, this.color, this.icon);
}

class _BreakdownData {
  final String label;
  final double ratio;
  final Color color;
  _BreakdownData(this.label, this.ratio, this.color);
}

class _LineChartPainter extends CustomPainter {
  final Color color;
  final List<double> values;
  _LineChartPainter(this.color, this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final stepX = size.width / (values.length - 1);

    path.moveTo(0, size.height);
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / (maxVal > 0 ? maxVal : 1)) * size.height * 0.85;
      if (i == 0) {
        path.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height - (values[i - 1] / (maxVal > 0 ? maxVal : 1)) * size.height * 0.85;
        final ctrlX1 = prevX + (x - prevX) / 3;
        final ctrlX2 = prevX + 2 * (x - prevX) / 3;
        path.cubicTo(ctrlX1, prevY, ctrlX2, y, x, y);
      }
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, linePaint..color = color.withValues(alpha: 0.8)..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
