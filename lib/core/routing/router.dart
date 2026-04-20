import 'package:go_router/go_router.dart';
import '../../usecase/landing_page/view/landing_page.dart';
import '../../usecase/chatsystem/screens/chat_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingPage()),
    GoRoute(
      path: '/chat/:chatId',
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']! ?? 'general';
        return ChatScreen(chatId: chatId);
      },
    ),
  ],
);




