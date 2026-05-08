import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/features/sessions/domain/entity/session_material_entity.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_material_bloc.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_material_event.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_material_state.dart';

class SessionMaterialsSection extends StatefulWidget {
  final String sessionId;
  final String currentUserId;

  const SessionMaterialsSection({
    super.key,
    required this.sessionId,
    required this.currentUserId,
  });

  @override
  State<SessionMaterialsSection> createState() =>
      _SessionMaterialsSectionState();
}

class _SessionMaterialsSectionState extends State<SessionMaterialsSection> {
  @override
  void initState() {
    super.initState();
    context.read<SessionMaterialBloc>().add(
          LoadSessionMaterialsRequested(sessionId: widget.sessionId),
        );
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

    final platformFile = result.files.first;
    if (platformFile.path == null) return;

    if (!mounted) return;
    context.read<SessionMaterialBloc>().add(
          UploadMaterialRequested(
            sessionId: widget.sessionId,
            file: File(platformFile.path!),
            uploadedBy: widget.currentUserId,
          ),
        );
  }

  IconData _fileIcon(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('video/')) return Icons.videocam;
    if (mimeType.startsWith('audio/')) return Icons.audiotrack;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('word') || mimeType.contains('document'))
      return Icons.description;
    if (mimeType.contains('sheet') || mimeType.contains('excel'))
      return Icons.table_chart;
    if (mimeType.contains('zip') || mimeType.contains('compress'))
      return Icons.folder_zip;
    return Icons.insert_drive_file;
  }

  Color _fileColor(String mimeType) {
    if (mimeType.startsWith('image/')) return Colors.blue;
    if (mimeType.startsWith('video/')) return Colors.purple;
    if (mimeType.contains('pdf')) return Colors.red;
    if (mimeType.contains('word')) return Colors.blue;
    if (mimeType.contains('excel')) return Colors.green;
    if (mimeType.contains('zip')) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<SessionMaterialBloc, SessionMaterialState>(
      listener: (context, state) {
        if (state is SessionMaterialError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Materials',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: _pickAndUploadFile,
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Upload'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          BlocBuilder<SessionMaterialBloc, SessionMaterialState>(
            builder: (context, state) {
              if (state is SessionMaterialLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is SessionMaterialUploading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Uploading...'),
                      ],
                    ),
                  ),
                );
              }

              List<SessionMaterialEntity> materials = [];
              if (state is SessionMaterialsLoaded) {
                materials = state.materials;
              }

              if (materials.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 40,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No materials yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Upload files to share with your session partner.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: materials.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final material = materials[index];
                  final isOwner = material.uploadedBy == widget.currentUserId;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        backgroundColor:
                            _fileColor(material.mimeType).withValues(alpha: 0.1),
                        child: Icon(
                          _fileIcon(material.mimeType),
                          color: _fileColor(material.mimeType),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        material.fileName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        material.formattedSize,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download, size: 20),
                            tooltip: 'Download',
                            onPressed: () => _openFile(material.fileUrl),
                          ),
                          if (isOwner)
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red.shade300,
                              ),
                              tooltip: 'Delete',
                              onPressed: () => _confirmDelete(material),
                            ),
                        ],
                      ),
                      onTap: () => _openFile(material.fileUrl),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openFile(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open file.')),
        );
      }
    }
  }

  void _confirmDelete(SessionMaterialEntity material) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text('Are you sure you want to delete "${material.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SessionMaterialBloc>().add(
                    DeleteMaterialRequested(
                      materialId: material.id,
                      sessionId: widget.sessionId,
                    ),
                  );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
