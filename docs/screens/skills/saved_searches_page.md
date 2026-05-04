# Saved Searches Page
**Status**: Existing
**Route**: `/skills/saved-searches/:uid`
**Priority**: P1
**Use Cases Covered**: S12

## Purpose
Display a list of saved search queries for the authenticated user. Saved searches allow users to quickly re-run complex or important searches without re-entering all filter criteria. Each saved search entry shows its parameters and can be tapped to trigger the search or swiped to delete. The page is scoped to the user ID from the route parameter.

## Layout Description
Simple list page with a header showing the page title and a count of saved searches. Each list item is a card or tile representing one saved search query. The list supports swipe-to-delete with a confirmation. A floating action button allows saving the current search (from the search page).

## Component Breakdown

### AppBar
- **Title**: "Saved Searches"
- **Subtitle**: "X searches saved" displayed below the title in smaller text
- **BackButton**: Standard back navigation

### Saved Search Card
Each saved search is displayed as a card containing:

- **SearchQueryText**: The original search query text (bold, prominent). Shown as a label if text search was used.
- **FilterChipsRow**: A horizontal row of compact chips representing active filters:
  - Category chip (e.g., "Technology")
  - Level chip (e.g., "Advanced")
  - Format chip (e.g., "Online")
  - Type chip (e.g., "Offer")
  - If many filters exist, shows "+X more" overflow chip
- **SavedDate**: Relative timestamp of when the search was saved (e.g., "Saved 2 weeks ago")
- **ResultCount**: The number of results the last time this search was run (e.g., "12 results")
- **TapTarget**: Entire card is tappable to re-run the search

### Swipe-to-Delete Action
- **SwipeBackground**: Red background with a white delete icon (`Icons.delete`) revealed when the user swipes left
- **UndoSnackbar**: After swiping, a Snackbar appears: "Search deleted" with an "Undo" action button for 5 seconds

### Delete Confirmation (Alternative)
- **LongPressDialog**: Long-pressing a card shows a confirmation dialog: "Delete saved search?" with "Cancel" and "Delete" buttons

### Empty State Illustration
- **Icon**: `Icons.bookmark_border` or a bookmark illustration
- **Title**: "No saved searches"
- **Subtitle**: "Save searches to quickly find skills you care about. From the search page, tap the bookmark icon to save your current search."
- **ActionButton**: "Browse Skills" outlined button navigating to `/skills/feed`

## States

### Loading State
- **Centered Spinner**: Full-page `CircularProgressIndicator` while saved searches are being loaded from the datasource
- **ShimmerList**: Optionally, a list of shimmer placeholder cards matching the saved search card layout

### Empty State
- **No Saved Searches**: Full empty state illustration as described above with the bookmark icon and encouragement text
- **No Results for User**: If the UID exists but has no saved searches, show the standard empty state

### Error State
- **Load Error**: Centered error view with `Icons.error_outline`, "Could not load saved searches", and a "Retry" button
- **Delete Error**: Snackbar: "Failed to delete search. Please try again."

### Data State
- **Saved Searches List**: A scrollable `ListView` of saved search cards. Each card shows the query, filter chips, save date, and result count. Pull-to-refresh is supported.
- **Empty filters**: If a saved search has no text query and no filters, show "All skills" as the query text.

## Navigation Connections
- **Card tap**: Navigate to `/skills/search` with the saved search query and filters pre-populated. The search automatically runs with the saved parameters.
- **Swipe delete**: Removes the saved search locally with undo option. On undo timeout, dispatches delete event to the bloc.
- **Undo tap**: Restores the deleted item in the list and cancels the deletion.
- **Browse Skills button**: Navigate to `/skills/feed`
- **Back button**: Navigate to previous page
