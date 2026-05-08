import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/core/backblaze_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/disputes/presentation/pages/report_dialog.dart';
import '../../domain/entity/file_attachment_entity.dart';
import '../../domain/entity/message_entity.dart';
import '../../domain/repository/message_repository.dart';
import '../../domain/usecases/watch_typing_indicator_usecase.dart';
import '../../presentation/bloc/message_bloc.dart';
import '../../../../injection_container.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatPage({super.key, required this.userId, required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Uuid _uuid = const Uuid();

  String? _currentUserId;
  bool _canSend = false;
  bool _isUploading = false;
  bool _peerTyping = false;
  bool _isTyping = false;
  Timer? _typingTimer;
  StreamSubscription? _typingSubscription;
  late final MessageRepository _messageRepository;
  late final String _conversationId;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_syncSendState);

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.userEntity.id;
      _conversationId = _getChatId(authState.userEntity.id, widget.userId);
      _messageRepository = sl<MessageRepository>();
      _typingSubscription = sl<WatchTypingIndicatorUsecase>()
          .call(WatchTypingIndicatorParams(conversationId: _conversationId))
          .listen((result) {
        result.fold(
          (_) {},
          (typing) {
            if (!mounted) return;
            setState(() {
              _peerTyping = typing[widget.userId] ?? false;
            });
          },
        );
      });

      context.read<MessageBloc>().add(
            LoadMessages(
              userId1: authState.userEntity.id,
              userId2: widget.userId,
            ),
          );
      context.read<MessageBloc>().add(
            MarkMessagesAsReadEvent(
              userId1: authState.userEntity.id,
              userId2: widget.userId,
            ),
          );
    }
  }

  void _syncSendState() {
    final canSend = _messageController.text.trim().isNotEmpty;
    if (canSend != _canSend) {
      setState(() => _canSend = canSend);
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    final currentUserId = _currentUserId;
    if (text.isEmpty || currentUserId == null) return;

    final message = MessageEntity(
      id: _uuid.v4(),
      senderId: currentUserId,
      receiverId: widget.userId,
      content: text,
      timestamp: DateTime.now(),
    );

    context.read<MessageBloc>().add(SendMessageEvent(message: message));
    _messageController.clear();
    _scrollToBottom();
    _updateTypingIndicator();
  }

  Future<void> _pickAndSendFile() async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;

    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    final pickedFile = result.files.first;
    final bytes = pickedFile.bytes;
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to read selected file.')),
      );
      return;
    }

    final contentType = pickedFile.extension != null
        ? 'application/${pickedFile.extension}'
        : 'application/octet-stream';

    setState(() => _isUploading = true);

    File? tmp;
    try {
      // write bytes to a temp file and upload via the FileStorageService (Backblaze)
      tmp = File('${Directory.systemTemp.path}/${_uuid.v4()}_${pickedFile.name}');
      await tmp.writeAsBytes(bytes);

      final storage = sl<FileStorageService>();
      final uploadResp = await storage.uploadFile(tmp, fileName: pickedFile.name);

      // uploadFile should return parsed response. prefer explicit 'fileUrl' if present.
      final fileUrl = (uploadResp['fileUrl'] as String?) ??
          (uploadResp['file_name'] as String? ?? '') // fallback keys some impls use
          ;

      if (fileUrl == null || fileUrl.isEmpty) {
        // If service returned only a downloadUrl base + other info, try to construct one.
        final downloadUrl = uploadResp['downloadUrl'] as String?;
        final bucket = uploadResp['bucketId'] as String? ?? uploadResp['bucketName'] as String?;
        final name = uploadResp['fileName'] as String? ?? pickedFile.name;
        if (downloadUrl != null && bucket != null) {
          // known Backblaze pattern: <downloadUrl>/<bucketName>/<fileName>
          // avoid double-encoding if fileName already encoded
          final encodedName = Uri.encodeFull(name);
          // ignore: prefer_interpolation_to_compose_strings
          tmp = tmp; // no-op to satisfy analyzer in some setups
          final constructed = '$downloadUrl/$bucket/$encodedName';
          // use constructed url
          // ignore: prefer_conditional_assignment
          uploadResp['fileUrl'] = constructed;
        }
      }

      final resolvedFileUrl = (uploadResp['fileUrl'] as String?) ?? '';

      final attachment = FileAttachmentEntity(
        id: _uuid.v4(),
        fileName: pickedFile.name,
        fileUrl: resolvedFileUrl,
        fileSizeBytes: pickedFile.size,
        mimeType: contentType,
        uploadedAt: DateTime.now(),
      );

      final message = MessageEntity(
        id: _uuid.v4(),
        senderId: currentUserId,
        receiverId: widget.userId,
        content: pickedFile.name,
        timestamp: DateTime.now(),
        attachments: [attachment],
      );

      context.read<MessageBloc>().add(SendMessageEvent(message: message));
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload file.')),
      );
    } finally {
      // cleanup temp file and reset upload state
      try {
        if (tmp != null && await tmp.exists()) await tmp.delete();
      } catch (_) {}
      if (!mounted) return;
      setState(() => _isUploading = false);
    }
  }

  void _updateTypingIndicator() {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;

    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText && !_isTyping) {
      _setTypingIndicator(true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _setTypingIndicator(false);
    });
  }

  Future<void> _setTypingIndicator(bool isTyping) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;
    _isTyping = isTyping;

    final result = await _messageRepository.setTypingIndicator(
      conversationId: _conversationId,
      userId: currentUserId,
      isTyping: isTyping,
    );
    result.fold((_) {}, (_) {});
  }

  void _openAttachment(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    launchUrl(uri);
  }

  String _getChatId(String userA, String userB) {
    return userA.compareTo(userB) < 0 ? '$userA-$userB' : '$userB-$userA';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_syncSendState);
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _typingSubscription?.cancel();
    if (_isTyping) {
      _setTypingIndicator(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: Text(_initials(widget.userName)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Skill exchange conversation',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.62,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') {
                ReportDialog.show(
                  context,
                  reportedUserId: widget.userId,
                  reportedUserName: widget.userName,
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Report User'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<MessageBloc, MessageState>(
                listener: (context, state) {
                  if (state is MessagesLoaded) {
                    _scrollToBottom();
                    final currentUserId = _currentUserId;
                    if (currentUserId != null) {
                      context.read<MessageBloc>().add(
                            MarkMessagesAsReadEvent(
                              userId1: currentUserId,
                              userId2: widget.userId,
                            ),
                          );
                    }
                  }
                },
                builder: (context, state) {
                  if (state is MessageInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is MessageError) {
                    return _MessageError(message: state.message);
                  }
                  if (state is MessagesLoaded) {
                    if (state.messages.isEmpty) {
                      return _EmptyConversation(userName: widget.userName);
                    }
                    return _MessageList(
                      controller: _scrollController,
                      currentUserId: _currentUserId,
                      messages: state.messages,
                      onAttachmentTap: _openAttachment,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            if (_peerTyping)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${widget.userName} is typing...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            _MessageComposer(
              controller: _messageController,
              canSend: _canSend && _currentUserId != null,
              isUploading: _isUploading,
              onPickFile: _pickAndSendFile,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final initials = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return initials.isEmpty ? '?' : initials;
  }
}

class _MessageList extends StatelessWidget {
  final ScrollController controller;
  final String? currentUserId;
  final List<MessageEntity> messages;
  final void Function(String url)? onAttachmentTap;

  const _MessageList({
    required this.controller,
    required this.currentUserId,
    required this.messages,
    this.onAttachmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final previous = index == 0 ? null : messages[index - 1];
        final showDate =
            previous == null || !_sameDay(previous.timestamp, message.timestamp);
        final isMine = message.senderId == currentUserId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDate) _DateDivider(date: message.timestamp),
            _MessageBubble(
              message: message,
              isMine: isMine,
              onAttachmentTap: onAttachmentTap,
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMine;
  final void Function(String url)? onAttachmentTap;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    this.onAttachmentTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bubbleColor = isMine
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final foreground = isMine
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    final metaColor = foreground.withValues(alpha: isMine ? 0.78 : 0.58);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.76,
          minWidth: 80,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMine ? 18 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 18),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground,
                    height: 1.32,
                  ),
                ),
                if (message.attachments.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: message.attachments
                        .map((attachment) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _AttachmentPreview(
                                attachment: attachment,
                                isMine: isMine,
                                onTap: onAttachmentTap,
                              ),
                            ))
                        .toList(),
                  ),
                ],
                if (message.reactionSummary.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: message.reactionSummary.entries
                        .map(
                          (entry) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: bubbleColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${entry.key} ${entry.value}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: foreground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatClock(message.timestamp),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: metaColor,
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 5),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 15,
                        color: metaColor,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatClock(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _AttachmentPreview extends StatelessWidget {
  final FileAttachmentEntity attachment;
  final bool isMine;
  final void Function(String url)? onTap;

  const _AttachmentPreview({
    required this.attachment,
    required this.isMine,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileTypeIcon = attachment.isImage
        ? Icons.image_outlined
        : attachment.isPdf
            ? Icons.picture_as_pdf_outlined
            : Icons.attach_file_rounded;

    return InkWell(
      onTap: onTap == null ? null : () => onTap!(attachment.fileUrl),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline,
            width: 0.8,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(fileTypeIcon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    attachment.fileSizeFormatted,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.open_in_new,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  final DateTime date;

  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              _formatDate(date),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final value = DateTime(date.year, date.month, date.day);
    final difference = today.difference(value).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _MessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool canSend;
  final bool isUploading;
  final VoidCallback onSend;
  final VoidCallback onPickFile;

  const _MessageComposer({
    required this.controller,
    required this.canSend,
    required this.isUploading,
    required this.onSend,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton.filled(
              tooltip: 'Attach file',
              onPressed: isUploading ? null : onPickFile,
              icon: isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.attach_file_rounded),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Message',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              tooltip: 'Send message',
              onPressed: canSend ? onSend : null,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  final String userName;

  const _EmptyConversation({required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 18),
            Text(
              'No messages yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation with $userName about learning, '
              'teaching, or arranging a skill exchange.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageError extends StatelessWidget {
  final String message;

  const _MessageError({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load messages',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
