# Matchmaking Flow

**Feature**: Matching Engine, Match Interaction, Match Optimization
**Screens**: 2 (2 existing + 0 pending)
**Status**: Complete

## Diagram

```mermaid
flowchart TD
    classDef done fill:#d4edda,stroke:#28a745,color:#155724
    classDef pending fill:#fff3cd,stroke:#ffc107,color:#856404
    classDef decision fill:#f8f9fa,stroke:#6c757d,stroke-width:2px

    MatchesTab(["Matches Tab"]):::done
    HomeExplore(["Explore Tab"]):::done

    MatchmakingPage["Matchmaking Page\n/matches"]:::done
    MatchHistoryPage["Match History\n/matches/history/:uid"]:::done

    subgraph CardActions["Match Card Actions"]
        Accept["Accept Match"]:::done
        Reject["Reject Match"]:::done
        Ignore["Ignore Match"]:::done
        Save["Save Match"]:::done
    end

    FeedbackDialog["Feedback Dialog\n(star rating)"]:::done
    FilterDialog["Filter Dialog\n(score, trust, dist)"]:::done

    MatchHistoryPage --> HistoryFilter["Status Filter\nChips: All/Accepted/Rejected"]:::done

    MatchesTab --> MatchmakingPage
    HomeExplore --> MatchHistoryPage

    MatchmakingPage --> FilterDialog
    MatchmakingPage --> Accept
    MatchmakingPage --> Reject
    MatchmakingPage --> Ignore
    MatchmakingPage --> Save

    Accept --> FeedbackDialog
    Reject --> FeedbackDialog
```

## Flow Description
The Matchmaking Page displays daily match suggestions as cards. Each card shows the target skill, match score, distance, and verification status. Users can accept, reject, or ignore matches. Accepting or rejecting triggers a feedback dialog for rating match quality. The filter dialog allows narrowing by minimum score, trust score, maximum distance, and verified-only. Match History shows past interactions with status filter chips.

## Screen Inventory

| Screen | Route | Status | Use Cases |
|--------|-------|--------|-----------|
| Matchmaking Page | `/matches` | ✅ Existing | M01-M11, M13-M14 |
| Match History | `/matches/history/:uid` | ✅ Existing | M12 |

## Notes
- Match scoring algorithm: category (30pts) + level (25pts) + format (20pts) + tags (15pts) + geo (10pts) + availability (5pts) = max 100pts
- Geo-proximity uses Haversine formula from `lib/core/utils/geo_utils.dart`
- After accept/reject → feedback dialog → currently only rating, no comment field used
