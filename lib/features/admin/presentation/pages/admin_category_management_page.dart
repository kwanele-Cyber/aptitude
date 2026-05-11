import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/utils/responsive_utils.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:myapp/features/admin/domain/entities/admin_entities.dart';
import 'package:myapp/features/admin/presentation/widgets/admin_sidebar.dart';

class AdminCategoryManagementPage extends StatefulWidget {
  const AdminCategoryManagementPage({super.key});

  @override
  State<AdminCategoryManagementPage> createState() => _AdminCategoryManagementPageState();
}

class _AdminCategoryManagementPageState extends State<AdminCategoryManagementPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      appBar: AdminAppBar(title: 'Skill Categories'),
      drawer: isDesktop ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isDesktop) const AdminSidebar(),
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
        _buildHeader(theme),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _categories.length,
            itemBuilder: (_, i) => _buildCategoryCard(theme, _categories[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Text('All categories are displayed in order. Drag to reorder.', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => _showCategoryDialog(context, null),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ThemeData theme, SkillCategoryEntity cat) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.drag_handle, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                const SizedBox(width: 8),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(cat.emoji, style: const TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 12),
                Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                if (!cat.active)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                    child: Text('Inactive', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                  ),
                const Spacer(),
                Text('${cat.skillCount} skills', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                const SizedBox(width: 16),
                _actBtn(theme, Icons.edit_outlined, 'Edit', () => _showCategoryDialog(context, cat)),
                const SizedBox(width: 4),
                _actBtn(theme, Icons.add, 'Add Sub', () => _showCategoryDialog(context, null, parent: cat.name)),
                const SizedBox(width: 4),
                _actBtn(theme, Icons.more_vert, 'More', () {}),
              ],
            ),
            if (cat.subcategories.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...cat.subcategories.map((sub) => Padding(
                padding: const EdgeInsets.only(left: 48, top: 6),
                child: Row(
                  children: [
                    Icon(Icons.drag_handle, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(6)),
                      child: Text(sub, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
                    ),
                    const Spacer(),
                    IconButton(icon: Icon(Icons.edit_outlined, size: 14), onPressed: () {}, padding: EdgeInsets.zero),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actBtn(ThemeData theme, IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(padding: const EdgeInsets.all(6), minimumSize: const Size(32, 32)),
    );
  }

  void _showCategoryDialog(BuildContext context, SkillCategoryEntity? existing, {String? parent}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing != null ? 'Edit Category' : 'Add ${parent != null ? 'Subcategory' : 'Category'}'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: '📘',
                decoration: InputDecoration(labelText: 'Icon', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true),
                items: ['📘', '🎨', '🎵', '📚', '⚽', '💼', '🔧', '🌍'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (_) {},
              ),
              if (parent != null) ...[
                const SizedBox(height: 12),
                Text('Parent: $parent', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () { Navigator.pop(ctx); }, child: const Text('Save')),
        ],
      ),
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

final _categories = [
  SkillCategoryEntity(id: 'c1', name: 'Technology & Programming', emoji: '📘', skillCount: 124, active: true, displayOrder: 1, subcategories: ['Web Development', 'Mobile Development', 'Data Science', 'DevOps & Cloud']),
  SkillCategoryEntity(id: 'c2', name: 'Arts & Design', emoji: '🎨', skillCount: 89, active: true, displayOrder: 2, subcategories: ['Graphic Design', 'UI/UX', 'Animation', 'Photography']),
  SkillCategoryEntity(id: 'c3', name: 'Music & Performance', emoji: '🎵', skillCount: 67, active: true, displayOrder: 3, subcategories: ['Guitar', 'Piano', 'Vocals', 'Drums', 'Production']),
  SkillCategoryEntity(id: 'c4', name: 'Academics & Languages', emoji: '📚', skillCount: 156, active: true, displayOrder: 4, subcategories: ['Mathematics', 'English', 'French', 'Science']),
  SkillCategoryEntity(id: 'c5', name: 'Sports & Fitness', emoji: '⚽', skillCount: 45, active: false, displayOrder: 5, subcategories: ['Soccer', 'Basketball', 'Yoga']),
  SkillCategoryEntity(id: 'c6', name: 'Business & Finance', emoji: '💼', skillCount: 78, active: true, displayOrder: 6, subcategories: ['Marketing', 'Accounting', 'Entrepreneurship']),
];
