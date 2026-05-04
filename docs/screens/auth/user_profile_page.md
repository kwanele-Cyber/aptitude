# User Profile Page

**Status**: Existing
**Route**: `/profile/:uid`
**Priority**: P1
**Use Cases Covered**: F14

## Purpose
Read-only public profile view for any user by UID. Fetches user data via `AuthViewUserProfileRequested` event. Displays user info, email, phone, bio, skills (as chips), and interests (as chips). Shows loading spinner while fetching and an error state with retry button on failure.

## Layout Description
```
+------------------------------------------+
|  [AppBar: "User Profile"]                |
+------------------------------------------+
|                                          |
|           [CircleAvatar - 48px]          |
|              Full Name                   |
|              Title (if any)              |
|                                          |
|  Email:      user@email.com              |
|  Phone:      +1234567890 (if present)    |
|                                          |
|  Bio                                     |
|  [bio text]                              |
|                                          |
|  Skills                                  |
|  [Chip] [Chip] [Chip]                    |
|                                          |
|  Interests                               |
|  [Chip] [Chip] [Chip]                    |
|                                          |
+------------------------------------------+
```

## Component Breakdown
| Component | Type | Description |
|-----------|------|-------------|
| Scaffold | Structural | Root widget with AppBar (title: "User Profile") |
| BlocBuilder<AuthBloc, AuthState> | State Management | Builds UI based on `AuthLoading`, `AuthUserProfileLoaded`, or `AuthError` states |
| CircleAvatar | Display | Shows user initials, radius 48, font size 32 |
| Text (name) | Display | User's full name, 24px bold, centered |
| Text (title) | Display | User's title/headline in grey, 16px |
| _InfoRow | Display | Label-value rows for email and phone |
| Text (bio label) | Display | Bold "Bio" section header |
| Text (bio) | Display | User's biography text |
| Text (skills label) | Display | Bold "Skills" section header |
| Wrap of Chip | Display | Skills rendered as chips |
| Text (interests label) | Display | Bold "Interests" section header |
| Wrap of Chip | Display | Interests rendered as chips |

## States - Loading, Empty, Error, Data Populated
| State | Description |
|-------|-------------|
| Loading | Centered `CircularProgressIndicator` |
| Empty | Shows "Loading..." text (default fallback) when no state matches |
| Error | Red error text with "Retry" `ElevatedButton` that re-dispatches `AuthViewUserProfileRequested` |
| Data Populated | `AuthUserProfileLoaded` state: displays full profile with name, email, bio, skills chips, interests chips; sections conditional on data presence |

## Navigation Connections
- **Entry**: `/profile/:uid` (parameter `uid` from path)
- On retry: dispatches `AuthViewUserProfileRequested(uid: uid)`
- AuthBloc event on initial load: `AuthViewUserProfileRequested(uid: uid)` must be dispatched from the calling page
- Fallback state: "Loading..." text displayed when no specific state is matched
