# Admin Dashboard Page
**Status**: Pending
**Route**: `/admin`
**Priority**: Admin
**Use Cases Covered**: A02
## Purpose
The main landing page for administrators after login. Provides a high-level overview of platform health with KPI cards, visual charts, recent activity feed, and quick action tiles for common administrative tasks.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| Admin Dashboard           [Admin ▼] [🔔]|
+------------------------------------------+
|                                           |
|  Welcome back, Admin!      Last login:   |
|                            Feb 15, 2:30PM |
|                                           |
|  KPI Cards                                |
|  +----------+----------+----------+---+  |
|  | 👥       | 🤝       | 📅       | ⭐|  |
|  | 2,847    | 1,234    | 892      |4.7|  |
|  | Users    | Matches  | Sessions |Rating |
|  | +12% wk  | +8% wk   | +15% wk  |      |
|  +----------+----------+----------+---+  |
|                                           |
|  Charts Row                               |
|  +--------------------+ +---------------+ |
|  | User Growth        | | Session       | |
|  | [Line Chart]       | | Completion    | |
|  | ▁▃▆▇▆▇█▇          | | [Donut Chart] | |
|  | Jan-Feb 2026       | | 78% Complete  | |
|  +--------------------+ +---------------+ |
|                                           |
|  Recent Activity                           |
|  +--------------------------------------+ |
|  | 🆕 New user: Thandi Nkosi joined    | |
|  |    2m ago                            | |
|  | 🚩 Flagged content: Report #42      | |
|  |    15m ago                           | |
|  | ⚠️ Dispute opened: D-2026-0042     | |
|  |    1h ago                            | |
|  | 🤝 New match: Python - Guitar       | |
|  |    2h ago                            | |
|  +--------------------------------------+ |
|  [View All Activity >]                    |
|                                           |
|  Quick Actions                            |
|  +----------+----------+----------+      |
|  | 👥       | 🚩       | ⚙️       |      |
|  | Users    | Content  | System   |      |
|  | Management|Moderation| Settings |      |
|  +----------+----------+----------+      |
|  | 📊       | 💬       | 📋       |      |
|  | Analytics| Broadcast| Audit    |      |
|  +----------+----------+----------+      |
+------------------------------------------+
```

## Component Breakdown
1. **Admin AppBar**: "Admin Dashboard" title, admin user menu (profile, settings, logout), notification bell with unread count.
2. **Welcome Header**: Greeting with last login timestamp.
3. **KPI Cards**: Row of metric cards with icon, value, label, and weekly trend arrow (up/down). Cards: Total Users, Active Matches, Sessions This Week, Average Rating.
4. **Charts Row**: Side-by-side chart widgets:
   - User Growth (line chart, 30-day view)
   - Session Completion Rate (donut/pie chart)
   - Match Success Rate (bar chart, optional third chart)
5. **Recent Activity Feed**: Scrolling list of recent platform events with emoji icons, descriptions, and relative timestamps. Auto-updates via WebSocket.
6. **Quick Action Tiles**: 2x3 grid of action cards with icons and labels linking to key admin pages.
7. **Sidebar Navigation** (desktop): Collapsible sidebar with links to all admin sections.

## States (Loading, Empty, Error, Data)
- **Loading**: Full skeleton dashboard with KPI card placeholders, chart skeletons, activity feed lines, and action tile placeholders with shimmer.
- **Empty (New Platform)**: KPI cards show 0 values. Charts show no data with "No data yet" message. Activity feed empty with illustration.
- **Error**: "Could not load dashboard data." with [Retry] button. Partial load for individual widgets with error state per card/chart.
- **Data**: Full interactive dashboard with animated KPI counters, live-updating activity feed, interactive charts with tooltips. Auto-refresh every 60 seconds.

## Navigation Connections
- **Incoming**: From Admin Login (success redirect), from admin navigation sidebar, from notification.
- **Outgoing**: KPI cards -> filtered list views. Quick Actions -> respective admin pages. View All Activity -> detailed audit/log page. Admin menu -> profile, settings, logout. Notification -> admin notifications.

## Future Considerations
- Customizable dashboard layout (drag widgets)
- Date range selector for all charts
- Export dashboard as PDF/image
- Real-time user count widget
- Server health monitoring (CPU, memory, uptime)
- Geographic user distribution map
- Revenue/financial metrics (if applicable)
- Scheduled report delivery via email
- Dark mode for admin panel
- Mobile-responsive admin view
