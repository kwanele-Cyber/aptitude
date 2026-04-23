import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../usecase/chatsystem/screens/chat_screen.dart';
import '../../usecase/chatsystem/screens/conversations_screen.dart';
import '../../usecase/chatsystem/screens/new_conversation_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => ConversationsScreen()),
    GoRoute(path: '/login', builder: (context, state) => const Scaffold(body: Center(child: Text('Login disabled')))),
    GoRoute(path: '/register', builder: (context, state) => const Scaffold(body: Center(child: Text('Registration disabled')))),
    GoRoute(path: '/new-conversation', builder: (context, state) => NewConversationScreen()),
    GoRoute(
      path: '/chat/:chatId',
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        return ChatScreen(chatId: chatId);
      },
    ),
  ],
);
