import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:photo_manager/photo_manager.dart';

class DecodeImage extends ImageProvider<DecodeImage> {
  final AssetPathEntity entity;
  final double scale;
  final int thumbSize;
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
      DecodeImage key, ImageDecoderCallback decode) async {
    assert(key == this);

    final assetList =
        await key.entity.getAssetListRange(start: index, end: index + 1);
    final coverEntity = assetList[0];

    final thumbData = await coverEntity.thumbnailDataWithSize(
      ThumbnailSize(thumbSize, thumbSize),
    );

    if (thumbData == null) {
      throw StateError("Unable to load thumbnail data for asset.");
    }

    return decode(await ui.ImmutableBuffer.fromUint8List(thumbData));
  }
}
