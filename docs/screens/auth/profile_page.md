# Profile Page

**Status**: Existing
**Route**: `/profile`
**Priority**: P1
**Use Cases Covered**: F11, F12, F13, F15

## Purpose
Editable profile form for the authenticated user. Pre-populates fields from `AuthAuthenticated.userEntity`. Allows editing first name, last name, phone, and bio. Uses `UpdateProfileUsecase` via service locator (`di.sl`). Includes menu items for Change Password, Two-Factor Authentication, Browse Skills Feed, Search Skills, Create Skill, and Saved Searches. Provides Delete Account and Logout actions.

## Layout Description
```
+------------------------------------------+
|  [AppBar: "Profile"]                     |
+------------------------------------------+
|                                          |
|           [CircleAvatar - 48px]          |
|              User Name                   |
|              user@email.com              |
|                                          |
|  +------------------+ +-----------------+ |
|  | First Name       | | Last Name       | |
|  +------------------+ +-----------------+ |
|                                          |
|  +------------------------------------+  |
|  | Phone                              |  |
|  +------------------------------------+  |
|                                          |
|  +------------------------------------+  |
|  | Bio (3 lines max)                  |  |
|  +------------------------------------+  |
|                                          |
|  [         Save Changes              ]   |
|  ------------------------------------    |
|  > Change Password                       |
|  > Two-Factor Authentication             |
|  ------------------------------------    |
|  Skills                                  |
|  > Browse Skills Feed                    |
|  > Search Skills                         |
|  > Create Skill                          |
|  > Saved Searches                        |
|                                          |
|  [Delete Account]  [Logout]              |
+------------------------------------------+
```

## Component Breakdown
| Component | Type | Description |
|-----------|------|-------------|
| Scaffold | Structural | Root widget with AppBar (title: "Profile") |
| BlocListener<AuthBloc, AuthState> | State Management | Listens for `AuthError` to show snackbar |
| CircleAvatar | Display | Shows user initials from first/last name, radius 48 |
| TextField (first name) | Input | Pre-filled with `userEntity.firstName` |
| TextField (last name) | Input | Pre-filled with `userEntity.lastName` |
| TextField (phone) | Input | Pre-filled with `userEntity.phone`, phone keyboard type |
| TextField (bio) | Input | Pre-filled with `userEntity.bio`, max 3 lines |
| ElevatedButton ("Save Changes") | Action | Calls `UpdateProfileUsecase`, shows spinner when saving |
| ListTile (menu items) | Navigation | Navigates to change password, 2FA, skills pages |
| TextButton ("Delete Account") | Action | Displays confirmation `AlertDialog`, dispatches `AuthDeleteAccountRequested` |
| TextButton ("Logout") | Action | Dispatches `AuthLogoutRequested` |
| SnackBar | Feedback | Success (green), Failure (red) |

## States - Loading, Empty, Error, Data Populated
| State | Description |
|-------|-------------|
| Loading | Save button shows `CircularProgressIndicator` while `_isSaving` is true |
| Empty | If `_user` is null, shows centered "No user data" text |
| Error | Red snackbar on `AuthError` or failed update result |
| Data Populated | All fields pre-filled from authenticated user entity; menu items visible |

## Navigation Connections
- **Entry**: `/profile` (protected route)
- Menu items navigate via `Navigator.pushNamed`: `/change-password`, `/2fa-setup`, `/skills/feed`, `/skills/search`, `/skills/create`, `/skills/saved-searches/:uid`
- Delete Account dispatches: `AuthDeleteAccountRequested`
- Logout dispatches: `AuthLogoutRequested`
- Uses: `UpdateProfileUsecase` via `di.sl<UpdateProfileUsecase>()`
