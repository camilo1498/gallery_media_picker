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
    this.gridViewPhysics,
    this.singlePick = true,
    this.maxPickImages = 2,
    this.gridViewController,
    this.crossAxisCount = 3,
    this.appBarHeight = 100,
    this.thumbnailQuality = 200,
    this.childAspectRatio = 0.5,
    this.appBarColor = Colors.black,
    this.albumTextColor = Colors.white,
    this.appBarIconColor = Colors.white,
    this.appBarTextColor = Colors.white,
    this.thumbnailBoxFix = BoxFit.cover,
    this.albumDividerColor = Colors.white,
    this.selectedCheckColor = Colors.white,
    this.imageBackgroundColor = Colors.white,
    this.albumBackGroundColor = Colors.black,
    this.mediaType = GalleryMediaTypeEnum.all,
    this.selectedBackgroundColor = Colors.white,
    this.gridViewBackgroundColor = Colors.black54,
    this.selectedCheckBackgroundColor = Colors.white,
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

  /// Quality of generated thumbnails (0–1000).
  final int thumbnailQuality;

  /// Color of album title text.
  final Color albumTextColor;

  /// Color of text in the app bar.
  final Color appBarTextColor;

  /// Color of icons in the app bar.
  final Color? appBarIconColor;

  /// How the thumbnails should be fit within their boxes.
  final BoxFit thumbnailBoxFix;

  /// Color of the divider line in the album dropdown.
  final Color albumDividerColor;

  /// Aspect ratio of each grid item.
  final double childAspectRatio;

  /// Padding applied to the entire grid view.
  final EdgeInsets? gridPadding;

  /// Color of the checkmark icon used when an item is selected.
  final Color selectedCheckColor;

  /// Background color of the album dropdown panel.
  final Color albumBackGroundColor;

  /// Background color of media thumbnails.
  final Color imageBackgroundColor;

  /// Background color of the entire grid view.
  final Color gridViewBackgroundColor;

  /// Background color shown when a thumbnail is selected.
  final Color selectedBackgroundColor;

  /// Scroll physics for the grid view.
  final ScrollPhysics? gridViewPhysics;

  /// Type of media to show (all, images, or videos).
  final GalleryMediaTypeEnum mediaType;

  /// Background color behind the selection checkmark.
  final Color selectedCheckBackgroundColor;

  /// Scroll controller used to manage grid view scroll behavior.
  final ScrollController? gridViewController;

  /// Returns a copy of this model with the given fields replaced.
  MediaPickerParamsModel copyWith({
    bool? singlePick,
    int? maxPickImages,
    Color? appBarColor,
    int? crossAxisCount,
    double? appBarHeight,
    int? thumbnailQuality,
    Color? albumTextColor,
    Color? appBarTextColor,
    Color? appBarIconColor,
    BoxFit? thumbnailBoxFix,
    Color? albumDividerColor,
    double? childAspectRatio,
    EdgeInsets? gridPadding,
    Color? selectedCheckColor,
    Color? albumBackGroundColor,
    Color? imageBackgroundColor,
    Widget? appBarLeadingWidget,
    Color? gridViewBackgroundColor,
    Color? selectedBackgroundColor,
    ScrollPhysics? gridViewPhysics,
    GalleryMediaTypeEnum? mediaType,
    Color? selectedCheckBackgroundColor,
    ScrollController? gridViewController,
  }) => MediaPickerParamsModel(
    mediaType: mediaType ?? this.mediaType,
    singlePick: singlePick ?? this.singlePick,
    gridPadding: gridPadding ?? this.gridPadding,
    appBarColor: appBarColor ?? this.appBarColor,
    appBarHeight: appBarHeight ?? this.appBarHeight,
    maxPickImages: maxPickImages ?? this.maxPickImages,
    crossAxisCount: crossAxisCount ?? this.crossAxisCount,
    albumTextColor: albumTextColor ?? this.albumTextColor,
    appBarTextColor: appBarTextColor ?? this.appBarTextColor,
    appBarIconColor: appBarIconColor ?? this.appBarIconColor,
    gridViewPhysics: gridViewPhysics ?? this.gridViewPhysics,
    thumbnailBoxFix: thumbnailBoxFix ?? this.thumbnailBoxFix,
    thumbnailQuality: thumbnailQuality ?? this.thumbnailQuality,
    childAspectRatio: childAspectRatio ?? this.childAspectRatio,
    albumDividerColor: albumDividerColor ?? this.albumDividerColor,
    selectedCheckColor: selectedCheckColor ?? this.selectedCheckColor,
    gridViewController: gridViewController ?? this.gridViewController,
    albumBackGroundColor: albumBackGroundColor ?? this.albumBackGroundColor,
    imageBackgroundColor: imageBackgroundColor ?? this.imageBackgroundColor,
    gridViewBackgroundColor:
        gridViewBackgroundColor ?? this.gridViewBackgroundColor,
    selectedBackgroundColor:
        selectedBackgroundColor ?? this.selectedBackgroundColor,
    selectedCheckBackgroundColor:
        selectedCheckBackgroundColor ?? this.selectedCheckBackgroundColor,
  );

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
        other.appBarTextColor == appBarTextColor &&
        other.appBarIconColor == appBarIconColor &&
        other.thumbnailBoxFix == thumbnailBoxFix &&
        other.thumbnailQuality == thumbnailQuality &&
        other.childAspectRatio == childAspectRatio &&
        other.albumDividerColor == albumDividerColor &&
        other.selectedCheckColor == selectedCheckColor &&
        other.gridViewController == gridViewController &&
        other.albumBackGroundColor == albumBackGroundColor &&
        other.imageBackgroundColor == imageBackgroundColor &&
        other.gridViewBackgroundColor == gridViewBackgroundColor &&
        other.selectedBackgroundColor == selectedBackgroundColor &&
        other.selectedCheckBackgroundColor == selectedCheckBackgroundColor;
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
    appBarTextColor,
    appBarIconColor,
    thumbnailBoxFix,
    thumbnailQuality,
    childAspectRatio,
    albumDividerColor,
    gridViewController,
    selectedCheckColor,
    albumBackGroundColor,
    imageBackgroundColor,
    gridViewBackgroundColor,
    selectedBackgroundColor,
    selectedCheckBackgroundColor,
  ]);
}
