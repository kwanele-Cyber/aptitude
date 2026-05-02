import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/chat_message.dart';
import 'package:intl/intl.dart';
import 'package:myapp/core/widgets/report_dialog.dart';
import 'package:myapp/usecase/chat/widgets/agreement_message_card.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final Function(String agreementId)? onAcceptAgreement;
  final Function(String agreementId)? onRejectAgreement;
  final Function(String agreementId)? onCancelAgreement;
  final Function(
    String agreementId,
    int sessionsCount,
    int minutesPerSession,
    String frequency,
  )?
  onModifyAgreement;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onAcceptAgreement,
    this.onRejectAgreement,
    this.onCancelAgreement,
    this.onModifyAgreement,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hm().format(
      DateTime.fromMillisecondsSinceEpoch(message.timestamp),
    );

    final agreementId = message.metadata?['agreementId'] as String?;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          if (!isMe) {
            _showReportOptions(context);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: message.type == MessageType.agreement && agreementId != null
              ? AgreementMessageCard(
                  agreementId: agreementId,
                  isMe: isMe,
                  onAccept: () => onAcceptAgreement?.call(agreementId),
                  onReject: () => onRejectAgreement?.call(agreementId),
                  onCancel: () => onCancelAgreement?.call(agreementId),
                  onModify: (sessions, minutes, frequency) => onModifyAgreement
                      ?.call(agreementId, sessions, minutes, frequency),
                )
              : Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF1E293B),
                    gradient: isMe
                        ? const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            time,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.isRead ? Icons.done_all : Icons.done,
                              size: 14,
                              color: message.isRead
                                  ? const Color(0xFF60A5FA) // Vibrant blue
                                  : Colors.white.withOpacity(0.5),
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

  void _showReportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.redAccent),
              title: const Text(
                'Report Message',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => ReportDialog(
                    title: 'Report Message',
                    reportedUserId: message.senderId,
                    context: 'message_id:${message.id}',
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
