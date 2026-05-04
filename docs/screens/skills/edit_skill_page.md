# Edit Skill Page
**Status**: Existing
**Route**: `/skills/edit`
**Priority**: P1
**Use Cases Covered**: S03

## Purpose
Allow users to edit an existing skill offer or request that they own. The form is identical to the create form but is pre-populated with data from the existing `SkillEntity` passed via `state.extra`. Includes a delete option to permanently remove the skill listing. Ownership verification is enforced before the page loads.

## Layout Description
Single scrollable form layout with an edit-specific header. Same structure as the create form but with the Submit button labeled "Update" instead of "Post." A subtle banner at the top indicates the skill was created on a specific date. A delete button is placed in the AppBar as a danger action.

## Component Breakdown

### AppBar
- **BackButton**: Standard back navigation arrow
- **DeleteIconButton**: Red/grey delete icon in the AppBar actions. Triggers a confirmation dialog before deletion.
- **Title**: "Edit Skill"

### Header Section
- **CreatedDateBanner**: Subtle info banner reading "Created on [date]" to distinguish from the create flow
- **PageSubtitle**: Shows the Skill ID in faint text for debugging/support

### Form Fields (Reused from Create)
- **TitleField**: Pre-populated with the existing skill title
- **DescriptionField**: Pre-populated with the existing skill description
- **CategoryChipSelector**: Pre-populated with the existing category. AI suggestion still available.
- **AICategorySuggestion**: Same as create. Can suggest a new category for the edited skill.
- **LevelSelector**: Pre-populated with the existing level
- **FormatSelector**: Pre-populated with the existing format
- **LocationField**: Pre-populated if format is "In-Person" and location exists
- **AvailabilityPicker**: Pre-populated with existing availability slots
- **TagsInput**: Pre-populated with existing tags

### Bottom Bar
- **CancelButton**: Text button to discard changes and navigate back
- **UpdateButton**: Elevated primary button labeled "Update". Disabled until changes are detected or required fields become invalid.

### Delete Confirmation Dialog
- **DialogTitle**: "Delete Skill?"
- **DialogBody**: Warning message: "This action cannot be undone. All associated data including matches and reviews will be permanently removed."
- **CancelButton**: Text button "Keep Skill"
- **ConfirmDeleteButton**: Red elevated button "Delete Permanently"

## States

### Loading State
- **Page Loading**: Full-page centered `CircularProgressIndicator` while the skill entity is being loaded from `state.extra`
- **AI Suggestion Loading**: Same as create -- spinner on the suggest button
- **Update Loading**: Submit button shows spinner, form fields disabled

### Error State
- **Validation Errors**: Same inline field-level errors as create form
- **Update Error**: Snackbar: "Failed to update skill. Please try again."
- **Delete Error**: Snackbar: "Failed to delete skill. Please try again."
- **Ownership Error**: If the user does not own the skill, a full-screen error page with "You do not have permission to edit this skill" and a "Go Back" button

### Data State
- **Form Populated**: All fields are pre-filled with the existing `SkillEntity` data. The Update button is enabled only when at least one field has been modified from its original value.
- **No Changes**: Update button disabled with a subtle message: "No changes to save"

### Empty State
- Not applicable -- the page always receives a SkillEntity. If no entity is provided, show an error state instead.

## Navigation Connections
- **Update success**: Navigate to `/skills/details/:id` with a success snackbar "Skill updated successfully"
- **Delete success**: Navigate to `/skills/feed` with a snackbar "Skill deleted"
- **Cancel**: Navigate back to `/skills/details/:id`
- **Permission denied**: Navigate back to previous page automatically
