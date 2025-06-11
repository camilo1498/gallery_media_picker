/// An enum representing the type of the picked asset.
///
/// This is used to differentiate between media types such as
/// images, videos, or other unsupported formats.
enum PickedAssetTypeEnum {
  /// The asset is a video file.
  video,

  /// The asset is an image file.
  image,

  /// The asset type is unknown or unsupported.
  other,
}
