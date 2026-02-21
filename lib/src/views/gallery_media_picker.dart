import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:gallery_media_picker/src/data/constants/album_constants.dart';
import 'package:gallery_media_picker/src/logic/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/logic/gallery_media_provider.dart';
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
  /// Controller managing picker state and logic for this specific instance.
  late final MediaPickerController provider;

  @override
  void initState() {
    super.initState();
    provider = MediaPickerController();

    provider
      ..onPickMax = _onPickMaxReached
      ..onPickChanged = widget.pathList
      ..paramsModel = widget.mediaPickerParams
      ..isSinglePick = widget.mediaPickerParams.singlePick
      ..maxSelection = widget.mediaPickerParams.maxPickImages;

    unawaited(_initPicker());
    _startGalleryObserver();
  }

  // Initializes the picker by requesting permissions and loading album data.
  Future<void> _initPicker({bool reset = false}) async {
    final result = await PhotoManager.requestPermissionExtend();
    provider.permitState.value = result;
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
        audioOption: const FilterOption(
          needTitle: true,
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
      ),
    );

    provider.resetPathList(paths, reset: reset);
  }

  // Callback when user exceeds the maximum number of selected media.
  void _onPickMaxReached() {
    final trans = provider.paramsModel.translations;
    showToast(trans.maxItemsPicked.replaceAll('%s', '${provider.max.value}'));
  }

  // Called when changes in the gallery are detected.
  Future<void> _onGalleryChanged(MethodCall call) async {
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
        audioOption: const FilterOption(
          needTitle: true,
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        orders: [const OrderOption()],
      ),
    );
    provider.resetPathList(paths);
  }

  // Starts observing the gallery for changes in real time.
  void _startGalleryObserver() {
    PhotoManager.addChangeCallback(_onGalleryChanged);
    unawaited(PhotoManager.startChangeNotify());
  }

  // Stops observing gallery changes when the widget is disposed.
  void _stopGalleryObserver() {
    PhotoManager.removeChangeCallback(_onGalleryChanged);
    unawaited(PhotoManager.stopChangeNotify());
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

      if (oldParams.mediaType != newParams.mediaType) {
        unawaited(_initPicker(reset: true));
      }
    }
  }

  @override
  void dispose() {
    _stopGalleryObserver();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GalleryMediaProvider(
      controller: provider,
      child: OKToast(
        child: Column(
          children: [
            // Album selection bar (dropdown)
            _AlbumSelector(appBarLeadingWidget: widget.appBarLeadingWidget),
            const SizedBox(height: 2),

            // Grid displaying the media thumbnails
            Expanded(
              child: ValueListenableBuilder<PermissionState>(
                valueListenable: provider.permitState,
                builder: (_, permit, __) {
                  if (permit == PermissionState.notDetermined) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!permit.isAuth) {
                    return _buildPermissionDeniedUI();
                  }

                  return RepaintBoundary(
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowIndicator();
                            return false;
                          },
                          child: ValueListenableBuilder<AssetPathEntity?>(
                            valueListenable: provider.currentAlbum,
                            builder: (_, album, _) =>
                                const _GalleryGridViewWidget(),
                          ),
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI displayed when the user explicitly denies gallery permissions.
  Widget _buildPermissionDeniedUI() {
    final theme = Theme.of(context);
    final trans = provider.paramsModel.translations;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              trans.permissionDenied,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: PhotoManager.openSetting,
            child: Text(trans.tapToOpenSettings),
          ),
        ],
      ),
    );
  }
}
