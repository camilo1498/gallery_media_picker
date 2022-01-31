// ignore_for_file: unnecessary_null_comparison
library gallery_media_picker;


import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/provider/gallery_provider.dart';
import 'package:gallery_media_picker/src/widgets/gallery_grid_view.dart';
import 'package:gallery_media_picker/src/widgets/current_path_selector.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

export 'package:gallery_media_picker/gallery_media_picker.dart';


class GalleryMediaPicker extends StatefulWidget {
  /// maximum images allowed (default 2)
  final int maxPickImages;
  /// picker mode
  final bool singlePick;
  /// return all selected paths
  final Function(List<String> path) pathList;
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

  const GalleryMediaPicker({
    Key? key,
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
    required this.pathList,
    this.selectedBackgroundColor = Colors.black,
    this.selectedCheckColor = Colors.white
  }) : super(key: key);

  @override
  _GalleryMediaPickerState createState() => _GalleryMediaPickerState();
}

class _GalleryMediaPickerState extends State<GalleryMediaPicker> {
  /// create object of PickerDataProvider
  final provider = PickerDataProvider();

  @override
  void initState() {
    provider.max = widget.maxPickImages;
    provider.onPickMax.addListener(onPickMax);
    provider.singlePickMode = widget.singlePick;
    if (provider.pathList.isEmpty) {
      PhotoManager.getAssetPathList().then((value) {
        provider.resetPathList(value);
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    provider.onPickMax.removeListener(onPickMax);
    super.dispose();
  }

  void onPickMax() {
    showToast("Already pick ${provider.max} items.");
  }


  @override
  Widget build(BuildContext context) {
    final key = GlobalKey();

    return OKToast(
      child:  Column(
        children: [
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
          Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: provider != null ? AnimatedBuilder(
                animation: provider.currentPathNotifier,
                builder: (BuildContext context, child) => GalleryGridView(
                  path: provider.currentPath,
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
                  onAssetItemClick: (ctx, asset, index) async{
                    provider.pickEntity(asset);
                    _getFile(asset).then((value) {
                      provider.pickPath(value);
                      widget.pathList(provider.pickedFile);
                    });
                  },
                ),
              ) : Container(),
            ),
          )
        ],
      ),
    );
  }
  Future _getFile(AssetEntity asset) async{
    var _file = await asset.file;
    return _file!.path;
  }
}
