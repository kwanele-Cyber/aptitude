# Export Data Page

**Status**: Existing
**Route**: `/export-data`
**Priority**: P1
**Use Cases Covered**: F16

## Purpose
Allows users to export their account data in JSON format. Initial state shows an "Export My Data" button. After tapping, dispatches `AuthExportUserDataRequested`. On `AuthUserDataExported`, displays the JSON data in a monospace, read-only selectable text view within a styled container. Provides a "Copy to Clipboard" button. On `AuthError`, shows error text with a retry button.

## Layout Description
```
+------------------------------------------+
|  [AppBar: "Export My Data"]              |
+------------------------------------------+
|                                          |
|  (Initial state)                         |
|                                          |
|        [ Export My Data  ]               |
|                                          |
|  (After export)                          |
|  =================                       |
|  Your data is available as JSON below.   |
|  You can copy it or save it for records. |
|                                          |
|  +------------------------------------+  |
|  |  {                                 |  |
|  |    "firstName": "John",            |  |
|  |    "lastName": "Doe",              |  |
|  |    "email": "john@example.com",    |  |
|  |    "phone": "+1234567890",         |  |
|  |    "bio": "...",                   |  |
|  |    "skills": [...],                |  |
|  |    ...                             |  |
|  |  }                                 |  |
|  +------------------------------------+  |
|                                          |
|  [   Copy to Clipboard   ]               |
|          [Done]                          |
|                                          |
|  (Error state)                           |
|  ==============                          |
|     Error message (red)                  |
|          [Retry]                         |
|                                          |
+------------------------------------------+
```

## Component Breakdown
| Component | Type | Description |
|-----------|------|-------------|
| Scaffold | Structural | Root widget with AppBar (title: "Export My Data") |
| BlocBuilder<AuthBloc, AuthState> | State Management | Builds UI based on `AuthLoading`, `AuthUserDataExported`, `AuthError`, or default state |
| ElevatedButton ("Export My Data") | Action | Initial state: triggers `AuthExportUserDataRequested` |
| Text (description) | Display | Grey instructional text about the exported data |
| Container (JSON viewer) | Display | Grey background container (grey[100]) with rounded corners; contains `SelectableText` in monospace font, 12px |
| ElevatedButton.icon ("Copy to Clipboard") | Action | Copies formatted JSON to clipboard via `Clipboard.setData`; shows confirmation snackbar |
| TextButton ("Done") | Action | Pops back to previous screen |
| Text (error) | Display | Red error message from `AuthError.state` |
| ElevatedButton ("Retry") | Action | Re-dispatches `AuthExportUserDataRequested` |

## States - Loading, Empty, Error, Data Populated
| State | Description |
|-------|-------------|
| Loading | Centered `CircularProgressIndicator` |
| Empty (initial) | "Export My Data" button shown; no data displayed yet |
| Error | Red error text with "Retry" button |
| Data Populated | `AuthUserDataExported` state: pretty-printed JSON in monospace selectable text view, with copy and done buttons |

## Navigation Connections
- **Entry**: `/export-data` (protected route, accessible from Profile menu)
- On "Done": `Navigator.pop(context)`
- On "Retry": re-dispatches `AuthExportUserDataRequested`
- AuthBloc event dispatched: `AuthExportUserDataRequested`
