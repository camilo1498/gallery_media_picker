part of '../../gallery_media_picker.dart';

/// A widget that displays a scrollable, responsive grid of media thumbnails
/// (photos and videos) loaded from the selected album.
class _GalleryGridViewWidget extends StatefulWidget {
  const _GalleryGridViewWidget();

  @override
  State<_GalleryGridViewWidget> createState() => _GalleryGridViewWidgetState();
}

class _GalleryGridViewWidgetState extends State<_GalleryGridViewWidget> {
  // Number of assets to preload each time the user nears the end of the scroll.
  final _preloadAmount = 20;

  // Tracks whether assets are currently being loaded
  // to prevent overlapping loads.
  bool _isLoading = false;

  // Stores loaded assets by index to avoid redundant fetches.
  final _assetCache = <int, AssetEntity>{};

  // Scroll controller to monitor scroll position for preloading logic.
  late final ScrollController _scrollController;

  // Shortcut to access the singleton controller.
  MediaPickerController get provider => MediaPickerController.instance;

  @override
  void initState() {
    super.initState();

    _scrollController =
        provider.paramsModel.gridViewController ?? ScrollController();

    // Attach scroll listener to trigger preloading when nearing the bottom.
    _scrollController
      ..addListener(_preloadWhenNearBottom)
      ..addListener(_preloadWhenNearBottom); // duplicated intentionally?

    // Listen for album changes to reload content.
    provider.currentAlbum.addListener(_onAlbumChanged);

    // Load initial assets if an album is already selected.
    if (provider.album != null) _loadInitialAssets();
  }

  @override
  void dispose() {
    // Remove scroll listeners and clean up scroll controller.
    _scrollController
      ..removeListener(_preloadWhenNearBottom)
      ..removeListener(_preloadWhenNearBottom)
      ..dispose();

    // Unsubscribe from album change notifications.
    provider.currentAlbum.removeListener(_onAlbumChanged);

    super.dispose();
  }

  // Called when the selected album changes.
  // Clears cache and reloads assets from the new album.
  void _onAlbumChanged() {
    _assetCache.clear();
    _loadInitialAssets();
  }

  // If the scroll position is near the bottom, preload more assets.
  void _preloadWhenNearBottom() {
    if (_scrollController.position.extentAfter < 500) {
      _preloadAssets(_assetCache.length, _assetCache.length + _preloadAmount);
    }
  }

  // Loads the initial batch of assets when an album is selected.
  Future<void> _loadInitialAssets() async {
    if (_isLoading || provider.album == null) return;
    _isLoading = true;

    // Fetch total asset count to configure grid.
    provider.assetCount.value = await provider.album!.assetCountAsync;

    // Load first N assets.
    await _preloadAssets(0, _preloadAmount);

    // Update UI after loading.
    if (mounted) setState(() {});
    _isLoading = false;
  }

  // Preloads a range of assets from [start] to [end] (exclusive).
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

    // Store loaded assets in cache.
    assets.asMap().forEach((i, asset) => _assetCache[start + i] = asset);

    if (mounted) setState(() {});
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AssetPathEntity?>(
      valueListenable: provider.currentAlbum,
      builder: (_, album, _) {
        if (album == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.assetCount.value == 0) {
          return const Center(child: Text('No media found.'));
        }

        // Build a scrollable grid of media thumbnails.
        return Container(
          decoration: BoxDecoration(
            color: provider.paramsModel.gridViewBgColor,
          ),
          child: GridView.builder(
            controller: _scrollController,
            itemCount: provider.assetCount.value,
            padding: provider.paramsModel.gridPadding,
            physics: provider.paramsModel.gridViewPhysics,
            gridDelegate: _buildGridDelegate(),
            itemBuilder: (_, index) => _buildGridItem(index, album),
          ),
        );
      },
    );
  }

  // Creates a grid delegate using the user's layout preferences.
  SliverGridDelegateWithFixedCrossAxisCount _buildGridDelegate() {
    final params = provider.paramsModel;
    return SliverGridDelegateWithFixedCrossAxisCount(
      mainAxisSpacing: 1.5,
      crossAxisSpacing: 1.5,
      crossAxisCount: params.crossAxisCount,
      childAspectRatio: params.childAspectRatio,
    );
  }

  // Builds an individual grid item (thumbnail) at the specified index.
  Widget _buildGridItem(int index, AssetPathEntity album) {
    final asset = _assetCache[index];
    if (asset != null) return _buildAssetWidget(asset, index);

    // Fallback to async load if not already cached.
    return FutureBuilder<AssetEntity>(
      future: _loadAsset(index, album),
      builder:
          (_, snapshot) =>
              snapshot.hasData
                  ? _buildAssetWidget(snapshot.data!, index)
                  : Container(color: Colors.grey[100]),
    );
  }

  // Builds the widget for a single media asset, including selection overlay.
  Widget _buildAssetWidget(AssetEntity asset, int index) {
    return ValueListenableBuilder<List<AssetEntity>>(
      valueListenable: provider.picked,
      builder: (_, picked, _) {
        final isSelected = picked.contains(asset);

        return AnimatedTapWidget(
          onTap: () => provider.pickEntity(asset),
          child: ThumbnailWidget(
            asset: asset,
            isSelected: isSelected,
            params: provider.paramsModel,
          ),
        );
      },
    );
  }

  // Loads a single asset entity for a specific index.
  Future<AssetEntity> _loadAsset(int index, AssetPathEntity album) async {
    final assets = await album.getAssetListRange(start: index, end: index + 1);
    return _assetCache[index] = assets.first;
  }
}
