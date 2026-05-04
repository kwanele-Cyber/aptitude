# Session Check-In Page
**Status**: Pending
**Route**: `/sessions/:id/checkin`
**Priority**: P4
**Use Cases Covered**: E10, E11
## Purpose
Verify attendance for a session using QR code scanning, geolocation verification, or a manual code entry fallback. Ensures both parties are present before a session can begin.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  Check In                         |
+------------------------------------------+
|                                           |
|  Python Programming #4                    |
|  with Kwanele Mhlongo                     |
|  Thu, Feb 15 · 2:00 PM                   |
|                                           |
|  +--------------------------------------+ |
|  |                                      | |
|  |      [QR Code Scanner Viewport]      | |
|  |                                      | |
|  |    ┌─────────────────────┐           | |
|  |    │                     │           | |
|  |    │    [██████████]     │           | |
|  |    │    [██████████]     │           | |
|  |    │    [██████████]     │           | |
|  |    │    [██████████]     │           | |
|  |    │                     │           | |
|  |    └─────────────────────┘           | |
|  |                                      | |
|  |    Align QR code within frame        | |
|  +--------------------------------------+ |
|                                           |
|  --- or ---                               |
|                                           |
|  Manual Code                               |
|  +--------------------------------------+ |
|  | Enter check-in code:                 | |
|  | [ _ ][ _ ][ _ ][ _ ][ _ ][ _ ]      | |
|  +--------------------------------------+ |
|                                           |
|  [Verify Check-In]                        |
|                                           |
|  Your code (show to partner):             |
|  [ A7K 3B2 ]  [Regenerate]               |
|                                           |
+------------------------------------------+
```

## Component Breakdown
1. **Session Context Header**: Shows skill name, partner name, date, and time for confirmation.
2. **QR Scanner Viewport**: Camera viewfinder with a target frame overlay. Auto-detects QR codes. Flash toggle for low light. Camera permission state handling.
3. **Manual Code Entry**: Alternative method with 6-character alphanumeric input fields (one per character). Auto-advances on input. Pasting supported.
4. **Partner's Code Display**: Shows the user's own code that the partner can scan. "Regenerate" button to refresh (invalidates old code).
5. **Verify Button**: Primary action button, enabled when code is fully entered or QR is scanned.
6. **Method Tabs/Toggle**: [Scan QR] / [Enter Code] to switch between methods.
7. **Geolocation Verification** (optional): Shows "Check in via location" option if proximity detection is enabled. Shows distance to partner if both have location sharing active.

## States (Loading, Empty, Error, Data)
- **Loading**: Camera initialization spinner. Code generation skeleton.
- **Camera Permission Required**: Shows permission explanation with [Grant Camera Access] button. Illustration of camera icon.
- **Scanning (Active)**: Live camera feed with scanning overlay. Visual feedback on code detection (green border animation).
- **Success**:
  ```
  +----------------------------------+
  |                                  |
  |    ✅ Checked In!               |
  |                                  |
  |  You and Kwanele are both       |
  |  present. Ready to start!       |
  |                                  |
  |  [Start Session]                 |
  |                                  |
  +----------------------------------+
  ```
  Confetti or success animation. "Start Session" button navigates to session detail (in-progress status).
- **Error - Invalid Code**: "Invalid code. Please try again or ask your partner to regenerate." with retry option.
- **Error - Wrong Location**: "You are not at the session location." with distance indicator.
- **Error - Too Early/Late**: "Check-in is only available 15 minutes before the session start time." with countdown.
- **Error - Already Checked In**: "You've already checked in for this session." with [View Session] button.
- **Error - Camera Unavailable**: Shows code entry as primary fallback with explanation.

## Navigation Connections
- **Incoming**: From Session Detail "Check In" button, from session reminder notification, from agreement flow.
- **Outgoing**: Success -> `/sessions/:id` (in-progress status). Back -> Session Detail. Manual fallback stays on page. Regenerate -> refreshes code in-place.

## Future Considerations
- NFC tap-to-check-in for in-person sessions
- Biometric verification (face scan)
- Session passcode generated per session
- Offline check-in with sync when online
- Both-party confirmation required for session start
- Check-in timeout (auto-cancel if no show after 15 min)
- Late check-in notifications to both parties
- Check-in history for dispute resolution
