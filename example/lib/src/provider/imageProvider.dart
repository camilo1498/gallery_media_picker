import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class PickerDataProvider extends ChangeNotifier {

  /// save selected asset item
  List<Map<String, dynamic>> pickedFile = [];

  /// Single-select mode, there are subtle differences between interaction and multiple selection.


  /// notify changes
  final pickedFileNotifier = ValueNotifier<List<Map<String, dynamic>>>([{}]);


  void pickPath(Map<String, dynamic> path) {
    if (pickedFile.where((element) => element['id'] == path['id']).isNotEmpty) {
      pickedFile.removeWhere((val) => val['id'] == path['id']);
    } else {
      pickedFile.add(path);
    }
    pickedFileNotifier.value = pickedFile;
    pickedFileNotifier.notifyListeners();
    notifyListeners();
  }
  /// List map model
  // [0: {
        // 'id': String,
        // 'path': Future<File>,
        // 'type': int  (1 => 'image' / 2 => 'video'),
        // 'videoDuration': Duration,
        // 'createDateTime': DateTime,
        // 'latitude': double,
        // 'longitude': double,
        // 'thumbnail': Uint8List,
        // 'height': double,
        // 'width': double,
        // 'orientationHeight': int,
        // 'orientationWidth': int,
        // 'orientationSize': Size,
        // 'file': String,
        // 'modifiedDateTime': DateTime
        // 'title': String,
        // 'size': Size,
    //  },]

}