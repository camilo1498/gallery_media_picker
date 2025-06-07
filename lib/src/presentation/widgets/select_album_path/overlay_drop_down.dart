import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/dropdown.dart';

class OverlayDropDown<T> extends StatelessWidget {
  final double height;
  final ValueChanged<T?> close;
  final AnimationController animationController;
  final DropdownWidgetBuilder<T> builder;

  const OverlayDropDown({
    Key? key,
    required this.height,
    required this.close,
    required this.animationController,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double screenHeight = size.height;
    final double screenWidth = size.width;
    final double topPadding = screenHeight - height;

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Align(
        alignment: Alignment.topLeft,
        child: Builder(
          builder:
              (ctx) => Stack(
                children: [
                  // Transparent full screen GestureDetector to close overlay on tap outside
                  GestureDetector(
                    onTap: () => close(null),
                    child: Container(
                      color: Colors.transparent,
                      height: height * animationController.value,
                      width: screenWidth,
                    ),
                  ),

                  // Dropdown content area
                  SizedBox(
                    height: height * animationController.value,
                    width: screenWidth * 0.5,
                    child: AnimatedBuilder(
                      animation: animationController,
                      builder: (context, _) {
                        return builder(ctx, close);
                      },
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
