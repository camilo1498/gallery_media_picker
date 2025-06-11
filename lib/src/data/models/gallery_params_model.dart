import 'package:flutter/material.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';

/// A configuration model for customizing the behavior and appearance
/// of the `GalleryMediaPicker` widget.
///
/// This model allows fine-grained control over UI elements, layout,
/// interaction, and media filtering preferences.
@immutable
class MediaPickerParamsModel {
  /// Creates a [MediaPickerParamsModel] with customizable parameters.
  ///
  /// Use this constructor to provide optional configuration values
  /// for layout, colors, limits, and behavior of the media picker.
  const MediaPickerParamsModel({
    this.gridPadding,
    this.singlePick = true,
    this.maxPickImages = 2,
    this.appBarHeight = 50,
    this.gridViewController,
    this.crossAxisCount = 3,
    this.childAspectRatio = 0.5,
    this.appBarColor = Colors.black,
    this.albumTextColor = Colors.white,
    this.thumbnailBoxFix = BoxFit.cover,
    this.selectedAlbumIcon = Icons.check,
    this.thumbnailBgColor = Colors.white,
    this.gridViewBgColor = Colors.black54,
    this.selectedCheckColor = Colors.white,
    this.albumSelectIconColor = Colors.white,
    this.albumSelectTextColor = Colors.white,
    this.selectedAlbumBgColor = Colors.white,
    this.selectedAssetBgColor = Colors.white,
    this.albumDropDownBgColor = Colors.black,
    this.mediaType = GalleryMediaType.all,
    this.selectedAlbumTextColor = Colors.white,
    this.selectedCheckBgColor = Colors.transparent,
    this.thumbnailQuality = ThumbnailQuality.medium,
    this.gridViewPhysics = const BouncingScrollPhysics(),
  });

  /// Whether only a single item can be picked.
  final bool singlePick;

  /// The maximum number of items allowed to be picked.
  final int maxPickImages;

  /// The color of the app bar background.
  final Color appBarColor;

  /// Number of columns in the grid.
  final int crossAxisCount;

  /// Height of the app bar in pixels.
  final double appBarHeight;

  /// Color of album title text.
  final Color albumTextColor;

  /// Background color of the entire grid view.
  final Color gridViewBgColor;

  /// How the thumbnails should be fit within their boxes.
  final BoxFit thumbnailBoxFix;

  /// Background color of media thumbnails.
  final Color thumbnailBgColor;

  /// Padding applied to the entire grid view.
  final EdgeInsets? gridPadding;

  /// Aspect ratio of each grid item.
  final double childAspectRatio;

  /// Color of the checkmark icon used when an item is selected.
  final Color selectedCheckColor;

  /// Color of text in the app bar.
  final Color albumSelectTextColor;

  /// Background color behind the selection checkmark.
  final Color selectedCheckBgColor;

  /// Color of icons in the app bar.
  final Color? albumSelectIconColor;

  /// Color of the background of the selected album dropdown.
  final Color? selectedAlbumBgColor;

  /// Background color of the album dropdown panel.
  final Color albumDropDownBgColor;

  /// Icon displayed in the app bar when an album is selected.
  final IconData selectedAlbumIcon;

  /// Background color shown when a thumbnail is selected.
  final Color selectedAssetBgColor;

  /// Color of the text in the selected album dropdown.
  final Color selectedAlbumTextColor;

  /// Scroll physics for the grid view.
  final ScrollPhysics gridViewPhysics;

  /// Type of media to show (all, images, or videos).
  final GalleryMediaType mediaType;

  /// Quality of generated thumbnails (0–1000).
  final ThumbnailQuality thumbnailQuality;

  /// Scroll controller used to manage grid view scroll behavior.
  final ScrollController? gridViewController;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MediaPickerParamsModel &&
        other.mediaType == mediaType &&
        other.singlePick == singlePick &&
        other.appBarColor == appBarColor &&
        other.gridPadding == gridPadding &&
        other.appBarHeight == appBarHeight &&
        other.maxPickImages == maxPickImages &&
        other.crossAxisCount == crossAxisCount &&
        other.albumTextColor == albumTextColor &&
        other.gridViewPhysics == gridViewPhysics &&
        other.gridViewBgColor == gridViewBgColor &&
        other.thumbnailBoxFix == thumbnailBoxFix &&
        other.thumbnailQuality == thumbnailQuality &&
        other.childAspectRatio == childAspectRatio &&
        other.thumbnailBgColor == thumbnailBgColor &&
        other.selectedAlbumIcon == selectedAlbumIcon &&
        other.selectedCheckColor == selectedCheckColor &&
        other.gridViewController == gridViewController &&
        other.albumSelectTextColor == albumSelectTextColor &&
        other.albumSelectIconColor == albumSelectIconColor &&
        other.selectedAlbumBgColor == selectedAlbumBgColor &&
        other.albumDropDownBgColor == albumDropDownBgColor &&
        other.selectedAssetBgColor == selectedAssetBgColor &&
        other.selectedCheckBgColor == selectedCheckBgColor &&
        other.selectedAlbumTextColor == selectedAlbumTextColor;
  }

  @override
  int get hashCode => Object.hashAll([
    mediaType,
    singlePick,
    appBarColor,
    gridPadding,
    appBarHeight,
    maxPickImages,
    crossAxisCount,
    albumTextColor,
    gridViewPhysics,
    thumbnailBoxFix,
    gridViewBgColor,
    thumbnailBgColor,
    thumbnailQuality,
    childAspectRatio,
    selectedAlbumIcon,
    gridViewController,
    selectedCheckColor,
    selectedAlbumBgColor,
    albumDropDownBgColor,
    albumSelectTextColor,
    selectedAssetBgColor,
    albumSelectIconColor,
    selectedCheckBgColor,
    selectedAlbumTextColor,
  ]);
}
