# Admin Flow

**Feature**: Admin Core System, Moderation, Enforcement, Operations, Communication, Database Administration
**Screens**: 12 (0 existing + 12 pending)
**Status**: Planned

## Diagram

```mermaid
flowchart TD
    classDef done fill:#d4edda,stroke:#28a745,color:#155724
    classDef pending fill:#fff3cd,stroke:#ffc107,color:#856404
    classDef admin fill:#cce5ff,stroke:#007bff,color:#004085
    classDef decision fill:#f8f9fa,stroke:#6c757d,stroke-width:2px

    AdminLogin["Admin Login"]:::admin
    AdminDashboard["Admin Dashboard"]:::admin

    subgraph Core["Core Admin"]
        RoleManagement["Role Management"]:::admin
        AuditLog["Audit Log"]:::admin
        SystemConfig["System Config"]:::admin
    end

    subgraph Moderation["User & Content Moderation"]
        UserManagement["User Management"]:::admin
        ContentModeration["Content Moderation"]:::admin
        FlaggingQueue["Flagging Queue"]:::admin
        BulkActions["Bulk Actions"]:::admin
    end

    subgraph Enforcement["Enforcement"]
        ApplyPenalties["Apply Penalties"]:::admin
        DisputeManagement["Dispute Management"]:::admin
        TrustOverrides["Trust Adjustments"]:::admin
        AppealReview["Appeal Review"]:::admin
        RestoreAccount["Restore Account"]:::admin
    end

    subgraph Operations["Platform Operations"]
        ViewAnalytics["View Analytics"]:::admin
        ExportData["Export System Data"]:::admin
        CategoryManagement["Category Management"]:::admin
    end

    subgraph Communication["Admin Communication"]
        Broadcast["Send Broadcast"]:::admin
        SupportRequests["Support Requests"]:::admin
        Announcements["Announcement Management"]:::admin
    end

    subgraph Database["Database Administration"]
        EmergencyAssign["Emergency Admin Assign"]:::admin
        ReadOnlyDB["Read-Only DB Access"]:::admin
        TempAdmin["Temporary Admin Grant"]:::admin
        RecoveryKey["Recovery Key Management"]:::admin
    end

    AdminLogin --> AdminDashboard
    AdminDashboard --> Core
    AdminDashboard --> Moderation
    AdminDashboard --> Enforcement
    AdminDashboard --> Operations
    AdminDashboard --> Communication
    AdminDashboard --> Database
```

## Flow Description
The admin panel provides full system management. Admins log in with elevated privileges and access a dashboard with KPIs. Core features include user management (view, suspend, delete), content moderation (queue, flag, bulk actions), dispute resolution, analytics, and system configuration. Communication tools allow broadcasting announcements. Database administration features handle emergency access, read-only analytics access, and recovery key management.

## Screen Inventory

| Screen | Route | Status | Use Cases |
|--------|-------|--------|-----------|
| Admin Login | `/admin/login` | ❌ Todo | A01 |
| Admin Dashboard | `/admin` | ❌ Todo | A02 |
| Role Management | `/admin/roles` | ❌ Todo | A03 |
| Audit Log | `/admin/audit` | ❌ Todo | A04 |
| User Management | `/admin/users` | ❌ Todo | A05 |
| Content Moderation | `/admin/moderation` | ❌ Todo | A06-A10 |
| Enforcement/Penalties | `/admin/penalties` | ❌ Todo | A11-A15 |
| Analytics | `/admin/analytics` | ❌ Todo | A16-A17 |
| System Config | `/admin/config` | ❌ Todo | A18 |
| Category Management | `/admin/categories` | ❌ Todo | A19 |
| Broadcast | `/admin/broadcast` | ❌ Todo | A20-A22 |
| Database Admin | `/admin/database` | ❌ Todo | A23-A26 |

## Notes
- Admin login requires role-based access control (RBAC)
- Audit log is immutable — all admin actions are recorded
- Penalties follow 3-strike rule: warning → suspension → permanent ban
- Emergency admin assignment uses multi-step verification
