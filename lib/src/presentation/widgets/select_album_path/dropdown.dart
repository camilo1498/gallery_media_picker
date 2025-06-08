import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/core/functions.dart';

typedef DropdownWidgetBuilder<T> =
    Widget Function(BuildContext context, ValueSetter<T> close);

class DropDown<T> extends StatefulWidget {
  final Widget child;
  final DropdownWidgetBuilder<T> dropdownWidgetBuilder;
  final ValueChanged<T?>? onResult;
  final ValueChanged<bool>? onShow;
  final GlobalKey? relativeKey;

  const DropDown({
    super.key,
    required this.child,
    required this.dropdownWidgetBuilder,
    this.onResult,
    this.onShow,
    this.relativeKey,
  });

  @override
  DropDownState<T> createState() => DropDownState<T>();
}

class DropDownState<T> extends State<DropDown<T>>
    with TickerProviderStateMixin {
  FeatureController<T?>? controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: widget.child,
      onTap: () async {
        if (controller != null) {
          controller!.close(null);
          return;
        }

        final height = MediaQuery.of(context).size.height;
        final ctx = widget.relativeKey?.currentContext ?? context;
        final box = ctx.findRenderObject() as RenderBox;
        final offsetStart = box.localToGlobal(Offset.zero);
        final dialogHeight = height - (offsetStart.dy + box.paintBounds.bottom);

        widget.onShow?.call(true);

        controller = GalleryFunctions.showDropDown<T>(
          context: context,
          height: dialogHeight,
          builder: (_, close) => widget.dropdownWidgetBuilder(context, close),
          tickerProvider: this,
        );

        final result = await controller!.closed;
        controller = null;
        widget.onResult?.call(result);
        widget.onShow?.call(false);
      },
    );
  }
}
