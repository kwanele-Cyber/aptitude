# Session Execution Flow

**Feature**: Scheduling, Session Lifecycle, Session Materials
**Screens**: 7 (0 existing + 7 pending)
**Status**: Planned

## Diagram

```mermaid
flowchart TD
    classDef done fill:#d4edda,stroke:#28a745,color:#155724
    classDef pending fill:#fff3cd,stroke:#ffc107,color:#856404
    classDef decision fill:#f8f9fa,stroke:#6c757d,stroke-width:2px

    AgreementAccepted(["Agreement Accepted"]):::pending
    HomeDashboard(["Dashboard"]):::done

    subgraph Scheduling["Scheduling"]
        CreateSession["Create Session"]:::pending
        SessionCalendar["Session Calendar"]:::pending
        SessionWaitlist["Session Waitlist"]:::pending
    end

    SessionDetail["Session Detail"]:::pending
    SessionCheckIn["Session Check-In"]:::pending

    subgraph Lifecycle["Session Lifecycle"]
        StartSession["Start Session"]:::pending
        CompleteSession["Complete Session"]:::pending
        CancelSession["Cancel Session"]:::pending
    end

    SessionHistory["Session History"]:::pending
    RateSession["Rate Session"]:::pending

    subgraph Materials["Materials"]
        ShareMaterials["Share Materials"]:::pending
        SessionNotes["Session Notes"]:::pending
    end

    AgreementAccepted --> CreateSession
    HomeDashboard --> SessionCalendar
    HomeDashboard --> SessionHistory

    CreateSession --> SessionDetail
    SessionCalendar --> SessionDetail
    SessionDetail --> StartSession
    SessionDetail --> CancelSession

    StartSession --> SessionCheckIn
    SessionCheckIn --> CompleteSession
    CompleteSession --> RateSession
    CompleteSession --> ShareMaterials
    CompleteSession --> SessionNotes

    SessionDetail --> ShareMaterials
    SessionDetail --> SessionNotes
    SessionDetail --> SessionWaitlist
```

## Flow Description
After an agreement is accepted, sessions can be scheduled with time, location, and format. Sessions appear on a calendar view. The session lifecycle: Scheduled → Started (check-in) → Completed (with optional verification). After completion, both parties can rate the session and share materials or collaborative notes.

## Screen Inventory

| Screen | Route | Status | Use Cases |
|--------|-------|--------|-----------|
| Create Session | `/sessions/create` | ❌ Todo | E01, E06 |
| Session Detail | `/sessions/:id` | ❌ Todo | E02, E03, E08, E09 |
| Session Calendar | `/sessions/calendar` | ❌ Todo | E05, E07 |
| Session Check-In | `/sessions/:id/checkin` | ❌ Todo | E10, E11 |
| Session History | `/sessions/history` | ❌ Todo | E12 |
| Share Materials | `/sessions/:id/materials` | ❌ Todo | E14 |
| Session Notes | `/sessions/:id/notes` | ❌ Todo | E15 |

## Notes
- Reminders (E04) handled via push notifications, not a dedicated page
- Calendar integration (E05) uses device calendar APIs
- QR code / geolocation for attendance verification (E10, E11)
