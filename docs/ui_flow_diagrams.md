# Aptitude UI Flow Diagrams (from `use_case_tracker`)

This document maps tracked use cases to practical UI navigation paths using Mermaid charts.

## 1) Authentication & Onboarding (P0)

```mermaid
flowchart TD
    LAUNCH[App Launch] --> SESSION{Existing Session?<br/>F04}

    SESSION -- No --> LOGIN[Login Screen<br/>F03]
    SESSION -- Yes --> HOME[Home]

    LOGIN --> REGISTER[Register<br/>F02]
    LOGIN --> FORGOT[Forgot Password<br/>F08]
    LOGIN --> LOGIN_SUBMIT[Submit Credentials<br/>F03]

    REGISTER --> VERIFY[Email Verification<br/>F07]
    VERIFY --> PROFILE_CREATE[Create Profile<br/>F11]

    FORGOT --> LOGIN
    LOGIN_SUBMIT --> HOME
    PROFILE_CREATE --> HOME

    HOME --> PROFILE[Profile Details/Edit<br/>F13/F12]
    PROFILE --> TWOFA[2FA Setup<br/>F10]
    PROFILE --> EXPORT[Export Data<br/>F16]
    PROFILE --> LOGOUT[Logout<br/>F05]
    LOGOUT --> LOGIN
```

## 2) Skill Creation, Discovery & Management (P1)

```mermaid
flowchart TD    
    HOME[Home / Discover] --> OFFER[Create Skill Offer<br/>S01]
    HOME --> REQUEST[Create Skill Request<br/>S02]
    HOME --> SEARCH[Search Skills<br/>S08]
    HOME --> FILTER[Filter Skills<br/>S09]
    HOME --> FEED[Browse Feed<br/>S10]
    
    OFFER --> AI_CAT["Suggest Category (AI)<br/>S13"]
    REQUEST --> AI_CAT
    AI_CAT --> DETAILS[Skill Details<br/>S11]

    DETAILS --> EDIT[Edit Skill<br/>S03]
    DETAILS --> DELETE[Delete Skill<br/>S04]
    DETAILS --> CLONE[Clone Skill<br/>S06]
    DETAILS --> ARCHIVE[Archive Skill<br/>S07]
    
    SEARCH --> SAVE_SEARCH[Save Search<br/>S12]
    FILTER --> SAVE_SEARCH
    FEED --> DETAILS
```

## 3) Matchmaking Journey (P2)

```mermaid
flowchart TD
    DISCOVER[Discover / Home] --> GENERATE[Generate Matches<br/>M01]
    GENERATE --> RANKED[Ranked Match List<br/>M02/M03]

    RANKED --> ACCEPT[Accept Match<br/>M07]
    RANKED --> REJECT[Reject Match<br/>M08]
    RANKED --> IGNORE[Ignore Match<br/>M09]
    RANKED --> SAVE[Save Match<br/>M11]
    RANKED --> REFRESH[Refresh Matches<br/>M14]
    RANKED --> FILTERS[Apply Filters<br/>M10/T08]

    ACCEPT --> CHAT[Open Chat<br/>C01]
    REJECT --> HISTORY[Match History<br/>M12]
    IGNORE --> HISTORY
    SAVE --> HISTORY

    TODO_GEO["Geo-Proximity Scoring<br/>M04 (TODO)"]:::todo -.future ranking.-> RANKED
    TODO_AVAIL["Availability Matching<br/>M05 (TODO)"]:::todo -.future ranking.-> RANKED

    classDef todo fill:#fff3cd,stroke:#d39e00,color:#5c4400;
```

## 4) Communication & Agreement (P3)

