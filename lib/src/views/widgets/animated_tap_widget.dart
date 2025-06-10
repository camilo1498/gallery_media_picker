import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Animated onTap scale
class AnimatedTapWidget extends StatefulWidget {
  /// default constructor
  const AnimatedTapWidget({
    required this.child,
    super.key,
    this.onTap,
    this.padding,
    this.boxShape,
    this.borderRadius,
    this.enabled = true,
    this.maxScale = 0.96,
    this.showScale = true,
    this.showHoverColor = false,
    this.hoverColorOpacity = 0.0,
    this.hoverColor = Colors.white,
  }) : assert(
         maxScale >= 0.1 && maxScale <= 1.0,
         'Error: The variable maxScale must be between 0.1 and 1.0',
       ),
       assert(
         hoverColorOpacity >= 0.0 && hoverColorOpacity <= 1.0,
         'Error: The variable hoverColorOpacity must be between 0.0 and 1.0',
       );

  ///
  final Widget child;

  ///
  final VoidCallback? onTap;

  ///
  final bool? enabled;

  ///
  final EdgeInsets? padding;

  ///
  final double maxScale;

  ///
  final Color hoverColor;

  ///
  final bool showHoverColor;

  ///
  final double? borderRadius;

  ///
  final BoxShape? boxShape;

  ///
  final bool showScale;

  ///
  final double hoverColorOpacity;

  @override
  State<AnimatedTapWidget> createState() => _AnimatedTapWidgetState();
}

class _AnimatedTapWidgetState extends State<AnimatedTapWidget>
    with TickerProviderStateMixin {
  double squareScaleA = 1;
  double squareScaleB = 1;
  late AnimationController _controllerA;
  late AnimationController _controllerB;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
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
    _controllerB = AnimationController(
      vsync: this,
      lowerBound: widget.hoverColorOpacity,
      value: 1,
      duration: const Duration(milliseconds: 10),
    )..addListener(() {
      setState(() {
        squareScaleB = _controllerB.value;
      });
    });
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
          widget.onTap != null && widget.enabled!
              ? () {
                HapticFeedback.lightImpact();
                _controllerA.reverse();
                _controllerB.reverse();
                widget.onTap!();
              }
              : () {},
      onTapDown:
          (dp) =>
              widget.enabled!
                  ? {_controllerA.reverse(), _controllerB.reverse()}
                  : null,
      onTapUp:
          (dp) =>
              widget.enabled! && mounted
                  ? _timer = Timer(const Duration(milliseconds: 100), () {
                    _controllerA.fling();
                    _controllerB.fling();
                  })
                  : null,
      onTapCancel:
          () =>
              widget.enabled!
                  ? {_controllerA.fling(), _controllerB.fling()}
                  : null,
      child: Transform.scale(
        scale: widget.showScale ? squareScaleA : 1,
        child: AnimatedContainer(
          padding: widget.padding,
          duration: Duration.zero,
          decoration: BoxDecoration(
            shape: widget.boxShape ?? BoxShape.rectangle,
            color:
                !widget.showHoverColor
                    ? null
                    : widget.hoverColor.withValues(alpha: 1 - squareScaleB),
            borderRadius:
                widget.borderRadius != null
                    ? BorderRadius.circular(widget.borderRadius ?? 0)
                    : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
