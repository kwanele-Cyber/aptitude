# Search Skills Page
**Status**: Existing
**Route**: `/skills/search`
**Priority**: P1
**Use Cases Covered**: S08

## Purpose
Provide a real-time search interface for skills. Users type queries into a search field, and results update dynamically using a debounced search mechanism that prevents excessive API calls. The search covers skill titles, descriptions, and tags. Results are displayed in a scrollable list with tap-to-detail navigation.

## Layout Description
Full-screen page with a prominent search field in the AppBar. Below the AppBar, the body shows either the initial hint state, a loading indicator, an empty results state, or the search results list. The search field auto-focuses on page load for immediate input.

## Component Breakdown

### AppBar
- **SearchTextField**: Auto-focused `TextField` with:
  - Search icon prefix (`Icons.search`)
  - Hint text: "Search skills by title, description, or tags..."
  - Clear button (`Icons.clear`) suffix when text is present
  - Debounce timer: 400ms delay before dispatching search query
- **BackButton**: Standard back navigation
- **Title**: Hidden (replaced by the search field)

### Search Results
- **ResultsListView**: A `ListView.builder` that renders search result items. Each item is a compact skill card similar to the feed card but with:
  - **HighlightedText**: The matching query terms are highlighted in bold within the title and description
  - **CategoryChip**: Small category chip
  - **LevelBadge**: Level indicator
  - **FormatBadge**: Online/In-Person indicator
  - **MatchRelevance**: Optional relevance percentage indicator
- **ResultsCount**: A small text header above the list: "X results found"

### Recent Searches (Initial State)
- **RecentSearchSection**: When the search field is empty and the user has previous searches, show a "Recent Searches" section with:
  - **RecentSearchChips**: A horizontal row of tappable chips with recent query text
  - **ClearRecentButton**: A "Clear All" text button to remove recent search history

## States

### Initial State (No Query)
- **Hint Text Display**: The search field is focused with a blinking cursor. Below it, either:
  - **With recent searches**: Recent search chips are shown with a "Recent Searches" header
  - **Without recent searches**: A centered icon (`Icons.search`) with text "Search for skills to learn or teach" as a prompt

### Loading State
- **Debounce Waiting**: No visible indicator during the 400ms debounce window (to avoid flickering)
- **Search In Progress**: Once the debounce timer fires and the API call begins, a small `LinearProgressIndicator` appears at the top of the results area (below the AppBar). If previous results exist, they remain visible but slightly dimmed.

### Empty State (Results)
- **No Results**: Centered column with a `Icons.search_off` icon, bold text "No results found", a subtitle with the search term: "No skills match '[query]'. Try different keywords or browse all skills.", and a "Browse All Skills" text button that navigates to `/skills/feed`

### Error State
- **Search Error**: A `SnackBar` appears with "Search failed. Please try again." The previous results (if any) remain visible. A retry button appears next to the error message.

### Data State
- **Results List**: A list of matching skill cards with highlighted query terms. Each card is tappable. Shows result count above the list. Results update in real-time as the user types (after debounce).

## Navigation Connections
- **Result item tap (commented out)**: Intended to navigate to `/skills/details/:id`. Navigation logic is present but commented out with a TODO note: `// TODO: Navigate to skill details page`
- **Back button**: Navigate to previous page (usually `/skills/feed`)
- **Recent search chip tap**: Populates the search field with the selected query and triggers search
- **Browse All Skills text button**: Navigate to `/skills/feed`
