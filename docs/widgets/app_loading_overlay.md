# AppLoadingOverlay

**Status**: Implemented
**Location**: `lib/core/widgets/app_loading_overlay.dart`
**Use Cases**: F21 (Common Utilities)

## Purpose
A reusable loading overlay widget that wraps page content and displays a semi-transparent overlay with a centered `CircularProgressIndicator` during async operations. Blocks user interaction while loading.

## Usage

```dart
AppLoadingOverlay(
  isLoading: state is SomeLoading,
  child: Column(
    children: [ /* page content */ ],
  ),
)
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `isLoading` | `bool` | required | When true, shows the overlay |
| `child` | `Widget` | required | The content to overlay |
| `opacity` | `double` | 0.3 | Opacity of the barrier color |
| `barrierColor` | `Color?` | theme surface | Background color of the barrier |
| `indicatorSize` | `double` | 48 | Size of the CircularProgressIndicator |

## How It Works
- Uses a `Stack` with the child at index 0 and the overlay at index 1
- The overlay uses `AnimatedOpacity` (200ms duration) for smooth transitions
- `IgnorePointer` prevents user interaction during loading
- The indicator uses the theme's primary color

## Integration Pattern

### In pages using BlocBuilder:
```dart
BlocBuilder<SomeBloc, SomeState>(
  builder: (context, state) {
    return AppLoadingOverlay(
      isLoading: state is SomeLoading,
      child: /* content widget */,
    );
  },
)
```

### In pages with multiple loading states:
```dart
final isLoading = state is Loading1 || state is Loading2;
return AppLoadingOverlay(
  isLoading: isLoading,
  child: /* content */,
);
```

## Future Enhancements
- Optional shimmer/skeleton loading placeholder behind the overlay
- Customizable indicator widget
- Percentage/progress mode for uploads
