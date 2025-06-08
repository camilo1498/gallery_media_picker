import 'package:flutter/material.dart';

typedef DropdownWidgetBuilder<T> =
    Widget Function(BuildContext context, void Function(T?) onClose);

class DropDown<T> extends StatefulWidget {
  const DropDown({
    required this.child,
    required this.dropdownBuilder,
    required this.animationController,
    super.key,
  });
  final Widget child;
  final Widget Function(void Function(T?) onClose) dropdownBuilder;
  final AnimationController animationController;

  @override
  DropDownState<T> createState() => DropDownState<T>();
}

class DropDownState<T> extends State<DropDown<T>> {
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void toggleDropdown() {
    if (_isOpen) {
      _closeDropdown(null);
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final position = renderBox?.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _closeDropdown(null),
              ),
              Positioned(
                left: position?.dx,
                top: (position?.dy ?? 0) + (renderBox?.size.height ?? 0),
                child: Material(child: widget.dropdownBuilder(_closeDropdown)),
              ),
            ],
          ),
    );

    overlay.insert(_overlayEntry!);
    widget.animationController.forward();
    setState(() => _isOpen = true);
  }

  void _closeDropdown(T? value) {
    widget.animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      setState(() => _isOpen = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }
}
