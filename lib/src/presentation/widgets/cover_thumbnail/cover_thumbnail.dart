import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/core/decode_image.dart';
import 'package:gallery_media_picker/src/core/functions.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:photo_manager/photo_manager.dart';

class CoverThumbnail extends StatefulWidget {
  const CoverThumbnail({
    super.key,
    this.thumbnailQuality = 120,
    this.thumbnailScale = 1.0,
    this.thumbnailFit = BoxFit.cover,
  });
  final int thumbnailQuality;
  final double thumbnailScale;
  final BoxFit thumbnailFit;

  @override
  State<CoverThumbnail> createState() => _CoverThumbnailState();
}

class _CoverThumbnailState extends State<CoverThumbnail> {
  final GalleryMediaPickerController _provider = GalleryMediaPickerController();

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    await GalleryFunctions.getPermission((callback) {
      if (mounted) setState(callback);
    }, _provider);
  }

  @override
  void dispose() {
    if (mounted) {
      _provider.pickedFile.clear();
      _provider.picked.clear();
      _provider.pathList.clear();
      PhotoManager.stopChangeNotify();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_provider.pathList.isEmpty) return const SizedBox.shrink();

    return Image(
      image: DecodeImage(
        _provider.pathList[0],
        thumbSize: widget.thumbnailQuality,
        scale: widget.thumbnailScale,
      ),
      fit: widget.thumbnailFit,
      filterQuality: FilterQuality.high,
    );
  }
}
