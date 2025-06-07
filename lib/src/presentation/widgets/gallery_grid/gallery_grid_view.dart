import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/presentation/widgets/gallery_grid/thumbnail_widget.dart';
import 'package:photo_manager/photo_manager.dart';

typedef OnAssetItemClick = void Function(AssetEntity entity, int index);

class GalleryGridView extends StatefulWidget {
  final AssetPathEntity? path;
  final OnAssetItemClick? onAssetItemClick;
  final GalleryMediaPickerController provider;

  const GalleryGridView({
    Key? key,
    required this.path,
    required this.provider,
    this.onAssetItemClick,
  }) : super(key: key);

  @override
  GalleryGridViewState createState() => GalleryGridViewState();
}

class GalleryGridViewState extends State<GalleryGridView> {
  final Map<int, AssetEntity> _cacheMap = {};
  final ValueNotifier<bool> _scrolling = ValueNotifier(false);

  @override
  void didUpdateWidget(covariant GalleryGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _cacheMap.clear();
      _scrolling.value = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.path == null) return const SizedBox.shrink();

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: AnimatedBuilder(
        animation: widget.provider.assetCountNotifier,
        builder:
            (_, __) => Container(
              color: widget.provider.paramsModel.gridViewBackgroundColor,
              child: GridView.builder(
                key: ValueKey(widget.path),
                shrinkWrap: true,
                padding:
                    widget.provider.paramsModel.gridPadding ?? EdgeInsets.zero,
                physics:
                    widget.provider.paramsModel.gridViewPhysics ??
                    const ScrollPhysics(),
                controller:
                    widget.provider.paramsModel.gridViewController ??
                    ScrollController(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.provider.paramsModel.crossAxisCount,
                  childAspectRatio:
                      widget.provider.paramsModel.childAspectRatio,
                  mainAxisSpacing: 2.5,
                  crossAxisSpacing: 2.5,
                ),
                itemCount: widget.provider.assetCount,
                addRepaintBoundaries: true,
                itemBuilder: (context, index) => _buildItem(context, index),
              ),
            ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    return GestureDetector(
      onTap: () async {
        AssetEntity? asset = _cacheMap[index];
        if (asset == null ||
            asset.type == AssetType.audio ||
            asset.type == AssetType.other)
          return;

        // Refetch asset for fresh data
        final assetList = await widget.path!.getAssetListRange(
          start: index,
          end: index + 1,
        );
        if (assetList.isEmpty) return;

        asset = assetList.first;
        _cacheMap[index] = asset;
        widget.onAssetItemClick?.call(asset, index);
      },
      child: _buildScrollItem(context, index),
    );
  }

  Widget _buildScrollItem(BuildContext context, int index) {
    final cachedAsset = _cacheMap[index];
    if (cachedAsset != null) {
      return ThumbnailWidget(
        asset: cachedAsset,
        provider: widget.provider,
        index: index,
      );
    }

    return FutureBuilder<List<AssetEntity>>(
      future: widget.path!.getAssetListRange(start: index, end: index + 1),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            color: widget.provider.paramsModel.gridViewBackgroundColor,
            width: double.infinity,
            height: double.infinity,
          );
        }

        final asset = snapshot.data!.first;
        _cacheMap[index] = asset;

        return ThumbnailWidget(
          asset: asset,
          index: index,
          provider: widget.provider,
        );
      },
    );
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _scrolling.value = true;
    } else if (notification is ScrollEndNotification) {
      _scrolling.value = false;
    }
    return false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GalleryGridViewState && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
