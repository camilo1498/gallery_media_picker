import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:gallery_media_picker/src/logic/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/views/widgets/animated_tap_widget.dart';
import 'package:gallery_media_picker/src/views/widgets/gridview/grid_thumbnail_item_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

part 'widgets/album/album_selector.dart';
part 'widgets/album/album_dropdown_widget.dart';
part 'widgets/gridview/gallery_grid_view_widget.dart';
part 'widgets/album/album_dropdown_overlay_widget.dart';

/// A widget that displays a customizable media picker UI.
///
/// Allows users to browse, preview, and select multiple images/videos
/// from their device gallery, using the `photo_manager` package.
class GalleryMediaPicker extends StatefulWidget {
  /// Creates a [GalleryMediaPicker].
  ///
  /// [pathList] is a callback that returns the selected media.
  /// [mediaPickerParams] contains the picker configuration options.
  /// [appBarLeadingWidget] can be used to display a
  /// custom widget on the top bar.
  const GalleryMediaPicker({
    required this.pathList,
    required this.mediaPickerParams,
    super.key,
    this.appBarLeadingWidget,
  });

  /// Optional widget displayed at the leading side of the top bar.
  final Widget? appBarLeadingWidget;

  /// Picker configuration options (e.g. selection
  /// limits, thumbnail sizes, etc).
  final MediaPickerParamsModel mediaPickerParams;

  /// Callback triggered whenever selected media changes.
  final ValueChanged<List<PickedAssetModel>> pathList;

  @override
  State<GalleryMediaPicker> createState() => _GalleryMediaPickerState();
}

class _GalleryMediaPickerState extends State<GalleryMediaPicker> {
  // Singleton instance of the controller that
  // manages gallery and selection state.
  final MediaPickerController provider = MediaPickerController.instance;

  @override
  void initState() {
    super.initState();

    // Initialize controller with the widget parameters.
    provider
      ..onPickMax = _onPickMaxReached
      ..onPickChanged = widget.pathList
      ..paramsModel = widget.mediaPickerParams
      ..isSinglePick = widget.mediaPickerParams.singlePick
      ..maxSelection = widget.mediaPickerParams.maxPickImages;

    // Request permission and load albums.
    _initPicker();
    _startGalleryObserver();
  }

  // Requests permission to access the gallery and loads the albums.
  Future<void> _initPicker() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (!result.isAuth) return;

    final paths = await PhotoManager.getAssetPathList();
    if (paths.isNotEmpty) {
      provider.resetPathList(paths);
    }
  }

  // Callback invoked when the user reaches the maximum pick limit.
  void _onPickMaxReached() {
    showToast('You have already picked ${provider.max.value} items.');
  }

  // Gallery change callback that reloads albums.
  Future<void> _onGalleryChanged(MethodCall call) async {
    final paths = await PhotoManager.getAssetPathList();
    if (paths.isNotEmpty) {
      provider.resetPathList(paths);
    }
  }

  void _startGalleryObserver() {
    PhotoManager.addChangeCallback(_onGalleryChanged);
    PhotoManager.startChangeNotify();
  }

  void _stopGalleryObserver() {
    PhotoManager.removeChangeCallback(_onGalleryChanged);
    PhotoManager.stopChangeNotify();
  }

  // Handles changes in the widget configuration
  // and updates the controller accordingly.
  @override
  void didUpdateWidget(covariant GalleryMediaPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldParams = oldWidget.mediaPickerParams;
    final newParams = widget.mediaPickerParams;

    if (oldParams != newParams) {
      provider.paramsModel = newParams;
      provider
        ..isSinglePick = newParams.singlePick
        ..maxSelection = newParams.maxPickImages;
    }
  }

  @override
  void dispose() {
    _stopGalleryObserver();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: Column(
        children: [
          // Displays the album dropdown selector with optional leading widget.
          _AlbumSelector(appBarLeadingWidget: widget.appBarLeadingWidget),

          const SizedBox(height: 2),

          // Main grid section showing media thumbnails.
          Expanded(
            child: RepaintBoundary(
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return false;
                },
                child: ValueListenableBuilder<AssetPathEntity?>(
                  valueListenable: provider.currentAlbum,
                  builder: (_, album, _) {
                    return const _GalleryGridViewWidget();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
