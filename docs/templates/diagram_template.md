# [Flow Name] Flow

**Feature**: [Feature Module]
**Screens**: [count] ([done] existing + [pending] pending)
**Status**: [Complete | Partial | Planned]

## Diagram

```mermaid
flowchart TD
    %% Style definitions
    classDef done fill:#d4edda,stroke:#28a745,color:#155724
    classDef pending fill:#fff3cd,stroke:#ffc107,color:#856404
    classDef admin fill:#cce5ff,stroke:#007bff,color:#004085
    classDef decision fill:#f8f9fa,stroke:#6c757d,stroke-width:2px

    %% Entry point
    Entry(["Entry Point"]):::done

    %% Screens
    Screen1["Screen 1"]:::done
    Screen2["Screen 2"]:::pending

    %% Decisions
    Decision1{"Decision?"}:::decision

    %% Edges
    Entry --> Screen1
    Screen1 --> Decision1
    Decision1 -->|"Yes"| Screen2
    Decision1 -->|"No"| Screen1
```

## Flow Description
[Narrative description of the flow]

## Screen Inventory

| Screen | Route | Status | Use Cases |
|--------|-------|--------|-----------|
| [Screen 1] | `/path` | ✅ Done | [IDs] |
| [Screen 2] | `/path` | ❌ Todo | [IDs] |

## Notes
[Edge cases, error flows, auth requirements]
