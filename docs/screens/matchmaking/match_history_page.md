# Match History Page
**Status**: Existing
**Route**: `/matches/history/:uid`
**Priority**: P2
**Use Cases Covered**: M12

## Purpose
Display the current user's complete match history, including all past accept, reject, ignore, and pending match responses. Users can review their past decisions, see the current status of each match, and filter by status. Pull-to-refresh is supported for reloading the list. Each entry links back to the original skill details.

## Layout Description
A standard list page with a filter bar at the top containing status chips. Below the filter bar is a scrollable list of match history items. Each item shows the matched skill, match score, status badge, and date. A `RefreshIndicator` wraps the list for pull-to-refresh. The page title includes the total match count.

## Component Breakdown

### AppBar
- **Title**: "Match History"
- **Subtitle**: "X total matches" displayed in smaller text below the title
- **BackButton**: Standard back navigation
- **ClearFilterButton**: Appears in the AppBar when a status filter is active; resets to "All"

### Status Filter Chips
A horizontal, scrollable row of `FilterChip` widgets:

- **AllChip**: Default active. Shows all matches regardless of status.
- **AcceptedChip**: Green-tinted chip. Filters to accepted matches.
- **RejectedChip**: Red-tinted chip. Filters to rejected matches.
- **IgnoredChip**: Orange-tinted chip. Filters to ignored matches.
- **PendingChip**: Grey/blue-tinted chip. Filters to matches still pending response.

The active chip is filled/highlighted. Inactive chips are outlined. Tapping a chip replaces the active filter (single-select, not multi-select).

### Match History Item
Each item is a card or list tile containing:

- **UserAvatar**: Small circular avatar of the matched user, with online status dot
- **UserName**: The matched user's name
- **SkillTitle**: The matched skill title, bold
- **CategoryChip**: Small category chip
- **MatchScore**: Percentage score displayed as a colored pill or small circular indicator (green/orange/red)
- **StatusBadge**: A colored badge displaying the match status:
  - "Accepted" -- green filled badge
  - "Rejected" -- red filled badge
  - "Ignored" -- orange filled badge
  - "Pending" -- grey outlined badge with clock icon
- **ActionDate**: Formatted date/time of when the action was taken (e.g., "Mar 15, 2026" or "2 weeks ago"). For pending matches, shows the date the match was created.
- **Divider**: Subtle divider between items

### Pull-to-Refresh
- **RefreshIndicator**: Wraps the entire list. On pull-down, triggers a refresh event to reload match history from the API. Shows the standard platform refresh animation (spinner with pull-down indicator).

### Empty State Illustration
- **Icon**: `Icons.history_toggle_off` or a history/timeline illustration
- **Title**: "No match history"
- **Subtitle**: "Your match history will appear here once you start interacting with matches on the Discover page."
- **ActionButton**: "Discover Matches" elevated button navigating to `/matches`

## States

### Loading State
- **Initial Load**: Centered `CircularProgressIndicator` on first page load. No list visible.
- **Pull-to-Refresh**: The `RefreshIndicator` animation plays. Existing list items remain visible and are not dimmed.
- **Filter Change Loading**: A small `LinearProgressIndicator` at the top of the list while filter results load. Existing items remain visible.

### Empty State
- **No History**: The empty state illustration as described above when the user has no match history at all.
- **No Results for Filter**: When a filter chip is active but no matches match the filter criteria:
  - Centered column with `Icons.filter_list_off` icon
  - Title: "No [status] matches"
  - Subtitle: "You don't have any [status] matches yet. Try selecting a different filter."
  - ActionButton: "Show All" text button that resets the filter to "All"

### Error State
- **Load Error**: Centered error view with `Icons.error_outline`, "Could not load match history", and "Retry" elevated button. The pull-to-refresh also works as a retry mechanism.
- **Refresh Error**: Snackbar: "Failed to refresh. Pull down to try again." The existing list remains visible.

### Data State
- **Full History List**: A scrollable list of match history items. The list is sorted by date (most recent first). Each item is tappable. Active filter chip determines which subset is shown. The total count updates to reflect the filtered count (e.g., "12 matches" filtered from "45 total").
- **Mixed Statuses**: Items with different statuses are visually distinguishable by their colored status badges.

## Navigation Connections
- **Match item tap**: Navigate to `/skills/details/:id` for the skill associated with the match
- **User avatar tap**: Navigate to user profile page (route TBD)
- **Discover Matches button**: Navigate to `/matches`
- **Filter chip tap**: Filters the current list locally or re-fetches from the API with the status parameter
- **Back button**: Navigate to previous page (usually `/matches`)
- **RefreshIndicator pull-down**: Dispatches refresh event to the match history bloc
