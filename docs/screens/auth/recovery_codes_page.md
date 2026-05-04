# Recovery Codes Page

**Status**: Existing
**Route**: `/recovery-codes`
**Priority**: P1
**Use Cases Covered**: F09

## Purpose
Allows users to generate and view account recovery codes. Initial state shows a prompt to generate codes. After generation (`AuthRecoveryCodesGenerated`), displays the list of recovery codes in monospace font with numbered entries and copy buttons. Each code can be used once. Codes are regenerated on each "Generate Codes" action.

## Layout Description
```
+------------------------------------------+
|  [AppBar: "Recovery Codes"]              |
+------------------------------------------+
|                                          |
|  (Initial state - no codes generated)    |
|                                          |
|         [Security Icon - 64px]           |
|                                          |
|        Generate Recovery Codes           |
|                                          |
|  Recovery codes can be used to regain    |
|  access to your account if you lose your |
|  password and cannot access your email.  |
|                                          |
|  [   Generate Codes   ]                  |
|                                          |
|  (After generation)                      |
|  ==================                      |
|        [Warning Icon - 48px]             |
|                                          |
|          Save These Codes                |
|    Each code can only be used once.      |
|                                          |
|  +------------------------------------+  |
|  | 1. ABC-DEF-GHI           [copy]   |  |
|  | 2. JKL-MNO-PQR           [copy]   |  |
|  | 3. STU-VWX-YZA           [copy]   |  |
|  | 4. BCD-EFG-HIJ           [copy]   |  |
|  +------------------------------------+  |
|                                          |
|  [      I've Saved Them              ]   |
+------------------------------------------+
```

## Component Breakdown
| Component | Type | Description |
|-----------|------|-------------|
| Scaffold | Structural | Root widget with AppBar (title: "Recovery Codes") |
| BlocConsumer<AuthBloc, AuthState> | State Management | Handles `AuthRecoveryCodesGenerated`, `AuthLoading`, and `AuthError` |
| _GeneratePrompt | Widget | Initial state: icon, title, description, and "Generate Codes" `ElevatedButton.icon` |
| _CodesDisplay | Widget | Post-generation: warning icon, instruction text, scrollable code list with copy buttons, and "I've Saved Them" button |
| Card | Container | Wraps the codes list view |
| ListView.separated | List | Numbered code entries with `Divider` separators |
| Row (code entry) | Display | Index number, monospace code text, and copy `IconButton` |
| SnackBar | Feedback | "Code copied" on copy action; error messages |

## States - Loading, Empty, Error, Data Populated
| State | Description |
|-------|-------------|
| Loading | Centered `CircularProgressIndicator` |
| Empty (pre-generation) | `_GeneratePrompt` shown with generate button |
| Error | Snackbar with error message |
| Data Populated | `_CodesDisplay` shown with list of recovery codes, each with copy-to-clipboard functionality |

## Navigation Connections
- **Entry**: `/recovery-codes` (protected route)
- On "I've Saved Them": `Navigator.of(context).pop()`
- AuthBloc event dispatched: `AuthGenerateRecoveryCodesRequested`
