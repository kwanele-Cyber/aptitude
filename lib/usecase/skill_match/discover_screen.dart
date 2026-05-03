import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/user.dart' as model;
import 'package:myapp/core/data/models/skill.dart';
import 'package:myapp/usecase/skill_match/view_model/discover_view_model.dart';
import 'package:provider/provider.dart';

class DiscoverScreen extends StatelessWidget {
  final model.User userData;
  const DiscoverScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiscoverViewModel()..loadSkills(),
      child: _DiscoverScreenContent(userData: userData),
    );
  }
}

class _DiscoverScreenContent extends StatefulWidget {
  final model.User userData;
  const _DiscoverScreenContent({required this.userData});
  @override
  State<_DiscoverScreenContent> createState() => _DiscoverScreenContentState();
}

class _DiscoverScreenContentState extends State<_DiscoverScreenContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiscoverViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(viewModel),
            if (viewModel.categories.isNotEmpty)
              _buildCategoryStrip(viewModel),
            Expanded(
              child: RefreshIndicator(
                onRefresh: viewModel.loadSkills,
                color: const Color(0xFF7C3AED),
                backgroundColor: const Color(0xFF1A1A2E),
                child: viewModel.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                    )
                  : viewModel.filteredSkills.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: viewModel.filteredSkills.length,
                      itemBuilder: (context, index) {
                        final skill = viewModel.filteredSkills[index];
                        return _buildSkillCard(skill);
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DiscoverViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover Skills',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Browse all skills available on the platform',
                      style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              if (viewModel.searchQuery.isNotEmpty || viewModel.selectedCategory != null)
                IconButton(
                  onPressed: () {
                    _searchController.clear();
                    viewModel.clearFilters();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  tooltip: 'Clear filters',
                ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSearchField(viewModel),
        ],
      ),
    );
  }

  Widget _buildSearchField(DiscoverViewModel viewModel) {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      onChanged: viewModel.search,
      decoration: InputDecoration(
        hintText: 'Search skills, categories, keywords...',
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF7C3AED), size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                onPressed: () {
                  _searchController.clear();
                  viewModel.search('');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildCategoryStrip(DiscoverViewModel viewModel) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildCategoryChip('All', viewModel.selectedCategory == null, () {
            viewModel.filterByCategory(null);
          }),
          const SizedBox(width: 8),
          ...viewModel.categories.map((cat) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildCategoryChip(cat, viewModel.selectedCategory == cat, () {
              viewModel.filterByCategory(cat);
            }),
          )),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF7C3AED)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[400],
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSkillCard(Skill skill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _categoryColor(skill.category).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _categoryIcon(skill.category),
              color: _categoryColor(skill.category),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _categoryColor(skill.category).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        skill.category,
                        style: TextStyle(
                          color: _categoryColor(skill.category),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (skill.description.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          skill.description,
                          style: TextStyle(color: Colors.grey[600], fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[700], size: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off, size: 40, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Text(
            'No skills found',
            style: TextStyle(color: Colors.grey[400], fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search or category',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return const Color(0xFF60A5FA);
      case 'design':
        return const Color(0xFFA78BFA);
      case 'culinary':
        return const Color(0xFFF472B6);
      case 'music':
        return const Color(0xFF34D399);
      case 'language':
        return const Color(0xFFFBBF24);
      case 'arts':
        return const Color(0xFFFB7185);
      default:
        return Colors.grey;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Icons.code;
      case 'design':
        return Icons.palette_outlined;
      case 'culinary':
        return Icons.restaurant_outlined;
      case 'music':
        return Icons.music_note_outlined;
      case 'language':
        return Icons.translate;
      case 'arts':
        return Icons.camera_alt_outlined;
      default:
        return Icons.lightbulb_outline;
    }
  }
}
