# Auth Flow

**Feature**: Authentication & Identity
**Screens**: 13 (13 existing + 0 pending)
**Status**: Complete

## Diagram

```mermaid
flowchart TD
    classDef done fill:#d4edda,stroke:#28a745,color:#155724
    classDef pending fill:#fff3cd,stroke:#ffc107,color:#856404
    classDef admin fill:#cce5ff,stroke:#007bff,color:#004085
    classDef decision fill:#f8f9fa,stroke:#6c757d,stroke-width:2px

    AppLaunch(["App Launch"]):::done
    SplashPage["Splash Page"]:::done
    AuthCheck{"Auth Check"}:::decision
    Authenticated{"Authenticated?"}:::decision
    HomePage["Dashboard / Home"]:::done
    LoginPage["Login Page"]:::done
    RegisterPage["Register Page"]:::done
    ForgotPasswordPage["Forgot Password"]:::done
    AccountRecoveryPage["Account Recovery"]:::done
    RecoveryCodesPage["Recovery Codes"]:::done
    TwoFactorSetupPage["2FA Setup"]:::done
    TwoFactorVerifyPage["2FA Verification"]:::done
    ChangePasswordPage["Change Password"]:::done
    ProfilePage["Profile Page"]:::done
    UserProfilePage["User Profile (view)"]:::done
    ExportDataPage["Export Data"]:::done
    Logout{"Logout / Delete"}:::decision

    AppLaunch --> SplashPage
    SplashPage --> AuthCheck
    AuthCheck --> Authenticated
    Authenticated -->|"No"| LoginPage
    Authenticated -->|"Yes"| HomePage
    LoginPage --> RegisterPage
    LoginPage --> ForgotPasswordPage
    LoginPage --> AccountRecoveryPage
    AccountRecoveryPage --> RecoveryCodesPage
    LoginPage -->|"2FA required"| TwoFactorVerifyPage
    TwoFactorVerifyPage -->|"verified"| HomePage
    HomePage --> ProfilePage
    ProfilePage --> ChangePasswordPage
    ProfilePage --> TwoFactorSetupPage
    ProfilePage --> ExportDataPage
    ProfilePage -->|"view user"| UserProfilePage
    ProfilePage --> Logout
    Logout -->|"logout"| LoginPage
    Logout -->|"delete"| LoginPage

    LoginPage -->|"on success"| HomePage
    LoginPage -->|"on error"| LoginPage
    RegisterPage -->|"on success"| HomePage
    RegisterPage -->|"on error"| RegisterPage
```

## Flow Description
On app launch, the Splash Page triggers an auth check. If the user has a valid session, they go directly to the Dashboard. If not, they land on the Login page. Login supports email/password authentication, with links to registration, password reset, and account recovery. After successful login, users with 2FA enabled must verify via TOTP before accessing the dashboard. The Profile page provides access to all authenticated settings.

## Screen Inventory

| Screen | Route | Status | Use Cases |
|--------|-------|--------|-----------|
| Splash Page | `/splash` | ✅ Existing | F01 |
| Login Page | `/login` | ✅ Existing | F03 |
| Register Page | `/register` | ✅ Existing | F02 |
| Forgot Password | `/forgot-password` | ✅ Existing | F08 |
| Account Recovery | `/account-recovery` | ✅ Existing | F09 |
| Recovery Codes | `/recovery-codes` | ✅ Existing | F09 |
| 2FA Setup | `/2fa-setup` | ✅ Existing | F10 |
| 2FA Verification | `/2fa-verify/:uid` | ✅ Existing | F10 |
| Dashboard / Home | `/home` | ✅ Existing | F06 |
| Profile Page | `/profile` | ✅ Existing | F11, F12, F13, F15 |
| User Profile | `/profile/:uid` | ✅ Existing | F14 |
| Change Password | `/change-password` | ✅ Existing | F08 |
| Export Data | `/export-data` | ✅ Existing | F16 |

## Notes
- Auth check happens via `AuthCheckRequested` event dispatched in `main.dart`
- Router guards: `AuthInitial`/`AuthLoading` = no redirect; `AuthUnauthenticated` = redirect to `/login`; `AuthAuthenticated` = allow
- Error states on login/register show snackbar messages and stay on the form
