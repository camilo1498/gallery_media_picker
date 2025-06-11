import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// An [ImageProvider] that decodes a thumbnail image from an [AssetEntity]
/// using the `photo_manager` package.
@immutable
class DecodeImage extends ImageProvider<DecodeImage> {
  /// Creates an instance of [DecodeImage].
  ///
  /// [asset] is the media asset to load the thumbnail for.
  /// [scale] is the image scale (e.g., for high-DPI screens).
  /// [thumbSize] sets the dimensions for the thumbnail (width and height).
  const DecodeImage({
    required this.asset,
    this.scale = 1.0,
    this.thumbSize = 200,
  });

  /// The media asset to load.
  final AssetEntity asset;

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
      debugLabel: 'GalleryThumbnail(${key.asset.id})',
    );
  }

  /// Loads and decodes the thumbnail image asynchronously.
  Future<ui.Codec> _loadAsync(
    DecodeImage key,
    ImageDecoderCallback decode,
  ) async {
    try {
      final thumbData = await key.asset.thumbnailDataWithSize(
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
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.transparent;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
      paint,
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
          asset == other.asset &&
          thumbSize == other.thumbSize;

  @override
  int get hashCode => Object.hash(asset, thumbSize);
}
