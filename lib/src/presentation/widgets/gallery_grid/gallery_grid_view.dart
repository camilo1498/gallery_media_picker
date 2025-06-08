import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/presentation/widgets/gallery_grid/thumbnail_widget.dart';
import 'package:photo_manager/photo_manager.dart';

typedef OnAssetItemClick = void Function(AssetEntity entity, int index);

class GalleryGridView extends StatefulWidget {
  final AssetPathEntity? path;
  final OnAssetItemClick? onAssetItemClick; // Parámetro añadido
  final GalleryMediaPickerController provider;

  const GalleryGridView({
    Key? key,
    required this.path,
    required this.provider,
    this.onAssetItemClick, // Parámetro añadido
  }) : super(key: key);

  @override
  State<GalleryGridView> createState() => _GalleryGridViewState();
}

class _GalleryGridViewState extends State<GalleryGridView> {
  final Map<int, AssetEntity> _assetCache = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _preloadInitialAssets();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _preloadMoreAssets();
    }
  }

  Future<void> _preloadInitialAssets() async {
    if (widget.path == null) return;

    final assets = await widget.path!.getAssetListRange(start: 0, end: 20);
    for (var i = 0; i < assets.length; i++) {
      _assetCache[i] = assets[i];
    }
    if (mounted) setState(() {});
  }

  Future<void> _preloadMoreAssets() async {
    if (widget.path == null) return;

    final start = _assetCache.length;
    final assets = await widget.path!.getAssetListRange(
      start: start,
      end: start + 20,
    );
    for (var i = 0; i < assets.length; i++) {
      _assetCache[start + i] = assets[i];
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.provider.assetCountNotifier,
      builder: (_, count, __) {
        return GridView.builder(
          controller: _scrollController,
          itemCount: count,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.provider.paramsModel!.crossAxisCount,
            childAspectRatio: widget.provider.paramsModel!.childAspectRatio,
          ),
          itemBuilder: (context, index) {
            return _buildGridItem(index);
          },
        );
      },
    );
  }

  Widget _buildGridItem(int index) {
    if (_assetCache.containsKey(index)) {
      return GestureDetector(
        onTap: () => widget.onAssetItemClick?.call(_assetCache[index]!, index),
        child: ThumbnailWidget(
          asset: _assetCache[index]!,
          index: index,
          provider: widget.provider,
        ),
      );
    }

    return FutureBuilder<List<AssetEntity>>(
      future: widget.path!.getAssetListRange(start: index, end: index + 1),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          _assetCache[index] = snapshot.data!.first;
          return GestureDetector(
            onTap:
                () =>
                    widget.onAssetItemClick?.call(snapshot.data!.first, index),
            child: ThumbnailWidget(
              asset: snapshot.data!.first,
              index: index,
              provider: widget.provider,
            ),
          );
        }
        return Container(color: Colors.grey[200]);
      },
    );
  }
}
