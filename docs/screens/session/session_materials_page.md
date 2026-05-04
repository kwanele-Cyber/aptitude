# Session Materials Page
**Status**: Pending
**Route**: `/sessions/:id/materials`
**Priority**: P4
**Use Cases Covered**: E14
## Purpose
Provide a centralized file repository for session-related materials. Both teacher and learner can upload, view, and download resources such as worksheets, presentations, code samples, and reference documents.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  Session Materials    [Add File +]|
+------------------------------------------+
|                                           |
|  Python Programming #4                    |
|  with Kwanele Mhlongo                     |
|                                           |
|  +--------------------------------------+ |
|  | 📄 Python_Basics_Cheatsheet.pdf     | |
|  | 2.4 MB · PDF · Uploaded Feb 12      | |
|  | by Kwanele                           | |
|  | [Download] [⋮]                       | |
|  +--------------------------------------+ |
|  | 📄 Homework_Week3.py                 | |
|  | 8 KB · Python · Uploaded Feb 14      | |
|  | by Me                                 | |
|  | [Download] [⋮]                       | |
|  +--------------------------------------+ |
|  | 📄 Code_Review_Notes.txt             | |
|  | 1.2 KB · Text · Uploaded Feb 14      | |
|  | by Kwanele                           | |
|  | [Download] [⋮]                       | |
|  +--------------------------------------+ |
|  | 📄 Session_Recording_Link.url         | |
|  | 1 KB · Link · Uploaded Feb 15        | |
|  | by Kwanele                           | |
|  | [Open] [⋮]                            | |
|  +--------------------------------------+ |
|                                           |
|  [Upload New Material]                    |
+------------------------------------------+
```

## Component Breakdown
1. **Session Header**: Skill name, session number, partner name for context.
2. **File List**: Scrollable list of file items, each showing:
   - File type icon (PDF, image, code, text, link, etc.) based on extension.
   - File name (tappable to preview/open).
   - File size (formatted: KB, MB).
   - File type label.
   - Upload date and uploader name.
   - Action buttons: [Download] / [Open] for links, and overflow menu [⋮] with [Delete] (own files only), [Share], [Copy Link].
3. **Add File Button**: Located in AppBar and/or as a bottom button. Triggers file picker or system share sheet.
4. **Upload Progress Indicator**: Shows progress bar per file during upload. Cancel option for in-progress uploads.
5. **Empty State Illustration**: When no materials exist yet (see below).
6. **File Preview** (in-app or system): Tapping a file opens quick preview for supported types (PDF, images, text).

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton file list with 3-4 placeholder items (icon + text lines with shimmer).
- **Empty**:
  ```
  +----------------------------------+
  |                                  |
  |    [Illustration: folder with    |
  |     documents]                   |
  |                                  |
  |  No materials yet                |
  |                                  |
  |  Upload worksheets, code         |
  |  samples, or reference docs      |
  |  to enhance your sessions.       |
  |                                  |
  |  [Upload First File]             |
  |                                  |
  +----------------------------------+
  ```
- **Error**: "Could not load materials" with [Retry] button. Individual file download error shown as toast/snackbar.
- **Upload Error**: "Failed to upload [filename]. [Retry]" inline error on the failed item.
- **Data**: Scrollable file list sorted by upload date (newest first). Each item has download and overflow actions. Pull-to-refresh supported.

## Navigation Connections
- **Incoming**: From Session Detail "Materials" quick link, from share sheet (other apps).
- **Outgoing**: Download -> Saves to device or opens in-app preview. File picker -> System file dialog (PDF, images, .doc, .txt, .zip). Delete -> Confirmation dialog -> refresh list. Upload -> Progress -> list refresh.

## Future Considerations
- Folder organization within sessions
- File versioning (upload new version, keep history)
- Drag-and-drop reorder for curriculum materials
- Bulk download as ZIP
- File comments/annotations per material
- Auto-generated session recording transcripts
- Material expiry (auto-archive after agreement ends)
- AI-generated summaries of uploaded materials
- Material sharing across sessions in same agreement
- File size limits and storage quota indicator
