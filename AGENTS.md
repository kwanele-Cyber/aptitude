# Codex Agent Instructions

This repository is a Flutter/Firebase app for the Aptitude community skill-sharing product.

## Working Rules

- Do not work directly on `master` for feature work. Create a branch such as `feature/<short-name>`, `bugfix/<short-name>`, or `hotfix/<short-name>`.
- Keep changes scoped to the requested task and preserve unrelated local edits.
- Prefer existing architecture and naming patterns in `lib/core` and `lib/usecase`.
- Update or add tests when behavior changes.
- Do not commit generated secrets, Firebase private keys, or local machine configuration.

## Useful Commands

Run these before opening or updating a PR when the toolchain is available:

```powershell
flutter pub get
dart format lib test
flutter analyze
flutter test
```

## GitHub Coordination

- Use pull requests for all Cloud Codex work.
- Include a short summary, tests run, and any remaining risks in the PR description.
- If a task starts from a GitHub issue, link the issue in the PR body.
- If tests cannot be run locally, say exactly which command could not run and why.
