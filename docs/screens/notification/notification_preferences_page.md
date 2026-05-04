# Notification Preferences Page
**Status**: Pending
**Route**: `/notifications/preferences`
**Priority**: P5
**Use Cases Covered**: X03
## Purpose
Allow users to configure which notification types they receive and through which channels (in-app, push, email). Provides granular control over notification categories to prevent notification fatigue.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  Notification Preferences         |
+------------------------------------------+
|                                           |
|  Push Notifications                       |
|  [Toggle: ON]                             |
|                                           |
|  Email Notifications                      |
|  [Toggle: ON]                             |
|                                           |
|  --- Notification Types ---               |
|                                           |
|  Matches                                  |
|  +--------------------------------------+ |
|  | New match alerts           [Toggle ON]| |
|  | Match expiration reminders [Toggle ON]| |
|  +--------------------------------------+ |
|                                           |
|  Messages                                 |
|  +--------------------------------------+ |
|  | New message notification [Toggle ON] | |
|  | Message reminders         [Toggle OFF]| |
|  +--------------------------------------+ |
|                                           |
|  Sessions                                 |
|  +--------------------------------------+ |
|  | Session reminders     [Toggle ON]    | |
|  |   [15 min before ▼]                  | |
|  | Session changes       [Toggle ON]    | |
|  | Check-in alerts       [Toggle ON]    | |
|  | Session reminders     [Toggle ON]    | |
|  +--------------------------------------+ |
|                                           |
|  Agreements                               |
|  +--------------------------------------+ |
|  | Agreement proposals    [Toggle ON]   | |
|  | Agreement accepted     [Toggle ON]   | |
|  | Modification requests  [Toggle ON]   | |
|  | Agreement expiring     [Toggle ON]   | |
|  +--------------------------------------+ |
|                                           |
|  Trust & Safety                           |
|  +--------------------------------------+ |
|  | Trust score changes    [Toggle ON]   | |
|  | Review received        [Toggle ON]   | |
|  | Appeal updates         [Toggle ON]   | |
|  +--------------------------------------+ |
|                                           |
|  Admin & System                           |
|  +--------------------------------------+ |
|  | Platform announcements  [Toggle OFF] | |
|  | Feature updates         [Toggle OFF] | |
|  +--------------------------------------+ |
|                                           |
|  [Save Preferences]                       |
+------------------------------------------+
```

## Component Breakdown
1. **Global Notification Toggles**: Master switches for "Push Notifications" and "Email Notifications" at the top. Turning off a channel disables all toggles below it with a visual dimming effect.
2. **Category Sections**: Grouped by notification type (Matches, Messages, Sessions, Agreements, Trust & Safety, Admin & System). Each section has a subtle header.
3. **Per-Type Toggle Switch**: Individual toggle for each notification event type. Some have additional settings (e.g., session reminder timing dropdown: 15min, 30min, 1hr, 1 day before).
4. **Save Button**: Primary action. Saves all preferences. Appears only when changes are unsaved.
5. **Restore Defaults**: Link at bottom to reset all toggles to default values with confirmation dialog.

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton preference list with all toggles grayed out and shimmer.
- **Error**: "Could not load preferences." with [Retry] button. Save error: "Failed to save preferences. [Retry]" with option to discard changes.
- **Data**: Fully interactive toggle list. Changes are staged until "Save Preferences" is pressed. Unsaved changes indicator in AppBar.

## Navigation Connections
- **Incoming**: From Settings "Notifications" link, from notification list "Preferences" link.
- **Outgoing**: Save -> Confirmation snackbar -> back to notifications. Restore defaults -> Confirmation dialog -> reload defaults. Back -> Prompt if unsaved changes -> confirm discard.

## Future Considerations
- Quiet hours scheduling (do not disturb time range)
- Notification delivery summary (daily/weekly digest)
- Per-match or per-agreement notification override
- Priority notification bypass (emergency alerts ignore preferences)
- Notification preview text on/off for privacy
- Sound selection per notification type
- Vibration pattern customization
- Notification cooldown (minimize duplicates)
- Platform-level notification settings deep link
