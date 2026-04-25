import 'package:flutter/material.dart';
import 'dart:async';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final Function(bool) onTyping;
  const ChatInput({required this.onSend, required this.onTyping});

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  Timer? _typingTimer;

  void _onTextChanged(String text) {
    widget.onTyping(true);

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1500), () {
      widget.onTyping(false);
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onChanged: _onTextChanged,
            decoration: InputDecoration(hintText: "Type a message..."),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              _typingTimer?.cancel();
              widget.onTyping(false);
              widget.onSend(_controller.text.trim());
              _controller.clear();
            }
          },
        ),
      ],
    );
  }
}
