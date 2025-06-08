import 'package:flutter/material.dart';

class MediaPickerParamsModel {
  final int maxPickImages;
  final bool singlePick;
  final Color appBarColor;
  final Color albumBackGroundColor;
  final Color albumDividerColor;
  final Color albumTextColor;
  final Color? appBarIconColor;
  final Color appBarTextColor;
  final int crossAxisCount;
  final Color gridViewBackgroundColor;
  final double childAspectRatio;
  final Widget? appBarLeadingWidget;
  final double appBarHeight;
  final Color imageBackgroundColor;
  final EdgeInsets? gridPadding;
  final ScrollPhysics? gridViewPhysics;
  final ScrollController? gridViewController;
  final Color selectedBackgroundColor;
  final Color selectedCheckColor;
  final BoxFit thumbnailBoxFix;
  final Color selectedCheckBackgroundColor;
  final bool onlyImages;
  final bool onlyVideos;
  final int thumbnailQuality;

  const MediaPickerParamsModel({
    this.maxPickImages = 2,
    this.singlePick = true,
    this.appBarColor = Colors.black,
    this.albumBackGroundColor = Colors.black,
    this.albumDividerColor = Colors.white,
    this.albumTextColor = Colors.white,
    this.appBarIconColor,
    this.appBarTextColor = Colors.white,
    this.crossAxisCount = 3,
    this.gridViewBackgroundColor = Colors.black54,
    this.childAspectRatio = 0.5,
    this.appBarLeadingWidget,
    this.appBarHeight = 100,
    this.imageBackgroundColor = Colors.white,
    this.gridPadding,
    this.gridViewPhysics,
    this.gridViewController,
    this.selectedBackgroundColor = Colors.white,
    this.selectedCheckColor = Colors.white,
    this.thumbnailBoxFix = BoxFit.cover,
    this.selectedCheckBackgroundColor = Colors.white,
    this.onlyImages = true,
    this.onlyVideos = false,
    this.thumbnailQuality = 200,
  });
}
