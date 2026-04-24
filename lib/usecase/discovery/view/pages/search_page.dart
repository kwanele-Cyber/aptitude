import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/usecase/discovery/discovery_viewmodel.dart';
import 'package:myapp/core/models/skill_model.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/usecase/auth/auth_viewmodel.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoveryViewModel>().loadInitialSkills();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiscoveryViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Skills'),
        backgroundColor: const Color(0xFF141E30),
        elevation: 0,
        actions: [
          if (authViewModel.isAdmin)
            IconButton(
              onPressed: () => context.push('/admin'),
              icon: const Icon(Icons.admin_panel_settings, color: Colors.blueAccent),
              tooltip: 'Admin Dashboard',
            ),
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF141E30), Color(0xFF243B55)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSearchBar(viewModel),
            ),
            _buildFilterRow(viewModel),
            const SizedBox(height: 8),
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : viewModel.error != null
                      ? Center(child: Text(viewModel.error!, style: const TextStyle(color: Colors.white)))
                      : _buildResultsList(viewModel.searchResults),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow(DiscoveryViewModel viewModel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChips(
            'Type',
            ['offer', 'request'],
            viewModel.selectedType,
            (val) => viewModel.setTypeFilter(val),
          ),
          const SizedBox(width: 12),
          _buildFilterChips(
            'Level',
            ['Beginner', 'Intermediate', 'Advanced', 'Expert'],
            viewModel.selectedLevel,
            (val) => viewModel.setLevelFilter(val),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(String title, List<String> options, String? selectedValue, Function(String?) onSelected) {
    return Row(
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(option[0].toUpperCase() + option.substring(1)),
            selected: isSelected,
            onSelected: (selected) => onSelected(selected ? option : null),
            selectedColor: Colors.blueAccent,
            backgroundColor: Colors.white.withOpacity(0.1),
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchBar(DiscoveryViewModel viewModel) {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        if (value.isEmpty) {
          viewModel.loadInitialSkills();
        } else {
          viewModel.search(value);
        }
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search skills, software, hobbies...',
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildResultsList(List<SkillModel> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text('No skills found.', style: TextStyle(color: Colors.white70, fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final skill = results[index];
        return _buildSkillCard(skill);
      },
    );
  }

  Widget _buildSkillCard(SkillModel skill) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          skill.name,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              skill.description,
              style: const TextStyle(color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                skill.level,
                style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
        onTap: () {
          context.push('/skills/details', extra: skill);
        },
      ),
    );
  }
}
