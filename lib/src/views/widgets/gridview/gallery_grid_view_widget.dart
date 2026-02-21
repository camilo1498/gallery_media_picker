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
  ScrollController? _internalScrollController;
  ScrollController get _scrollController =>
      provider.paramsModel.gridViewController ?? _internalScrollController!;

  // Shortcut to access the inherited controller.
  MediaPickerController get provider => GalleryMediaProvider.of(context);

  MediaPickerController? _oldProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newProvider = provider;
    if (_oldProvider != newProvider) {
      if (_oldProvider != null) {
        _oldProvider!.currentAlbum.removeListener(_onAlbumChanged);
        _oldProvider!.assetCount.removeListener(_onAssetCountChanged);
        _scrollController.removeListener(_preloadWhenNearBottom);
      }

      _oldProvider = newProvider;

      if (newProvider.paramsModel.gridViewController == null &&
          _internalScrollController == null) {
        _internalScrollController = ScrollController();
      }

      _scrollController.addListener(_preloadWhenNearBottom);
      newProvider.currentAlbum.addListener(_onAlbumChanged);
      newProvider.assetCount.addListener(_onAssetCountChanged);

      if (newProvider.album != null && _assetCache.isEmpty) {
        unawaited(_loadInitialAssets(_albumChangeId));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_preloadWhenNearBottom);
    _internalScrollController?.dispose();
    _oldProvider?.currentAlbum.removeListener(_onAlbumChanged);
    _oldProvider?.assetCount.removeListener(_onAssetCountChanged);
    super.dispose();
  }

  int _albumChangeId = 0;

  // Called when the selected album changes.
  // Clears cache and reloads assets from the new album.
  void _onAlbumChanged() {
    _albumChangeId++;
    _assetCache.clear();
    unawaited(_loadInitialAssets(_albumChangeId));
  }

  // Called when the asset count changes (e.g. new photos saved externally).
  // Invalidates the stale cache and reloads so new media appears.
  void _onAssetCountChanged() {
    _albumChangeId++;
    _assetCache.clear();
    unawaited(_loadInitialAssets(_albumChangeId));
  }

  // If the scroll position is near the bottom, preload more assets.
  void _preloadWhenNearBottom() {
    if (_scrollController.position.extentAfter < 500) {
      unawaited(
        _preloadAssets(
          _assetCache.length,
          _assetCache.length + _preloadAmount,
          _albumChangeId,
        ),
      );
    }
  }

  // Loads the initial batch of assets when an album is selected.
  Future<void> _loadInitialAssets(int changeId) async {
    final album = provider.album;
    if (album == null) return;

    // Fetch total asset count to configure grid.
    final count = await album.assetCountAsync;

    if (changeId != _albumChangeId) return;
    provider.assetCount.value = count;

    // Wait until any previous preload is done
    while (_isLoading) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (changeId != _albumChangeId) return;
    }

    // Load first N assets.
    await _preloadAssets(0, _preloadAmount, changeId);

    if (changeId != _albumChangeId) return;
    if (mounted) setState(() {});
  }

  // Preloads a range of assets from [start] to [end] (exclusive).
  Future<void> _preloadAssets(int start, int end, int changeId) async {
    if (_isLoading ||
        provider.album == null ||
        start >= provider.assetCount.value) {
      return;
    }
    _isLoading = true;

    final album = provider.album!;
    final assets = await album.getAssetListRange(
      start: start,
      end: end.clamp(0, provider.assetCount.value),
    );

    if (changeId != _albumChangeId) {
      _isLoading = false;
      return;
    }

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

        // React to asset count changes (e.g. new photos saved externally)
        // without requiring a full album swap that causes flicker.
        return ValueListenableBuilder<int>(
          valueListenable: provider.assetCount,
          builder: (_, count, _) {
            if (count == 0) {
              return Center(
                child: Text(provider.paramsModel.translations.noMediaFound),
              );
            }

            // Build a scrollable grid of media thumbnails.
            return Container(
              decoration: BoxDecoration(
                color:
                    provider.paramsModel.gridViewBgColor ??
                    Theme.of(context).colorScheme.surface,
              ),
              child: GridView.builder(
                controller: _scrollController,
                itemCount: count,
                padding: provider.paramsModel.gridPadding,
                physics: provider.paramsModel.gridViewPhysics,
                gridDelegate: _buildGridDelegate(context),
                itemBuilder: (_, index) {
                  if (index >= count) {
                    return const SizedBox.shrink();
                  }
                  return _buildGridItem(index, album);
                },
              ),
            );
          },
        );
      },
    );
  }

  // Creates a grid delegate using the user's layout preferences.
  SliverGridDelegateWithMaxCrossAxisExtent _buildGridDelegate(
    BuildContext context,
  ) {
    final params = provider.paramsModel;
    // Calculate a max extent relative to a standard mobile width so that it
    // respects the user's column preference on mobile, but auto-expands the
    // column count on wider screens like tablets or desktop.
    final maxExtent = 360.0 / params.crossAxisCount;

    return SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: maxExtent,
      mainAxisSpacing: 1.5,
      crossAxisSpacing: 1.5,
      childAspectRatio: params.childAspectRatio,
    );
  }

  // Builds an individual grid item (thumbnail) at the specified index.
  Widget _buildGridItem(int index, AssetPathEntity album) {
    if (index < 0) return const SizedBox.shrink();

    final asset = _assetCache[index];
    if (asset != null) return _buildAssetWidget(asset, index);

    // Fallback to async load if not already cached.
    return FutureBuilder<AssetEntity?>(
      future: _loadAsset(index, album),
      builder: (_, snapshot) => snapshot.hasData
          ? _buildAssetWidget(snapshot.data!, index)
          : Container(color: Colors.grey[100]),
    );
  }

  // Builds the widget for a single media asset, including selection overlay.
  Widget _buildAssetWidget(AssetEntity asset, int index) {
    return _SelectionWatcher(
      key: ValueKey(asset.id),
      asset: asset,
      builder: (_, {required isSelected}) {
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
  Future<AssetEntity?> _loadAsset(int index, AssetPathEntity album) async {
    final assets = await album.getAssetListRange(start: index, end: index + 1);
    if (assets.isEmpty) return null;
    final asset = assets.first;
    _assetCache[index] = asset;
    return asset;
  }
}

/// A highly-optimized stateful watcher that isolates selection rebuilds.
///
/// Under a standard reactive architecture, selecting a photo rebuilds the
/// entire list of visible items because they all listen to the global `picked`
/// list. [ _SelectionWatcher ] subscribes to the `picked` list but manually
/// caches its own Boolean state. It only invokes `setState` if its exact
/// ownership flips, guaranteeing O(1) selection rebuilds across thousands
/// of grid items.
class _SelectionWatcher extends StatefulWidget {
  const _SelectionWatcher({
    super.key,
    required this.asset,
    required this.builder,
  });

  final AssetEntity asset;
  final Widget Function(BuildContext context, {required bool isSelected})
  builder;

  @override
  State<_SelectionWatcher> createState() => _SelectionWatcherState();
}

class _SelectionWatcherState extends State<_SelectionWatcher> {
  bool _isSelected = false;
  MediaPickerController? _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newProvider = GalleryMediaProvider.of(context);
    if (_provider != newProvider) {
      _provider?.picked.removeListener(_onSelectionChanged);
      _provider = newProvider;
      _provider!.picked.addListener(_onSelectionChanged);
      _isSelected = _provider!.picked.value.contains(widget.asset);
    }
  }

  void _onSelectionChanged() {
    final isNowSelected = _provider!.picked.value.contains(widget.asset);
    if (_isSelected != isNowSelected) {
      if (mounted) {
        setState(() => _isSelected = isNowSelected);
      }
    }
  }

  @override
  void dispose() {
    _provider?.picked.removeListener(_onSelectionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, isSelected: _isSelected);
  }
}
