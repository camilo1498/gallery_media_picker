import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// Un [ImageProvider] personalizado que decodifica una miniatura
/// de una entidad de tipo [AssetPathEntity] usando `photo_manager`.
class DecodeImage extends ImageProvider<DecodeImage> {
  /// Álbum o entidad que contiene los assets (imágenes/videos).
  final AssetPathEntity entity;

  /// Escala de la imagen.
  final double scale;

  /// Tamaño de la miniatura (ancho y alto).
  final int thumbSize;

  /// Índice del asset dentro del álbum.
  final int index;

  const DecodeImage(
    this.entity, {
    this.scale = 1.0,
    this.thumbSize = 120,
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
    );
  }

  Future<ui.Codec> _loadAsync(
    DecodeImage key,
    ImageDecoderCallback decode,
  ) async {
    assert(key == this);

    final assetList = await key.entity.getAssetListRange(
      start: index,
      end: index + 1,
    );

    if (assetList.isEmpty) {
      throw StateError("No assets found at index $index.");
    }

    final asset = assetList.first;
    final thumbData = await asset.thumbnailDataWithSize(
      ThumbnailSize(thumbSize, thumbSize),
    );

    if (thumbData == null) {
      throw StateError(
        "Unable to load thumbnail data for asset at index $index.",
      );
    }

    final buffer = await ui.ImmutableBuffer.fromUint8List(thumbData);
    return decode(buffer);
  }
}
