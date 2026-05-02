import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/models/saved_search.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:myapp/core/data/repositories/search_repository.dart';
import 'package:myapp/core/data/repositories/skills_repository.dart';
import 'package:myapp/core/data/repositories/invite_repository.dart';
import 'package:myapp/core/data/models/user.dart' as model;
import 'package:myapp/core/services/auth_service.dart';
import 'package:myapp/usecase/skill_match/view_model/discover_view_model.dart';
import 'package:myapp/usecase/skill_match/widgets/match_card.dart';
import 'package:myapp/core/services/seed_data_service.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

class DiscoverScreen extends StatelessWidget {
  final model.User userData;
  const DiscoverScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiscoverViewModel()..loadMatches(),
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
  final _inviteRepo = InviteRepository();
  final _skillsRepo = SkillsRepository();
  final _searchRepo = SearchRepository();
  final _auth = AuthService();
  
  final _searchController = SearchController();

  @override
  void initState() {
    super.initState();
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
            Expanded(
              child: RefreshIndicator(
                onRefresh: viewModel.loadMatches,
                color: const Color(0xFF7C3AED),
                backgroundColor: const Color(0xFF1A1A2E),
                child: viewModel.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7C3AED),
                      ),
                    )
                  : viewModel.matches.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: viewModel.matches.length,
                      itemBuilder: (context, index) {
                        final result = viewModel.matches[index];
                        return MatchCard(
                          result: result,
                          onConnect: () async {
                            await viewModel.acceptMatch(result);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Match Accepted! Chat started.'),
                                  backgroundColor: Color(0xFF22C55E),
                                ),
                              );
                            }
                          },
                          onReject: () async {
                            await viewModel.rejectMatch(result);
                          },
                          onIgnore: () async {
                            await viewModel.ignoreMatch(result);
                          },
                          onSave: () async {
                            await viewModel.saveMatch(result);
                          },
                        );
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
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${widget.userData.firstName} 👋',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Find people with matching skills',
                      style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  final auth = AuthService();
                  final user = await auth.getCurrentUser();
                  if (user != null) {
                    await SeedDataService().seed(user.uid);
                    viewModel.loadMatches(); // Refresh
                  }
                },
                icon: const Icon(Icons.auto_awesome, color: Color(0xFF7C3AED)),
                tooltip: 'Seed Demo Data',
              ),
              IconButton(
                onPressed: () {
                  _searchController.clear();
                  viewModel.clearFilters();
                },
                icon: const Icon(Icons.refresh, color: Colors.white70),
                tooltip: 'Reset',
              ),
              IconButton(
                onPressed: () => _showSavedSearches(viewModel),
                icon: const Icon(Icons.bookmarks_outlined, color: Colors.white70),
                tooltip: 'Saved Searches',
              ),
              IconButton(
                onPressed: () => _showSaveDialog(viewModel),
                icon: Icon(
                  Icons.save_outlined,
                  color: (viewModel.selectedSkillId != null || viewModel.selectedLevels.isNotEmpty || viewModel.selectedFormats.isNotEmpty)
                      ? const Color(0xFF7C3AED)
                      : Colors.white70,
                ),
                tooltip: 'Save Search',
              ),
              IconButton(
                onPressed: () => context.push('/match-history'),
                icon: const Icon(Icons.history, color: Colors.white70),
                tooltip: 'Match History',
              ),
              IconButton(
                onPressed: () => _showFilterSheet(viewModel),
                icon: Icon(
                  Icons.tune,
                  color: (viewModel.selectedLevels.isNotEmpty || viewModel.selectedFormats.isNotEmpty)
                      ? const Color(0xFF7C3AED)
                      : Colors.white70,
                ),
                tooltip: 'Filters',
              ),
            ],
          ),
          if (viewModel.selectedLevels.isNotEmpty || viewModel.selectedFormats.isNotEmpty)
            _buildFilterChips(viewModel),
          const SizedBox(height: 16),
          _buildSearchBar(viewModel),
        ],
      ),
    );
  }

  Widget _buildFilterChips(DiscoverViewModel viewModel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          ...viewModel.selectedLevels.map((l) => _buildChip(l.name, () {
                viewModel.toggleLevel(l);
              })),
          ...viewModel.selectedFormats.map((f) => _buildChip(f.name, () {
                viewModel.toggleFormat(f);
              })),
          if (viewModel.minTrustScore > 0)
            _buildChip('Trust > ${viewModel.minTrustScore.toStringAsFixed(1)}', () {
              viewModel.setMinTrustScore(0.0);
            }),
          if (viewModel.onlyVerified)
            _buildChip('Verified Only', () {
              viewModel.setOnlyVerified(false);
            }),
        ],
      ),
    );
  }

  Widget _buildChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
        backgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.3),
        onDeleted: onDeleted,
        deleteIconColor: Colors.white70,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _showFilterSheet(DiscoverViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text('Proficiency Level', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: SkillLevel.values.map((l) {
                      final selected = viewModel.selectedLevels.contains(l);
                      return ChoiceChip(
                        label: Text(l.name, style: TextStyle(color: selected ? Colors.white : Colors.grey)),
                        selected: selected,
                        onSelected: (val) {
                          setModalState(() {
                            viewModel.toggleLevel(l);
                          });
                        },
                        selectedColor: const Color(0xFF7C3AED),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Format', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: SkillFormat.values.map((f) {
                      final selected = viewModel.selectedFormats.contains(f);
                      return ChoiceChip(
                        label: Text(f.name, style: TextStyle(color: selected ? Colors.white : Colors.grey)),
                        selected: selected,
                        onSelected: (val) {
                          setModalState(() {
                            viewModel.toggleFormat(f);
                          });
                        },
                        selectedColor: const Color(0xFF7C3AED),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Minimum Trust Score', style: TextStyle(color: Colors.grey)),
                      Text(
                        viewModel.minTrustScore.toStringAsFixed(1),
                        style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: viewModel.minTrustScore,
                    min: 0.0,
                    max: 5.0,
                    divisions: 10,
                    activeColor: const Color(0xFF7C3AED),
                    onChanged: (val) {
                      setModalState(() {
                        viewModel.setMinTrustScore(val);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Verified Members Only', style: TextStyle(color: Colors.white, fontSize: 14)),
                    subtitle: const Text('Only show users with verified expertise', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    value: viewModel.onlyVerified,
                    activeThumbColor: const Color(0xFF7C3AED),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setModalState(() {
                        viewModel.setOnlyVerified(val);
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildSearchBar(DiscoverViewModel viewModel) {
    return SearchAnchor(
      searchController: _searchController,
      viewBackgroundColor: const Color(0xFF1A1A2E),
      viewSurfaceTintColor: Colors.transparent,
      builder: (context, controller) {
        return SearchBar(
          controller: controller,
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          onTap: () {
            controller.openView();
          },
          onChanged: (_) {
            controller.openView();
          },
          leading: const Icon(Icons.search, color: Color(0xFF7C3AED)),
          hintText: viewModel.selectedSkillName ?? 'Search for a skill...',
          hintStyle: WidgetStatePropertyAll<TextStyle>(
            TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          backgroundColor: WidgetStatePropertyAll<Color>(
            Colors.white.withValues(alpha: 0.05),
          ),
          elevation: const WidgetStatePropertyAll<double>(0),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textStyle: const WidgetStatePropertyAll<TextStyle>(
            TextStyle(color: Colors.white, fontSize: 14),
          ),
        );
      },
      suggestionsBuilder: (context, controller) async {
        final query = controller.text;
        final results = await _skillsRepo.searchSkills(query);
        
        return results.map((skill) {
          return ListTile(
            title: Text(skill.name, style: const TextStyle(color: Colors.white)),
            onTap: () {
              viewModel.setSkill(skill.sid, skill.name);
              controller.closeView(skill.name);
            },
          );
        }).toList();
      },
    );
  }

  void _showSaveDialog(DiscoverViewModel viewModel) {
    if (viewModel.selectedSkillId == null && viewModel.selectedLevels.isEmpty && viewModel.selectedFormats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a skill or filter to save this search')),
      );
      return;
    }

    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Save Search', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search Name (e.g. Expert Python)',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final me = await _auth.getCurrentUser();
              if (me == null) return;

              final saved = SavedSearch(
                id: const Uuid().v4(),
                name: name,
                query: viewModel.selectedSkillName,
                levels: Set.from(viewModel.selectedLevels),
                formats: Set.from(viewModel.selectedFormats),
              );

              await _searchRepo.saveSearch(me.uid, saved);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Search "$name" saved!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSavedSearches(DiscoverViewModel viewModel) async {
    final auth = AuthService();
    final me = await auth.getCurrentUser();
    if (me == null) return;

    final saved = await _searchRepo.getSavedSearches(me.uid);

    if (mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        builder: (context) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saved Searches', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              if (saved.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No saved searches yet.', style: TextStyle(color: Colors.grey))),
                ),
              ...saved.map((s) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  '${s.query ?? "No Keyword"} • ${s.levels.length + s.formats.length} filters',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () async {
                    await _searchRepo.deleteSearch(me.uid, s.id);
                    Navigator.pop(context);
                    _showSavedSearches(viewModel);
                  },
                ),
                onTap: () async {
                  viewModel.setSkill(s.id, s.query); // Wait, s.id is searchId. s.query is skillName
                  // We need to resolve ID again or store it in SavedSearch
                  String? sid;
                  if (s.query != null) {
                    sid = await _skillsRepo.resolveSkillId(s.query!);
                  }
                  
                  viewModel.setSkill(sid, s.query);
                  for (var l in s.levels) { viewModel.toggleLevel(l); }
                  for (var f in s.formats) { viewModel.toggleFormat(f); }

                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              )),
            ],
          ),
        ),
      );
    }
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
            child: Icon(
              Icons.people_outline,
              size: 40,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No matches yet',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Update your skills to find matches',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }
}



