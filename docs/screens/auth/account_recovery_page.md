# Account Recovery Page

**Status**: Existing
**Route**: `/account-recovery`
**Priority**: P0
**Use Cases Covered**: F09

## Purpose
Allows users to recover their account using an email and recovery code. Dispatches `AuthRecoverAccountRequested` on form submission. On `AuthAccountRecovered` state, shows a success snackbar and pops the page. Provides an alternative access path when the user cannot log in normally.

## Layout Description
```
+------------------------------------------+
|  [AppBar: "Account Recovery"]            |
+------------------------------------------+
|                                          |
|          [Restore Icon - 64px]           |
|                                          |
|         Recover Your Account             |
|                                          |
|  Enter your email and a recovery code    |
|  to regain access.                       |
|                                          |
|  +------------------------------------+  |
|  | Email                      [@ icn] |  |
|  +------------------------------------+  |
|                                          |
|  +------------------------------------+  |
|  | Recovery Code              [key ic]|  |
|  +------------------------------------+  |
|                                          |
|  [    Recover Account (or spinner)    ]  |
|                                          |
+------------------------------------------+
```

## Component Breakdown
| Component | Type | Description |
|-----------|------|-------------|
| Scaffold | Structural | Root widget with AppBar (title: "Account Recovery") |
| BlocConsumer<AuthBloc, AuthState> | State Management | Handles `AuthAccountRecovered` and `AuthError` states |
| Form (with GlobalKey) | Form | Wraps fields for validation |
| Icon (restore) | Display | 64px blue restore icon |
| Text (title) | Display | "Recover Your Account" 24px bold, centered |
| Text (subtitle) | Display | "Enter your email and a recovery code to regain access." in grey |
| TextFormField (email) | Input | Email field with `@` prefix icon; validates non-empty and contains `@` |
| TextFormField (recovery code) | Input | Recovery code field with key prefix icon; validates non-empty |
| ElevatedButton ("Recover Account") | Action | Submit button with loading spinner; disabled when `AuthLoading` |

## States - Loading, Empty, Error, Data Populated
| State | Description |
|-------|-------------|
| Loading | Button shows `CircularProgressIndicator`; button disabled |
| Empty | Both fields empty on initial load |
| Error | Snackbar with error message; "Please enter your email" or "Please enter your recovery code" on empty field validation |
| Data Populated | Both fields filled and validated; form ready to submit |
| Success | `AuthAccountRecovered` triggers green snackbar and `Navigator.of(context).pop()` |

## Navigation Connections
- **Entry**: `/account-recovery` (accessible from Profile menu; also linked from login page)
- On success: `Navigator.of(context).pop()` returns to previous screen
- On error: Snackbar shown; user remains on page
- AuthBloc event dispatched: `AuthRecoverAccountRequested(email, recoveryCode)`
