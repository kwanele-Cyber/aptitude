# Trust Score Page
**Status**: Pending
**Route**: `/trust-score`
**Priority**: P5
**Use Cases Covered**: T06, T07, T08, T09
## Purpose
Display the user's trust score (0-100) with a visual gauge, breakdown by contributing factors, historical trend chart, and actionable recommendations for improvement. This is a key trust and safety feature that encourages positive behavior.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  Trust Score         [Share]      |
+------------------------------------------+
|                                           |
|       +-------------------------+         |
|       |       Score Gauge       |         |
|       |    ┌───────────────┐   |         |
|       |    │    78         │   |         |
|       |    │   / 100       │   |         |
|       |    └───────────────┘   |         |
|       |   Good Standing        |         |
|       +-------------------------+         |
|                                           |
|  Factor Breakdown                         |
|  +--------------------------------------+ |
|  | ✅ Session Completion   28/30   93%  | |
|  |    ████████████████████████░░░      | |
|  +--------------------------------------+ |
|  | ✅ Rating Score         4.7/5.0  94% | |
|  |    ████████████████████████░░░      | |
|  +--------------------------------------+ |
|  | ✅ Behavior Flags       0          100%| |
|  |    ████████████████████████████      | |
|  +--------------------------------------+ |
|  | ⚠️ Review Responsiveness 60%       | |
|  |    ██████████████░░░░░░░░░░░░      | |
|  +--------------------------------------+ |
|                                           |
|  Trust Score Trend                         |
|  +--------------------------------------+ |
|  |  [Chart: Line graph]                 | |
|  |  80 ┤         ╱╲                     | |
|  |  70 ┤  ╱╲   ╱  ╲    ╱╲              | |
|  |  60 ┤╱  ╲ ╱    ╲  ╱  ╲             | |
|  |  50 ┤      ╲      ╲                  | |
|  |     └───┬──┬──┬──┬──┬──┬──┬──       | |
|  |        Jan Feb Mar Apr May Jun Jul   | |
|  +--------------------------------------+ |
|                                           |
|  [How to Improve My Score >]              |
+------------------------------------------+
```

## Component Breakdown
1. **Score Gauge**: Large circular or semicircular gauge with animated needle/arc. Color gradient: red (0-40) -> yellow (41-60) -> light green (61-80) -> dark green (81-100). Status label below ("Needs Improvement", "Fair", "Good Standing", "Excellent").
2. **Factor Breakdown Cards**: Each factor shows:
   - Icon and factor name
   - Current value and score percentage
   - Progress bar (color-coded)
   - ▲/▼ trend indicator (improving/declining)
   - Factors: Session Completion Rate, Rating Score, Behavior Flags, Review Responsiveness, Account Age, Verification Status
3. **Trust Score Trend Chart**: Interactive line chart showing score over time (configurable: 1m, 3m, 6m, 1y). Tapping data points shows exact date and score. Dips annotated with reason icons.
4. **Score Composition Pie Chart** (alternative/optional): Shows weighted contribution of each factor.
5. **Improvement Tips Button**: Link to a page or expandable section with personalized recommendations.

## States (Loading, Empty, Error, Data)
- **Loading**: Gauge skeleton (circle), factor breakdown skeleton bars, chart skeleton with shimmer.
- **Empty (New User)**: Gauge shows 0 with "No score yet" label. Factor breakdowns show "--" values. Message: "Complete your first few sessions to build your trust score." Placeholder chart with no data points.
- **Error**: "Could not load trust score data." with [Retry] button.
- **Data**: Full interactive score display with animations on load. Gauge animates from 0 to current value. Trend chart interactive with tooltips. Pull-to-refresh for latest data.

## Navigation Connections
- **Incoming**: From Profile "Trust Score" link, from settings, from trust score notification/alerts, from rating flow.
- **Outgoing**: Share -> Share score as image/link (optional: show badge). How to Improve -> `/trust-score/tips` or expandable section. Factor detail -> expand/collapse per factor. Appeal -> `/trust-score/appeal`.

## Future Considerations
- Score percentile rank vs community average
- Badge for reaching score milestones
- Score simulation ("What if I get 5 stars?")
- Notifications on score changes
- Peer comparison (anonymous)
- Score-based privileges (priority matching, etc.)
- Identity verification boost to score
- Score history download
- Multi-community score portability
- Score freeze for extended absences
