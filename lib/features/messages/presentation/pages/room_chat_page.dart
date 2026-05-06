import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/messages/domain/entity/file_attachment_entity.dart';
import 'package:myapp/features/messages/domain/entity/message_entity.dart';
import 'package:myapp/features/messages/domain/entity/room_entity.dart';
import 'package:myapp/features/messages/domain/usecases/get_room_messages_usecase.dart';
import 'package:myapp/features/messages/domain/usecases/send_room_message_usecase.dart';
import 'package:myapp/injection_container.dart';
import 'package:uuid/uuid.dart';

class RoomChatArgs {
  final RoomEntity room;
  final Map<String, String> memberNames;

  const RoomChatArgs({
    required this.room,
    required this.memberNames,
  });
}

class RoomChatPage extends widgets.StatefulWidget {
  final RoomChatArgs args;

  const RoomChatPage({super.key, required this.args});

  @override
  widgets.State<RoomChatPage> createState() => _RoomChatPageState();
}

class _RoomChatPageState extends widgets.State<RoomChatPage> {
  final widgets.TextEditingController _messageController = widgets.TextEditingController();
  final widgets.ScrollController _scrollController = widgets.ScrollController();
  final Uuid _uuid = const Uuid();
  late final Stream<Either<Failure, List<MessageEntity>>> _messagesStream;

