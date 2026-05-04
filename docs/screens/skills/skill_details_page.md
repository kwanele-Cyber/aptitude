# Skill Details Page
**Status**: Existing
**Route**: `/skills/details/:id`
**Priority**: P1
**Use Cases Covered**: S11

## Purpose
Display the full details of a single skill offer or request. This is the primary read view for a skill listing, showing all metadata and enabling actions such as editing (for owners), cloning, archiving/deleting, and verification (for viewers/verifiers). The page resolves the skill ID from the route parameter and fetches the full `SkillEntity`.

## Layout Description
Scrollable detail page with a hero section at the top containing the title and primary metadata. Below is a structured breakdown of all skill information. Action buttons are context-sensitive based on whether the current user is the owner or a viewer. A sticky bottom bar contains the primary call-to-action.

## Component Breakdown

### AppBar
- **BackButton**: Standard back navigation
- **Title**: Skill title (truncated if long) or "Skill Details"
- **OverflowMenu**: Three-dot menu with contextual options:
  - **Owner Actions**: Edit, Clone, Archive, Delete
  - **Viewer Actions**: Report, Share
  - **Verifier Actions**: Verify Skill (if user has verification privileges)
- **EditButton** (owner only): Pencil icon for quick edit navigation

### Hero Section
- **SkillTypeBadge**: Large colored badge "Offer" (green) or "Request" (blue)
- **TitleText**: Large bold title, full width
- **UserInfoRow**: User avatar (circular, tappable), username, and a "View Profile" link
- **PostedTimestamp**: Relative time (e.g., "Posted 3 days ago")
- **LastUpdatedTimestamp**: Shown if edited (e.g., "Updated 1 day ago")

### Metadata Section
- **CategoryRow**: Category label with icon and colored chip
- **LevelRow**: Level label with icon (Beginner/Intermediate/Advanced)
- **FormatRow**: Format label with icon (Online/In-Person)
- **LocationRow**: Location text with map pin icon (shown only for In-Person)
- **AvailabilitySection**: List of day/time slots displayed as chips with a calendar icon

### Description Section
- **SectionHeader**: "Description" in bold with an underline accent
- **DescriptionBody**: Full description text, multi-line, with text wrapping. May contain formatted content.

### Tags Section
- **TagChips**: Horizontal scrollable row of tag chips. Each chip is non-interactive. Section is hidden if no tags exist.

### Match Score Section (if applicable)
- **MatchScoreCard**: A card showing the calculated match score between the current user and this skill. Displayed as a circular percentage with color: green (>80%), orange (>50%), red (<50%). Only shown when a match score has been calculated.

### Action Buttons (Owner)
- **EditButton**: Full-width outlined button "Edit Skill", navigates to `/skills/edit`
- **CloneButton**: Full-width outlined button "Clone Skill", navigates to `/skills/create` with pre-populated fields
- **ArchiveButton**: Full-width outlined button "Archive", with confirmation dialog. Only shown if skill is active.
- **DeleteButton**: Full-width red text button "Delete Skill", with confirmation dialog. Only shown if skill is active and user confirms twice.

### Action Buttons (Viewer)
- **ContactButton**: Full-width elevated button "Contact [Username]" or "Send Request"
- **ReportButton**: Text button "Report Skill", opens a report dialog

### Verification Section (Verifier only)
- **VerifyButton**: Elevated green button "Verify This Skill". Marks the skill as verified.
- **VerifiedBadge**: If already verified, a blue checkmark badge with "Verified" text is shown in the hero section.

## States

### Loading State
- **Full-Page Spinner**: Centered `CircularProgressIndicator` while fetching skill data from the repository
- **ShimmerPlaceholder**: Optional shimmer loading placeholders matching the hero and section layout

### Error State
- **Not Found**: Centered error view with `Icons.help_outline`, "Skill not found", subtitle "This skill may have been removed or the link is invalid", and a "Browse Skills" button navigating to `/skills/feed`
- **Network Error**: Centered error view with `Icons.wifi_off`, "Could not load skill details", subtitle "Check your internet connection and try again", and a "Retry" elevated button
- **Generic Error**: Centered error view with `Icons.error_outline`, "Something went wrong", error message from the bloc, and "Retry" button

### Data State
- **Full Skill Details**: All sections rendered with complete data from the `SkillEntity`. Actions are context-sensitive based on ownership and permissions.

## Navigation Connections
- **Edit button** (owner): Navigate to `/skills/edit` with the skill entity in state
- **Clone button** (owner): Navigate to `/skills/create` with pre-populated data
- **Archive/Delete success**: Navigate to `/skills/feed` with appropriate snackbar
- **User avatar / profile link**: Navigate to user profile page (route TBD)
- **Contact button** (viewer): Navigate to chat or messaging with the skill owner
- **Back button**: Navigate to previous page (usually `/skills/feed`)
- **Verify success**: Stays on page, VerifiedBadge appears, snackbar "Skill verified successfully"
- **Report**: Opens a modal/bottom sheet (stays on page)
