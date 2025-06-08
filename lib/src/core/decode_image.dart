import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class DecodeImage extends ImageProvider<DecodeImage> {
  final AssetPathEntity entity;
  final double scale;
  final int thumbSize;
  final int index;

  const DecodeImage(
    this.entity, {
    this.scale = 1.0,
    this.thumbSize = 200,
    this.index = 0,
  });

  @override
  Future<DecodeImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<DecodeImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(DecodeImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      chunkEvents: Stream<ImageChunkEvent>.empty(),
      informationCollector:
          () => [
            DiagnosticsProperty<AssetPathEntity>('AssetPath', key.entity),
            DiagnosticsProperty<int>('Index', key.index),
          ],
    );
  }

  Future<ui.Codec> _loadAsync(
    DecodeImage key,
    ImageDecoderCallback decode,
  ) async {
    try {
      final assetList = await key.entity.getAssetListRange(
        start: key.index,
        end: key.index + 1,
      );

      if (assetList.isEmpty) {
        throw StateError('No asset found at index ${key.index}');
      }

      final thumbData = await assetList.first.thumbnailDataWithSize(
        ThumbnailSize(key.thumbSize, key.thumbSize),
        quality: 85,
      );

      if (thumbData == null) {
        throw StateError('Failed to load thumbnail data');
      }

      final buffer = await ui.ImmutableBuffer.fromUint8List(thumbData);
      return decode(buffer);
    } catch (e) {
      debugPrint('Error loading image: $e');
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DecodeImage &&
            runtimeType == other.runtimeType &&
            entity == other.entity &&
            index == other.index &&
            thumbSize == other.thumbSize;
  }

  @override
  int get hashCode => Object.hash(entity, index, thumbSize);
}
