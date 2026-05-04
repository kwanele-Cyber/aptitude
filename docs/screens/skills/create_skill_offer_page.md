# Create Skill Offer Page
**Status**: Existing
**Route**: `/skills/create` and `/skills/create-request`
**Priority**: P1
**Use Cases Covered**: S01, S02

## Purpose
Allow users to create a new skill offer or skill request. The page operates in two modes controlled by a `SkillType` parameter: "offer" mode lets users list a skill they can teach/provide, and "request" mode lets users request a skill they want to learn. The form includes AI-assisted category suggestions to improve discoverability.

## Layout Description
Single scrollable form layout with a hero header indicating the mode ("Create Offer" vs "Create Request"). The form is organized into clear sections with labels, input fields, and helper text. A sticky bottom bar contains the primary action button. The header displays an icon and title that change based on the mode.

## Component Breakdown

### Header Section
- **ModeIndicator**: Displays the current mode (Offer/Request) with a color-coded icon (green for offer, blue for request)
- **PageTitle**: "Create a Skill Offer" or "Create a Skill Request" depending on `SkillType` parameter

### Form Fields
- **TitleField**: Text input for skill name (required, max 100 characters). Shows character count.
- **DescriptionField**: Multi-line text input for detailed description (required, max 500 characters). Shows character count.
- **CategoryChipSelector**: Multi-select chips for skill category (e.g., Technology, Arts, Languages, Sports, Music, Business, Cooking, Academic). Includes AI suggestion button.
- **AICategorySuggestion**: Button labeled "Suggest Category" that triggers AI-based category analysis from the title/description. Shows loading spinner while processing. Displays suggested category as a highlighted chip.
- **LevelSelector**: Segmented button or dropdown for proficiency level: Beginner, Intermediate, Advanced.
- **FormatSelector**: Toggle between "Online" and "In-Person" with an icon for each option.
- **LocationField**: Text input for location (shown only when Format is "In-Person"). Optional, with geolocation suggest.
- **AvailabilityPicker**: Day/time picker component for selecting available slots. Shows selected slots as chips.
- **TagsInput**: Optional text input for adding tags/keywords, displayed as removable chips below the input.

### Bottom Bar
- **CancelButton**: Text button to discard and navigate back
- **SubmitButton**: Elevated primary button labeled "Post Offer" or "Post Request" based on mode. Disabled until required fields are valid.

## States

### Loading State
- **Form validation**: Inline validation errors appear as the user types (red helper text below fields)
- **AI Category Suggestion**: A spinner replaces the "Suggest Category" button text while the AI processes the title/description. The button is disabled during loading.
- **Submission Loading**: The SubmitButton shows a `CircularProgressIndicator` replacing the button text. All form fields become disabled. A semi-transparent overlay covers the form to prevent interaction.

### Error State
- **Validation Errors**: Inline field-level error messages for required fields, max length exceeded, invalid format selection
- **Submission Error**: A `SnackBar` or dismissible error banner at the top of the form with the error message (e.g., "Failed to create skill offer. Please try again.")
- **AI Suggestion Error**: The button re-enables with text "Suggest Category" and a brief toast message: "Could not generate suggestion. Try again."

### Success State
- **Data / Form Populated**: All fields display the user's input. After successful submission, the user is navigated away. If editing (reusing this form via `edit_skill_page`), fields are pre-populated with existing skill data.
- **Empty / Initial**: Fresh form with all fields empty. Default mode indicator visible. Submit button disabled.

## Navigation Connections
- **Submit success**: Navigate to `/skills/feed` (browse skills feed) with a success snackbar message
- **Cancel**: Navigate back to previous page
- **AI category tap**: Triggers AI suggestion flow; no navigation
- **Category chip tap**: Filters locally; no navigation
- **Format toggle**: Conditionally shows/hides LocationField; no navigation
- **Location geolocation suggest**: Opens platform location picker if available
