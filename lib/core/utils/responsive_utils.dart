import 'package:flutter/material.dart';

class ResponsiveUtils {
  ResponsiveUtils._();

  static const double tabletBreakpoint = 720;
  static const double mobileBreakpoint = 480;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobileBreakpoint && w < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  /// Returns horizontal page padding: 16 on mobile, 24 on tablet, 32 on desktop.
  static double horizontalPadding(BuildContext context) => isMobile(context)
      ? 16
      : isTablet(context)
      ? 24
      : 32;

  /// Returns a cross-axis count for grids: 1 on mobile, 2 on tablet, [desktop] on desktop.
  static int gridColumns(BuildContext context, {int desktop = 3}) =>
      isMobile(context)
      ? 1
      : isTablet(context)
      ? 2
      : desktop;
}
