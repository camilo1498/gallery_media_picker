import 'package:flutter/material.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';

@immutable
class MediaPickerParamsModel {
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

  final bool singlePick;
  final int maxPickImages;
  final Color appBarColor;
  final int crossAxisCount;
  final double appBarHeight;
  final int thumbnailQuality;
  final Color albumTextColor;
  final Color appBarTextColor;
  final Color? appBarIconColor;
  final BoxFit thumbnailBoxFix;
  final Color albumDividerColor;
  final double childAspectRatio;
  final EdgeInsets? gridPadding;
  final Color selectedCheckColor;
  final Color albumBackGroundColor;
  final Color imageBackgroundColor;
  final Color gridViewBackgroundColor;
  final Color selectedBackgroundColor;
  final ScrollPhysics? gridViewPhysics;
  final GalleryMediaTypeEnum mediaType;
  final Color selectedCheckBackgroundColor;
  final ScrollController? gridViewController;

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
  }) {
    return MediaPickerParamsModel(
      singlePick: singlePick ?? this.singlePick,
      maxPickImages: maxPickImages ?? this.maxPickImages,
      appBarColor: appBarColor ?? this.appBarColor,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      appBarHeight: appBarHeight ?? this.appBarHeight,
      thumbnailQuality: thumbnailQuality ?? this.thumbnailQuality,
      albumTextColor: albumTextColor ?? this.albumTextColor,
      appBarTextColor: appBarTextColor ?? this.appBarTextColor,
      appBarIconColor: appBarIconColor ?? this.appBarIconColor,
      thumbnailBoxFix: thumbnailBoxFix ?? this.thumbnailBoxFix,
      albumDividerColor: albumDividerColor ?? this.albumDividerColor,
      childAspectRatio: childAspectRatio ?? this.childAspectRatio,
      gridPadding: gridPadding ?? this.gridPadding,
      selectedCheckColor: selectedCheckColor ?? this.selectedCheckColor,
      albumBackGroundColor: albumBackGroundColor ?? this.albumBackGroundColor,
      imageBackgroundColor: imageBackgroundColor ?? this.imageBackgroundColor,
      gridViewBackgroundColor:
          gridViewBackgroundColor ?? this.gridViewBackgroundColor,
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      gridViewPhysics: gridViewPhysics ?? this.gridViewPhysics,
      mediaType: mediaType ?? this.mediaType,
      selectedCheckBackgroundColor:
          selectedCheckBackgroundColor ?? this.selectedCheckBackgroundColor,
      gridViewController: gridViewController ?? this.gridViewController,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MediaPickerParamsModel &&
        other.singlePick == singlePick &&
        other.maxPickImages == maxPickImages &&
        other.appBarColor == appBarColor &&
        other.crossAxisCount == crossAxisCount &&
        other.appBarHeight == appBarHeight &&
        other.thumbnailQuality == thumbnailQuality &&
        other.albumTextColor == albumTextColor &&
        other.appBarTextColor == appBarTextColor &&
        other.appBarIconColor == appBarIconColor &&
        other.thumbnailBoxFix == thumbnailBoxFix &&
        other.albumDividerColor == albumDividerColor &&
        other.childAspectRatio == childAspectRatio &&
        other.gridPadding == gridPadding &&
        other.selectedCheckColor == selectedCheckColor &&
        other.albumBackGroundColor == albumBackGroundColor &&
        other.imageBackgroundColor == imageBackgroundColor &&
        other.gridViewBackgroundColor == gridViewBackgroundColor &&
        other.selectedBackgroundColor == selectedBackgroundColor &&
        other.gridViewPhysics == gridViewPhysics &&
        other.mediaType == mediaType &&
        other.selectedCheckBackgroundColor == selectedCheckBackgroundColor &&
        other.gridViewController == gridViewController;
  }

  @override
  int get hashCode => Object.hashAll([
    singlePick,
    maxPickImages,
    appBarColor,
    crossAxisCount,
    appBarHeight,
    thumbnailQuality,
    albumTextColor,
    appBarTextColor,
    appBarIconColor,
    thumbnailBoxFix,
    albumDividerColor,
    childAspectRatio,
    gridPadding,
    selectedCheckColor,
    albumBackGroundColor,
    imageBackgroundColor,
    gridViewBackgroundColor,
    selectedBackgroundColor,
    gridViewPhysics,
    mediaType,
    selectedCheckBackgroundColor,
    gridViewController,
  ]);
}
