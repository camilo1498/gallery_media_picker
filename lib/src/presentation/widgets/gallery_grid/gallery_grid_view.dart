import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/presentation/widgets/gallery_grid/thumbnail_widget.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryGridView extends StatefulWidget {
  const GalleryGridView({
    required this.path,
    required this.provider,
    super.key,
    this.onAssetTap,
  });
  final AssetPathEntity? path;
  final GalleryMediaPickerController provider;
  final void Function(AssetEntity, int)? onAssetTap;

  @override
  State<GalleryGridView> createState() => _GalleryGridViewState();
}

class _GalleryGridViewState extends State<GalleryGridView> {
  final _assetCache = <int, AssetEntity>{};
  final _scrollController = ScrollController();
  final _preloadAmount = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _preloadAssets(0, _preloadAmount);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.extentAfter < 500) {
      _preloadAssets(_assetCache.length, _assetCache.length + _preloadAmount);
    }
  }

  Future<void> _preloadAssets(int start, int end) async {
    if (widget.path == null) return;

    final assets = await widget.path!.getAssetListRange(start: start, end: end);
    for (var i = 0; i < assets.length; i++) {
      _assetCache[start + i] = assets[i];
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.provider.assetCountNotifier,
      builder: (_, count, _) {
        return GridView.builder(
          controller: _scrollController,
          itemCount: count,
          gridDelegate: _buildGridDelegate(),
          itemBuilder: (_, index) => _buildGridItem(index),
        );
      },
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _buildGridDelegate() {
    final params = widget.provider.paramsModel!;
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: params.crossAxisCount,
      childAspectRatio: params.childAspectRatio,
      mainAxisSpacing: 1.5,
      crossAxisSpacing: 1.5,
    );
  }

  Widget _buildGridItem(int index) {
    final asset = _assetCache[index];
    if (asset != null) {
      return GestureDetector(
        onTap: () => widget.onAssetTap?.call(asset, index),
        child: ThumbnailWidget(
          asset: asset,
          index: index,
          provider: widget.provider,
        ),
      );
    }

    return FutureBuilder<AssetEntity>(
      future: _loadAsset(index),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          _assetCache[index] = snapshot.data!;
          return GestureDetector(
            onTap: () => widget.onAssetTap?.call(snapshot.data!, index),
            child: ThumbnailWidget(
              asset: snapshot.data!,
              index: index,
              provider: widget.provider,
            ),
          );
        }
        return Container(color: Colors.grey[200]);
      },
    );
  }

  Future<AssetEntity> _loadAsset(int index) async {
    final assets = await widget.path!.getAssetListRange(
      start: index,
      end: index + 1,
    );
    if (assets.isEmpty) {
      throw Exception('No asset found at index $index');
    }
    return _assetCache[index] = assets.first;
  }
}
