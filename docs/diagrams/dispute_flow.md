# Dispute & Safety Flow

**Feature**: Dispute & Safety
**Screens**: 3 (0 existing + 3 pending)
**Status**: Planned

## Diagram

```mermaid
flowchart TD
    classDef done fill:#d4edda,stroke:#28a745,color:#155724
    classDef pending fill:#fff3cd,stroke:#ffc107,color:#856404
    classDef admin fill:#cce5ff,stroke:#007bff,color:#004085
    classDef decision fill:#f8f9fa,stroke:#6c757d,stroke-width:2px

    ChatDetail(["Chat Detail"]):::pending
    UserProfile(["User Profile"]):::done
    SessionDetail(["Session Detail"]):::pending

    ReportUserPage["Report User"]:::pending
    CreateDisputePage["Create Dispute"]:::pending
    DisputeDetailPage["Dispute Detail"]:::pending
    AppealDecisionPage["Appeal Decision"]:::pending

    AdminResolve["Admin Resolution"]:::admin
    AdminReview["Admin Review"]:::admin

    ChatDetail --> ReportUserPage
    UserProfile --> ReportUserPage
    SessionDetail --> CreateDisputePage

    ReportUserPage --> DisputeDetailPage
    CreateDisputePage --> DisputeDetailPage
    DisputeDetailPage --> AppealDecisionPage

    DisputeDetailPage --> AdminResolve
    AppealDecisionPage --> AdminReview
```

## Flow Description
Users can report others from chat or their profile, or create formal disputes related to sessions/agreements. Each report/dispute is tracked with a status and can be escalated for admin review. Users can appeal dispute decisions if they disagree with the resolution.

## Screen Inventory

| Screen | Route | Status | Use Cases |
|--------|-------|--------|-----------|
| Report User | `/report/:userId` | ❌ Todo | X05 |
| Create Dispute | `/disputes/create` | ❌ Todo | X06 |
| Dispute Detail | `/disputes/:id` | ❌ Todo | X07, X08 |

## Notes
- Evidence attachment (screenshots, messages) needed for reports
- Admin-mediated resolution with status tracking
- Appeal window should have a time limit
