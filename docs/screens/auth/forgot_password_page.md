# Forgot Password Page

**Status**: Existing
**Route**: `/forgot-password`
**Priority**: P0
**Use Cases Covered**: F08

## Purpose
Allows users to request a password reset email. User enters their email address and taps "Send Reset Link". Dispatches `AuthResetPasswordRequested`. On success (`AuthPasswordResetEmailSent`), a green snackbar confirms the email was sent and the page pops.

## Layout Description
```
+------------------------------------------+
|  [AppBar: "Reset Password"]              |
+------------------------------------------+
|                                          |
|  Enter your email address and we will    |
|  send you a link to reset your password. |
|                                          |
|  +------------------------------------+  |
|  | Email                     [@ icon] |  |
|  +------------------------------------+  |
|                                          |
|  [       Send Reset Link (or spinner)  ] |
|                                          |
+------------------------------------------+
```

## Component Breakdown
| Component | Type | Description |
|-----------|------|-------------|
| Scaffold | Structural | Root widget with AppBar (title: "Reset Password") |
| BlocConsumer<AuthBloc, AuthState> | State Management | Listens for `AuthPasswordResetEmailSent` and `AuthError` |
| Column | Layout | Vertical layout with instruction text, email field, and button |
| Text (instruction) | Display | Grey informational text about the reset process |
| TextFormField (email) | Input | Email field with `emailAddress` keyboard type, `email_outlined` prefix icon |
| SizedBox (full-width) | Action | `ElevatedButton` "Send Reset Link" with loading spinner |
| SnackBar (green) | Feedback | "Password reset email sent! Check your inbox." on success |
| SnackBar (red) | Feedback | Error message on `AuthError` |

## States - Loading, Empty, Error, Data Populated
| State | Description |
|-------|-------------|
| Loading | Button shows `CircularProgressIndicator`; button disabled |
| Empty | Email field empty on initial load |
| Error | Red snackbar with `state.message`; basic empty-field validation via snackbar |
| Success | `AuthPasswordResetEmailSent` triggers green snackbar and `Navigator.pop(context)` |

## Navigation Connections
- **Entry**: `/forgot-password` (public route)
- On success: `Navigator.pop(context)` returns to previous screen
- On error: Snackbar shown; user remains on page
- AuthBloc event dispatched: `AuthResetPasswordRequested(email)`
