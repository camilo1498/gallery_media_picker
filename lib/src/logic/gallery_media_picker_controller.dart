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
  /// Factory constructor that returns the singleton instance.
  factory MediaPickerController() => instance;

  // Singleton instance initialization
  MediaPickerController._internal() {
    currentAlbum.addListener(_updateAssetCount);
  }

  /// The singleton instance of this controller.
  static final MediaPickerController instance =
      MediaPickerController._internal();

  // ================================
  // Notifiers and State
  // ================================

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
  void resetPathList(List<AssetPathEntity> newPaths) {
    pathList
      ..clear()
      ..addAll(newPaths);
    if (pathList.isNotEmpty && currentAlbum.value == null) {
      currentAlbum.value = pathList.first;
      _updateAssetCount();
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
      current
        ..clear()
        ..add(entity);
    } else {
      if (current.contains(entity)) {
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

    // Build list of enriched picked asset models
    final pickedModels = await Future.wait(
      current.map(PickedAssetModel.fromAssetEntity),
    );

    pickedFile.value = pickedModels;
    await _notifyPickChanged();
  }

  /// Return the index of a picked asset, or -1 if not picked.
  int pickIndex(AssetEntity entity) => picked.value.indexOf(entity);

  /// Change the current album and update its asset count.
  void setAlbum(AssetPathEntity album) {
    if (album.id != currentAlbum.value?.id) {
      currentAlbum.value = album;
      _updateAssetCount();
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
    super.dispose();
  }
}
