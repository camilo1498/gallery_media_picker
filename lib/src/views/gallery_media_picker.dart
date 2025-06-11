import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:gallery_media_picker/src/logic/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/views/widgets/animated_tap_widget.dart';
import 'package:gallery_media_picker/src/views/widgets/gridview/grid_thumbnail_item_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

part 'widgets/album/album_dropdown_overlay_widget.dart';
part 'widgets/album/album_dropdown_widget.dart';
part 'widgets/album/album_selector.dart';
part 'widgets/gridview/gallery_grid_view_widget.dart';

/// A widget that displays a customizable media picker UI.
///
/// Allows users to browse, preview, and select images and/or videos from the
/// device's media gallery. Internally uses the `photo_manager` package to
/// access media and handles dynamic updates as the gallery changes.
class GalleryMediaPicker extends StatefulWidget {
  /// Creates an instance of [GalleryMediaPicker].
  ///
  /// [pathList] is called whenever the list of selected media changes.
  /// [mediaPickerParams] contains configuration options for the picker.
  /// [appBarLeadingWidget] optionally defines a leading widget
  /// in the album selector bar.
  const GalleryMediaPicker({
    required this.pathList,
    required this.mediaPickerParams,
    super.key,
    this.appBarLeadingWidget,
  });

  /// Optional widget to be displayed as the leading
  /// element in the album selector.
  final Widget? appBarLeadingWidget;

  /// Parameters for configuring picker behavior, such as
  /// selection mode or UI colors.
  final MediaPickerParamsModel mediaPickerParams;

  /// Callback that returns the list of selected media whenever it changes.
  final ValueChanged<List<PickedAssetModel>> pathList;

  @override
  State<GalleryMediaPicker> createState() => _GalleryMediaPickerState();
}

class _GalleryMediaPickerState extends State<GalleryMediaPicker> {
  /// Singleton controller managing picker state and logic.
  final MediaPickerController provider = MediaPickerController.instance;

  @override
  void initState() {
    super.initState();

    provider
      ..onPickMax = _onPickMaxReached
      ..onPickChanged = widget.pathList
      ..paramsModel = widget.mediaPickerParams
      ..isSinglePick = widget.mediaPickerParams.singlePick
      ..maxSelection = widget.mediaPickerParams.maxPickImages;

    _initPicker();
    _startGalleryObserver();
  }

  // Initializes the picker by requesting permissions and loading album data.
  Future<void> _initPicker() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (!result.isAuth) return;

    final paths = await PhotoManager.getAssetPathList(
      type: provider.paramsModel.mediaType.type,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          needTitle: true,
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        videoOption: const FilterOption(
          needTitle: true,
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
      ),
    );

    if (paths.isNotEmpty) {
      provider.resetPathList(paths);
    }
  }

  // Callback when user exceeds the maximum number of selected media.
  void _onPickMaxReached() {
    showToast('You have already picked ${provider.max.value} items.');
  }

  // Called when changes in the gallery are detected.
  Future<void> _onGalleryChanged(MethodCall call) async {
    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.all,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          needTitle: true,
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        videoOption: const FilterOption(
          needTitle: true,
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        orders: [const OrderOption()],
      ),
    );
    if (paths.isNotEmpty) {
      provider.resetPathList(paths);
    }
  }

  // Starts observing the gallery for changes in real time.
  void _startGalleryObserver() {
    PhotoManager.addChangeCallback(_onGalleryChanged);
    PhotoManager.startChangeNotify();
  }

  // Stops observing gallery changes when the widget is disposed.
  void _stopGalleryObserver() {
    PhotoManager.removeChangeCallback(_onGalleryChanged);
    PhotoManager.stopChangeNotify();
  }

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
          // Album selection bar (dropdown)
          _AlbumSelector(appBarLeadingWidget: widget.appBarLeadingWidget),
          const SizedBox(height: 2),

          // Grid displaying the media thumbnails
          Expanded(
            child: RepaintBoundary(
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return false;
                },
                child: ValueListenableBuilder<AssetPathEntity?>(
                  valueListenable: provider.currentAlbum,
                  builder: (_, album, __) => const _GalleryGridViewWidget(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
