# Agreement Flow

**Feature**: Agreement System
**Screens**: 3 (0 existing + 3 pending)
**Status**: Planned

## Diagram

```mermaid
flowchart TD
    classDef done fill:#d4edda,stroke:#28a745,color:#155724
    classDef pending fill:#fff3cd,stroke:#ffc107,color:#856404
    classDef decision fill:#f8f9fa,stroke:#6c757d,stroke-width:2px

    ChatDetail(["Chat Detail"]):::pending
    MatchedProfile(["Matched User Profile"]):::done

    CreateAgreement["Create Agreement"]:::pending
    AgreementDetail["Agreement Detail"]:::pending
    ModifyAgreement["Modify Agreement"]:::pending

    AcceptDecision{"Accept?"}:::decision
    Modified{"Modified?"}:::decision

    SessionFlow["Session Execution Flow"]:::pending

    ChatDetail --> CreateAgreement
    MatchedProfile --> CreateAgreement
    CreateAgreement --> AgreementDetail

    AgreementDetail --> AcceptDecision
    AcceptDecision -->|"Yes"| SessionFlow
    AcceptDecision -->|"No, modify"| ModifyAgreement
    ModifyAgreement --> Modified
    Modified -->|"re-submit"| AgreementDetail
    Modified -->|"cancel"| CreateAgreement
```

## Flow Description
After matching with a user, either party can propose a skill exchange agreement. The Create Agreement form captures the terms — what skills are being exchanged, duration, frequency, and format. The other party views the agreement and can accept, request modifications, or cancel. Once accepted, the flow proceeds to Session scheduling.

## Screen Inventory

| Screen | Route | Status | Use Cases |
|--------|-------|--------|-----------|
| Create Agreement | `/agreements/create` | ❌ Todo | C09 |
| Agreement Detail | `/agreements/:id` | ❌ Todo | C10, C12, C13 |
| Modify Agreement | `/agreements/:id/modify` | ❌ Todo | C11 |

## Notes
- Agreements are the bridge between matching and session execution
- Cancellation policy enforcement (cooldown periods, notifications) needs design consideration
- Version history of modifications should be tracked
