import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

mixin PhotoDataProvider on ChangeNotifier {
  AssetPathEntity? _current;

  AssetPathEntity? get currentPath => _current;

  /// current gallery album
  set currentPath(AssetPathEntity? current) {
    if (_current != current) {
      _current = current;
      currentPathNotifier.value = current;
    }
  }

  /// notify changes
  final currentPathNotifier = ValueNotifier<AssetPathEntity?>(null);
  final pathListNotifier = ValueNotifier<List<AssetPathEntity>>([]);

  /// save path in list
  List<AssetPathEntity> pathList = [];

  /// order path by date
  static int _defaultSort(
      AssetPathEntity a,
      AssetPathEntity b,
      ) {
    if (a.isAll) {
      return -1;
    }
    if (b.isAll) {
      return 1;
    }
    return 0;
  }

  /// clear path list
  void resetPathList(
      List<AssetPathEntity> list, {
        int defaultIndex = 0,
        int Function(
            AssetPathEntity a,
            AssetPathEntity b,
            ) sortBy = _defaultSort,
      }) {
    list.sort(sortBy);
    pathList.clear();
    pathList.addAll(list);
    currentPath = list[defaultIndex];
    pathListNotifier.value = pathList;
    notifyListeners();
  }

}

class PickerDataProvider extends ChangeNotifier with PhotoDataProvider {
  PickerDataProvider({List<AssetPathEntity>? pathList, int max = 9}) {
    if (pathList != null && pathList.isNotEmpty ) {
      this.pathList.addAll(pathList);
    }
    pickedNotifier.value = picked;
    maxNotifier.value = max;
  }

  /// Notification when max is modified.
  final maxNotifier = ValueNotifier(0);

  int get max => maxNotifier.value;
  set max(int value) => maxNotifier.value = value;

  final onPickMax = ChangeNotifier();

  /// save selected asset item
  List<AssetEntity> picked = [];
  List<String> pickedFile = [];

  final isOriginNotifier =  ValueNotifier(false);

  bool get isOrigin => isOriginNotifier.value;

  set isOrigin(bool isOrigin) {
    isOriginNotifier.value = isOrigin;
  }

  /// Single-select mode, there are subtle differences between interaction and multiple selection.
  ///
  /// In single-select mode, when you click an unselected item, the old one is automatically cleared and the new one is selected.
  bool get singlePickMode => _singlePickMode;
  bool _singlePickMode = false;
  set singlePickMode(bool singlePickMode) {
    _singlePickMode = singlePickMode;
    if (singlePickMode) {
      maxNotifier.value = 1;
      notifyListeners();
    }
    notifyListeners();
  }

  /// notify changes
  final pickedNotifier = ValueNotifier<List<AssetEntity>>([]);
  final pickedFileNotifier = ValueNotifier<List<String>>([]);

  /// pick asset entity
  void pickEntity(AssetEntity entity) {
    if (singlePickMode) {
      if (picked.contains(entity)) {
        picked.remove(entity);
      } else {
        picked.clear();
        picked.add(entity);
      }
    } else {
      if (picked.contains(entity)) {
        picked.remove(entity);
      } else {
        if (picked.length == max) {
          onPickMax.notifyListeners();
          return;
        }
        picked.add(entity);
      }
    }
    pickedNotifier.value = picked;
    pickedNotifier.notifyListeners();
    notifyListeners();
  }

  void pickPath(String path) {
    if (singlePickMode) {
      if (pickedFile.contains(path)) {
        pickedFile.remove(path);
      } else {
        pickedFile.clear();
        pickedFile.add(path);
      }
    } else {
      if (pickedFile.contains(path)) {
        pickedFile.remove(path);
      } else {
        if (pickedFile.length == max) {
          onPickMax.notifyListeners();
          return;
        }
        pickedFile.add(path);
      }
    }
    pickedFileNotifier.value = pickedFile;
    pickedFileNotifier.notifyListeners();
    notifyListeners();
  }

   /// picked path index
  int pickIndex(AssetEntity entity) {
    return picked.indexOf(entity);
  }

}