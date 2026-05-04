# Admin Role Management Page
**Status**: Pending
**Route**: `/admin/roles`
**Priority**: Admin
**Use Cases Covered**: A03
## Purpose
Allow super administrators to manage admin roles and permissions. Displays a list of existing roles (super admin, moderator, support) with their associated permissions shown as checkboxes. Enables creating new roles and editing existing ones.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [<] Role Management          [+ Add Role]|
+------------------------------------------+
|                                           |
|  Roles Overview                           |
|  +--------------------------------------+ |
|  | 🛡️ Super Admin                     | |
|  |  2 members                          | |
|  |  Permissions: All (47/47)          | |
|  |  [Edit] [Clone] [Delete]            | |
|  +--------------------------------------+ |
|  | 👮 Moderator                         | |
|  |  5 members                          | |
|  |  Permissions: 32/47                 | |
|  |  [Edit] [Clone] [Delete]            | |
|  +--------------------------------------+ |
|  | 🎧 Support                           | |
|  |  3 members                          | |
|  |  Permissions: 18/47                 | |
|  |  [Edit] [Clone] [Delete]            | |
|  +--------------------------------------+ |
|                                           |
|  (Edit Mode - Moderator selected)         |
|  +--------------------------------------+ |
|  | Editing: Moderator                   | |
|  |                                      | |
|  | Users Management                     | |
|  | [✓] View users                      | |
|  | [✓] Edit users                      | |
|  | [✓] Suspend users                   | |
|  | [ ] Delete users                     | |
|  |                                      | |
|  | Content Moderation                   | |
|  | [✓] View flagged content            | |
|  | [✓] Dismiss flags                   | |
|  | [✓] Remove content                  | |
|  | [ ] Bulk moderation actions          | |
|  |                                      | |
|  | Dispute Management                   | |
|  | [✓] View disputes                   | |
|  | [✓] Assign disputes                  | |
|  | [ ] Resolve disputes                 | |
|  |                                      | |
|  | System Configuration                 | |
|  | [ ] View config                     | |  | [ ] Edit config                     | |
|  |                                      | |
|  | [Save Changes] [Cancel]             | |
|  +--------------------------------------+ |
+------------------------------------------+
```

## Component Breakdown
1. **Role List Cards**: Each card shows role name with icon, member count, permission count, and action buttons [Edit], [Clone], [Delete] (disabled if role is in use or protected).
2. **Add Role Button**: Creates a new role with default permissions.
3. **Edit Panel** (side panel or inline): When editing a role, shows:
   - Role name field (editable)
   - Permission checklist grouped by category:
     - User Management (view, edit, suspend, delete)
     - Content Moderation (view, dismiss, remove, bulk actions)
     - Dispute Management (view, assign, resolve, close)
     - System Configuration (view, edit, feature flags)
     - Broadcast (compose, send, schedule, view history)
     - Analytics (view, export)
     - Audit Log (view, export)
   - Each permission is a toggle checkbox with description
   - "Select All" / "Deselect All" per category
   - Save/Cancel buttons
4. **Member List**: Clicking member count shows a list of users with that role (inline or popup).

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton role cards and edit panel with shimmer.
- **Empty (No Roles Configured)**: Should not happen as at least Super Admin must exist. If it does, show "No roles configured. The system requires at least one role." with [Create Default Roles] button.
- **Error**: "Could not load roles." with [Retry] button. Save error: "Failed to save role. [Retry]".
- **Data**: Full role list with interactive edit panel. Changes are staged until save. Confirmation on deleting roles that are assigned to users.

## Navigation Connections
- **Incoming**: From Admin Dashboard "Roles" link, from admin settings sidebar.
- **Outgoing**: Edit -> inline panel opens. Save -> confirmation -> refresh. Clone -> duplicates role for editing. Delete -> confirmation dialog (cannot delete Super Admin). Member count -> shows member list popup -> tappable to view user management.

## Future Considerations
- Role inheritance (Moderator inherits from Support + extra)
- Granular resource-level permissions (per-agency, per-region)
- Permission audit trail (who changed what and when)
- Role templates for common configurations
- Temporary role elevation (time-bound)
- Two-factor requirement per role enforcement
- IP allowlist per role
- Role-based dashboard customization
- Permission matrix export
- Role versioning and rollback
