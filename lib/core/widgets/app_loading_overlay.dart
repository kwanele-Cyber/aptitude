import 'package:flutter/material.dart';

class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final double opacity;
  final Color? barrierColor;
  final double indicatorSize;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.opacity = 0.3,
    this.barrierColor,
    this.indicatorSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = barrierColor ?? theme.colorScheme.surface;

    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: isLoading ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                child: Container(
                  color: color.withValues(alpha: opacity),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
