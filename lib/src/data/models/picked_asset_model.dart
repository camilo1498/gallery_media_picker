import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:gallery_media_picker/src/data/enum/picked_asset_type_enum.dart';
import 'package:photo_manager/photo_manager.dart';

/// A model representing a selected media asset (image or video) with
/// extended metadata, used by the Gallery Media Picker.
///
/// This class wraps essential and optional data extracted from
/// [AssetEntity] and adds support for additional UI-friendly data such as
/// thumbnails and orientation-aware sizes.
class PickedAssetModel {
  /// Creates a [PickedAssetModel] instance with all required properties.
  PickedAssetModel({
    required this.id,
    required this.path,
    required this.type,
    required this.size,
    required this.width,
    required this.height,
    required this.videoDuration,
    required this.createDateTime,
    required this.orientationSize,
    required this.orientationWidth,
    required this.modifiedDateTime,
    required this.orientationHeight,
    this.file,
    this.title,
    this.latitude,
    this.longitude,
    this.thumbnail,
  });

  /// Unique ID of the asset.
  final String id;

  /// Width of the asset in pixels.
  final int width;

  /// Height of the asset in pixels.
  final int height;

  /// Original size of the asset.
  final Size size;

  /// File object for the asset, if available.
  final File? file;

  /// File path to the asset, used for playback or display.
  final String path;

  /// Optional title or name of the asset.
  final String? title;

  /// Latitude coordinate where the asset was captured.
  final double? latitude;

  /// Longitude coordinate where the asset was captured.
  final double? longitude;

  /// Optional thumbnail bytes used for previews.
  final Uint8List? thumbnail;

  /// Orientation-aware width of the asset.
  final int orientationWidth;

  /// Orientation-aware height of the asset.
  final int orientationHeight;

  /// Orientation-aware [Size] of the asset.
  final Size orientationSize;

  /// Duration of the video, or zero for images.
  final Duration videoDuration;

  /// Creation timestamp of the asset.
  final DateTime createDateTime;

  /// Last modification timestamp of the asset.
  final DateTime modifiedDateTime;

  /// Type of the asset (image or video).
  final PickedAssetTypeEnum type;

  /// Creates a [PickedAssetModel] from an [AssetEntity] asynchronously.
  ///
  /// This method extracts all relevant metadata and media file
  /// information to construct a complete instance of [PickedAssetModel].
  static Future<PickedAssetModel> fromAssetEntity(AssetEntity entity) async {
    final file = await entity.file;
    final thumbnail = await entity.thumbnailData;
    final type =
        entity.type == AssetType.video
            ? PickedAssetTypeEnum.video
            : PickedAssetTypeEnum.image;

    return PickedAssetModel(
      file: file,
      type: type,
      id: entity.id,
      size: entity.size,
      width: entity.width,
      title: entity.title,
      thumbnail: thumbnail,
      height: entity.height,
      path: file?.path ?? '',
      latitude: entity.latitude,
      longitude: entity.longitude,
      videoDuration: entity.videoDuration,
      createDateTime: entity.createDateTime,
      orientationSize: entity.orientatedSize,
      orientationWidth: entity.orientatedWidth,
      orientationHeight: entity.orientatedHeight,
      modifiedDateTime: entity.modifiedDateTime,
    );
  }
}
