import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Screen size breakpoints
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;

  // Check device type based on screen width
  static bool isMobile(BuildContext context) => 
      MediaQuery.of(context).size.width < mobileBreakpoint;
      
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width >= mobileBreakpoint && 
      MediaQuery.of(context).size.width < desktopBreakpoint;
      
  static bool isDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  // Get screen width percentage
  static double screenWidthPercentage(BuildContext context, double percentage) =>
      MediaQuery.of(context).size.width * percentage;

  // Get screen height percentage
  static double screenHeightPercentage(BuildContext context, double percentage) =>
      MediaQuery.of(context).size.height * percentage;

  // Get responsive value based on screen size
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktop(context)) {
      return desktop;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  // Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) =>
      EdgeInsets.symmetric(
        horizontal: getResponsiveValue(
          context: context,
          mobile: 16.0,
          tablet: 24.0,
          desktop: 32.0,
        ),
        vertical: getResponsiveValue(
          context: context,
          mobile: 12.0,
          tablet: 16.0,
          desktop: 20.0,
        ),
      );

  // Get responsive font size
  static double responsiveFontSize(
    BuildContext context, 
    {double small = 12, double medium = 16, double large = 20}
  ) =>
      getResponsiveValue(
        context: context,
        mobile: small,
        tablet: medium,
        desktop: large,
      );
}
