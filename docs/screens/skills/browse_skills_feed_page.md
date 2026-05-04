# Browse Skills Feed Page
**Status**: Existing
**Route**: `/skills/feed`
**Priority**: P1
**Use Cases Covered**: S10

## Purpose
Display a browsable grid or list of all available skill offers and requests in the system. This is the primary discovery surface where users can scroll through skill cards, get a quick overview of each listing, and tap to view details. The feed is paginated and uses the `SkillBloc` with the `BrowseSkillsFeedRequested` event to load data.

## Layout Description
Full-screen scrollable feed with a toggle between grid view and list view. Each item is rendered as a skill card showing key metadata. A floating action button (FAB) provides quick access to create a new skill. A filter bar at the top allows quick pre-filtering by category.

## Component Breakdown

### AppBar
- **Title**: "Skills Feed"
- **SearchIconButton**: Icon button that navigates to `/skills/search`
- **FilterIconButton**: Icon button that navigates to `/skills/filter`
- **ViewToggle**: Segmented button to switch between grid layout (2 columns) and list layout (single column, full-width cards)

### Filter Bar
- **QuickCategoryChips**: Horizontally scrollable row of category chips. Tapping a chip filters the feed to that category. An "All" chip resets the filter. Active chip is highlighted.
- **ActiveFilterIndicator**: If filters from the filter page are active, a small badge appears on the filter icon showing the count of active filters. A "Clear Filters" text button appears next to the chips.

### Skill Card (used in both grid and list modes)
- **UserAvatar**: Circular avatar of the skill owner, with online status dot
- **UserName**: Text label below or next to the avatar
- **TitleLabel**: Skill title, bold, max 2 lines with ellipsis
- **CategoryChip**: Small chip showing the skill category with category color coding
- **LevelBadge**: Icon + text indicating Beginner/Intermediate/Advanced
- **FormatBadge**: Icon indicating Online or In-Person
- **SkillTypeBadge**: "Offer" or "Request" badge with color coding (green/blue)
- **MatchScoreOverlay**: If the viewing user has a match score calculated, a small colored circle with the percentage is shown in the corner (green > 80%, orange > 50%, red < 50%)
- **Timestamp**: Relative time since posting (e.g., "2d ago")

### Floating Action Button
- **CreateFAB**: Circular FAB with "+" icon. Expands to two options: "Offer" and "Request" via speed dial, navigating to `/skills/create` or `/skills/create-request` respectively.

### Pagination
- **ScrollListener**: Infinite scroll listener at the bottom of the list. When the user scrolls near the bottom, a `BrowseSkillsFeedRequested` event is dispatched with the next page.
- **PageLoader**: At the bottom of the list during pagination, a small `CircularProgressIndicator` or loading shimmer.

## States

### Loading State
- **Initial Load**: Full-page centered `CircularProgressIndicator` with no content below
- **Pagination Loading**: Small spinner at the bottom of the existing list. Existing cards remain visible.

### Empty State
- **No Skills Available**: Centered column with a large icon (e.g., `Icons.explore_off` or custom illustration), bold text "No skills available", subtitle "Be the first to share your skills!", and a "Create a Skill Offer" elevated button that navigates to `/skills/create`

### Error State
- **Load Error**: Centered column with an error icon (`Icons.error_outline`), text "Something went wrong", error message subtitle, and a "Retry" elevated button
- **Network Error**: Similar to load error but with a "No internet connection" specific message and a "Try Again" button

### Data State
- **Grid of Cards**: Two-column grid or single-column list of `SkillCard` widgets rendered from the `SkillEntity` list in the bloc state
- **Infinite Scroll**: As the user scrolls, more items load seamlessly. A "Showing X of Y skills" label appears at the bottom when all pages are loaded.

## Navigation Connections
- **Card tap**: Navigate to `/skills/details/:id` with the selected skill's ID
- **Search icon**: Navigate to `/skills/search`
- **Filter icon**: Navigate to `/skills/filter`
- **Quick category chip**: Filters feed locally (re-dispatches `BrowseSkillsFeedRequested` with category param)
- **Create FAB**: Navigate to `/skills/create` or `/skills/create-request` based on selection
- **User avatar tap**: Navigate to user profile page (route TBD)
