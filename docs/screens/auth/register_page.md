# Register Page

**Status**: Existing
**Route**: `/register`
**Priority**: P0
**Use Cases Covered**: F02

## Purpose
New user registration form. Collects first name, last name, email, password, and confirm password. Includes a terms and conditions checkbox. Dispatches `AuthRegisterRequested` on valid submission. On success, the router redirects to `/home`.

## Layout Description
```
+------------------------------------------+
|  [AppBar: "Create Account"]              |
+------------------------------------------+
|  +------------------+ +-----------------+ |
|  | First Name       | | Last Name       | |
|  +------------------+ +-----------------+ |
|                                          |
|  +------------------------------------+  |
|  | Email                              |  |
|  +------------------------------------+  |
|                                          |
|  +------------------------------------+  |
|  | Password                    [👁/👁]|  |
|  +------------------------------------+  |
|                                          |
|  +------------------------------------+  |
|  | Confirm Password           [👁/👁]|  |
|  +------------------------------------+  |
|                                          |
|  [x] I agree to Terms & Conditions       |
|                                          |
|  [      Register (or spinner)         ]  |
+------------------------------------------+
```

## Component Breakdown
| Component | Type | Description |
|-----------|------|-------------|
| Scaffold | Structural | Root widget with AppBar (title: "Create Account") |
| BlocConsumer<AuthBloc, AuthState> | State Management | Handles error snackbars and loading state |
| SingleChildScrollView | Layout | Scrollable form body |
| Form (with GlobalKey) | Form | Wraps fields for validation |
| TextFormField (first name) | Input | First name; validated as non-empty, "Required" message |
| TextFormField (last name) | Input | Last name; validated as non-empty |
| TextFormField (email) | Input | Email with regex validation |
| TextFormField (password) | Input | Password with visibility toggle; min 6 characters |
| TextFormField (confirm password) | Input | Confirm password; validates match against password field |
| Checkbox (acceptTerms) | Input | Terms acceptance toggle; must be true to submit |
| ElevatedButton | Action | Submit button with loading spinner |
| SnackBar | Feedback | Error messages and terms-warning |

## States - Loading, Empty, Error, Data Populated
| State | Description |
|-------|-------------|
| Loading | Button shows spinner; fields remain editable |
| Empty | All fields empty on initial load |
| Error | Red snackbar with `state.message`; terms warning snackbar if checkbox unchecked |
| Data Populated | Form state after user input |

## Navigation Connections
- **Entry**: `/register` (public route)
- On success: Router detects `AuthAuthenticated`, redirects to `/home`
- AuthBloc event dispatched: `AuthRegisterRequested(firstName, lastName, email, password)`
