# [Screen Name]

**Status**: [Existing | Pending]
**Route**: `/path`
**Priority**: [P0/P1/P2/P3/P4/P5/Admin]
**Use Cases Covered**: [IDs from use case tracker]

## Purpose
[One paragraph describing what this screen does and who uses it]

## Layout Description
```
+------------------------------------------+
|  [AppBar / Header]                       |
+------------------------------------------+
|                                          |
|  [Body content area]                     |
|                                          |
|                                          |
+------------------------------------------+
|  [Bottom bar / FAB if applicable]        |
+------------------------------------------+
```

[Text description of layout sections]

## Component Breakdown

| Component | Type | Description | States |
|-----------|------|-------------|--------|
| [Name] | [Card/List/Form/Dialog] | What it does | loading, empty, error, data |

## States

### Loading
- Position and type of loading indicator
- Any skeleton/shimmer shown

### Empty
- Icon, message text, optional action button
- Contextual message variation

### Error
- Error message display
- Retry behavior

### Data Populated
- Default layout of data
- Pagination or infinite scroll behavior

## Navigation Connections
- **Entry points**: [screens/routes that link here]
- **Exit points**: [screens/routes this screen links to]
- **Dialogs/Modals**: [in-page dialogs]

## Future Considerations
[Enhancements planned but not implemented]
