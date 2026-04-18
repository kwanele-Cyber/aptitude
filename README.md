# Aptitude

Aptitude is a Community Skill Sharing App.

# Developer Workflow: Protecting the Main Branch

please don't work directly on the main branch. To keep our builds stable and our deployment path clear, please follow these steps whenever you are implementing a new use case:

## 1. Sync Your Local Main
Before you start any new work, always make sure you have the most recent updates from the rest of the team.

* `git checkout main`
* `git pull origin main`

## 2. Create a Dedicated Feature Branch
Never code on `main`. Always create a fresh branch for your specific task using our naming conventions (e.g., `feature/`, `bugfix/`, or `hotfix/`).

* `git checkout -b feature/your-usecase-name`

## 3. Build and Commit
Work on your implementation and commit your changes locally. Try to keep your commit messages descriptive so we know what changed.

* `git add .`
* `git commit -m "feat: description of the usecase implementation"`

## 4. Push and Open a Pull Request (PR)
Once you're ready, push your branch to the repository. Do not merge it yourself; open a PR so we can review the logic together.

* `git push origin feature/your-usecase-name`

**Final Step:** Head over to GitHub/GitLab and open a **Pull Request** to merge your branch into `main`.