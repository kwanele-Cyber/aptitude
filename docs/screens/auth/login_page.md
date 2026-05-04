# Login Page

**Status**: Existing
**Route**: `/login`
**Priority**: P0
**Use Cases Covered**: F03

## Purpose
Provides email/password authentication form. Dispatches `AuthLoginRequested` on form submission. Displays error snackbars via `BlocConsumer` on `AuthError` state. Shows a loading spinner in the submit button while `AuthLoading` is active.

## Layout Description
```
+------------------------------------------+
|  [AppBar: "Login"]                       |
+------------------------------------------+
|                                          |
|            [Lock Icon - 80px]            |
|                                          |
|  +------------------------------------+  |
|  |  Email                    [@ icon] |  |
|  +------------------------------------+  |
|                                          |
|  +------------------------------------+  |
|  |  Password                 [key icn]|  |
|  +------------------------------------+  |
|                                          |
|  [    Login  (or spinner if loading)   ] |
|                                          |
+------------------------------------------+
```

## Component Breakdown
| Component | Type | Description |
|-----------|------|-------------|
| Scaffold | Structural | Root widget with AppBar (title: "Login") |
| BlocConsumer<AuthBloc, AuthState> | State Management | Listens for `AuthError` to show snackbar; rebuilds on state change |
| Form (with GlobalKey) | Form | Wraps input fields for validation |
| TextFormField (email) | Input | Email address with `emailAddress` keyboard type; validates format with regex |
| TextFormField (password) | Input | Password field with `obscureText: true`; validates min 6 characters |
| ElevatedButton | Action | Submit button; shows `CircularProgressIndicator` (20x20, stroke 2) when `AuthLoading` |
| SnackBar | Feedback | Displayed on `AuthError` state with red background |

## States - Loading, Empty, Error, Data Populated
| State | Description |
|-------|-------------|
| Loading | Button text replaced by `CircularProgressIndicator`; button disabled |
| Empty | Initial state with empty fields |
| Error | Red `SnackBar` with `state.message` shown via `BlocConsumer.listener` |
| Data Populated | Not stored on this page; on success the router redirects to `/home` |

## Navigation Connections
- **Entry**: `/login` (public route, no auth required)
- On success: Router detects `AuthAuthenticated` and redirects to `/home`
- Links out: Register page (`/register`), Forgot password (`/forgot-password`), Account recovery (`/account-recovery`)
- AuthBloc event dispatched: `AuthLoginRequested(email, password)`
