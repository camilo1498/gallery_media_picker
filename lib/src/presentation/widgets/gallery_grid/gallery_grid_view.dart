import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/data/models/gallery_params_model.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/presentation/widgets/gallery_grid/thumbnail_widget.dart';
import 'package:photo_manager/photo_manager.dart';

typedef OnAssetItemClick = void Function(AssetEntity entity, int index);

class GalleryGridView extends StatefulWidget {
  /// asset album
  final AssetPathEntity? path;

  /// on tap thumbnail
  final OnAssetItemClick? onAssetItemClick;

  /// picker data provider
  final GalleryMediaPickerController provider;

  /// params model
  final MediaPickerParamsModel mediaPickerParams;

  const GalleryGridView({
    Key? key,
    required this.path,
    required this.provider,
    required this.mediaPickerParams,
    this.onAssetItemClick,
  }) : super(key: key);

  @override
  GalleryGridViewState createState() => GalleryGridViewState();
}

class GalleryGridViewState extends State<GalleryGridView> {
  static Map<int?, AssetEntity?> _createMap() {
    return {};
  }

  /// create cache for images
  var cacheMap = _createMap();

  /// notifier for scroll events
  final scrolling = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// generate thumbnail grid view
    return widget.path != null
        ? NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: AnimatedBuilder(
              animation: widget.provider.assetCountNotifier,
              builder: (_, __) => Container(
                color: widget.mediaPickerParams.gridViewBackgroundColor,
                child: GridView.builder(
                  key: ValueKey(widget.path),
                  shrinkWrap: true,
                  padding: widget.mediaPickerParams.gridPadding ??
                      const EdgeInsets.all(0),
                  physics: widget.mediaPickerParams.gridViewPhysics ??
                      const ScrollPhysics(),
                  controller: widget.mediaPickerParams.gridViewController ??
                      ScrollController(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: widget.mediaPickerParams.childAspectRatio,
                    crossAxisCount: widget.mediaPickerParams.crossAxisCount,
                    mainAxisSpacing: 2.5,
                    crossAxisSpacing: 2.5,
                  ),

                  /// render thumbnail
                  itemBuilder: (context, index) =>
                      _buildItem(context, index, widget.provider),
                  itemCount: widget.provider.assetCount,
                  addRepaintBoundaries: true,
                ),
              ),
            ),
          )
        : Container();
  }

  Widget _buildItem(
      BuildContext context, index, GalleryMediaPickerController provider) {
    return GestureDetector(
      /// on tap thumbnail
      onTap: () async {
        var asset = cacheMap[index];
        if (asset == null) {
          asset = (await widget.path!
              .getAssetListRange(start: index, end: index + 1))[0];
          cacheMap[index] = asset;
        }
        widget.onAssetItemClick?.call(asset, index);
      },

      /// render thumbnail
      child: _buildScrollItem(context, index, provider),
    );
  }

  Widget _buildScrollItem(
      BuildContext context, int index, GalleryMediaPickerController provider) {
    /// load cache images
    final asset = cacheMap[index];
    if (asset != null) {
      return ThumbnailWidget(
        asset: asset,
        provider: provider,
        index: index,
        mediaPickerParams: widget.mediaPickerParams,
      );
    } else {
      /// read the assets from selected album
      return FutureBuilder<List<AssetEntity>>(
        future: widget.path!.getAssetListRange(start: index, end: index + 1),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: widget.mediaPickerParams.gridViewBackgroundColor,
            );
          }
          final asset = snapshot.data![0];
          cacheMap[index] = asset;

          /// thumbnail widget
          return ThumbnailWidget(
            asset: asset,
            index: index,
            provider: provider,
            mediaPickerParams: widget.mediaPickerParams,
          );
        },
      );
    }
  }

  /// scroll notifier
  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      scrolling.value = false;
    } else if (notification is ScrollStartNotification) {
      scrolling.value = true;
    }
    return false;
  }

  /// update widget on scroll
  @override
  void didUpdateWidget(GalleryGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      cacheMap.clear();
      scrolling.value = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
