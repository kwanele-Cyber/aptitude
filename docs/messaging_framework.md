# Messaging Development Framework

This document outlines the development framework for the in-app messaging feature. It is designed to align with the project's existing centralized development framework, ensuring consistency and scalability.

## Core Components

The messaging feature will be built upon the same layered architecture as the rest of the application:

*   **Models:** Representing the data structures for messaging.
*   **Repositories:** Wrapping the `DatabaseService` to provide a high-level API for messaging data.
*   **ViewModels:** Containing the business logic for the messaging UI.
*   **Views:** The UI components for the messaging feature.

## Data Models

Two new models will be introduced for the messaging feature. These models will reside in `lib/usecase/messaging/models/`.

### 1. `Message` Model

This model represents a single message sent within a conversation.

```dart
// lib/usecase/messaging/models/message.dart

class Message {
  final String id; // Unique ID for the message
  final String conversationId; // ID of the conversation it belongs to
  final String senderId; // ID of the user who sent the message
  final String text; // The content of the message
  final DateTime timestamp; // The time the message was sent

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });
}
```

### 2. `Conversation` Model

This model represents a distinct chat thread between two or more users.

```dart
// lib/usecase/messaging/models/conversation.dart

class Conversation {
  final String id; // Unique ID for the conversation
  final List<String> participants; // List of user IDs participating in the conversation
  final String lastMessage; // The content of the most recent message
  final DateTime lastMessageTimestamp; // Timestamp of the last message

  Conversation({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTimestamp,
  });
}
```

## Model Mapping

The new messaging models will have direct relationships with the existing `User` model:

*   **`Conversation.participants` -> `User.uid`:** The `participants` list in the `Conversation` model will contain the unique IDs (`uid`) of the users involved in the chat. This allows us to fetch user profiles (e.g., names, avatars) for display in the UI.
*   **`Message.senderId` -> `User.uid`:** The `senderId` in the `Message` model will be the `uid` of the user who sent the message. This allows us to identify the sender of each message and display their information accordingly.

## Repository Layer

Two new repositories will be created to manage the messaging data. They will be located in `lib/core/data/repositories/`.

### 1. `ConversationRepository`

*   **Responsibilities:** Manages conversations.
*   **Methods:**
    *   `Future<List<Conversation>> getUserConversations(String uid)`: Get all conversations for a user.
    *   `Future<String> createConversation(List<String> participantUids)`: Create a new conversation.

### 2. `MessageRepository`

*   **Responsibilities:** Manages messages within conversations.
*   **Methods:**
    *   `Stream<List<Message>> getMessages(String conversationId)`: Get a real-time stream of messages for a conversation.
    *   `Future<void> sendMessage(Message message)`: Send a new message.

## ViewModel Layer

The ViewModels will handle the business logic for the messaging UI.

*   **`ConversationListViewModel`:**
    *   Fetches and manages the list of a user's conversations using `ConversationRepository`.
    *   Exposes a `List<Conversation>` to the `ConversationListScreen`.
*   **`ChatViewModel`:**
    *   Takes a `conversationId` as input.
    *   Uses `MessageRepository` to get a stream of messages for the conversation.
    *   Provides a method to send new messages.

## View Layer

The UI for the messaging feature will consist of two main screens:

*   **`ConversationListScreen`:**
    *   Displays a list of the user's conversations, showing the other participant(s) and the last message.
    *   Tapping on a conversation will navigate to the `ChatScreen`.
*   **`ChatScreen`:**
    *   Displays the messages in a conversation.
    *   Provides a text input field and a send button to send new messages.

## Data Flow Example: Sending a Message

1.  **View (`ChatScreen`):** User types a message and taps the send button.
2.  **ViewModel (`ChatViewModel`):** The `sendMessage` method is called on the ViewModel.
3.  **Repository (`MessageRepository`):** The ViewModel creates a `Message` object and calls `messageRepository.sendMessage(message)`.
4.  **Database Service:** The `MessageRepository` uses the `DatabaseService` to write the new message to the database.
5.  **Real-time Update:** The `getMessages` stream in the `ChatViewModel` receives the new message, and the UI is automatically updated to display it.