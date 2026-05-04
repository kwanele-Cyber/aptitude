# Admin Login Page
**Status**: Pending
**Route**: `/admin/login`
**Priority**: Admin
**Use Cases Covered**: A01
## Purpose
Provide a dedicated login portal for administrators with elevated credentials and role-based access verification. This is separate from the regular user login and includes additional security measures.
## Layout Description (include ASCII wireframe)

```
+------------------------------------------+
|                                           |
|                                           |
|           ⚙️ Admin Portal                |
|              Aptitude                     |
|                                           |
|  +--------------------------------------+ |
|  |                                      | |
|  |  Admin Email                         | |
|  |  [____________________________]     | |
|  |                                      | |
|  |  Password                            | |
|  |  [____________________________]     | |
|  |                                      | |
|  |  [🔒 Login as Admin]                | |
|  |                                      | |
|  |  [Forgot password?]                 | |
|  +--------------------------------------+ |
|                                           |
|  +--------------------------------------+ |
|  | ℹ️ This portal is for authorized    | |
|  | administrators only. Unauthorized   | |
|  | access attempts are logged and      | |
|  | monitored.                          | |
|  +--------------------------------------+ |
|                                           |
|  [Back to Main App]                       |
|                                           |
+------------------------------------------+
```

## Component Breakdown
1. **Admin Branding**: "Admin Portal" header with gear icon. Distinct from user-facing branding.
2. **Login Form**: Email input field with validation. Password input with show/hide toggle. "Login as Admin" primary button with loading state.
3. **Security Notice**: Warning banner about unauthorized access monitoring.
4. **Forgot Password Link**: Triggers admin password reset flow (email-based).
5. **Back to Main App Link**: Returns to regular user app.
6. **Two-Factor Authentication** (post-login step if enabled): TOTP code input field after successful password verification.

## States (Loading, Empty, Error, Data)
- **Loading**: Button shows spinner, inputs disabled during authentication.
- **Error - Invalid Credentials**: "Invalid email or password." with field-level error styling. "Too many attempts" lockout message after 5 failed attempts with cooldown timer.
- **Error - Not Authorized**: "This account does not have admin privileges." with contact support message.
- **Error - 2FA Required**: TOTP input field appears after password verification. "Invalid 2FA code" error on failure.
- **Data**: Clean login form. On success, redirects to admin dashboard.

## Navigation Connections
- **Incoming**: From admin URL direct access, from main app footer "Admin" link.
- **Outgoing**: Login success -> `/admin` (Admin Dashboard). Forgot password -> password reset flow (email sent). Back to Main App -> `/` (user home).

## Future Considerations
- Biometric admin authentication (fingerprint/face)
- Session timeout for admin panel (shorter than user sessions)
- IP-based access restrictions
- Admin audit log entry on each login
- Emergency access protocol (break-glass procedure)
- Hardware security key support (WebAuthn)
- Admin session management (view active sessions)
