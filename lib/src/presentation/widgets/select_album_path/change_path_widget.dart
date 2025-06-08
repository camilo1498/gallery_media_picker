import 'package:flutter/material.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/dropdown.dart';
import 'package:photo_manager/photo_manager.dart';

class ChangePathWidget extends StatefulWidget {
  final GalleryMediaPickerController provider;
  final ValueSetter<AssetPathEntity> close;
  final MediaPickerParamsModel mediaPickerParams;

  const ChangePathWidget({
    super.key,
    required this.provider,
    required this.close,
    required this.mediaPickerParams,
  });

  @override
  ChangePathWidgetState createState() => ChangePathWidgetState();
}

class ChangePathWidgetState extends State<ChangePathWidget> {
  static const double itemHeight = 65;
  late final ScrollController controller;
  late final TextStyle albumTextStyle;

  @override
  void initState() {
    super.initState();
    final index = widget.provider.pathList.indexOf(
      widget.provider.currentAlbum!,
    );
    controller = ScrollController(initialScrollOffset: itemHeight * index);
    albumTextStyle = TextStyle(
      color: widget.mediaPickerParams.albumTextColor,
      fontSize: 18,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.mediaPickerParams.albumBackGroundColor,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return false;
        },
        child: MediaQuery.removePadding(
          removeTop: true,
          removeBottom: true,
          context: context,
          child: ListView.builder(
            controller: controller,
            itemCount: widget.provider.pathList.length,
            itemBuilder: _buildItem,
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = widget.provider.pathList[index];
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => widget.close.call(item),
      child: Stack(
        children: <Widget>[
          SizedBox(
            height: itemHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  item.name,
                  overflow: TextOverflow.ellipsis,
                  style: albumTextStyle,
                ),
              ),
            ),
          ),
          Positioned(
            height: 1,
            bottom: 0,
            right: 0,
            left: 1,
            child: IgnorePointer(
              child: Container(
                color: widget.mediaPickerParams.albumDividerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
