# User Reviews Page
**Status**: Pending
**Route**: `/profile/:uid/reviews`
**Priority**: P5
**Use Cases Covered**: T03
## Purpose
Display all reviews received by a user, aggregated by average rating. Allows visitors (and the profile owner) to read through feedback from past session partners, with filtering and sorting options.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  Reviews        [Share Profile]   |
+------------------------------------------+
|                                           |
|  [Avatar] Kwanele Mhlongo                |
|                                           |
|  ⭐ 4.8  ·  23 reviews                   |
|  +---+---+---+---+---+                   |
|  | 5 | 4 | 3 | 2 | 1 |                  |
|  |18 | 3 | 1 | 1 | 0 |                  |
|  +---+---+---+---+---+                   |
|  Rating distribution bar chart           |
|                                           |
|  [Most Recent ▼] [All Skills ▼]          |
|                                           |
|  +--------------------------------------+ |
|  | ★★★★★                               | |
|  | "Excellent teacher! Very patient    | |
|  |  and knowledgeable. Highly          | |
|  |  recommend for Python beginners."   | |
|  | Thandi Nkosi · Python #4            | |
|  | Feb 2026                            | |
|  +--------------------------------------+ |
|  | ★★★★☆                               | |
|  | "Good session, but could have       | |
|  |  prepared more material."           | |
|  | Busi Dlamini · Python #2            | |
|  | Jan 2026                            | |
|  +--------------------------------------+ |
|  | ★★★★★                               | |
|  | "Amazing! Learned a lot in one      | |
|  |  session. Clear explanations."      | |
|  | Sipho Zulu · Python #1              | |
|  | Jan 2026                            | |
|  +--------------------------------------+ |
|                                           |
|  Loaded 10 of 23 reviews  [Load More]    |
+------------------------------------------+
```

## Component Breakdown
1. **Profile Header**: User avatar, name, average rating (large), total review count.
2. **Rating Distribution**: Horizontal bar chart showing count of each star rating (5-star through 1-star). Each bar tappable to filter by that rating.
3. **Filter/Sort Controls**: Sort dropdown (Most Recent, Highest Rated, Lowest Rated). Skill filter dropdown. Optionally, rating filter from distribution bars.
4. **Review Card**: Each review shows:
   - Star rating (display-only, filled stars)
   - Review text (up to 3 lines with "Read more" expandable)
   - Reviewer name (tappable -> reviewer profile)
   - Skill and session number reference
   - Month and year
   - Verified badge (if review is from a confirmed session)
5. **Pagination**: Infinite scroll or "Load More" button.
6. **Share Profile Button**: Share user's profile/reviews link externally.

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton with rating summary bar chart placeholder and 3 review card skeletons with shimmer.
- **Empty (No Reviews)**:
  ```
  +----------------------------------+
  |                                  |
  |    [Illustration: speech bubble  |
  |     with star]                   |
  |                                  |
  |  No reviews yet                  |
  |                                  |
  |  Reviews will appear here once   |
  |  this user completes sessions    |
  |  with other community members.   |
  |                                  |
  +----------------------------------+
  ```
- **Error**: "Could not load reviews." with [Retry] button.
- **Data**: Full scrollable list with sort/filter. Pull-to-refresh. Expandable review text for long reviews.

## Navigation Connections
- **Incoming**: From User Profile "View Reviews" link, from trust score page, from review notification.
- **Outgoing**: Tap reviewer name -> `/profile/:uid`. Share -> System share sheet. Filter/Sort -> in-place list update.

## Future Considerations
- Review helpfulness voting (thumbs up/down)
- Review reply from profile owner
- Photo/video review attachments
- Review translation for cross-language pairs
- Reported/flagged review indicators
- Trending reviews (most helpful/recent)
- Review verification badges (confirmed session)
- Review analytics for profile owner (trends over time)
