# Change Password Page

**Status**: Existing
**Route**: `/change-password`
**Priority**: P1
**Use Cases Covered**: F08

## Purpose
Allows authenticated users to change their password. Collects current password, new password, and confirm new password. All fields have visibility toggles. Dispatches `AuthChangePasswordRequested` on submission. On `AuthPasswordUpdated` state, shows a success snackbar and pops the page.

## Layout Description
```
+------------------------------------------+
|  [AppBar: "Change Password"]             |
+------------------------------------------+
|                                          |
|  +------------------------------------+  |
|  | Current Password           [👁/👁] |  |
|  +------------------------------------+  |
|                                          |
|  +------------------------------------+  |
|  | New Password               [👁/👁] |  |
|  +------------------------------------+  |
|                                          |
|  +------------------------------------+  |
|  | Confirm New Password       [👁/👁] |  |
|  +------------------------------------+  |
|                                          |
|  [       Update Password (or spinner)   ] |
|                                          |
+------------------------------------------+
```

## Component Breakdown
| Component | Type | Description |
|-----------|------|-------------|
| Scaffold | Structural | Root widget with AppBar (title: "Change Password") |
| BlocConsumer<AuthBloc, AuthState> | State Management | Listens for `AuthPasswordUpdated` and `AuthError` |
| _buildPasswordField | Input | Reusable `TextFormField` with `obscureText` toggle and `OutlineInputBorder` |
| TextFormField (current password) | Input | Current/old password field |
| TextFormField (new password) | Input | New password field; validated min 6 characters |
| TextFormField (confirm new) | Input | Confirm field; validated to match new password |
| ElevatedButton ("Update Password") | Action | Submit button with loading spinner |
| SnackBar | Feedback | Success (green "Password updated successfully") or error (red message) |

## States - Loading, Empty, Error, Data Populated
| State | Description |
|-------|-------------|
| Loading | Button shows `CircularProgressIndicator`; button disabled |
| Empty | All three fields empty on initial load |
| Error | Red snackbar with `state.message`; client-side validation snackbars for empty fields, min length, and password mismatch |
| Data Populated | User has entered values; form is valid and ready to submit |
| Success | `AuthPasswordUpdated` triggers green snackbar and `Navigator.pop(context)` |

## Navigation Connections
- **Entry**: `/change-password` (protected route, accessible from Profile menu)
- On success: `Navigator.pop(context)` returns to previous screen
- On error: Snackbar shown; user remains on page
- AuthBloc event dispatched: `AuthChangePasswordRequested(oldPassword, newPassword)`
