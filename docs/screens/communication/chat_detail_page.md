# Chat Detail Page
**Status**: Pending
**Route**: `/chats/:id`
**Priority**: P3
**Use Cases Covered**: C02, C03, C04, C05, C06, C07, C08
## Purpose
Provide a real-time messaging interface between two users who have been matched. Supports text messages, read receipts, typing indicators, and overflow actions for safety (block/report).
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back] Kwanele Mhlongo    [⋮ Overflow]   |
|              Online                       |
+------------------------------------------+
|                                           |
|  +----------------------------+           |
|  | Hey, are you free tomorrow?| 10:30 AM |
|  |                            |  ✓✓       |
|  +----------------------------+           |
|                                           |
|            +-----------------------+      |
|            | Yes, I am! 2pm works |      |
|            |                   ✓✓ |      |
|            +-----------------------+      |
|                                           |
|  +----------------------------+           |
|  | Great, see you at the      | 10:32 AM |
|  | library                    |  ✓✓      |
|  +----------------------------+           |
|                                           |
|         Kwanele is typing...              |
|                                           |
|                                           |
|                                           |
|                                           |
|                                           |
|                                           |
| +----------------------------------------+|
| | [📎]  [📷]  [Type a message...] [➤]  ||
| +----------------------------------------+|
+------------------------------------------+
```

## Component Breakdown
1. **Chat AppBar**: Partner's name, online/offline status indicator (green dot / gray dot), overflow menu (⋮) with "View Profile", "Block User", "Report User" options.
2. **Message Bubble**:
   - Sent messages: right-aligned, primary color background, white text.
   - Received messages: left-aligned, gray/light background, dark text.
   - Timestamp shown below each bubble or on hover.
   - Read receipts: single gray check (✓ = delivered), double blue checks (✓✓ = read).
3. **Date Separator**: Centered divider with date text (e.g., "--- Today ---").
4. **Typing Indicator**: Animated dots with partner's name when they are composing.
5. **Message Input Bar**:
   - Attachment button (📎) for files/documents.
   - Image button (📷) for camera/gallery.
   - Text field with auto-resize.
   - Send button (➤) enabled only when text or attachment is present.
6. **Overflow Menu**: Bottom sheet with "View Profile", "Block User" (with confirmation dialog), "Report User" (navigates to report flow), "Clear Chat".

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton message bubbles (alternating left/right gray blocks) with shimmer. No input bar shown until loaded.
- **Empty (New Conversation)**:
  ```
  +----------------------------------+
  |                                  |
  |    [Illustration: handshake]     |
  |                                  |
  |  You matched with Kwanele!       |
  |                                  |
  |  Say hello to start the          |
  |  conversation                    |
  |                                  |
  |  [Send First Message]            |
  |                                  |
  +----------------------------------+
  ```
  Shows match illustration, congratulatory message, and quick-prompt buttons like "Say hi!" or "Ask about Python".
- **Error**: Error banner at top: "Could not load messages. [Retry]". Option to go back. Input bar disabled if chat is inaccessible.
- **Data**: Scrollable message list anchored to bottom (newest). Auto-scrolls to latest on new messages. Pull-to-refresh to load older history.

## Navigation Connections
- **Incoming**: From Chat List (tap item), from push notification, from match screen.
- **Outgoing**: Back -> `/chats` (Chat List). Profile -> `/profile/:uid`. Block/Report -> confirmation then back. Attachment picker -> system file/gallery picker. Camera -> native camera.

## Future Considerations
- Voice message recording and playback
- Image preview with lightbox
- Message reactions (emoji long-press)
- Reply threading (swipe to reply)
- Message search within chat
- Message deletion for everyone
- Share contact information card
- Video call initiation from chat
- Scheduled message sending
- Chat export as PDF/text
