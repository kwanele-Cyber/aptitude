# Session Notes Page
**Status**: Pending
**Route**: `/sessions/:id/notes`
**Priority**: P4
**Use Cases Covered**: E15
## Purpose
Provide a collaborative rich text or markdown note-taking space for session participants. Both teacher and learner can add, edit, and view notes, making it a shared reference document for each session.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back] Session Notes      [Last edit: 2m]|
+------------------------------------------+
|                                           |
|  Python Programming #4                    |
|  with Kwanele Mhlongo · Feb 15, 2026     |
|                                           |
|  [B] [I] [U] [H] [• List] [1. List]     |
|  [Code] [Quote] [Link] [Image] [+]      |
+------------------------------------------+
|                                           |
|  # Session 4 - Functions & Modules       |
|                                           |
|  ## Key Concepts Covered                 |
|                                           |
|  1. **Function definitions** - `def`     |
|     keyword, parameters, return values   |
|                                           |
|  2. **Lambda functions** - anonymous     |
|     functions with `lambda`              |
|                                           |
|  3. **Modules and imports** - `import`,  |
|     `from ... import`, aliasing          |
|                                           |
|  ## Homework                             |
|  - Complete exercises 5.1-5.4           |
|  - Build a calculator module            |
|                                           |
|  ## Questions for Next Session           |
|  - How do decorators work?              |
|                                           |
+------------------------------------------+
|  +2 collaborators editing now             |
+------------------------------------------+
```

## Component Breakdown
1. **Session Header**: Skill name, session number, partner name, and session date.
2. **Toolbar**: Rich text formatting controls:
   - Bold, Italic, Underline, Strikethrough
   - Heading levels (H1-H3)
   - Bullet list, Numbered list, Checklist
   - Code block, Block quote
   - Link insertion, Image upload
   - Undo/Redo
3. **Editor Area**: Rich text editor (or markdown editor with preview toggle). Supports:
   - Real-time collaborative editing (WebSocket-based)
   - Cursor position indicators for collaborators
   - Auto-save with debounce
   - Last saved timestamp
4. **Collaborator Indicator**: Shows avatars of other users currently viewing/editing. "X collaborators editing now" text.
5. **Version History Access**: Button to view/edit history (future).
6. **Export Button**: Download as Markdown, PDF, or plain text.

## States (Loading, Empty, Error, Data)
- **Loading**: Editor skeleton with toolbar placeholder and gray text lines with shimmer.
- **Empty (No Notes Yet)**:
  ```
  +----------------------------------+
  |                                  |
  |    [Illustration: notepad]       |
  |                                  |
  |  No notes for this session yet   |
  |                                  |
  |  Start taking notes to capture   |
  |  key concepts, homework, and     |
  |  questions for next time.        |
  |                                  |
  |  [Start Writing]                 |
  |                                  |
  +----------------------------------+
  ```
  Tapping "Start Writing" focuses the editor with a blank document.
- **Error**: "Could not load notes" with [Retry]. Auto-save failure shows warning banner: "Changes not saved. [Retry]". Connection lost banner for collaborative features.
- **Data**: Full rich text editor with content loaded. Auto-save indicator ("Saving..." / "Saved"). Collaborative presence indicators. Read-only view if session has ended (with "View Only" banner).

## Navigation Connections
- **Incoming**: From Session Detail "Notes" quick link.
- **Outgoing**: Back -> Auto-saves before navigating away. Export -> Share sheet or file download. Image upload -> System image picker. Link insertion -> URL input dialog.

## Future Considerations
- Per-session note templates (agenda, key points, action items)
- Note sharing outside of session (public link with view-only access)
- AI-powered note summarization
- Search across all session notes
- Note categories/tags
- Voice-to-text note input
- Drawing/whiteboard integration for visual notes
- @mention to reference skills or concepts
- Note version diff view
- Print-friendly formatting
