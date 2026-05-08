import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_note_bloc.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_note_event.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_note_state.dart';

class SessionNotesSection extends StatefulWidget {
  final String sessionId;
  final String currentUserId;

  const SessionNotesSection({
    super.key,
    required this.sessionId,
    required this.currentUserId,
  });

  @override
  State<SessionNotesSection> createState() => _SessionNotesSectionState();
}

class _SessionNotesSectionState extends State<SessionNotesSection> {
  final _notesController = TextEditingController();
  Timer? _debounceTimer;
  bool _isLocalEdit = false;

  @override
  void initState() {
    super.initState();
    context.read<SessionNoteBloc>().add(
          LoadSessionNotesRequested(sessionId: widget.sessionId),
        );
    context.read<SessionNoteBloc>().add(
          NotesSubscriptionRequested(sessionId: widget.sessionId),
        );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _notesController.dispose();
    context.read<SessionNoteBloc>().add(NotesSubscriptionCancelled());
    super.dispose();
  }

  void _onNotesChanged(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _isLocalEdit = true;
      context.read<SessionNoteBloc>().add(
            UpdateSessionNotesRequested(
              sessionId: widget.sessionId,
              content: text,
              updatedBy: widget.currentUserId,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<SessionNoteBloc, SessionNoteState>(
      listener: (context, state) {
        if (state is SessionNotesLoaded && !_isLocalEdit) {
          final newText = state.notes.content;
          if (_notesController.text != newText) {
            final selection = _notesController.selection;
            _notesController.text = newText;
            // Restore cursor position if it was editing
            if (selection.isValid && selection.baseOffset <= newText.length) {
              _notesController.selection = selection;
            }
          }
        }
        if (state is SessionNotesUpdated) {
          _isLocalEdit = false;
        }
        if (state is SessionNoteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
        // Mark local edit as resolved after any load/update
        if (state is SessionNotesLoaded || state is SessionNotesUpdated) {
          _isLocalEdit = false;
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Session Notes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              BlocBuilder<SessionNoteBloc, SessionNoteState>(
                builder: (context, state) {
                  if (state is SessionNotesLoaded && state.notes.updatedBy.isNotEmpty) {
                    return Text(
                      'Last edited by ${state.notes.updatedBy == widget.currentUserId ? 'you' : 'partner'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlocBuilder<SessionNoteBloc, SessionNoteState>(
            builder: (context, state) {
              final isLoading = state is SessionNoteLoading;
              final isInitial = state is SessionNoteInitial;

              if (isLoading || isInitial) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: _notesController,
                  onChanged: _onNotesChanged,
                  maxLines: null,
                  minLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Collaborative notes...\n\n'
                        'Both you and your session partner can edit these notes in real-time.',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          BlocBuilder<SessionNoteBloc, SessionNoteState>(
            builder: (context, state) {
              if (state is SessionNotesLoaded) {
                final updatedAt = state.notes.updatedAt;
                final now = DateTime.now();
                final diff = now.difference(updatedAt);
                String timeAgo;
                if (diff.inSeconds < 60) {
                  timeAgo = 'just now';
                } else if (diff.inMinutes < 60) {
                  timeAgo = '${diff.inMinutes}m ago';
                } else if (diff.inHours < 24) {
                  timeAgo = '${diff.inHours}h ago';
                } else {
                  timeAgo = '${diff.inDays}d ago';
                }
                return Text(
                  'Auto-saved $timeAgo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
