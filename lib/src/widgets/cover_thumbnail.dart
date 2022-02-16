import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/provider/gallery_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:ui' as ui;

class CoverThumbnail extends StatefulWidget {
  final int thumbnailQuality;
  final double thumbnailScale;
  final BoxFit thumbnailFit;
  const CoverThumbnail(
      {Key? key,
      this.thumbnailQuality = 120,
      this.thumbnailScale = 1.0,
      this.thumbnailFit = BoxFit.cover})
      : super(key: key);

  @override
  State<CoverThumbnail> createState() => _CoverThumbnailState();
}

class _CoverThumbnailState extends State<CoverThumbnail> {
  /// create object of PickerDataProvider
  final provider = PickerDataProvider();

  @override
  void initState() {
    _getPermission();
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      provider.pickedFile.clear();
      provider.picked.clear();
      provider.pathList.clear();
      PhotoManager.stopChangeNotify();
      super.dispose();
    }
  }

  _getPermission() async {
    var result = await PhotoManager.requestPermissionExtend(
        requestOption: const PermisstionRequestOption(
            iosAccessLevel: IosAccessLevel.readWrite));
    if (result.isAuth) {
      PhotoManager.startChangeNotify();
      PhotoManager.addChangeCallback((value) {
        _refreshPathList();
      });

      if (provider.pathList.isEmpty) {
        _refreshPathList();
      }
    } else {
      /// if result is fail, you can call `PhotoManager.openSetting();`
      /// to open android/ios application's setting to get permission
      PhotoManager.openSetting();
    }
  }

  _refreshPathList() {
    PhotoManager.getAssetPathList().then((pathList) {
      /// don't delete setState
      setState(() {
        provider.resetPathList(pathList);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return provider.pathList.isNotEmpty
        ? Image(
            image: PathCoverImageProvider(provider.pathList[0],
                thumbSize: widget.thumbnailQuality,
                index: 0,
                scale: widget.thumbnailScale),
            fit: widget.thumbnailFit,
            filterQuality: FilterQuality.high,
          )
        : Container();
  }
}

class PathCoverImageProvider extends ImageProvider<PathCoverImageProvider> {
  final AssetPathEntity entity;
  final double scale;
  final int thumbSize;
  final int index;

  const PathCoverImageProvider(
    this.entity, {
    this.scale = 1.0,
    this.thumbSize = 120,
    this.index = 0,
  });

  @override
  ImageStreamCompleter load(
      PathCoverImageProvider key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
    );
  }

  Future<ui.Codec> _loadAsync(
      PathCoverImageProvider key, DecoderCallback decode) async {
    assert(key == this);

    final coverEntity =
        (await key.entity.getAssetListRange(start: index, end: index + 1))[0];

    final bytes = await coverEntity.thumbDataWithSize(thumbSize, thumbSize);

    return decode(bytes!);
  }

  @override
  Future<PathCoverImageProvider> obtainKey(
      ImageConfiguration configuration) async {
    return this;
  }
}
