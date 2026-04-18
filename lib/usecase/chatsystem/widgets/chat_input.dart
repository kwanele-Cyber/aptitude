import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  const ChatInput({required this.onSend});

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Type a message..."),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onSend(_controller.text.trim());
              _controller.clear();
            }
          },
        ),
      ],
    );
  }
}
