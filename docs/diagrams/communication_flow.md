# Communication Flow

**Feature**: Messaging System
**Screens**: 2 (0 existing + 2 pending)
**Status**: Planned

## Diagram

```mermaid
flowchart TD
    classDef done fill:#d4edda,stroke:#28a745,color:#155724
    classDef pending fill:#fff3cd,stroke:#ffc107,color:#856404
    classDef decision fill:#f8f9fa,stroke:#6c757d,stroke-width:2px

    MessagesTab(["Messages Tab"]):::pending
    MatchesTab(["Matches Tab"]):::done
    UserProfile(["User Profile"]):::done

    ChatListPage["Chat List Page"]:::pending
    ChatDetailPage["Chat Detail Page"]:::pending

    subgraph ChatActions["Chat Actions"]
        SendMessage["Send Message\n(text, image, file)"]:::pending
        TypingIndicator["Typing Indicator"]:::pending
        ReadReceipts["Read Receipts\n(single/double ticks)"]:::pending
    end

    BlockDialog["Block User Dialog"]:::pending
    ReportDialog["Report Message Dialog"]:::pending
    AgreementLink["Create Agreement\n(from chat profile)"]:::pending

    MessagesTab --> ChatListPage
    MatchesTab -->|"matched user"| ChatDetailPage
    UserProfile --> ChatDetailPage
    ChatListPage --> ChatDetailPage

    ChatDetailPage --> SendMessage
    ChatDetailPage --> TypingIndicator
    ChatDetailPage --> ReadReceipts
    ChatDetailPage --> BlockDialog
    ChatDetailPage --> ReportDialog
    ChatDetailPage --> AgreementLink
```

## Flow Description
The Messages tab shows a list of active conversations. Tapping a conversation opens the Chat Detail Page with real-time messaging, typing indicators, and read receipts. Users can send text, images, and files. From a chat, users can block the other person or report inappropriate messages. After matching, users can initiate a chat or proceed to create a formal agreement.

## Screen Inventory

| Screen | Route | Status | Use Cases |
|--------|-------|--------|-----------|
| Chat List | `/chats` | ❌ Todo | C01, C04 |
| Chat Detail | `/chats/:id` | ❌ Todo | C02-C08 |

## Notes
- Requires real-time messaging via Firebase (FCM for push, Realtime Database for messages)
- Block user (C07) and report message (C08) are essential safety features
- Typing indicator and read receipts add polish for premium feel
