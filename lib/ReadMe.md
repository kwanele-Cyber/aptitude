# MVVM Architecture with Flutter

This project follows the Model-View-ViewModel (MVVM) architectural pattern. This pattern helps to separate the user interface (View) from the business logic and data (Model), with a ViewModel acting as the intermediary.

## Core Concepts

- **Model**: Represents the data and business logic of the application. In this project, models can be found in the `core` directory (for shared models) and within each feature's directory under `usecase` for feature-specific models.

- **View**: The UI of the application. Views are responsible for displaying data and capturing user input. In our structure, Views are located in the `view` sub-directory of each feature folder (e.g., `lib/usecase/auth/view`).

- **ViewModel**: Acts as a bridge between the Model and the View. The ViewModel retrieves data from the Model and exposes it to the View in a display-friendly format. It also handles user interactions from the View and updates the Model accordingly. ViewModels are typically located in the feature's root directory (e.g., `lib/usecase/auth`).

## Implementation in this Project

Our project structure is designed to support the MVVM pattern:

- `lib/core`: Contains the core, reusable components of the application. This is where you'll find shared models, networking clients, and other utilities.

- `lib/usecase`: This directory is organized by features. Each feature-specific folder contains the business logic for that feature. This is where you'll find the ViewModels and feature-specific Models.

- `lib/usecase/<feature>/view`: This sub-directory contains the UI components (Views) for a specific feature.

## Routing with go_router

This project uses the `go_router` package for declarative routing. The routing configuration is centralized in `lib/core/routing/router.dart`.

### Defining Routes

To add or modify routes, edit the `router` object in `lib/core/routing/router.dart`. Each route is an instance of `GoRoute`.

```dart
// lib/core/routing/router.dart

final GoRouter router = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
      },
    ),
    // Route with a parameter
    GoRoute(
      path: '/user/:userId',
      builder: (BuildContext context, GoRouterState state) {
        final userId = state.pathParameters['userId'];
        return UserProfilePage(userId: userId!);
      },
    ),
  ],
);
```

### Navigating Between Screens

To navigate to a different screen, use the `go_router` extension methods on `BuildContext`.

-   **`context.go()`**: Navigates to a new screen and replaces the current screen in the navigation stack.

    ```dart
    // Navigate to the login page
    context.go('/login');
    ```

-   **`context.push()`**: Pushes a new screen onto the navigation stack. The user can go back to the previous screen.

    ```dart
    // Navigate to the user profile page with a parameter
    context.push('/user/123');
    ```

### Integrating with `main.dart`

To enable `go_router`, the `main.dart` file needs to be configured to use the `.router` constructor for `MaterialApp`.

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'core/routing/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Flutter MVVM',
    );
  }
}
```

## Example: Authentication Feature

Let's consider the authentication feature as an example:

1.  **Model** (`lib/core/models/user.dart` or `lib/usecase/auth/user_model.dart`):

    ```dart
    class User {
      final String id;
      final String email;

      User({required this.id, required this.email});
    }
    ```

2.  **ViewModel** (`lib/usecase/auth/auth_viewmodel.dart`):

    ```dart
    import 'package:flutter/foundation.dart';

    class AuthViewModel with ChangeNotifier {
      // ... (dependency injection for auth repository)

      bool _isLoading = false;
      bool get isLoading => _isLoading;

      Future<void> login(String email, String password) async {
        _isLoading = true;
        notifyListeners();

        // ... (call to auth repository)

        _isLoading = false;
        notifyListeners();
      }
    }
    ```

3.  **View** (`lib/usecase/auth/view/login_page.dart`):

    ```dart
    import 'package:flutter/material.dart';
    import 'package:provider/provider.dart';
    import '../auth_viewmodel.dart';

    class LoginPage extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        final authViewModel = Provider.of<AuthViewModel>(context);

        return Scaffold(
          appBar: AppBar(title: Text('Login')),
          body: // ... UI code that uses authViewModel.isLoading and calls authViewModel.login
        );
      }
    }
    ```

## Implementing a New Feature

When adding a new feature to the application, follow these steps to maintain consistency with the MVVM architecture:

1.  **Create a Feature Directory**: Inside the `lib/usecase/` directory, create a new directory named after your feature (e.g., `lib/usecase/profile/`).

2.  **Define the Model(s)**: Before creating a new model, check if an existing model in `lib/core/models/` can be reused. If the data is specific to your new feature, create the model file(s) inside your new feature directory (e.g., `lib/usecase/profile/profile_model.dart`).

3.  **Create the ViewModel**: Create a ViewModel class file in the root of your feature directory (e.g., `lib/usecase/profile/profile_viewmodel.dart`). This class should handle the business logic for the feature, interact with repositories or services, and manage the state. It should extend `ChangeNotifier` to notify the UI of any data changes.

4.  **Create the View(s)**: Create a `view` subdirectory within your feature directory (e.g., `lib/usecase/profile/view/`). Build your UI widgets (Pages, Screens, etc.) inside this `view` directory. These are your "Views".

5.  **Connect View and ViewModel**: In your View, use a state management solution like `Provider` to access the ViewModel. `Provider.of<YourViewModel>(context)` will give you access to the ViewModel's data and methods. Wrap your UI widgets that depend on the ViewModel's state with a `Consumer` or use `context.watch<YourViewModel>()` to have them automatically rebuild when the data changes (i.e., when `notifyListeners()` is called in the ViewModel).

## Promoting a Feature-Specific Resource to a Core Resource

As an application grows, you might find that a resource initially created for a single feature is now needed by other features. When a resource needs to be shared across multiple features, it should be promoted to a "core" resource.

### Rules for Promotion

1.  **Identify the Need for Sharing**: The primary reason to promote a resource is when it is required by at least two different features. Keeping a resource feature-specific until it's needed elsewhere prevents premature abstraction and keeps the core lean.

2.  **Ensure Generality**: Before moving the resource, review its code to ensure it is generic and not tightly coupled to the original feature.
    *   Remove any logic that is specific to the original feature.
    *   If the resource contains both generic and specific logic, refactor it. Extract the generic part into a new file that will be moved to `core`, and keep the feature-specific part in its original location.

3.  **Move the File**:
    *   Move the file from its feature-specific directory (e.g., `lib/usecase/feature_name/`) to the appropriate sub-directory within `lib/core/`. For instance:
        *   A shared model goes into `lib/core/models/`.
        *   A shared utility goes into `lib/core/utils/`.
        *   A shared networking component goes into `lib/core/networking/`.

4.  **Update Imports**: After moving the file, update all import statements in the files that were referencing the old location to point to the new location in `lib/core/`. A project-wide search for the old path is often the easiest way to find all instances.

### Example: Promoting a `Product` Model

Imagine you have a `Product` model in an `inventory` feature (`lib/usecase/inventory/product_model.dart`). Later, a new `shopping_cart` feature also needs to use the `Product` model.

1.  **Identify Need**: The `Product` model is needed by both `inventory` and `shopping_cart`.
2.  **Ensure Generality**: The `Product` model contains only product data (ID, name, price) and is not tied to inventory-specific logic. It's safe to move.
3.  **Move**: Move `lib/usecase/inventory/product_model.dart` to `lib/core/models/product_model.dart`.
4.  **Update Imports**: In all files within the `inventory` feature that used the `Product` model, change the import from `import 'package:your_app/usecase/inventory/product_model.dart';` to `import 'package:your_app/core/models/product_model.dart';`. The new `shopping_cart` feature will also use this new import path.
