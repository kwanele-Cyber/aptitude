# Centralized Development Framework

This document outlines the centralized development framework for this project, designed to ensure a scalable, maintainable, and testable codebase. The framework is built around a core set of components that manage data and business logic, with a clear separation of concerns.

## Core Principles

*   **Separation of Concerns:** UI, business logic, and data access are kept separate.
*   **Dependency Inversion:** High-level modules do not depend on low-level modules; both depend on abstractions.
*   **Single Responsibility Principle:** Each class has a single, well-defined responsibility.

## Architecture Overview

The framework follows a layered architecture, inspired by Clean Architecture and MVVM principles.

```
+-------------------+
|       View        | (UI Layer)
+-------------------+
        |
        v
+-------------------+
|     ViewModel     | (Presentation Layer)
+-------------------+
        |
        v
+-------------------+
|    Repository     | (Domain/Data Layer)
+-------------------+
        |
        v
+-------------------+
|  Database Service | (Data Source Layer)
+-------------------+
        |
        v
+-------------------+
|     Database      | (e.g., Firebase)
+-------------------+
```

## Core Components

### 1. Models (`lib/core/data/models/`)

*   Plain Dart objects (PDOs) that represent the data entities of the application.
*   Examples: `User`, `Skill`, `Post`, `Session`.
*   They are immutable and contain no business logic.
*   These models are used throughout the application, from the database layer to the UI layer.

### 2. Database Service (`lib/core/services/interfaces/database_interface.dart`)

*   An abstract class that defines the contract for all database operations (CRUD - Create, Read, Update, Delete).
*   This abstraction allows the underlying database technology (e.g., Firebase Firestore, a REST API, a local SQLite database) to be swapped out with minimal impact on the rest of the application.
*   A concrete implementation of this interface (e.g., `FirebaseService` in `lib/core/services/firebase_service.dart`) handles the specific details of interacting with the chosen database.

### 3. Repositories (`lib/core/data/repositories/`)

*   The cornerstone of this framework. Repositories act as a centralized point of access to the application's data.
*   Each repository corresponds to a specific data model (e.g., `UserRepository`, `SessionRepository`).
*   **Responsibilities:**
    *   Wrap the `DatabaseService` to provide a high-level API for data access.
    *   Centralize all data logic for a specific model. This includes fetching, creating, updating, and deleting data.
    *   Handle data caching, if necessary.
    *   Transform data from the database format to the application's model format (and vice versa).
*   Repositories are the *only* part of the application (outside of the service layer itself) that should directly interact with the `DatabaseService`.

### 4. ViewModels / Use Cases (`lib/usecase/*/`)

*   These components contain the application's business logic.
*   They depend on one or more repositories to get the data they need.
*   They **do not** know where the data comes from (Firebase, local cache, etc.). They simply ask the repository for it.
*   They process the data and expose it to the View layer in a format that is easy to consume.
*   They handle user interactions and call the appropriate repository methods to update the application's state.

## Data Flow Example: Adding a New Skill

1.  **View:** The user clicks a button in the UI to add a new skill.
2.  **ViewModel:** The `AddSkillViewModel`'s `addSkill` method is called.
3.  **Repository:** The `ViewModel` calls `skillRepository.addSkill(newSkill)`.
4.  **Database Service:** The `SkillRepository` uses its instance of the `DatabaseService` to write the new skill to the database (e.g., `databaseService.addDocument('skills', newSkill.toJson())`).
5.  **Database:** The new skill is persisted.
6.  **Feedback:** The result of the operation flows back up the chain, and the UI is updated to reflect the change.

## Benefits of this Framework

*   **Testability:** Because dependencies are injected (e.g., passing a `DatabaseService` to a `Repository`), we can easily mock dependencies in our tests. We can test a `ViewModel` by providing a mock `Repository`, and we can test a `Repository` by providing a mock `DatabaseService`.
*   **Maintainability:** Data logic is centralized in the repositories. If we need to change how we fetch or store user data, we only need to modify `UserRepository`. The rest of the application remains unchanged.
*   **Scalability:** As new features are added, they can easily leverage the existing repositories. If a new data entity is needed, a new model and repository can be created, following the established pattern.
*   **Flexibility:** The underlying database can be changed by simply creating a new implementation of the `DatabaseService` interface, without affecting the repositories or view models.