import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// An [ImageProvider] that decodes a thumbnail image from an [AssetPathEntity]
/// (e.g., an album) using the `photo_manager` package.
///
/// This class is useful for displaying images in a grid without having to
/// manually manage thumbnail loading and decoding.
@immutable
class DecodeImage extends ImageProvider<DecodeImage> {
  /// Creates an instance of [DecodeImage].
  ///
  /// [entity] refers to the album or folder of media assets.
  /// [index] is the index of the asset to display.
  /// [scale] is the image scale (e.g., for high-DPI screens).
  /// [thumbSize] sets the dimensions for the thumbnail (width and height).
  const DecodeImage(
    this.entity, {
    this.index = 0,
    this.scale = 1.0,
    this.thumbSize = 200,
  });

  /// The album or folder of media assets.
  final AssetPathEntity entity;

  /// Index of the asset in the album.
  final int index;

  /// Image scale (used for high-DPI displays).
  final double scale;

  /// Size of the thumbnail (width and height in pixels).
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

  /// Loads and decodes the thumbnail image asynchronously.
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
    } on Exception catch (e, stack) {
      debugPrint('Error loading image: $e\n$stack');
      return _errorCodec(decode);
    }
  }

  /// Retrieves a single asset from the specified album.
  Future<AssetEntity?> _loadAsset(AssetPathEntity entity, int index) async {
    final assets = await entity.getAssetListRange(start: index, end: index + 1);
    return assets.isNotEmpty ? assets.first : null;
  }

  /// Fallback method to provide a blank placeholder image if loading fails.
  Future<ui.Codec> _errorCodec(ImageDecoderCallback decode) async {
    final bytes = await _createPlaceholderBytes();
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  /// Creates a transparent 10x10 PNG placeholder image.
  Future<Uint8List> _createPlaceholderBytes() async {
    const size = 10;
    final recorder = ui.PictureRecorder();
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
