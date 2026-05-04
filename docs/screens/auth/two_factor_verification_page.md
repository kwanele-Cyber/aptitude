# Two-Factor Verification Page

**Status**: Existing
**Route**: `/2fa-verify/:uid`
**Priority**: P0
**Use Cases Covered**: F10

## Purpose
TOTP-style PIN verification during login flow. Accepts a 6-digit PIN from the user and dispatches `AuthVerify2FARequested`. On `Auth2FAVerified`, navigates to `/home` and clears the navigation stack. Automatically triggers verification when all 6 digits are entered (via `onChanged`).

## Layout Description
```
+------------------------------------------+
|  [AppBar: "Security Check"]              |
+------------------------------------------+
|                                          |
|                                          |
|          [Lock Person Icon - 80px]       |
|                                          |
|     Enter your 6-digit PIN to continue   |
|                                          |
|  +------------------------------------+  |
|  |  _  _  _  _  _  _                  |  |
|  +------------------------------------+  |
|                                          |
|       [CircularProgressIndicator]        |
|            (if loading)                  |
|                                          |
|              [Cancel]                    |
|                                          |
+------------------------------------------+
```

## Component Breakdown
| Component | Type | Description |
|-----------|------|-------------|
| Scaffold | Structural | Root widget with AppBar (title: "Security Check") |
| BlocConsumer<AuthBloc, AuthState> | State Management | Listens for `Auth2FAVerified` and `AuthError` |
| Icon (lock_person) | Display | 80px lock-person icon |
| Text (instruction) | Display | "Enter your 6-digit PIN to continue" |
| TextField (PIN) | Input | 6-digit numeric input, obscure text, centered, large font (32px, letter spacing 8); auto-verifies on `onChanged` when length reaches 6 |
| CircularProgressIndicator | Loading | Shown when `AuthLoading` |
| TextButton ("Cancel") | Action | Pops back to previous screen |

## States - Loading, Empty, Error, Data Populated
| State | Description |
|-------|-------------|
| Loading | `CircularProgressIndicator` replaces the Cancel button |
| Empty | Empty PIN field; Cancel button visible |
| Error | Red snackbar with `state.message` |
| Data Populated | PIN field filled (6 digits); verification auto-triggers |
| Success | `Auth2FAVerified` triggers `Navigator.pushNamedAndRemoveUntil('/home')` |

## Navigation Connections
- **Entry**: `/2fa-verify/:uid` (parameter `uid` from path; pre-login, not protected)
- On success: `Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false)` -- clears stack and goes to home
- On cancel: `Navigator.pop(context)` returns to login
- AuthBloc event dispatched: `AuthVerify2FARequested(uid, pin)`