```mermaid
flowchart TD
    MATCHED[Matched Users] --> CHAT_LIST[Chat List]
    CHAT_LIST --> CHANNEL[Open Chat Channel<br/>C01]

    CHANNEL --> SEND[Send Message<br/>C02]
    CHANNEL --> RECEIVE[Receive Message<br/>C03]
    CHANNEL --> TYPING[Typing Indicator<br/>C06]
    CHANNEL --> READS[Read Receipts<br/>C05]
    CHANNEL --> HISTORY[Message History<br/>C04]

    CHANNEL --> BLOCK[Block User<br/>C07]
    CHANNEL --> REPORT[Report Message<br/>C08]

    CHANNEL --> AGREEMENT_CREATE[Create Agreement<br/>C09]
    AGREEMENT_CREATE --> AGREEMENT_VIEW[View Agreement<br/>C13]
    AGREEMENT_VIEW --> AGREEMENT_ACCEPT[Accept Agreement<br/>C10]
    AGREEMENT_ACCEPT --> SESSION_FLOW[Continue to Session Scheduling]

    AGREEMENT_MOD["Modify Agreement<br/>C11 (TODO)"]:::todo -.future branch.-> AGREEMENT_VIEW
    AGREEMENT_CANCEL["Cancel Agreement<br/>C12 (TODO)"]:::todo -.future branch.-> AGREEMENT_VIEW

    classDef todo fill:#fff3cd,stroke:#d39e00,color:#5c4400;
```

## 5) Session Execution (P4)

```mermaid
flowchart TD
    AGREED[Accepted Agreement] --> CREATE_SESSION[Create Session<br/>E01]
    CREATE_SESSION --> UPCOMING[Upcoming Sessions]
    UPCOMING --> SESSION_DETAIL[Session Detail]

    SESSION_DETAIL --> COMPLETE[Complete Session<br/>E09]
    COMPLETE --> SESSION_HISTORY[Session History<br/>E12]

    COMPLETE --> RATE[Rate User<br/>T01]
    RATE --> REVIEW[Write Review<br/>T02]

    UPCOMING --> REMINDERS[Reminders / Notifications<br/>X01/X02]

    UPDATE_SESSION["Update Session<br/>E02 (TODO)"]:::todo -.future action.-> SESSION_DETAIL
    CANCEL_SESSION["Cancel Session<br/>E03 (TODO)"]:::todo -.future action.-> SESSION_DETAIL
    START_SESSION["Start Session<br/>E08 (TODO)"]:::todo -.future action.-> SESSION_DETAIL

    classDef todo fill:#fff3cd,stroke:#d39e00,color:#5c4400;
```

## 6) Trust, Safety & Notifications (P5 + Cross-cutting)

```mermaid
flowchart TD
    ACTION[Any Core Action] --> NOTIFY_SEND[Send Notification<br/>X01]
    NOTIFY_SEND --> NOTIFY_RECEIVE[Receive Notification<br/>X02]
    NOTIFY_RECEIVE --> NOTIFY_HISTORY[Notification History<br/>X04]

    ACTION --> RATING[Submit Rating<br/>T01]
    RATING --> TRUST[Trust Score Updated<br/>T06]
    TRUST --> TRUST_FILTER[Trust-based Discovery Filter<br/>T08]

    ACTION --> REPORT_USER[Report User<br/>X05]
    REPORT_USER --> SAFETY_QUEUE[Admin Moderation Queue]
```

## 7) End-to-End Primary User Journey

```mermaid
flowchart TD
    AUTH[Register / Login] --> PROFILE[Create Profile]
    PROFILE --> SKILL[Post Offer/Request]
    SKILL --> MATCH[Discover + Match]
    MATCH --> ACCEPT[Accept Match]
    ACCEPT --> CHAT[Open Chat]
    CHAT --> TERMS[Create/Accept Agreement]
    TERMS --> SESSION[Schedule Session]
    SESSION --> COMPLETE[Complete Session]
    COMPLETE --> FEEDBACK[Rate + Review]
    FEEDBACK --> TRUST["Improved Trust & Better Future Matches"]
```

## Notes
- Node labels include use-case IDs from `docs/use_case_tracker.md`.
- Dashed links indicate planned TODO branches not yet implemented.
- These diagrams are intentionally screen-oriented for design/review workflows.
