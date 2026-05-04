# Skills Ecosystem Flow

**Feature**: Skill Creation & Management, Discovery System, Skill Validation
**Screens**: 7 (7 existing + 0 pending)
**Status**: Complete

## Diagram

```mermaid
flowchart TD
    classDef done fill:#d4edda,stroke:#28a745,color:#155724
    classDef pending fill:#fff3cd,stroke:#ffc107,color:#856404
    classDef decision fill:#f8f9fa,stroke:#6c757d,stroke-width:2px

    HomePage(["Dashboard"]):::done

    subgraph Creation["Skill Creation"]
        CreateOffer["Create Skill Offer\n/skills/create"]:::done
        CreateRequest["Create Skill Request\n/skills/create-request"]:::done
        EditSkill["Edit Skill\n/skills/edit"]:::done
        SkillDetails["Skill Details\n/skills/details/:id"]:::done
    end

    subgraph Discovery["Discovery"]
        BrowseFeed["Browse Skills Feed\n/skills/feed"]:::done
        SearchSkills["Search Skills\n/skills/search"]:::done
        FilterSkills["Filter Skills\n/skills/filter"]:::done
        SavedSearches["Saved Searches\n/skills/saved-searches/:uid"]:::done
    end

    HomePage --> CreateOffer
    HomePage --> CreateRequest
    HomePage --> BrowseFeed
    HomePage --> SearchSkills

    BrowseFeed --> SkillDetails
    SearchSkills --> SkillDetails
    CreateOffer --> EditSkill
    CreateRequest --> EditSkill
    SkillDetails --> EditSkill
    FilterSkills --> BrowseFeed
    SavedSearches --> SearchSkills
```

## Flow Description
Users can offer skills they want to teach or request skills they want to learn. Both flows use the same `CreateSkillOfferPage` differentiated by a `SkillType` parameter. The Browse Feed shows all available skills with cards; tapping one opens the details page. Search and Filter complement browsing. Skills can be edited, cloned, archived, or deleted from their details page. Saved searches allow users to quickly re-run specific queries.

## Screen Inventory

| Screen | Route | Status | Use Cases |
|--------|-------|--------|-----------|
| Create Skill Offer | `/skills/create` | ✅ Existing | S01 |
| Create Skill Request | `/skills/create-request` | ✅ Existing | S02 |
| Edit Skill | `/skills/edit` | ✅ Existing | S03 |
| Skill Details | `/skills/details/:id` | ✅ Existing | S11 |
| Browse Skills Feed | `/skills/feed` | ✅ Existing | S10 |
| Search Skills | `/skills/search` | ✅ Existing | S08 |
| Filter Skills | `/skills/filter` | ✅ Existing | S09 |
| Saved Searches | `/skills/saved-searches/:uid` | ✅ Existing | S12 |

## Notes
- Skill CRUD operations (S04 delete, S05 fetch, S06 clone, S07 archive) are handled via bloc/dialogs, not dedicated pages
- S13 (Suggest Category) and S14 (Verify Expertise) are AI/backend features without dedicated pages
- Feed cards and search results currently have commented-out `onTap` navigation to details
