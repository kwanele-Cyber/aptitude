# Trust & AI Flow

**Feature**: Feedback System, Trust System, AI Enhancements
**Screens**: 5 (0 existing + 5 pending)
**Status**: Planned

## Diagram

```mermaid
flowchart TD
    classDef done fill:#d4edda,stroke:#28a745,color:#155724
    classDef pending fill:#fff3cd,stroke:#ffc107,color:#856404
    classDef decision fill:#f8f9fa,stroke:#6c757d,stroke-width:2px

    SessionComplete(["Session Completed"]):::pending
    UserProfile(["User Profile"]):::done

    RateUserPage["Rate User\n(1-5 stars + review)"]:::pending
    UserReviewsPage["User Reviews"]:::pending
    EditReviewPage["Edit Review"]:::pending
    RespondToReview["Respond to Review"]:::pending

    TrustScorePage["Trust Score\n(score breakdown)"]:::pending
    AppealTrustPage["Appeal Trust Score"]:::pending

    SkillRecommendations["Skill Recommendations\n(AI suggested)"]:::pending
    BehaviorAnalysis["Behavior Analysis\n(fraud detection)"]:::pending
    SmartMatchOpt["Smart Match Optimization\n(ML improvement)"]:::pending

    SessionComplete --> RateUserPage
    RateUserPage --> UserReviewsPage
    UserReviewsPage --> EditReviewPage
    UserReviewsPage --> RespondToReview

    UserReviewsPage --> TrustScorePage
    TrustScorePage --> AppealTrustPage

    UserProfile --> UserReviewsPage
    UserProfile --> TrustScorePage
    HomeDashboard(["Dashboard"]):::done --> SkillRecommendations
```

## Flow Description
After each completed session, users rate each other (1-5 stars) with optional written reviews. Reviews are visible on user profiles. Users can edit their review within 48 hours and respond to received feedback. The Trust Score (0-100) is computed from all reviews and behavior, visible with a breakdown of contributing factors. Users can appeal trust score adjustments. AI features provide skill recommendations on the dashboard.

## Screen Inventory

| Screen | Route | Status | Use Cases |
|--------|-------|--------|-----------|
| Rate User | `/rate/:sessionId` | ❌ Todo | T01, T02 |
| User Reviews | `/profile/:uid/reviews` | ❌ Todo | T03 |
| Edit Review | `/reviews/:id/edit` | ❌ Todo | T04 |
| Trust Score | `/trust-score` | ❌ Todo | T06-T09 |
| Appeal Trust Score | `/trust-score/appeal` | ❌ Todo | T10 |

## Notes
- Trust score is AI-computed (0-100) based on completed sessions, ratings, behavior
- AI recommendations displayed on the dashboard Explore tab
- Fraud detection runs in the background, no dedicated page
