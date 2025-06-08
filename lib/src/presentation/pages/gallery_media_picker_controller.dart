import 'package:flutter/material.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryMediaPickerController extends ChangeNotifier {
  final maxNotifier = ValueNotifier<int>(0);
  int get max => maxNotifier.value;
  set max(int value) => maxNotifier.value = value;

  final onPickMax = ChangeNotifier();

  bool _singlePickMode = false;
  bool get singlePickMode => _singlePickMode;
  set singlePickMode(bool value) {
    if (_singlePickMode != value) {
      _singlePickMode = value;
      maxNotifier.value = value ? 1 : maxNotifier.value;
      notifyListeners();
    }
  }

  final pickedNotifier = ValueNotifier<List<AssetEntity>>([]);
  final List<AssetEntity> picked = [];

  final pickedFileNotifier = ValueNotifier<List<PickedAssetModel>>([]);
  final List<PickedAssetModel> pickedFile = [];

  final currentAlbumNotifier = ValueNotifier<AssetPathEntity?>(null);
  AssetPathEntity? get currentAlbum => currentAlbumNotifier.value;
  set currentAlbum(AssetPathEntity? value) {
    if (currentAlbumNotifier.value != value) {
      currentAlbumNotifier.value = value;
      setAssetCount();
      notifyListeners();
    }
  }

  final List<AssetPathEntity> pathList = [];

  MediaPickerParamsModel? paramsModel;

  void resetPathList(List<AssetPathEntity> newPathList) {
    pathList
      ..clear()
      ..addAll(newPathList);
    if (pathList.isNotEmpty && currentAlbum == null) {
      currentAlbum = pathList.first;
    }
    notifyListeners();
  }

  void pickEntity(AssetEntity entity) {
    if (singlePickMode) {
      if (picked.contains(entity)) {
        picked.remove(entity);
      } else {
        picked
          ..clear()
          ..add(entity);
      }
    } else {
      if (picked.contains(entity)) {
        picked.remove(entity);
      } else {
        if (picked.length >= max) {
          onPickMax.notifyListeners();
          return;
        }
        picked.add(entity);
      }
    }
    // Actualiza ambos notificadores
    pickedNotifier.value = List.from(picked);
    notifyListeners();
  }

  void pickPath(PickedAssetModel path) {
    final exists = pickedFile.any((e) => e.id == path.id);
    if (_singlePickMode) {
      if (exists) {
        pickedFile.removeWhere((e) => e.id == path.id);
      } else {
        pickedFile
          ..clear()
          ..add(path);
      }
    } else {
      if (exists) {
        pickedFile.removeWhere((e) => e.id == path.id);
      } else {
        if (pickedFile.length >= max) {
          onPickMax.notifyListeners();
          return;
        }
        pickedFile.add(path);
      }
    }
    pickedFileNotifier.value = List.unmodifiable(pickedFile);
    notifyListeners();
  }

  int pickIndex(AssetEntity entity) => picked.indexOf(entity);

  int _assetCount = 0;
  int get assetCount => _assetCount;

  final assetCountNotifier = ValueNotifier<int>(0);

  Future<void> setAssetCount() async {
    await Future<dynamic>.delayed(const Duration(seconds: 1));
    if (currentAlbum != null) {
      _assetCount = await currentAlbum!.assetCountAsync;
    } else {
      _assetCount = 0;
    }
    assetCountNotifier.value = _assetCount;
    notifyListeners();
  }
}
