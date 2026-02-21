import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:photo_manager/photo_manager.dart';

/// Controller that manages the state and logic for media selection.
///
/// This singleton controller handles album navigation, asset selection,
/// maximum selection constraints, single/multiple pick modes, and notifies
/// listeners when selections change.
class MediaPickerController extends ChangeNotifier {
  /// Creates a new instance of [MediaPickerController].
  MediaPickerController() {
    currentAlbum.addListener(_updateAssetCount);
  }

  // ================================
  // Notifiers and State
  // ================================

  /// The current permission state of the gallery.
  final ValueNotifier<PermissionState> permitState =
      ValueNotifier<PermissionState>(PermissionState.notDetermined);

  /// Maximum number of items allowed to pick.
  final ValueNotifier<int> max = ValueNotifier<int>(0);

  /// Whether the picker is in single selection mode.
  final ValueNotifier<bool> singlePickMode = ValueNotifier<bool>(false);

  /// Currently selected raw assets.
  final ValueNotifier<List<AssetEntity>> picked =
      ValueNotifier<List<AssetEntity>>([]);

  /// Currently selected parsed asset models.
  final ValueNotifier<List<PickedAssetModel>> pickedFile =
      ValueNotifier<List<PickedAssetModel>>([]);

  /// Currently selected album.
  final ValueNotifier<AssetPathEntity?> currentAlbum =
      ValueNotifier<AssetPathEntity?>(null);

  /// Number of assets in the current album.
  final ValueNotifier<int> assetCount = ValueNotifier<int>(0);

  /// Active cancellation tokens for ongoing native background extractions.
  final Map<String, PMCancelToken> _cancelTokens = {};

  Timer? _debounceTimer;

  /// Optional callback when maximum selection is reached.
  VoidCallback? onPickMax;

  /// Optional callback when selection changes.
  void Function(List<PickedAssetModel>)? onPickChanged;

  /// List of all available albums.
  final List<AssetPathEntity> pathList = [];

  /// Picker UI and behavior parameters.
  MediaPickerParamsModel paramsModel = const MediaPickerParamsModel();

  // ================================
  // Getters
  // ================================

  /// Unmodifiable view of selected asset entities.
  UnmodifiableListView<AssetEntity> get pickedAssets =>
      UnmodifiableListView(picked.value);

  /// Unmodifiable view of selected parsed files.
  UnmodifiableListView<PickedAssetModel> get pickedFiles =>
      UnmodifiableListView(pickedFile.value);

  /// Whether the picker is in single selection mode.
  bool get isSinglePick => singlePickMode.value;

  /// Currently selected album.
  AssetPathEntity? get album => currentAlbum.value;

  /// Maximum selection limit.
  int get maxSelection => max.value;

  /// Set the maximum selection limit.
  set maxSelection(int value) => max.value = value;

  /// Set single/multi pick mode and adjust max accordingly.
  set isSinglePick(bool value) {
    if (singlePickMode.value == value) return;
    singlePickMode.value = value;
    if (value) max.value = 1;
  }

  // ================================
  // Methods
  // ================================

  /// Set available albums and optionally set the initial album.
  void resetPathList(List<AssetPathEntity> newPaths, {bool reset = false}) {
    pathList
      ..clear()
      ..addAll(newPaths);
    if (pathList.isNotEmpty && (currentAlbum.value == null || reset)) {
      currentAlbum.value = pathList.first;
      unawaited(_updateAssetCount());
    } else if (pathList.isEmpty) {
      currentAlbum.value = null;
      unawaited(_updateAssetCount());
    }
  }

  /// Select or deselect an asset.
  ///
  /// Handles both single and multiple pick logic. If max is reached,
  /// calls [onPickMax].
  Future<void> pickEntity(AssetEntity entity) async {
    final singlePick = singlePickMode.value;
    final current = List<AssetEntity>.from(picked.value);

    if (singlePick) {
      if (current.length == 1 && current[0] == entity) return;
      // Cancel previous single pick extraction to save CPU
      if (current.isNotEmpty) {
        _cancelTokens[current[0].id]?.cancelRequest();
      }
      current
        ..clear()
        ..add(entity);
    } else {
      if (current.contains(entity)) {
        // Cancel the extraction running in background for deselected item
        _cancelTokens[entity.id]?.cancelRequest();
        current.remove(entity);
      } else {
        if (current.length >= max.value) {
          onPickMax?.call();
          return;
        }
        current.add(entity);
      }
    }

    picked.value = current;

    // Track a new cancel token for the upcoming extraction phase
    _cancelTokens[entity.id] = PMCancelToken();

    // Offload the heavy platform channel parsing to not block the tap animation
    unawaited(_processPickedFilesFor(current));
  }

  /// Processes the [AssetEntity] representations into [PickedAssetModel]s.
  /// Skips items that have already been parsed to save platform channel I/O.
  Future<void> _processPickedFilesFor(List<AssetEntity> targetAssets) async {
    final futures = targetAssets.map((e) async {
      final existing = pickedFile.value.where((p) => p.id == e.id).firstOrNull;
      if (existing != null) return existing;
      try {
        return await PickedAssetModel.fromAssetEntity(
          e,
          cancelToken: _cancelTokens[e.id],
        );
      } catch (_) {
        return null;
      }
    });

    final results = await Future.wait(futures);
    final newPickedFiles = results.whereType<PickedAssetModel>().toList();

    // Only commit if the user hasn't tapped anything else globally meanwhile
    if (picked.value == targetAssets) {
      pickedFile.value = newPickedFiles;
      await _notifyPickChanged();
    }
  }

  /// Return the index of a picked asset, or -1 if not picked.
  int pickIndex(AssetEntity entity) => picked.value.indexOf(entity);

  /// Change the current album and update its asset count.
  void setAlbum(AssetPathEntity album) {
    if (album.id != currentAlbum.value?.id) {
      currentAlbum.value = album;
      unawaited(_updateAssetCount());
    }
  }

  /// Notify listener of selection changes.
  Future<void> _notifyPickChanged() async {
    if (onPickChanged == null) return;
    onPickChanged?.call(pickedFile.value);
  }

  /// Update the asset count for the current album (debounced).
  Future<void> _updateAssetCount() async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final count = await currentAlbum.value?.assetCountAsync ?? 0;
      assetCount.value = count;
    });
  }

  /// Dispose the controller and clear listeners.
  @override
  void dispose() {
    onPickMax = null;
    onPickChanged = null;
    _debounceTimer?.cancel();
    currentAlbum.removeListener(_updateAssetCount);

    // Clear the ghost thumbnail/origin data generated by iOS/Android
    // to instantly recover the device's storage and RAM
    unawaited(PhotoManager.clearFileCache());

    // Kill any surviving parsing background operations
    for (final token in _cancelTokens.values) {
      token.cancelRequest();
    }
    _cancelTokens.clear();

    super.dispose();
  }
}
