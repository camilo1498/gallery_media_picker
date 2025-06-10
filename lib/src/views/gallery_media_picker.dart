import 'package:flutter/material.dart';
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

class GalleryMediaPicker extends StatefulWidget {
  const GalleryMediaPicker({
    required this.pathList,
    required this.mediaPickerParams,
    super.key,
    this.appBarLeadingWidget,
  });

  final Widget? appBarLeadingWidget;
  final MediaPickerParamsModel mediaPickerParams;
  final ValueChanged<List<PickedAssetModel>> pathList;

  @override
  State<GalleryMediaPicker> createState() => _GalleryMediaPickerState();
}

class _GalleryMediaPickerState extends State<GalleryMediaPicker> {
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
  }

  Future<void> _initPicker() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (!result.isAuth) return;

    final paths = await PhotoManager.getAssetPathList();
    if (paths.isNotEmpty) {
      provider.resetPathList(paths);
    }
  }

  void _onPickMaxReached() {
    showToast('You have already picked ${provider.max.value} items.');
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
  Widget build(BuildContext context) {
    return OKToast(
      child: Column(
        children: [
          _AlbumSelector(appBarLeadingWidget: widget.appBarLeadingWidget),
          const SizedBox(height: 2),
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
