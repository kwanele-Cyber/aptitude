# Two-Factor Setup Page

**Status**: Existing
**Route**: `/2fa-setup`
**Priority**: P0
**Use Cases Covered**: F10

## Purpose
Allows users to enable or disable two-factor authentication on their account. Shows an informational banner about 2FA, a toggle switch to enable/disable, and a 6-digit PIN input field that appears when enabled. PIN is saved via `UpdateProfileUsecase` with `twoFactorEnabled` and `twoFactorPin` fields. Pre-populates from the authenticated user entity's existing 2FA settings. **Note**: This page manages a PIN-based 2FA rather than QR-code TOTP setup.

## Layout Description
```
+------------------------------------------+
|  [AppBar: "Two-Factor Authentication"]   |
+------------------------------------------+
|                                          |
|  +------------------------------------+  |
|  | [shield icon] Two-Factor           |  |
|  | Authentication adds an extra layer |  |
|  | of security to your account...     |  |
|  +------------------------------------+  |
|                                          |
|  Enable 2FA                  [Switch]    |
|  Secure your account with a PIN          |
|                                          |
|  (if enabled):                           |
|  Set 6-Digit PIN                         |
|  +------------------------------------+  |
|  |  _  _  _  _  _  _                  |  |
|  +------------------------------------+  |
|                                          |
|                                          |
|  [         Save Settings            ]    |
|                                          |
+------------------------------------------+
```

## Component Breakdown
| Component | Type | Description |
|-----------|------|-------------|
| Scaffold | Structural | Root widget with AppBar (title: "Two-Factor Authentication") |
| Column | Layout | Vertical layout with all sections |
| Container (info banner) | Display | Purple-tinted card with shield icon and explanation text |
| Row (enable label + Switch) | Input | Toggle switch to enable/disable 2FA |
| TextField (PIN, conditional) | Input | 6-digit numeric input, obscure text, large font (24px, letter spacing 8), max length 6 |
| ElevatedButton ("Save Settings") | Action | Calls `UpdateProfileUsecase` with 2FA data, shows spinner |

## States - Loading, Empty, Error, Data Populated
| State | Description |
|-------|-------------|
| Loading | Save button shows `CircularProgressIndicator` while `_saving` is true |
| Empty | Switch defaults to user's existing `twoFactorEnabled` value; PIN field pre-filled with existing `twoFactorPin` |
| Error | Red snackbar on failed save ("Failed to save settings"); client-side validation if PIN not exactly 6 digits |
| Data Populated | Switch reflects current 2FA status; PIN field filled if previously set |

## Navigation Connections
- **Entry**: `/2fa-setup` (protected route, accessible from Profile menu)
- On success: Green snackbar "Security settings updated" and `Navigator.pop(context)`
- On error: Red snackbar; user remains on page
- Uses: `UpdateProfileUsecase` via `di.sl<UpdateProfileUsecase>()` with params `{uid, twoFactorEnabled, twoFactorPin}`
