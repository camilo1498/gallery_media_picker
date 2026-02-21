import 'package:flutter/foundation.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';

class PickerDataProvider extends ChangeNotifier {
  final List<PickedAssetModel> _pickedFiles = [];

  final ValueNotifier<List<PickedAssetModel>> pickedFileNotifier =
      ValueNotifier([]);

  List<PickedAssetModel> get pickedFiles => List.unmodifiable(_pickedFiles);

  void pickPath(PickedAssetModel path) {
    if (_pickedFiles.any((element) => element.id == path.id)) {
      _pickedFiles.removeWhere((val) => val.id == path.id);
    } else {
      _pickedFiles.add(path);
    }
    pickedFileNotifier.value = List.unmodifiable(_pickedFiles);
    notifyListeners();
  }

  void setPickedFiles(List<PickedAssetModel> files) {
    _pickedFiles
      ..clear()
      ..addAll(files);
    pickedFileNotifier.value = List.unmodifiable(_pickedFiles);
    notifyListeners();
  }
}
