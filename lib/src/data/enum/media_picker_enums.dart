import 'package:photo_manager/photo_manager.dart';

/// Defines the available quality levels for thumbnail generation.
enum ThumbnailQuality { low, medium, high }

/// Extension to retrieve the numeric size for each quality level.
extension ThumbnailQualityExtension on ThumbnailQuality {
  /// Returns the pixel size associated with the thumbnail quality.
  int get size {
    switch (this) {
      case ThumbnailQuality.low:
        return 100;
      case ThumbnailQuality.medium:
        return 250;
      case ThumbnailQuality.high:
        return 400;
    }
  }
}

/// An enum representing the type of the picked asset.
///
/// This is used to differentiate between media types such as
/// images, videos, or other unsupported formats.
enum PickedAssetType {
  /// The asset is a video file.
  video,

  /// The asset is an image file.
  image,

  /// The asset type is unknown or unsupported.
  other,
}

/// An enum that defines the types of media to display or filter
/// in the gallery media picker.
///
/// It controls whether the picker should show all media, only images,
/// or only videos.
enum GalleryMediaType {
  /// Show all types of media (images and videos).
  all,

  /// Show only image files.
  onlyImages,

  /// Show only video files.
  onlyVideos,
}

/// Extension to convert a [GalleryMediaType] to a [RequestType].
extension GalleryMediaTypeExtension on GalleryMediaType {
  /// Returns the corresponding [RequestType]
  /// based on the [GalleryMediaType].
  RequestType get type {
    switch (this) {
      case GalleryMediaType.all:
        return RequestType.all;
      case GalleryMediaType.onlyImages:
        return RequestType.image;
      case GalleryMediaType.onlyVideos:
        return RequestType.video;
    }
  }
}
