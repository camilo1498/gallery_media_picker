import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaPickerController extends ChangeNotifier {
  factory MediaPickerController() => instance;

  // Singleton
  MediaPickerController._internal() {
    currentAlbum.addListener(_updateAssetCount);
  }

  static final MediaPickerController instance =
      MediaPickerController._internal();

  /// Notifiers y estado
  final max = ValueNotifier<int>(0);
  final singlePickMode = ValueNotifier<bool>(false);
  final picked = ValueNotifier<List<AssetEntity>>([]);
  final pickedFile = ValueNotifier<List<PickedAssetModel>>([]);
  final currentAlbum = ValueNotifier<AssetPathEntity?>(null);
  final assetCount = ValueNotifier<int>(0);

  Timer? _debounceTimer;
  VoidCallback? onPickMax;

  /// Nuevo callback para cambios de selección
  void Function(List<PickedAssetModel>)? onPickChanged;

  final List<AssetPathEntity> pathList = [];
  MediaPickerParamsModel? paramsModel;

  // ================================
  // Getters
  // ================================

  UnmodifiableListView<AssetEntity> get pickedAssets =>
      UnmodifiableListView(picked.value);

  UnmodifiableListView<PickedAssetModel> get pickedFiles =>
      UnmodifiableListView(pickedFile.value);

  bool get isSinglePick => singlePickMode.value;

  AssetPathEntity? get album => currentAlbum.value;

  int get maxSelection => max.value;

  set maxSelection(int value) => max.value = value;

  set isSinglePick(bool value) {
    if (singlePickMode.value == value) return;
    singlePickMode.value = value;
    if (value) max.value = 1;
  }

  // ================================
  // Métodos
  // ================================

  void resetPathList(List<AssetPathEntity> newPaths) {
    pathList
      ..clear()
      ..addAll(newPaths);
    if (pathList.isNotEmpty && currentAlbum.value == null) {
      currentAlbum.value = pathList.first;
      _updateAssetCount();
    }
  }

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

    final pickedModels = await Future.wait(
      current.map((e) async {
        final file = await e.file;
        return PickedAssetModel(
          id: e.id,
          path: file?.path ?? '',
          type:
              e.typeInt == 1
                  ? PickedAssetTypeEnum.image
                  : PickedAssetTypeEnum.video,
          videoDuration: e.videoDuration,
          createDateTime: e.createDateTime,
          latitude: e.latitude,
          longitude: e.longitude,
          thumbnail: await e.thumbnailData,
          height: e.height,
          width: e.width,
          orientationHeight: e.orientatedHeight,
          orientationWidth: e.orientatedWidth,
          orientationSize: e.orientatedSize,
          file: file,
          modifiedDateTime: e.modifiedDateTime,
          title: e.title,
          size: e.size,
        );
      }),
    );

    pickedFile.value = pickedModels;
    await _notifyPickChanged();
  }

  int pickIndex(AssetEntity entity) => picked.value.indexOf(entity);

  void setAlbum(AssetPathEntity album) {
    if (album.id != currentAlbum.value?.id) {
      currentAlbum.value = album;
      _updateAssetCount();
    }
  }

  Future<void> _notifyPickChanged() async {
    if (onPickChanged == null) return;
    onPickChanged?.call(pickedFile.value);
  }

  Future<void> _updateAssetCount() async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final count = await currentAlbum.value?.assetCountAsync ?? 0;
      assetCount.value = count;
    });
  }

  @override
  void dispose() {
    onPickMax = null;
    onPickChanged = null;
    _debounceTimer?.cancel();
    currentAlbum.removeListener(_updateAssetCount);
    super.dispose();
  }
}
