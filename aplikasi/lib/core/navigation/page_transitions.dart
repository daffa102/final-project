import 'package:flutter/material.dart';

/// Reusable Slide-Up page transition.
/// Specs: begin: Offset(0, 1), end: Offset.zero,
/// Curves.easeInOutQuart, Duration: 800ms.
Route<T> slideUpRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 800),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutQuart,
        ),
      );
      return SlideTransition(position: slide, child: child);
    },
  );
}
