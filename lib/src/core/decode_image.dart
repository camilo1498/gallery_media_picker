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
  final int index;
  final double scale;
  final int thumbSize;

  @override
  Future<DecodeImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<DecodeImage>(this);

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
    try {
      final asset = await _loadAsset(key.entity, key.index);
      if (asset == null) return _errorCodec(decode);

      final thumbData = await asset.thumbnailDataWithSize(
        ThumbnailSize(key.thumbSize, key.thumbSize),
        quality: 80,
      );

      if (thumbData == null) return _errorCodec(decode);

      final buffer = await ui.ImmutableBuffer.fromUint8List(thumbData);
      return decode(buffer);
    } catch (e, stack) {
      debugPrint('Error loading image: $e\n$stack');
      return _errorCodec(decode);
    }
  }

  Future<AssetEntity?> _loadAsset(AssetPathEntity entity, int index) async {
    final assets = await entity.getAssetListRange(start: index, end: index + 1);
    return assets.isNotEmpty ? assets.first : null;
  }

  Future<ui.Codec> _errorCodec(ImageDecoderCallback decode) async {
    final bytes = await _createPlaceholderBytes();
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  Future<Uint8List> _createPlaceholderBytes() async {
    const size = 10;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..drawRect(
      Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
      Paint()..color = Colors.grey[300]!,
    );
    final image = await recorder.endRecording().toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecodeImage &&
          runtimeType == other.runtimeType &&
          entity == other.entity &&
          index == other.index &&
          thumbSize == other.thumbSize;

  @override
  int get hashCode => Object.hash(entity, index, thumbSize);
}
