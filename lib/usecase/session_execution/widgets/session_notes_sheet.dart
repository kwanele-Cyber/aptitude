import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/session_note.dart';
import 'package:myapp/usecase/session_execution/view_model/note_view_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SessionNotesSheet extends StatefulWidget {
  final String sessionId;
  const SessionNotesSheet({super.key, required this.sessionId});

  @override
  State<SessionNotesSheet> createState() => _SessionNotesSheetState();
}

class _SessionNotesSheetState extends State<SessionNotesSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteViewModel>().loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NoteViewModel>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                'Session Notes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showAddNoteDialog(context, viewModel),
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF7C3AED)),
                    tooltip: 'Add note',
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Collaborative notes — visible to all session participants',
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
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
                : viewModel.notes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: viewModel.notes.length,
                        itemBuilder: (context, index) {
                          final note = viewModel.notes[index];
                          return _buildNoteCard(context, note, viewModel);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context,
    SessionNote note,
    NoteViewModel viewModel,
  ) {
    final dateStr = DateFormat('MMM d, yyyy - h:mm a').format(note.createdAt);
    final isEdited = note.updatedAt != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: note.isPinned
            ? Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.isPinned)
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 1),
                  child: Icon(
                    Icons.push_pin,
                    size: 14,
                    color: const Color(0xFF7C3AED),
                  ),
                ),
              Expanded(
                child: Text(
                  note.content,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                dateStr,
                style: TextStyle(color: Colors.grey[600], fontSize: 10),
              ),
              if (isEdited) ...[
                const SizedBox(width: 4),
                Text(
                  '(edited)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: () => viewModel.togglePin(note),
                child: Icon(
                  note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 16,
                  color: note.isPinned
                      ? const Color(0xFF7C3AED)
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showEditNoteDialog(context, note, viewModel),
                child: Icon(Icons.edit_outlined, size: 16, color: Colors.grey[600]),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _confirmDelete(context, note, viewModel),
                child: Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showAddNoteDialog(
    BuildContext context,
    NoteViewModel viewModel,
  ) {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Add Note', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: 4,
          minLines: 2,
          decoration: _inputDecoration('Write a note...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await viewModel.addNote(content: controller.text);
              if (context.mounted) {
                Navigator.pop(context);
                final error = viewModel.errorMessage;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Note added'),
                    backgroundColor:
                        error == null ? Colors.green : Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditNoteDialog(
    BuildContext context,
    SessionNote note,
    NoteViewModel viewModel,
  ) {
    final controller = TextEditingController(text: note.content);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Edit Note', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: 4,
          minLines: 2,
          decoration: _inputDecoration('Update your note...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await viewModel.editNote(
                note: note,
                newContent: controller.text,
              );
              if (context.mounted) {
                Navigator.pop(context);
                final error = viewModel.errorMessage;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Note updated'),
                    backgroundColor:
                        error == null ? Colors.green : Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SessionNote note,
    NoteViewModel viewModel,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete Note?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove this note?',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            onPressed: () async {
              await viewModel.deleteNote(note);
              if (context.mounted) Navigator.pop(context);
              final error = viewModel.errorMessage;
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Note deleted'),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[600]),
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
          Icon(Icons.note_alt_outlined, size: 48, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to add a collaborative note',
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
