# Platform Rules Page
**Status**: Pending
**Route**: `/rules`
**Priority**: P5
**Use Cases Covered**: X13, X14
## Purpose
Present the platform's community guidelines and rules in a readable, styled markdown format. Users must scroll to the bottom and acknowledge the rules before they can proceed with certain actions (e.g., creating an agreement, filing a dispute).
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
| [Back]  Platform Rules                   |
+------------------------------------------+
|                                           |
|  Community Guidelines                     |
|  ==========================              |
|                                           |
|  Welcome to Aptitude! To maintain a      |
|  safe and productive learning            |
|  environment, please follow these        |
|  rules.                                  |
|                                           |
|  1. Be Respectful                        |
|  --------------------------------------- |
|  Treat all community members with        |
|  kindness and respect. Harassment,       |
|  discrimination, or hate speech of any   |
|  kind will not be tolerated.             |
|                                           |
|  2. Show Up on Time                      |
|  --------------------------------------- |
|  Sessions are commitments. If you        |
|  cannot make a session, notify your      |
|  partner at least 24 hours in advance.   |
|  Repeated no-shows will affect your      |
|  trust score and may result in account   |
|  suspension.                             |
|                                           |
|  3. Keep Communication on Platform       |
|  --------------------------------------- |
|  All communication related to skill      |
|  exchanges should remain on the          |
|  platform. Taking conversations off-     |
|  platform violates our safety policies.  |
|                                           |
|  4. No Financial Transactions            |
|  --------------------------------------- |
|  Aptitude is for skill exchange only.    |
|  No monetary transactions are permitted  |
|  between users for services.             |
|                                           |
|  ... (continued) ...                     |
|                                           |
|  +--------------------------------------+ |
|  | [☐] I have read and agree to the   | |
|  |      Platform Rules                  | |
|  +--------------------------------------+ |
|                                           |
|  [Continue]                                |
+------------------------------------------+
```

## Component Breakdown
1. **AppBar**: "Platform Rules" title with back button.
2. **Styled Markdown Content**: Rules rendered with proper typography:
   - Section headings (numbered)
   - Divider lines between sections
   - Bold/italic emphasis for key terms
   - Bullet points for sub-rules
   - Iconography for rule categories (optional)
   - Callout boxes for important notices
   - Links to support pages
3. **Scroll Progress Indicator**: Shows how far the user has scrolled through the rules.
4. **Acknowledgement Checkbox**: "I have read and agree to the Platform Rules" checkbox positioned at the bottom of the content, after the last rule. Disabled until all content has been scrolled through at least once.
5. **Continue Button**: Primary action, disabled until checkbox is checked. Only shown in mandatory contexts (e.g., registration, agreement creation). In view-only mode (from settings), the button is hidden or shows "Done".

## States (Loading, Empty, Error, Data)
- **Loading**: Skeleton markdown content with heading and paragraph placeholders with shimmer.
- **Error**: "Could not load platform rules. [Retry]".
- **Data**: Full scrollable markdown content with proper styling. Checkbox at bottom. Scroll progress tracked. Continue button active only when acknowledged. In view-only mode (from settings/help), the acknowledgement section is hidden.

## Navigation Connections
- **Incoming**: From Registration flow (mandatory), from Agreement Creation (mandatory), from Settings "Platform Rules", from Dispute flow (mandatory).
- **Outgoing**: Continue -> Proceed to next step in the flow (registration, agreement creation, etc.). Back -> Return to previous screen without acknowledgment (may show warning if mandatory).

## Future Considerations
- Multi-language rule display
- Version tracking (show "Last updated: Date" and rule version number)
- Change highlights when rules are updated (show what changed)
- Condensed vs full view toggle
- Age-restricted content warnings
- Rule search functionality
- Bookmark specific rules for reference
- Download rules as PDF
- Compliance tracking per user (which versions they acknowledged)
- Quiz mode to confirm understanding of key rules
