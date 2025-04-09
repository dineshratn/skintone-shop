import 'package:flutter/material.dart';

class NavigationUtils {
  // Navigate to a screen with a fade transition
  static Future<T?> navigateWithFade<T>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: duration,
      ),
    );
  }

  // Navigate to a screen with a slide transition
  static Future<T?> navigateWithSlide<T>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
    AxisDirection direction = AxisDirection.right,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Determine the slide offset based on direction
          Offset begin;
          switch (direction) {
            case AxisDirection.up:
              begin = const Offset(0, 1);
              break;
            case AxisDirection.down:
              begin = const Offset(0, -1);
              break;
            case AxisDirection.right:
              begin = const Offset(-1, 0);
              break;
            case AxisDirection.left:
              begin = const Offset(1, 0);
              break;
          }
          
          return SlideTransition(
            position: Tween<Offset>(
              begin: begin,
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
        transitionDuration: duration,
      ),
    );
  }

  // Navigate and remove all previous routes
  static void navigateAndRemoveUntil(
    BuildContext context,
    Widget page,
  ) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  // Navigate and replace the current route
  static void navigateAndReplace(
    BuildContext context,
    Widget page,
  ) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // Pop to a specific route
  static void popUntilNamed(BuildContext context, String routeName) {
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }

  // Pop multiple levels
  static void popMultiple(BuildContext context, int count) {
    int popped = 0;
    Navigator.of(context).popUntil((_) => popped++ >= count);
  }
}
