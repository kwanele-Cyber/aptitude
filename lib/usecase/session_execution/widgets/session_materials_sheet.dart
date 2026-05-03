import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/session_material.dart';
import 'package:myapp/usecase/session_execution/view_model/material_view_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SessionMaterialsSheet extends StatefulWidget {
  final String sessionId;
  const SessionMaterialsSheet({super.key, required this.sessionId});

  @override
  State<SessionMaterialsSheet> createState() => _SessionMaterialsSheetState();
}

class _SessionMaterialsSheetState extends State<SessionMaterialsSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialViewModel>().loadMaterials();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MaterialViewModel>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Session Materials',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showShareDialog(context, viewModel),
                    icon: const Icon(Icons.upload_file, color: Color(0xFF7C3AED)),
                    tooltip: 'Share material',
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (viewModel.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                viewModel.errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          Expanded(
            child: viewModel.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                  )
                : viewModel.materials.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: viewModel.materials.length,
                        itemBuilder: (context, index) {
                          final material = viewModel.materials[index];
                          return _buildMaterialCard(context, material, viewModel);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(
    BuildContext context,
    SessionMaterial material,
    MaterialViewModel viewModel,
  ) {
    final dateStr = DateFormat('MMM d, yyyy').format(material.uploadedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _materialColor(material.type).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _materialIcon(material.type),
              color: _materialColor(material.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateStr • ${material.formattedSize}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _onMaterialTap(context, material),
            icon: const Icon(Icons.open_in_new, color: Colors.white54, size: 18),
            tooltip: 'Open',
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, material, viewModel),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  void _onMaterialTap(BuildContext context, SessionMaterial material) {
    if (material.type == SessionMaterialType.link) {
      // Links open externally — in a real app this would launch the URL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${material.url}'),
          backgroundColor: const Color(0xFF7C3AED),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading ${material.name}'),
          backgroundColor: const Color(0xFF7C3AED),
        ),
      );
    }
  }

  Future<void> _showShareDialog(
    BuildContext context,
    MaterialViewModel viewModel,
  ) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    SessionMaterialType selectedType = SessionMaterialType.document;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text(
            'Share Material',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Material name'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: urlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('URL or file link'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<SessionMaterialType>(
                  initialValue: selectedType,
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Type'),
                  items: SessionMaterialType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() => selectedType = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: viewModel.isUploading
                  ? null
                  : () async {
                      await viewModel.shareMaterial(
                        name: nameController.text,
                        url: urlController.text,
                        type: selectedType,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        final error = viewModel.errorMessage;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error ?? 'Material shared'),
                            backgroundColor:
                                error == null ? Colors.green : Colors.redAccent,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
              ),
              child: viewModel.isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Share'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SessionMaterial material,
    MaterialViewModel viewModel,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Delete Material?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove "${material.name}"?',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            onPressed: () async {
              await viewModel.deleteMaterial(material);
              if (context.mounted) Navigator.pop(context);
              final error = viewModel.errorMessage;
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Material deleted'),
                    backgroundColor:
                        error == null ? Colors.green : Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 48, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text(
            'No materials shared yet',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the upload icon to share session resources',
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        ],
      ),
    );
  }

  IconData _materialIcon(SessionMaterialType type) {
    switch (type) {
      case SessionMaterialType.document:
        return Icons.description_outlined;
      case SessionMaterialType.image:
        return Icons.image_outlined;
      case SessionMaterialType.video:
        return Icons.videocam_outlined;
      case SessionMaterialType.link:
        return Icons.link;
      case SessionMaterialType.other:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _materialColor(SessionMaterialType type) {
    switch (type) {
      case SessionMaterialType.document:
        return const Color(0xFF60A5FA);
      case SessionMaterialType.image:
        return const Color(0xFF34D399);
      case SessionMaterialType.video:
        return const Color(0xFFF472B6);
      case SessionMaterialType.link:
        return const Color(0xFFA78BFA);
      case SessionMaterialType.other:
        return Colors.grey;
    }
  }
}
