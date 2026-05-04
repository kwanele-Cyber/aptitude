# Matchmaking Page
**Status**: Existing
**Route**: `/matches`
**Priority**: P2
**Use Cases Covered**: M01, M02, M03, M04, M05, M06, M07, M08, M09, M10, M11, M13, M14

## Purpose
Provide the core matchmaking experience where users swipe or browse through skill match suggestions. Each card represents a potential match between the current user and another user's skill offer/request. The system calculates a match score based on skill compatibility, location, level, and trust factors. Users can accept, ignore, or reject matches, and provide feedback after each action.

## Layout Description
Full-screen card stack interface inspired by dating app mechanics. A card deck sits in the center of the screen with the top card fully visible and subsequent cards slightly offset below. Below the card stack, three large action buttons let the user accept (green), ignore (orange), or reject (red) the current match. A header shows the page title and a filter icon. Action buttons animate on press, and the card flies off-screen in the corresponding direction before the next card animates in.

## Component Breakdown

### AppBar
- **Title**: "Discover Matches"
- **FilterIconButton**: Icon button (`Icons.tune`) that opens the match filter dialog. Shows a badge dot when filters are active.
- **HistoryIconButton**: Icon button (`Icons.history`) that navigates to `/matches/history/:uid`

### Match Card Stack
The card deck renders up to 3 cards at a time with a stack effect (z-index layering and slight y-offset + scale).

#### Match Card (single card content)
- **UserAvatar**: Large circular avatar at the top of the card, with online status indicator
- **UserName**: Bold name text below avatar
- **SkillTitle**: The matched skill title, prominently displayed
- **MatchScoreIndicator**: A circular or pill-shaped score indicator with percentage text. Color-coded:
  - Green: 80% and above (Excellent match)
  - Orange: 50-79% (Good match)
  - Red: Below 50% (Low match)
  - The indicator may pulse or shimmer for high scores to draw attention
- **CategoryChip**: Category chip with color coding
- **LevelBadge**: Beginner/Intermediate/Advanced with icon
- **FormatBadge**: Online/In-Person with icon
- **DistanceBadge**: Distance from the user (e.g., "2.3 km away"), shown for in-person matches
- **VerifiedBadge**: Blue checkmark badge if the user or skill is verified
- **BioPreview**: A 2-line truncated preview of the skill description
- **ExpandedInfoButton**: A "Show More" text button that expands the card to full screen or shows additional details in a modal

### Action Buttons
Three large circular action buttons in a row at the bottom of the screen:

- **RejectButton**: Red circular button with `Icons.close` (X) icon. On tap, card animates left and off-screen.
- **IgnoreButton**: Orange circular button with `Icons.do_not_disturb_alt` (pause/minus) icon. On tap, card animates downward and off-screen.
- **AcceptButton**: Green circular button with `Icons.check` or `Icons.favorite` (heart) icon. On tap, card animates right and off-screen.
- **Swipe Gestures**: Users can also swipe left (reject), right (accept), or down (ignore) on the card directly. Swipe distance threshold triggers the action with haptic feedback.

### Feedback Dialog
After each accept/reject/ignore action, a feedback dialog slides up:

- **RatingBar**: 5-star rating widget with tappable stars. The star rating sets the feedback intensity.
- **FeedbackReasonChips**: Optional multi-select reason chips:
  - For Accept: "Great fit", "Close location", "Similar interests", "Recommended by friend"
  - For Reject: "Wrong level", "Too far", "Not interested", "Incompatible schedule"
  - For Ignore: "Not now", "Maybe later", "Need more info"
- **SubmitButton**: "Submit Feedback" elevated button. Can be skipped with "Skip" text button.
- **CloseAnimation**: After submission, the dialog closes and the next card appears.

### Filter Dialog (Bottom Sheet)
A modal bottom sheet with filter controls:

- **MinScoreSlider**: Slider from 0-100% for minimum match score (default: 0)
- **TrustScoreFilter**: Slider from 0-100% for minimum trust score
- **MaxDistanceSlider**: Slider from 1-100 km for maximum distance (only relevant for in-person matches)
- **VerifiedOnlyToggle**: Switch toggle "Show verified only" -- when on, only shows verified users/skills
- **CategoryFilter**: Multi-select category chips (optional filter)
- **LevelFilter**: Multi-select level chips (optional filter)
- **FormatFilter**: Toggle between Online, In-Person, or Both
- **ResetButton**: "Reset to Defaults"
- **ApplyButton**: "Apply Filters" -- re-fetches matches with new criteria

### Card Counter
- **RemainingCount**: A small text at the bottom: "X matches remaining" or "Showing match X of Y"

### Empty State (No More Cards)
- **CheckAgainLater**: Centered column with a refresh icon, bold text "No more matches right now", subtitle "New matches may appear as more users join or update their skills. Check back later!", and a "Refresh" elevated button. Triggered when all available matches have been shown.

## States

### Loading State
- **Spinner**: Full-page centered `CircularProgressIndicator` while match suggestions are being loaded
- **Card Shimmer**: The card stack area shows a shimmer placeholder in the shape of a match card

### Empty State
- **No Matches Found**: Centered column with a compass/search icon, bold text "No matches found", a contextual subtitle: "Try adjusting your filters or updating your skill profile to get better matches.", and a "Refresh" elevated button. Also an "Update Profile" text button.
- **All Cards Seen**: Same as "No more matches right now" as described above. Distinguish from the initial empty state by showing "You've seen all available matches" instead.

### Error State
- **Load Error**: Centered error view with `Icons.error_outline`, "Could not load matches", error message, and "Retry" elevated button.
- **Action Error**: Snackbar: "Failed to record your response. Please try again." The card returns to the stack if the action failed.
- **Filter Error**: Snackbar: "Failed to apply filters. Try again."

### Data State
- **Card Stack**: Full card deck with active animations. Cards are swipeable and action buttons are fully interactive. Feedback dialog appears after each action.
- **Post-Action**: After accepting/rejecting/ignoring, the card animates away and the next card slides in. A brief snackbar may show "Match accepted!" or similar.

## Navigation Connections
- **Filter icon**: Opens filter bottom sheet (stays on page)
- **History icon**: Navigate to `/matches/history/:uid`
- **User avatar / card tap**: Optionally navigate to user profile (commented out or TBD)
- **Card "Show More"**: Opens expanded details modal or navigates to `/skills/details/:id`
- **Feedback submit**: Closes dialog, loads next card
- **Refresh on empty**: Re-dispatches match loading event
- **Filter apply**: Re-fetches matches with new criteria
