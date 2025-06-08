import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

@immutable
class DecodeImage extends ImageProvider<DecodeImage> {
  const DecodeImage(
    this.entity, {
    this.index = 0,
    this.scale = 1.0,
    this.thumbSize = 200,
  });
  final AssetPathEntity entity;
  final double scale;
  final int thumbSize;
  final int index;

  @override
  Future<DecodeImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<DecodeImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(DecodeImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: 'GalleryThumbnail(${key.entity.name} - ${key.index})',
    );
  }

  Future<ui.Codec> _loadAsync(
    DecodeImage key,
    ImageDecoderCallback decode,
  ) async {
    assert(key == this);

    try {
      final assetList = await key.entity.getAssetListRange(
        start: key.index,
        end: key.index + 1,
      );

      if (assetList.isEmpty) {
        debugPrint(
          'No asset found at index ${key.index} in album ${key.entity.name}',
        );
        return _createErrorPlaceholder(key.thumbSize, decode);
      }

      final asset = assetList.first;
      final thumbData = await asset.thumbnailDataWithSize(
        ThumbnailSize(key.thumbSize, key.thumbSize),
        quality: 80,
      );

      if (thumbData == null) {
        debugPrint('Failed to load thumbnail for asset at index ${key.index}');
        return _createErrorPlaceholder(key.thumbSize, decode);
      }

      final buffer = await ui.ImmutableBuffer.fromUint8List(thumbData);
      return decode(buffer);
    } catch (e, stack) {
      debugPrint('Error loading thumbnail: $e\n$stack');
      return _createErrorPlaceholder(key.thumbSize, decode);
    }
  }

  Future<ui.Codec> _createErrorPlaceholder(
    int size,
    ImageDecoderCallback decode,
  ) async {
    final placeholder = await _createBlankImage(size, size);
    final buffer = await ui.ImmutableBuffer.fromUint8List(placeholder);
    return decode(buffer);
  }

  Future<Uint8List> _createBlankImage(int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.grey[300]!;

    canvas.drawRect(
      Rect.fromLTRB(0, 0, width.toDouble(), height.toDouble()),
      paint,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DecodeImage &&
            index == other.index &&
            entity == other.entity &&
            thumbSize == other.thumbSize &&
            runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => Object.hash(entity, index, thumbSize);
}
