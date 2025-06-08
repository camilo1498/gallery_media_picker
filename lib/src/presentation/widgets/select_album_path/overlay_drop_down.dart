import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/dropdown.dart';

class OverlayDropDown<T> extends StatelessWidget {
  final double height;
  final ValueChanged<T?> close;
  final AnimationController animationController;
  final DropdownWidgetBuilder<T> builder;

  const OverlayDropDown({
    super.key,
    required this.height,
    required this.close,
    required this.animationController,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPadding = size.height - height;

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Align(
        alignment: Alignment.topLeft,
        child: Builder(
          builder:
              (ctx) => Stack(
                children: [
                  GestureDetector(
                    onTap: () => close(null),
                    child: Container(
                      color: Colors.transparent,
                      height: height * animationController.value,
                      width: size.width,
                    ),
                  ),
                  SizedBox(
                    height: height * animationController.value,
                    width: size.width * 0.5,
                    child: AnimatedBuilder(
                      animation: animationController,
                      builder: (context, _) => builder(ctx, close),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
