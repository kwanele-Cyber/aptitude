# Admin System Configuration Page
**Status**: Pending
**Route**: `/admin/config`
**Priority**: Admin
**Use Cases Covered**: A18
## Purpose
Provide a centralized configuration panel for platform-wide settings. Includes feature flag toggles, match parameter sliders, threshold inputs, and other system-level configurations that affect platform behavior.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [<] System Configuration                 |
+------------------------------------------+
|                                           |
|  +--------------------------------------+ |
|  | ⚠️ Changes take effect immediately. | |
|  | Configuration changes are logged in  | |
|  | the audit log.                       | |
|  +--------------------------------------+ |
|                                           |
|  Feature Flags                            |
|  +--------------------------------------+ |
|  | 🔵 Chat System              [ON  ●] | |
|  | 🔵 Video Calls               [OFF ○] | |
|  | 🔵 Geolocation Check-in      [ON  ●] | |
|  | 🔵 QR Code Scanner           [ON  ●] | |
|  | 🔵 Emoji Reactions           [ON  ●] | |
|  | 🔵 End-to-End Encryption     [OFF ○] | |
|  | 🔵 Trust Score v2            [OFF ○] | |
|  | 🔵 AI Match Suggestions      [ON  ●] | |
|  | 🔵 In-App Video Player       [OFF ○] | |
|  +--------------------------------------+ |
|                                           |
|  Match Parameters                         |
|  +--------------------------------------+ |
|  | Match Radius (km)        [ 50 ===●== ]|
|  | Max Matches per Day       [  5 ===●== ]|
|  | Skill Overlap Threshold   [ 70% ==●== ]|
|  | Availability Match Weight [ 30  ==●== ]|
|  | Rating Impact Weight      [ 20  ==●== ]|
|  +--------------------------------------+ |
|                                           |
|  Trust Score Thresholds                   |
|  +--------------------------------------+ |
|  | Excellent Score Min   [ 80 ]         | |
|  | Good Score Min        [ 60 ]         | |
|  | Fair Score Min        [ 40 ]         | |
|  | No-Show Penalty       [ -15 ]        | |
|  | Session Credit        [ +2 ]         | |
|  | Rating Weight         [ 30% ]        | |
|  +--------------------------------------+ |
|                                           |
|  General Settings                         |
|  +--------------------------------------+ |
|  | Session Auto-Cancel Timeout (min) [15]| |
|  | Review Edit Window (hours)        [48]| |
|  | Agreement Expiry (days)            [90]| |
|  | Max Active Agreements Per User      [10]| |
|  | Maintenance Mode         [OFF ○]      | |
|  +--------------------------------------+ |
|                                           |
|  [Save Configuration]  [Restore Defaults] |
+------------------------------------------+
```

## Component Breakdown
1. **Warning Banner**: Notice that changes take effect immediately and are logged.
2. **Feature Flags Section**: Toggle switches for each feature. Green/blue when on, gray when off. Each toggle has a label and short description on hover. Changes take effect immediately on toggle (with confirmation for critical features).
3. **Match Parameters Section**: Sliders with numeric labels for each parameter:
   - Match radius (km/miles)
   - Max matches per day
   - Skill overlap minimum threshold %
   - Various weight parameters for match algorithm
   - Real-time preview of how slider changes affect match results (optional)
4. **Trust Score Thresholds**: Numeric input fields for trust score boundaries and penalty/credit values. Validation ensures logical min/max ranges.
5. **General Settings**: Mixed input types (number fields, dropdowns, toggles) for platform-wide configuration values.
6. **Save Button**: Saves all pending configuration changes. Only enabled when changes are unsaved.
7. **Restore Defaults Button**: Resets all values to system defaults with confirmation dialog.
8. **Unsaved Changes Indicator**: Yellow banner at top when there are unsaved changes.

## States (Loading, Empty, Error, Data)
- **Loading**: Full skeleton with feature flag placeholders, slider skeletons, input field placeholders with shimmer.
- **Error**: "Could not load configuration." with [Retry] button. Save error: "Failed to save configuration. [Retry]" with option to revert to previous values.
- **Validation Errors**: Inline validation on inputs (min/max, required format). Banner for cross-field validation failures (e.g., "Excellent min must be greater than Good min").
- **Data**: Full interactive configuration panel. Sliders update in real-time. Toggles show immediate state. Save button highlights when changes are pending.

## Navigation Connections
- **Incoming**: From Admin Dashboard "System Settings" quick action, from admin sidebar.
- **Outgoing**: Save -> confirmation -> audit log entry created. Restore Defaults -> confirmation dialog -> reload defaults -> save required. Feature toggle -> immediate effect (with optional confirmation for critical features).

## Future Considerations
- Configuration environment support (staging vs production)
- Configuration version history and rollback
- Scheduled configuration changes (time-based)
- A/B test configuration management
- Environment variable overrides
- Configuration export/import for backup
- Role-based config access (some settings for super admin only)
- Configuration validation test suite
- Config change impact preview
- Dependency graph for config options
- Canary deployment of configuration changes
- Auto-suggested configuration values based on platform data
