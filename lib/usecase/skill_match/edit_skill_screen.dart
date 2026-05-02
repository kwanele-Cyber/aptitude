import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:provider/provider.dart';
import 'package:myapp/core/data/models/skill_proof.dart';
import 'view_model/edit_skill_view_model.dart';

class EditSkillScreen extends StatefulWidget {
  final String id;
  final bool isOffer;

  const EditSkillScreen({
    super.key,
    required this.id,
    required this.isOffer,
  });

  @override
  State<EditSkillScreen> createState() => _EditSkillScreenState();
}

class _EditSkillScreenState extends State<EditSkillScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    
    // Load item data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EditSkillViewModel>().loadItem(widget.id, widget.isOffer).then((_) {
        _descriptionController.text = context.read<EditSkillViewModel>().description;
      });
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditSkillViewModel(),
      child: Consumer<EditSkillViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.isOffer ? 'Edit Skill Offer' : 'Edit Learning Request'),
            ),
            body: viewModel.isLoading && viewModel.skillName.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Editing: ${viewModel.skillName}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              widget.isOffer ? 'Proficiency Level' : 'Target Level',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            SegmentedButton<SkillLevel>(
                              segments: SkillLevel.values.map((level) {
                                return ButtonSegment<SkillLevel>(
                                  value: level,
                                  label: Text(level.displayName),
                                );
                              }).toList(),
                              selected: {viewModel.level},
                              onSelectionChanged: (Set<SkillLevel> newSelection) {
                                viewModel.updateLevel(newSelection.first);
                              },
                            ),
                            const SizedBox(height: 24),
                            Text(
                              widget.isOffer ? 'Teaching Format' : 'Preferred Format',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            SegmentedButton<SkillFormat>(
                              segments: SkillFormat.values.map((format) {
                                return ButtonSegment<SkillFormat>(
                                  value: format,
                                  label: Text(format.displayName),
                                );
                              }).toList(),
                              selected: {viewModel.format},
                              onSelectionChanged: (Set<SkillFormat> newSelection) {
                                viewModel.updateFormat(newSelection.first);
                              },
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: viewModel.updateDescription,
                            ),
                            if (widget.isOffer) ...[
                              const SizedBox(height: 24),
                              const Text(
                                'Verification & Experience',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...viewModel.proofs.map((proof) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      proof.type == ProofType.certification ? Icons.verified_user : Icons.link,
                                      color: const Color(0xFF7C3AED),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(proof.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                          if (proof.issuer != null)
                                            Text(proof.issuer!, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                      onPressed: () => viewModel.removeProof(proof.id),
                                    ),
                                  ],
                                ),
                              )),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () => _showAddProofDialog(context, viewModel),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add Proof (Certification, Portfolio, etc.)'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF9D6FEF),
                                  side: const BorderSide(color: Color(0xFF7C3AED)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Icon(Icons.history, color: Color(0xFF7C3AED)),
                                  const SizedBox(width: 12),
                                  const Text('Years of Experience', style: TextStyle(color: Colors.grey)),
                                  const Spacer(),
                                  Text(
                                    '${viewModel.yearsOfExperience} years',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Slider(
                                value: viewModel.yearsOfExperience.toDouble(),
                                min: 0,
                                max: 20,
                                divisions: 20,
                                activeColor: const Color(0xFF7C3AED),
                                onChanged: (val) => viewModel.updateYearsOfExperience(val.toInt()),
                              ),
                            ],
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () async {
                                      final success = await viewModel.updateItem();
                                      if (success && mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Updated successfully!')),
                                        );
                                        Navigator.pop(context);
                                      } else if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Update failed')),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: viewModel.isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Save Changes'),
                            ),
                            const SizedBox(height: 20),
                            _buildDeleteButton(context, viewModel),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, EditSkillViewModel viewModel) {
    return Center(
      child: TextButton.icon(
        onPressed: viewModel.isLoading ? null : () => _showDeleteDialog(context, viewModel),
        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
        label: const Text(
          'Delete Listing Permanently',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, EditSkillViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete Listing', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to permanently remove this skill listing?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await viewModel.deleteItem();
      if (success && context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing deleted')),
        );
      }
    }
  }

  void _showAddProofDialog(BuildContext context, EditSkillViewModel viewModel) {
    final titleController = TextEditingController();
    final issuerController = TextEditingController();
    final urlController = TextEditingController();
    ProofType selectedType = ProofType.certification;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Add Proof', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ProofType>(
                  initialValue: selectedType,
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Type', labelStyle: TextStyle(color: Colors.grey)),
                  items: ProofType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  )).toList(),
                  onChanged: (val) => setState(() => selectedType = val!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Title (e.g. AWS Certified Developer)', labelStyle: TextStyle(color: Colors.grey)),
                ),
                if (selectedType == ProofType.certification) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: issuerController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Issuing Organization', labelStyle: TextStyle(color: Colors.grey)),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: urlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'URL (Credential or Portfolio)', labelStyle: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty) return;
                viewModel.addProof(SkillProof(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: selectedType,
                  title: titleController.text,
                  issuer: issuerController.text.isEmpty ? null : issuerController.text,
                  url: urlController.text.isEmpty ? null : urlController.text,
                ));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
