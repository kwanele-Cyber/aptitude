# Repository Wrappers

This document details the repository wrappers for each data model. These repositories are a core component of our centralized development framework, providing a high-level abstraction for data access and manipulation. Each repository wraps the `DatabaseService`, ensuring that all database interactions are centralized and consistent.

## Core Responsibilities

As outlined in the `development_framework.md`, each repository is responsible for:

*   **Wrapping the `DatabaseService`:** Providing a model-specific API for data operations.
*   **Centralizing Data Logic:** Handling all CRUD (Create, Read, Update, Delete) operations for a specific model.
*   **Data Transformation:** Converting data between the database format and the application's data models.

## Repository Implementations

Below are the outlines for the repositories corresponding to each of our data models.

### 1. UserRepository

*   **Model:** `User` (`lib/core/data/models/user.dart`)
*   **Responsibilities:** Manages all user-related data, including profiles and authentication information.
*   **Methods:**
    *   `Future<User?> getUser(String uid)`: Retrieves a user's profile by their unique ID.
    *   `Future<void> createUser(User user)`: Creates a new user profile.
    *   `Future<void> updateUser(User user)`: Updates an existing user's profile.
    *   `Future<void> deleteUser(String uid)`: Deletes a user's profile.

### 2. SkillRepository

*   **Model:** `Skill` (`lib/core/data/models/skill.dart`)
*   **Responsibilities:** Manages the skills that users can add to their profiles or request from others.
*   **Methods:**
    *   `Future<Skill?> getSkill(String skillId)`: Retrieves a specific skill by its ID.
    *   `Future<List<Skill>> getAllSkills()`: Retrieves a list of all available skills.
    *   `Future<void> addSkill(Skill skill)`: Adds a new skill to the database.
    *   `Future<void> updateSkill(Skill skill)`: Updates an existing skill.

### 3. PostRepository

*   **Model:** `Post` (`lib/core/data/models/post.dart`)
*   **Responsibilities:** Manages user-generated posts, which may be requests for skills or offers of skills.
*   **Methods:**
    *   `Future<Post?> getPost(String postId)`: Retrieves a single post by its ID.
    *   `Future<List<Post>> getPostsForUser(String uid)`: Retrieves all posts made by a specific user.
    *   `Future<List<Post>> getPostsBySkill(String skillId)`: Retrieves all posts related to a specific skill.
    *   `Future<void> createPost(Post post)`: Creates a new post.
    *   `Future<void> updatePost(Post post)`: Updates an existing post.
    *   `Future<void> deletePost(String postId)`: Deletes a post.

### 4. SessionRepository

*   **Model:** `Session` (`lib/core/data/models/session.dart`)
*   **Responsibilities:** Manages the learning/collaboration sessions between users.
*   **Methods:**
    *   `Future<Session?> getSession(String sessionId)`: Retrieves a session by its ID.
    *   `Future<List<Session>> getSessionsForUser(String uid)`: Retrieves all sessions a user is a part of.
    *   `Future<void> createSession(Session session)`: Creates a new session.
    *   `Future<void> updateSession(Session session)`: Updates a session's details (e.g., time, status).

### 5. ReviewRepository

*   **Model:** `Review` (`lib/core/data/models/review.dart`)
*   **Responsibilities:** Manages reviews that users can leave for each other after a session.
*   **Methods:**
    *   `Future<List<Review>> getReviewsForUser(String uid)`: Retrieves all reviews for a specific user.
    *   `Future<void> addReview(Review review)`: Adds a new review.

### 6. SkillMatchRepository

*   **Model:** `SkillMatch` (`lib/core/data/models/skill_match.dart`)
*   **Responsibilities:** Manages potential matches between users based on their skills and requests.
*   **Methods:**
    *   `Future<List<SkillMatch>> findMatches(String uid)`: Finds potential skill matches for a given user.
    *   `Future<void> createMatch(SkillMatch match)`: Creates a record of a skill match.
