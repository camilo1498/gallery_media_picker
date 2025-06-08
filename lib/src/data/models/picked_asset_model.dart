import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

class PickedAssetModel {
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
  final String id;
  final int width;
  final Size size;
  final File? file;
  final int height;
  final String path;
  final String type;
  final String? title;
  final double? latitude;
  final double? longitude;
  final Uint8List? thumbnail;
  final int orientationWidth;
  final Size orientationSize;
  final int orientationHeight;
  final Duration videoDuration;
  final DateTime createDateTime;
  final DateTime modifiedDateTime;
}
