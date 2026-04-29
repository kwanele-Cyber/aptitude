import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/chat_message.dart';
import 'package:intl/intl.dart';
import 'package:myapp/usecase/skill_match/widgets/agreement_message_card.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final Function(String agreementId)? onAcceptAgreement;
  final Function(String agreementId)? onRejectAgreement;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onAcceptAgreement,
    this.onRejectAgreement,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hm().format(
      DateTime.fromMillisecondsSinceEpoch(message.timestamp),
    );

    final agreementId = message.metadata?['agreementId'] as String?;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
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
              )
            : Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF7C3AED) : const Color(0xFF1E293B),
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
                      style: const TextStyle(color: Colors.white, fontSize: 14),
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
                            Icons.done_all,
                            size: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
