import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that adds a scaling animation when tapped,
/// similar to a "press" effect.
///
/// Useful for buttons, thumbnails, or any tappable component
/// to provide subtle feedback.
class AnimatedTapWidget extends StatefulWidget {
  /// Creates an [AnimatedTapWidget].
  ///
  /// [child] is the widget to animate when tapped.
  /// [onTap] is the callback to trigger when the user taps the widget.
  /// [maxScale] defines the minimum scale value during the tap animation
  /// (default is 0.98). Must be between 0.1 and 1.0.
  const AnimatedTapWidget({
    required this.child,
    super.key,
    this.onTap,
    this.maxScale = 0.98,
  }) : assert(
         maxScale >= 0.1 && maxScale <= 1.0,
         'Error: The variable maxScale must be between 0.1 and 1.0',
       );

  /// The widget that will be scaled on tap.
  final Widget child;

  /// The minimum scale value to apply during animation.
  final double maxScale;

  /// Callback when the widget is tapped.
  final VoidCallback? onTap;

  @override
  State<AnimatedTapWidget> createState() => _AnimatedTapWidgetState();
}

class _AnimatedTapWidgetState extends State<AnimatedTapWidget>
    with TickerProviderStateMixin {
  // Current scale value used during animation.
  double squareScale = 1;

  // Animation controller to handle scale animations.
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize controller with a lower bound from maxScale to 1.
    _controller =
        AnimationController(
          vsync: this,
          lowerBound: widget.maxScale,
          value: 1,
          duration: const Duration(milliseconds: 10),
        )..addListener(() {
          setState(() {
            squareScale = _controller.value;
          });
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap != null
          ? () {
              unawaited(HapticFeedback.lightImpact());
              unawaited(_controller.reverse());
              widget.onTap!();
              unawaited(_controller.fling());
            }
          : null,
      onTapDown: (_) {
        unawaited(_controller.reverse());
      },
      onTapUp: (_) {
        if (mounted) unawaited(_controller.fling());
      },
      onTapCancel: () {
        if (mounted) unawaited(_controller.fling());
      },
      child: Transform.scale(
        scale: squareScale,
        child: widget.child,
      ),
    );
  }
}
