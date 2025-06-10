part of '../../gallery_media_picker.dart';

class _GalleryGridViewWidget extends StatefulWidget {
  const _GalleryGridViewWidget();

  @override
  State<_GalleryGridViewWidget> createState() => _GalleryGridViewWidgetState();
}

class _GalleryGridViewWidgetState extends State<_GalleryGridViewWidget> {
  final _preloadAmount = 20;
  bool _isLoading = false;
  final _assetCache = <int, AssetEntity>{};
  final _scrollController = ScrollController();

  MediaPickerController get provider => MediaPickerController.instance;

  @override
  void initState() {
    super.initState();
    _scrollController
      ..addListener(_preloadWhenNearBottom)
      ..addListener(_preloadWhenNearBottom);
    provider.currentAlbum.addListener(_onAlbumChanged);
    if (provider.album != null) _loadInitialAssets();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_preloadWhenNearBottom)
      ..removeListener(_preloadWhenNearBottom)
      ..dispose();
    provider.currentAlbum.removeListener(_onAlbumChanged);
    super.dispose();
  }

  void _onAlbumChanged() {
    _assetCache.clear();
    _loadInitialAssets();
  }

  void _preloadWhenNearBottom() {
    if (_scrollController.position.extentAfter < 500) {
      _preloadAssets(_assetCache.length, _assetCache.length + _preloadAmount);
    }
  }

  Future<void> _loadInitialAssets() async {
    if (_isLoading || provider.album == null) return;
    _isLoading = true;

    provider.assetCount.value = await provider.album!.assetCountAsync;
    await _preloadAssets(0, _preloadAmount);

    if (mounted) setState(() {});
    _isLoading = false;
  }

  Future<void> _preloadAssets(int start, int end) async {
    if (_isLoading ||
        provider.album == null ||
        start >= provider.assetCount.value) {
      return;
    }
    _isLoading = true;

    final assets = await provider.album!.getAssetListRange(
      start: start,
      end: end.clamp(0, provider.assetCount.value),
    );

    assets.asMap().forEach((i, asset) => _assetCache[start + i] = asset);
    if (mounted) setState(() {});
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AssetPathEntity?>(
      valueListenable: provider.currentAlbum,
      builder: (_, album, __) {
        if (album == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.assetCount.value == 0) {
          return const Center(child: Text("No media found."));
        }

        return GridView.builder(
          controller: _scrollController,
          itemCount: provider.assetCount.value,
          gridDelegate: _buildGridDelegate(),
          itemBuilder: (_, index) => _buildGridItem(index, album),
        );
      },
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _buildGridDelegate() {
    final params = provider.paramsModel!;
    return SliverGridDelegateWithFixedCrossAxisCount(
      mainAxisSpacing: 1.5,
      crossAxisSpacing: 1.5,
      crossAxisCount: params.crossAxisCount,
      childAspectRatio: params.childAspectRatio,
    );
  }

  Widget _buildGridItem(int index, AssetPathEntity album) {
    final asset = _assetCache[index];
    if (asset != null) return _buildAssetWidget(asset, index);

    return FutureBuilder<AssetEntity>(
      future: _loadAsset(index, album),
      builder:
          (_, snapshot) =>
              snapshot.hasData
                  ? _buildAssetWidget(snapshot.data!, index)
                  : Container(color: Colors.grey[100]),
    );
  }

  Widget _buildAssetWidget(AssetEntity asset, int index) {
    return ValueListenableBuilder<List<AssetEntity>>(
      valueListenable: provider.picked,
      builder: (_, picked, _) {
        final isSelected = picked.contains(asset);

        return AnimatedTapWidget(
          maxScale: .98,
          onTap: () => provider.pickEntity(asset),
          child: ThumbnailWidget(
            index: index,
            asset: asset,
            params: provider.paramsModel!,
            currentAlbum: provider.currentAlbum.value!,
            isSelected: isSelected,
          ),
        );
      },
    );
  }

  Future<AssetEntity> _loadAsset(int index, AssetPathEntity album) async {
    final assets = await album.getAssetListRange(start: index, end: index + 1);
    return _assetCache[index] = assets.first;
  }
}