  String? _currentUserId;
  bool _canSend = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_syncSendState);
    _messagesStream = sl<GetRoomMessagesUseCase>().call(widget.args.room.id);

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.userEntity.id;
    }
  }

  void _syncSendState() {
    final canSend = _messageController.text.trim().isNotEmpty;
    if (canSend != _canSend) {
      setState(() => _canSend = canSend);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final currentUserId = _currentUserId;
    if (text.isEmpty || currentUserId == null) return;

    final roomId = widget.args.room.id;
    final message = MessageEntity(
      id: _uuid.v4(),
      senderId: currentUserId,
      receiverId: roomId,
      roomId: roomId,
      content: text,
      timestamp: DateTime.now(),
    );

    final result = await sl<SendRoomMessageUseCase>()(
      SendRoomMessageParams(roomId: roomId, message: message),
    );

    if (!mounted) return;
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message ?? 'Failed to send message.')),
        );
      },
      (_) {
        _messageController.clear();
        _scrollToBottom();
        setState(() {});
      },
    );
  }

  Future<void> _pickAndSendFile() async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;

    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    final pickedFile = result.files.first;
    final bytes = pickedFile.bytes;
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to read selected file.')),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      final storageRef = FirebaseStorage.instance
          .ref('message_attachments/${_uuid.v4()}_${pickedFile.name}');
      final uploadTask = await storageRef.putData(
        bytes,
        SettableMetadata(contentType: pickedFile.extension != null
            ? 'application/${pickedFile.extension}'
            : 'application/octet-stream'),
      );
      final fileUrl = await uploadTask.ref.getDownloadURL();
      final attachment = FileAttachmentEntity(
        id: _uuid.v4(),
        fileName: pickedFile.name,
        fileUrl: fileUrl,
        fileSizeBytes: pickedFile.size,
        mimeType: pickedFile.extension != null
            ? 'application/${pickedFile.extension}'
            : 'application/octet-stream',
        uploadedAt: DateTime.now(),
      );

      final roomId = widget.args.room.id;
      final message = MessageEntity(
        id: _uuid.v4(),
        senderId: currentUserId,
        receiverId: roomId,
        roomId: roomId,
        content: pickedFile.name,
        timestamp: DateTime.now(),
        attachments: [attachment],
      );

      final result = await sl<SendRoomMessageUseCase>()(
        SendRoomMessageParams(roomId: roomId, message: message),
      );

      if (!mounted) return;
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message ?? 'Failed to send file.')),
          );
        },
        (_) {
          _scrollToBottom();
          setState(() {});
        },
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload file.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _openAttachment(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _scrollToBottom() {
    widgets.WidgetsBinding.instance.addPostFrameCallback((_) {
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
    super.dispose();
  }

  @override
  widgets.Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final room = widget.args.room;
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
              child: Text(_initials(room.name)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    room.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${room.memberIds.length} members',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<Either<Failure, List<MessageEntity>>>(
                stream: _messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == widgets.ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final result = snapshot.data;
                  if (result == null) {
                    return _EmptyRoom(
                      roomName: room.name,
                      memberCount: room.memberIds.length,
                    );
                  }

                  return result.fold(
                    (failure) => _RoomError(
                      message: failure.message ?? 'Unable to load room messages.',
                    ),
                    (messages) {
                      if (messages.isEmpty) {
                        return _EmptyRoom(
                          roomName: room.name,
                          memberCount: room.memberIds.length,
                        );
                      }

                      widgets.WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMine = message.senderId == _currentUserId;
                          final senderName = isMine
                              ? 'You'
                              : widget.args.memberNames[message.senderId] ??
                                  message.senderId;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RoomMessageBubble(
                              message: message,
                              isMine: isMine,
                              senderName: senderName,
                              onAttachmentTap: _openAttachment,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            _RoomComposer(
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

class _RoomMessageBubble extends widgets.StatelessWidget {
  final MessageEntity message;
  final bool isMine;
  final String senderName;
  final widgets.ValueChanged<String> onAttachmentTap;

  const _RoomMessageBubble({
    required this.message,
    required this.isMine,
    required this.senderName,
    required this.onAttachmentTap,
  });

  @override
  widgets.Widget build(BuildContext context) {
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
          maxWidth: MediaQuery.of(context).size.width * 0.78,
          minWidth: 100,
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
                if (!isMine)
                  Text(
                    senderName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: metaColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (!isMine) const SizedBox(height: 4),
                Text(
                  message.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground,
                    height: 1.32,
                  ),
                ),
                if (message.attachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...message.attachments.map(
                    (attachment) => _AttachmentPreview(
                      attachment: attachment,
                      onTap: () => onAttachmentTap(attachment.fileUrl),
                      foreground: foreground,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  _formatClock(message.timestamp),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: metaColor,
                  ),
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

class _AttachmentPreview extends widgets.StatelessWidget {
  final FileAttachmentEntity attachment;
  final widgets.VoidCallback onTap;
  final Color foreground;

  const _AttachmentPreview({
    required this.attachment,
    required this.onTap,
    required this.foreground,
  });

  @override
  widgets.Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isImage = attachment.isImage;
    final isVideo = attachment.isVideo;
    final isPdf = attachment.isPdf;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: foreground.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isImage
                  ? Icons.image_rounded
                  : isVideo
                      ? Icons.video_file_rounded
                      : isPdf
                          ? Icons.picture_as_pdf_rounded
                          : Icons.attach_file_rounded,
              size: 20,
              color: foreground,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    attachment.fileName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    attachment.fileSizeFormatted,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: foreground.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomComposer extends widgets.StatelessWidget {
  final widgets.TextEditingController controller;
  final bool canSend;
  final widgets.VoidCallback onSend;
  final bool isUploading;
  final widgets.VoidCallback onPickFile;

  const _RoomComposer({
    required this.controller,
    required this.canSend,
    required this.onSend,
    required this.isUploading,
    required this.onPickFile,
  });

  @override
  widgets.Widget build(BuildContext context) {
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
                  hintText: 'Message room',
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
              tooltip: 'Send room message',
              onPressed: canSend ? onSend : null,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRoom extends widgets.StatelessWidget {
  final String roomName;
  final int memberCount;

  const _EmptyRoom({
    required this.roomName,
    required this.memberCount,
  });

  @override
  widgets.Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 18),
            Text(
              roomName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This room has $memberCount members. Start the conversation here.',
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

class _RoomError extends widgets.StatelessWidget {
  final String message;

  const _RoomError({required this.message});

  @override
  widgets.Widget build(BuildContext context) {
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
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
