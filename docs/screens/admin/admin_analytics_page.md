# Admin Analytics Page
**Status**: Pending
**Route**: `/admin/analytics`
**Priority**: Admin
**Use Cases Covered**: A16, A17
## Purpose
Provide comprehensive platform analytics with visual charts and data tables. Covers user growth, match success rates, session completion rates, and other key metrics. Includes date range selection and data export functionality.

## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [<] Analytics                     [Export]|
+------------------------------------------+
|                                           |
|  Date Range: [Last 30 Days ▼] [Apply]    |
|  Custom: [Feb 01, 2026] to [Mar 02, 2026]|
|                                           |
|  Overview                                 |
|  +----------+----------+----------+      |
|  | New Users| Matches  | Sessions |      |
|  | 847      | 1,234    | 892      |      |
|  | +12.3%   | +8.1%    | +15.7%   |      |
|  +----------+----------+----------+      |
|                                           |
|  User Growth                              |
|  +--------------------------------------+ |
|  |  [Line Chart]                        | |
|  |  ░░░░░░░░░░░░░░░░░░░░░░░           | |
|  |  ░░░░░██░░░░███░░░░█░░░░          | |
|  |  ░░██░░██░░░███░░███░░███         | |
|  |  ██████████████████████████         | |
|  |  └──┬──┬──┬──┬──┬──┬──┬──┘        | |
|  |     Week 1-4 of selected period     | |
|  +--------------------------------------+ |
|                                           |
|  Match Success Rate                       |
|  +--------------------------------------+ |
|  |  [Bar Chart]                         | |
|  |  80% ┤ ██                            | |
|  |  60% ┤ ██ ██                         | |
|  |  40% ┤ ██ ██ ██ ██                   | |
|  |  20% ┤ ██ ██ ██ ██ ██                | |
|  |     └──┬──┬──┬──┬──┬──              | |
|  |        Skills Categories             | |
|  +--------------------------------------+ |
|                                           |
|  Session Completion Breakdown             |
|  +--------------------------------------+ |
|  | Completed:   78%  [████████░░]      | |
|  | Cancelled:   12%  [██░░░░░░░░]      | |
|  | No-Show:      8%  [█░░░░░░░░░]      | |
|  | Rescheduled:  2%  [░░░░░░░░░░]      | |
|  +--------------------------------------+ |
|                                           |
|  [Export as CSV] [Export as PDF] [Schedule Report]|
+------------------------------------------+
```

## Component Breakdown
1. **Date Range Selector**: Preset ranges (Last 7 days, 30 days, 90 days, This Year, All Time) and custom date picker. Apply button.
2. **Overview Metric Cards**: Key numbers with period-over-period percentage change and trend arrows. Cards: New Users, Total Matches, Sessions Completed, Avg Rating, Trust Score Avg, Dispute Rate.
3. **User Growth Chart**: Interactive line/area chart showing cumulative and new user registrations over time. Hover tooltips with exact values.
4. **Match Success Rate Chart**: Bar chart grouped by skill category or time period. Shows conversion rate from match to first session.
5. **Session Completion Breakdown**: Horizontal stacked bar or donut chart showing session outcome distribution.
6. **Additional Charts** (scrollable): Trust score distribution, geographic user map, peak usage times, retention cohort analysis.
7. **Export Buttons**: [Export as CSV] for raw data, [Export as PDF] for chart report, [Schedule Report] for recurring email delivery.
8. **Data Table** (expandable): Below charts, a sortable data table with raw numbers for transparency.

## States (Loading, Empty, Error, Data)
- **Loading**: All chart skeletons with shimmer, metric card placeholders, export buttons disabled.
- **Empty (New Platform)**: "Not enough data for analytics. Data will appear once users start registering and completing sessions." Placeholder charts with "No data" overlays.
- **Empty (Date Range)**: "No data available for the selected date range." with suggestion to expand range.
- **Error**: "Could not load analytics data." with [Retry] button. Individual chart error handling (one chart failing doesn't affect others).
- **Data**: Full interactive analytics page with responsive charts. Hover/click for data point details. Chart zoom/pan for detailed views.

## Navigation Connections
- **Incoming**: From Admin Dashboard "Analytics" quick action, from admin sidebar.
- **Outgoing**: Export -> file download or email dialog. Schedule Report -> configuration modal (frequency, recipients, sections). Date Range -> updates all charts. Chart interaction -> tooltips and drill-down modals.

## Future Considerations
- Cohort analysis (user retention by signup month)
- Funnel analysis (registration -> match -> session -> review)
- Geographic heat maps
- Device/platform breakdown
- User segment comparison
- Custom report builder
- Automated insight generation (AI-powered)
- Real-time analytics dashboard
- API analytics (if applicable)
- Anomaly detection alerts
- Competitor benchmarking
- Projection/forecasting charts
- Role-based analytics access
