import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/core/functions.dart';
import 'package:gallery_media_picker/src/data/models/gallery_params_model.dart';
import 'package:gallery_media_picker/src/data/models/picked_asset_model.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/presentation/widgets/gallery_grid/gallery_grid_view.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/current_path_selector.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryMediaPicker extends StatefulWidget {
  final MediaPickerParamsModel mediaPickerParams;
  final ValueChanged<List<PickedAssetModel>> pathList;

  const GalleryMediaPicker({
    Key? key,
    required this.mediaPickerParams,
    required this.pathList,
  }) : super(key: key);

  @override
  State<GalleryMediaPicker> createState() => _GalleryMediaPickerState();
}

class _GalleryMediaPickerState extends State<GalleryMediaPicker> {
  final GalleryMediaPickerController provider = GalleryMediaPickerController();

  @override
  void initState() {
    super.initState();
    provider.paramsModel = widget.mediaPickerParams;
    _initPicker();
  }

  void _initPicker() {
    GalleryFunctions.getPermission(setState, provider);
    provider.onPickMax.addListener(_onPickMaxReached);
  }

  void _onPickMaxReached() {
    showToast("You have already picked ${provider.max} items.");
  }

  @override
  void dispose() {
    provider.onPickMax.removeListener(_onPickMaxReached);
    provider.pickedFile.clear();
    provider.picked.clear();
    provider.pathList.clear();
    PhotoManager.stopChangeNotify();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    provider.max = widget.mediaPickerParams.maxPickImages;
    provider.singlePickMode = widget.mediaPickerParams.singlePick;

    return OKToast(
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return false;
        },
        child: Column(
          children: [
            _buildAlbumSelector(),
            Expanded(child: _buildGalleryGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumSelector() {
    return Container(
      color: widget.mediaPickerParams.appBarColor,
      alignment: Alignment.bottomLeft,
      height: widget.mediaPickerParams.appBarHeight,
      child: SelectedPathDropdownButton(
        provider: provider,
        mediaPickerParams: widget.mediaPickerParams,
      ),
    );
  }

  Widget _buildGalleryGrid() {
    return AnimatedBuilder(
      animation: provider.currentAlbumNotifier,
      builder: (_, __) {
        final album = provider.currentAlbum;
        return GalleryGridView(
          provider: provider,
          path: album,
          onAssetItemClick: _onAssetItemClick,
        );
      },
    );
  }

  Future<void> _onAssetItemClick(AssetEntity asset, int index) async {
    provider.pickEntity(asset);
    final path = await GalleryFunctions.getFile(asset);

    final pickedModel = PickedAssetModel(
      id: asset.id,
      path: path,
      type: asset.typeInt == 1 ? 'image' : 'video',
      videoDuration: asset.videoDuration,
      createDateTime: asset.createDateTime,
      latitude: asset.latitude,
      longitude: asset.longitude,
      thumbnail: await asset.thumbnailData,
      height: asset.height,
      width: asset.width,
      orientationHeight: asset.orientatedHeight,
      orientationWidth: asset.orientatedWidth,
      orientationSize: asset.orientatedSize,
      file: await asset.file,
      modifiedDateTime: asset.modifiedDateTime,
      title: asset.title,
      size: asset.size,
    );

    provider.pickPath(pickedModel);
    widget.pathList(provider.pickedFile);
  }
}
