# Cross-Cutting Flow

**Feature**: System-Wide Integration
**Screens**: All
**Status**: Reference

## Diagram

```mermaid
flowchart TD
    classDef done fill:#d4edda,stroke:#28a745,color:#155724
    classDef pending fill:#fff3cd,stroke:#ffc107,color:#856404
    classDef admin fill:#cce5ff,stroke:#007bff,color:#004085

    subgraph Auth["Authentication Layer"]
        AuthCheck["Auth Check"]:::done
        Login["Login"]:::done
        Session["Session Persistence"]:::done
    end

    subgraph CoreFeatures["Core Features"]
        Skills["Skills Ecosystem"]:::done
        Matching["Matchmaking"]:::done
        Chat["Communication"]:::pending
        Agreement["Agreements"]:::pending
        Sessions["Session Execution"]:::pending
    end

    subgraph Quality["Quality Layer"]
        Trust["Trust & Reputation"]:::pending
        Feedback["Feedback & Ratings"]:::pending
        AI["AI Enhancements"]:::pending
    end

    subgraph CrossCutting["Cross-Cutting Systems"]
        Notifications["Notification System"]:::pending
        Disputes["Dispute Resolution"]:::pending
        Progress["Progress Tracking"]:::pending
        Rules["Platform Rules"]:::pending
    end

    subgraph Admin["Admin System"]
        AdminPanel["Admin Panel"]:::admin
    end

    subgraph Safety["Safety & Refinements"]
        Blocking["Blocked Users"]:::pending
        Filtering["Filtering Integration"]:::pending
        AutoBlock["Auto-Block Suggestion"]:::pending
    end

    Auth --> CoreFeatures
    CoreFeatures --> Quality
    CoreFeatures --> CrossCutting
    Quality --> CrossCutting
    CoreFeatures --> Admin
    CrossCutting --> Admin
    Safety --> CoreFeatures
```

## Flow Description
The app architecture follows a layered model. Authentication gates all core features. Skills and Matching feed into Communication, which leads to Agreements and Sessions. Completed Sessions trigger Feedback and Trust Score updates. AI enhances matching and recommendations. Cross-cutting systems (Notifications, Disputes, Progress) serve all features. Admin oversees everything.

## Data Flow Summary

| Trigger | Action | Downstream Effect |
|---------|--------|-------------------|
| User registers | Auth creates profile | Ready for skills & matching |
| User creates skill | Skill entity stored | Becomes discoverable in feed |
| Matches generated | Scoring algorithm runs | Cards shown in matchmaking |
| Match accepted | Status updated | Chat enabled, agreement possible |
| Agreement accepted | Terms locked | Session scheduling unlocked |
| Session completed | Rating triggered | Trust score updated, progress tracked |
| Negative behavior | Report/Dispute filed | Admin review, trust adjustment |

## Notes
- Auth guard applies to all routes except `/login`, `/register`, `/forgot-password`
- Notifications can be triggered from any feature (matches, messages, reminders)
- Trust score is a global metric affecting match ranking and discovery filtering
- Admin has oversight across all features via audit log
