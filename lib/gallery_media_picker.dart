// ignore_for_file: unnecessary_null_comparison
library gallery_media_picker;

import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/provider/gallery_provider.dart';
import 'package:gallery_media_picker/src/widgets/gallery_grid_view.dart';
import 'package:gallery_media_picker/src/widgets/current_path_selector.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

export 'package:gallery_media_picker/gallery_media_picker.dart';
export 'package:gallery_media_picker/src/widgets/cover_thumbnail.dart';

class GalleryMediaPicker extends StatefulWidget {
  /// maximum images allowed (default 2)
  final int maxPickImages;

  /// picker mode
  final bool singlePick;

  /// return all selected paths
  final Function(List<Map<String, dynamic>> path)? pathList;

  /// dropdown appbar color
  final Color appBarColor;

  /// appBar TextColor
  final Color appBarTextColor;

  /// appBar icon Color
  final Color? appBarIconColor;

  /// gridView background color
  final Color gridViewBackgroundColor;

  /// grid image backGround color
  final Color imageBackgroundColor;

  /// album background color
  final Color? albumBackGroundColor;

  /// album text color
  final Color albumTextColor;

  /// album divider color
  final Color? albumDividerColor;

  /// gallery gridview crossAxisCount
  final int? crossAxisCount;

  /// gallery gridview aspect ratio
  final double? childAspectRatio;

  /// appBar leading widget
  final Widget? appBarLeadingWidget;

  /// appBar height
  final double appBarHeight;

  /// gridView Padding
  final EdgeInsets? gridPadding;

  /// gridView physics
  final ScrollPhysics? gridViewPhysics;

  /// gridView controller
  final ScrollController? gridViewController;

  /// selected background color
  final Color selectedBackgroundColor;

  /// selected check color
  final Color selectedCheckColor;

  /// thumbnail box fit
  final BoxFit thumbnailBoxFix;

  /// selected Check Background Color
  final Color selectedCheckBackgroundColor;

  /// load video
  final bool onlyVideos;

  /// load images
  final bool onlyImages;

  /// image quality thumbnail
  final int? thumbnailQuality;

  const GalleryMediaPicker(
      {Key? key,
      this.maxPickImages = 2,
      this.singlePick = true,
      this.appBarColor = Colors.black,
      this.albumBackGroundColor,
      this.albumDividerColor,
      this.albumTextColor = Colors.white,
      this.appBarIconColor,
      this.appBarTextColor = Colors.white,
      this.crossAxisCount,
      this.gridViewBackgroundColor = Colors.black54,
      this.childAspectRatio,
      this.appBarLeadingWidget,
      this.appBarHeight = 100,
      this.imageBackgroundColor = Colors.white,
      this.gridPadding,
      this.gridViewController,
      this.gridViewPhysics,
      this.pathList,
      this.selectedBackgroundColor = Colors.black,
      this.selectedCheckColor = Colors.white,
      this.thumbnailBoxFix = BoxFit.cover,
      this.selectedCheckBackgroundColor = Colors.white,
      this.onlyImages = false,
      this.onlyVideos = false,
      this.thumbnailQuality})
      : super(key: key);

  @override
  _GalleryMediaPickerState createState() => _GalleryMediaPickerState();
}

class _GalleryMediaPickerState extends State<GalleryMediaPicker> {
  /// create object of PickerDataProvider
  final provider = PickerDataProvider();

  @override
  void initState() {
    provider.onPickMax.addListener(onPickMax);
    _getPermission();
    super.initState();
  }

  _getPermission() async {
    var result = await PhotoManager.requestPermissionExtend(
        requestOption: const PermisstionRequestOption(iosAccessLevel: IosAccessLevel.readWrite));
    if (result.isAuth) {
      PhotoManager.startChangeNotify();
      PhotoManager.addChangeCallback((value) {
        _refreshPathList();
      });

      if (provider.pathList.isEmpty) {
        _refreshPathList();
      }
    } else {
      /// if result is fail, you can call `PhotoManager.openSetting();`
      /// to open android/ios application's setting to get permission
      PhotoManager.openSetting();
    }
  }

