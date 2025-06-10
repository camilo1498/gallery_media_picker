part of '../../gallery_media_picker.dart';

class _GalleryGridViewWidget extends StatefulWidget {
  const _GalleryGridViewWidget();

  @override
  State<_GalleryGridViewWidget> createState() => _GalleryGridViewWidgeState();
}

class _GalleryGridViewWidgeState extends State<_GalleryGridViewWidget> {
  final MediaPickerController provider = MediaPickerController.instance;
  final _scrollController = ScrollController();
  final _assetCache = <int, AssetEntity>{};
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
    final album = provider.currentAlbum.value;
    if (album == null) return;

    final assets = await album.getAssetListRange(start: start, end: end);
    for (var i = 0; i < assets.length; i++) {
      _assetCache[start + i] = assets[i];
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: provider.assetCount,
      builder: (_, count, _) {
        return ValueListenableBuilder<AssetPathEntity?>(
          valueListenable: provider.currentAlbum,
          builder: (_, album, _) {
            if (album == null) return const SizedBox.shrink();

            return GridView.builder(
              controller: _scrollController,
              itemCount: count,
              gridDelegate: _buildGridDelegate(),
              itemBuilder: (_, index) => _buildGridItem(index, album),
            );
          },
        );
      },
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _buildGridDelegate() {
    final params = provider.paramsModel!;
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: params.crossAxisCount,
      childAspectRatio: params.childAspectRatio,
      mainAxisSpacing: 1.5,
      crossAxisSpacing: 1.5,
    );
  }

  Widget _buildGridItem(int index, AssetPathEntity album) {
    final asset = _assetCache[index];
    if (asset != null) {
      return AnimatedTapWidget(
        maxScale: .98,
        onTap: () => _onAssetTap(asset, index),
        /*   child: ThumbnailWidget(
          asset: asset,
          index: index,
          provider: provider,
        ),*/
        child: Container(color: Colors.grey[200]),
      );
    }

    return FutureBuilder<AssetEntity>(
      future: _loadAsset(index, album),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          final loadedAsset = snapshot.data!;
          _assetCache[index] = loadedAsset;
          return GestureDetector(
            onTap: () => _onAssetTap(loadedAsset, index),
            /*   child: ThumbnailWidget(
              asset: loadedAsset,
              index: index,
              provider: provider,
            ),*/
            child: Container(),
          );
        }
        return Container(color: Colors.grey[200]);
      },
    );
  }

  Future<AssetEntity> _loadAsset(int index, AssetPathEntity album) async {
    final assets = await album.getAssetListRange(start: index, end: index + 1);
    if (assets.isEmpty) {
      throw Exception('No asset found at index $index');
    }
    return _assetCache[index] = assets.first;
  }

  void _onAssetTap(AssetEntity asset, int index) {
    provider.pickEntity(asset);
    // Si necesitas propagar la selección, puedes usar otro listener aquí o un callback registrado.
  }
}
