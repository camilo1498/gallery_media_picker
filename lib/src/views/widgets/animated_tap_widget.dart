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
  // Current scale values used during animation.
  double squareScaleA = 1;
  double squareScaleB = 1;

  // Animation controllers to handle scale animations.
  late AnimationController _controllerA;
  late AnimationController _controllerB;

  // A timer used to delay the animation reset after tap.
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // Initialize controller A with a lower bound from maxScale to 1.
    _controllerA = AnimationController(
      vsync: this,
      lowerBound: widget.maxScale,
      value: 1,
      duration: const Duration(milliseconds: 10),
    )..addListener(() {
      setState(() {
        squareScaleA = _controllerA.value;
      });
    });

    // Initialize controller B (unused for scale but
    // maintained for legacy or symmetry).
    _controllerB = AnimationController(
      vsync: this,
      value: 1,
      duration: const Duration(milliseconds: 10),
    )..addListener(() {
      setState(() {
        squareScaleB = _controllerB.value;
      });
    });

    // Initialize a dummy timer to avoid null references.
    _timer = Timer(const Duration(milliseconds: 300), () {});
  }

  @override
  void dispose() {
    _controllerA.dispose();
    _controllerB.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap:
          widget.onTap != null
              ? () {
                HapticFeedback.lightImpact();
                _controllerA.reverse();
                _controllerB.reverse();
                widget.onTap!();
              }
              : () {},
      onTapDown: (dp) {
        _controllerA.reverse();
        _controllerB.reverse();
      },
      onTapUp: (dp) {
        if (mounted) {
          _timer = Timer(const Duration(milliseconds: 100), () {
            _controllerA.fling(); // Restore scale
            _controllerB.fling();
          });
        }
      },
      onTapCancel: () {
        _controllerA.fling();
        _controllerB.fling();
      },
      child: Transform.scale(
        scale: squareScaleA,
        child: AnimatedContainer(duration: Duration.zero, child: widget.child),
      ),
    );
  }
}
