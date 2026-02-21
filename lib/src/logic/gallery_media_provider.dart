import 'package:flutter/widgets.dart';
import 'package:gallery_media_picker/src/logic/gallery_media_picker_controller.dart';

/// An [InheritedWidget] that provides the [MediaPickerController] down
/// the tree. This replaces the legacy singleton and allows scoped state
/// management native to Flutter, conforming to Clean Architecture.
class GalleryMediaProvider extends InheritedWidget {
  /// Creates a [GalleryMediaProvider].
  const GalleryMediaProvider({
    required this.controller,
    required super.child,
    super.key,
  });

  /// The controller instance managed for this specific gallery picker.
  final MediaPickerController controller;

  /// Retrieves the closest [MediaPickerController] from the widget tree.
  static MediaPickerController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<GalleryMediaProvider>();
    assert(provider != null, 'No GalleryMediaProvider found in context');
    return provider!.controller;
  }

  @override
  bool updateShouldNotify(covariant GalleryMediaProvider oldWidget) {
    return oldWidget.controller != controller;
  }
}
