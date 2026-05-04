# Filter Skills Page
**Status**: Existing
**Route**: `/skills/filter`
**Priority**: P1
**Use Cases Covered**: S09

## Purpose
Provide a dedicated filtering interface for skill listings. Users can refine the skill feed by selecting multiple criteria using chips and segmented controls. Supports filtering by category, proficiency level, format (online/in-person), and type (offer/request). Active filters are passed back to the feed page via query parameters or bloc state.

## Layout Description
Full-screen modal or pushed page with a scrollable list of filter sections. Each section has a clear header and a row/collection of selectable chips. A sticky bottom bar contains Reset and Apply buttons. A live preview or count of matching results is displayed at the top.

## Component Breakdown

### AppBar
- **Title**: "Filter Skills"
- **BackButton**: Standard back navigation (discards changes without applying, with a confirmation dialog if filters are dirty)
- **ClearAllButton**: Text button "Clear All" in the AppBar actions, resets all filters to defaults

### Active Filter Summary
- **ActiveFilterCount**: A small banner or chip row showing the count of active filters, e.g., "3 filters active"
- **ResultPreviewCount**: Text showing approximately how many skills match the current filter combination: "~X skills match"

### Filter Sections

#### Category Section
- **SectionHeader**: "Category" with a divider below
- **CategoryChipGrid**: A `Wrap` layout of multi-select chips for all available categories:
  - Technology, Arts, Languages, Sports, Music, Business, Cooking, Academic, Other
  - Selected chips are filled/accent-colored. Unselected chips are outlined/grey.
  - Multiple categories can be selected simultaneously (OR logic).

#### Level Section
- **SectionHeader**: "Proficiency Level" with a divider below
- **LevelChipRow**: Multi-select chips for Beginner, Intermediate, Advanced
  - Multiple levels can be selected (OR logic).

#### Format Section
- **SectionHeader**: "Format" with a divider below
- **FormatChipRow**: Multi-select chips for Online, In-Person
  - Both can be selected (OR logic). If none selected, both formats are included.

#### Type Section
- **SectionHeader**: "Type" with a divider below
- **TypeChipRow**: Multi-select chips for Offer, Request
  - Both can be selected. If none selected, both types are included.

### Bottom Bar
- **ResetButton**: Outlined button "Reset to Defaults". Clears all selections. Shows a confirmation dialog if filters are dirty: "Reset all filters?"
- **ApplyButton**: Elevated primary button "Apply Filters" (or "Show X Results"). Applies the filters and navigates back. Disabled if no filters have changed from the incoming active filter state.

## States

### Initial State
- **Data / Active Filters Loaded**: All filter chips are displayed. If the page was opened with existing active filters (passed via state or query params), those chips are pre-selected. Reset button is enabled only if filters are active.

### Empty State
- Not applicable -- the filter options are static and always present.

### Loading State
- **Result Preview Loading**: While the result preview count is being calculated, show a small shimmer or "..." placeholder next to "~" symbol. The filter UI itself remains fully interactive.

### Error State
- **Filter Application Error**: If filters fail to apply when the user taps Apply, a Snackbar error appears: "Failed to apply filters." The user can retry.

### Data State
- All sections are rendered with chips. Selections are visually distinct (filled vs outlined). The Apply button is enabled when at least one filter differs from the incoming defaults.

## Navigation Connections
- **Apply**: Navigate back to `/skills/feed` with the selected filters applied (via bloc event or query params)
- **Reset**: Clears all chips. If in dirty state, shows confirmation dialog. On confirm, all chips reset to unselected.
- **Back (with dirty filters)**: Shows confirmation dialog "Discard filter changes?" with "Discard" and "Keep Editing" buttons
- **Back (no changes)**: Navigates back silently
- **Clear All**: Resets all filters without confirmation (instant)
