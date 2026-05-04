# Splash Page

**Status**: Existing
**Route**: `/splash`
**Priority**: P0
**Use Cases Covered**: F01

## Purpose
Entry point for the auth flow. Displays a centered loading indicator while the app checks whether the user is already authenticated (via `AuthCheckRequested` event). Based on the result, the router redirects to `/login` (unauthenticated) or `/home` (authenticated).

## Layout Description
```
+------------------------------------------+
|                                          |
|                                          |
|              [App Icon / Logo]           |
|                                          |
|          [CircularProgressIndicator]     |
|                                          |
|         "Checking authentication..."     |
|                                          |
+------------------------------------------+
```

## Component Breakdown
| Component | Type | Description |
|-----------|------|-------------|
| Scaffold | Structural | Root widget with no AppBar |
| Center | Layout | Centers the loading indicator |
| CircularProgressIndicator | Widget | Indeterminate spinner while auth state is resolved |

## States - Loading, Empty, Error, Data Populated
| State | Description |
|-------|-------------|
| Loading (default) | `CircularProgressIndicator` shown centered on screen; `AuthCheckRequested` is dispatched in `initState` |
| Empty | Not applicable -- the page always shows the loader |
| Error | Not applicable -- errors bubble through the router redirect |
| Data Populated | Not applicable -- page transitions away once auth state is known |

## Navigation Connections
- **Entry point**: App launches at `/splash` (via router's initial redirect logic)
- On `AuthAuthenticated`: Router redirects to `/home`
- On `AuthUnauthenticated`: Router redirects to `/login`
- AuthBloc event dispatched: `AuthCheckRequested`
