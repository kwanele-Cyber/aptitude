# Admin Category Management Page
**Status**: Pending
**Route**: `/admin/categories`
**Priority**: Admin
**Use Cases Covered**: A19
## Purpose
Allow administrators to manage skill categories on the platform. Supports CRUD operations (create, read, update, delete) on categories, drag-to-reorder, and bulk management. Each category has a name, icon, description, and display order.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [<] Skill Categories       [+ Add Category]
+------------------------------------------+
|                                           |
|  All categories are displayed in order   |
|  shown below. Drag to reorder.           |
|                                           |
|  +--------------------------------------+ |
|  | ≡ 1  📘 Technology & Programming    | |
|  |     Subcategories: 6 | Skills: 124  | |
|  |     [Edit] [Add Sub] [Deactivate]   | |
|  |                                      | |
|  |     ≡ 1.1  Web Development          | |
|  |     ≡ 1.2  Mobile Development       | |
|  |     ≡ 1.3  Data Science             | |
|  |     ≡ 1.4  DevOps & Cloud           | |
|  +--------------------------------------+ |
|  | ≡ 2  🎨 Arts & Design               | |
|  |     Subcategories: 4 | Skills: 89   | |
|  |     [Edit] [Add Sub] [Deactivate]   | |
|  +--------------------------------------+ |
|  | ≡ 3  🎵 Music & Performance         | |
|  |     Subcategories: 5 | Skills: 67   | |
|  |     [Edit] [Add Sub] [Deactivate]   | |
|  +--------------------------------------+ |
|  | ≡ 4  📚 Academics & Languages       | |
|  |     Subcategories: 7 | Skills: 156  | |
|  |     [Edit] [Add Sub] [Deactivate]   | |
|  +--------------------------------------+ |
|                                           |
|  --- Add/Edit Category Dialog ---         |
|  +--------------------------------------+ |
|  | Add New Category                     | |
|  |                                      | |
|  | Name *                               | |
|  | [______________________________]    | |
|  |                                      | |
|  | Icon (emoji): [📘 ▼]                | |
|  |                                      | |
|  | Description                          | |
|  | [______________________________]    | |
|  |                                      | |
|  | Parent Category: [None (Top Level)] | |
|  |                                      | |
|  | Status: ● Active ○ Inactive          | |
|  |                                      | |
|  | [Save] [Cancel]                      | |
|  +--------------------------------------+ |
+------------------------------------------+
```

## Component Breakdown
1. **Category List**: Expandable tree structure with:
   - Drag handle (≡) for reordering
   - Order number
   - Category icon (emoji picker)
   - Category name
   - Metadata: subcategory count, skill count
   - Action buttons: [Edit], [Add Subcategory], [Deactivate/Activate], [Delete]
   - Expandable to show subcategories (indented)
2. **Drag-to-Reorder**: Long-press drag handle to reorder categories. Visual feedback on drop. Order auto-saves on change.
3. **Add/Edit Dialog**: Modal form for category CRUD with:
   - Name (required, unique validation)
   - Icon selector (emoji grid picker)
   - Description (optional, max 200 chars)
   - Parent category dropdown (for subcategories)
   - Status toggle (Active/Inactive)
   - Save/Cancel buttons
4. **Delete Confirmation**: Warning if category has associated skills (requires reassignment or archiving).

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton category tree with placeholders for 4-5 categories with shimmer.
- **Empty (No Categories)**: "No categories defined. Add your first skill category to organize the platform." with [Add First Category] button.
- **Error**: "Could not load categories." with [Retry] button. Save error: "Failed to save category. [Retry]". Delete error: "Cannot delete category with active skills."
- **Data**: Full interactive tree with drag-reorder. Expandable subcategories. CRUD actions via modals. Real-time order save feedback.

## Navigation Connections
- **Incoming**: From Admin Dashboard "Categories" link, from admin sidebar, from skill management flow.
- **Outgoing**: Edit -> opens modal pre-filled. Add -> empty modal. Delete -> confirmation -> refresh. Drag reorder -> auto-save -> visual confirmation. Subcategory add -> modal with parent pre-selected. Deactivate/Activate -> inline toggle.

## Future Considerations
- Category bulk import from CSV
- Category merge (combine two categories)
- Category visibility (public vs internal-only)
- Category image/cover photo
- Skill count by category analytics
- Category approval workflow (for user suggestions)
- Category version history
- Multi-language category names
- Category-based recommendation rules
- Category display customization (featured, highlighted)
- AI-suggested category improvements
- Category sharing/syndication to partner platforms