  _refreshPathList() {
    PhotoManager.getAssetPathList(
            type: widget.onlyVideos
                ? RequestType.video
                : widget.onlyImages
                    ? RequestType.image
                    : RequestType.all)
        .then((pathList) {
      /// don't delete setState
      setState(() {
        provider.resetPathList(pathList);
      });
    });
  }

  @override
  void dispose() {
    if (mounted) {
      provider.onPickMax.removeListener(onPickMax);
      provider.pickedFile.clear();
      provider.picked.clear();
      provider.pathList.clear();
      PhotoManager.stopChangeNotify();
      super.dispose();
    }
  }

  void onPickMax() {
    showToast("Already pick ${provider.max} items.");
  }

  void isSinglePickMode() {
    provider.singlePickMode = widget.singlePick;
  }

  @override
  Widget build(BuildContext context) {
    provider.max = widget.maxPickImages;
    provider.singlePickMode = widget.singlePick;
    final key = GlobalKey();

    return OKToast(
      child: Column(
        children: [
          /// album drop down
          Center(
            child: Container(
              color: widget.appBarColor,
              alignment: Alignment.bottomLeft,
              height: widget.appBarHeight,
              child: SelectedPathDropdownButton(
                dropdownRelativeKey: key,
                provider: provider,
                appBarColor: widget.appBarColor,
                appBarIconColor: widget.appBarIconColor ?? const Color(0xFFB2B2B2),
                appBarTextColor: widget.appBarTextColor,
                albumTextColor: widget.albumTextColor,
                albumDividerColor: widget.albumDividerColor ?? const Color(0xFF484848),
                albumBackGroundColor: widget.albumBackGroundColor ?? const Color(0xFF333333),
                appBarLeadingWidget: widget.appBarLeadingWidget,
              ),
            ),
          ),

          /// grid view
          Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: provider != null
                  ? AnimatedBuilder(
                      animation: provider.currentPathNotifier,
                      builder: (BuildContext context, child) => GalleryGridView(
                        path: provider.currentPath,
                        thumbnailQuality: widget.thumbnailQuality ?? 200,
                        provider: provider,
                        padding: widget.gridPadding,
                        childAspectRatio: widget.childAspectRatio ?? 0.5,
                        crossAxisCount: widget.crossAxisCount ?? 3,
                        gridViewBackgroundColor: widget.gridViewBackgroundColor,
                        gridViewController: widget.gridViewController,
                        gridViewPhysics: widget.gridViewPhysics,
                        imageBackgroundColor: widget.imageBackgroundColor,
                        selectedBackgroundColor: widget.selectedBackgroundColor,
                        selectedCheckColor: widget.selectedCheckColor,
                        thumbnailBoxFix: widget.thumbnailBoxFix,
                        selectedCheckBackgroundColor: widget.selectedCheckBackgroundColor,
                        onAssetItemClick: (ctx, asset, index) async {
                          provider.pickEntity(asset);
                          _getFile(asset).then((value) {
                            /// add metadata to map list
                            provider.pickPath({
                              'id': asset.id,
                              'path': value,
                              'type': asset.typeInt == 1 ? 'image' : 'video',
                              'videoDuration': asset.videoDuration,
                              'createDateTime': asset.createDateTime,
                              'latitude': asset.latitude,
                              'longitude': asset.longitude,
                              'thumbnail': asset.thumbnailData,
                              'height': asset.height,
                              'width': asset.width,
                              'orientationHeight': asset.orientatedHeight,
                              'orientationWidth': asset.orientatedWidth,
                              'orientationSize': asset.orientatedSize,
                              'file': asset.file,
                              'modifiedDateTime': asset.modifiedDateTime,
                              'title': asset.title,
                              'size': asset.size,
                            });
                            widget.pathList!(provider.pickedFile);
                          });
                        },
                      ),
                    )
                  : Container(),
            ),
          )
        ],
      ),
    );
  }

  /// get asset path
  Future _getFile(AssetEntity asset) async {
    var _file = await asset.file;
    return _file!.path;
  }
}
