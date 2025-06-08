import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/data/models/gallery_params_model.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:photo_manager/photo_manager.dart';

class ChangePathWidget extends StatelessWidget {
  const ChangePathWidget({
    required this.close,
    required this.provider,
    required this.mediaPickerParams,
    super.key,
  });
  final GalleryMediaPickerController provider;
  final void Function(AssetPathEntity?) close;
  final MediaPickerParamsModel mediaPickerParams;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: mediaPickerParams.albumBackGroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: provider.pathList.length,
        itemBuilder: (context, index) {
          final path = provider.pathList[index];
          return ListTile(
            title: Text(
              path.name,
              style: TextStyle(color: mediaPickerParams.albumTextColor),
            ),
            onTap: () {
              provider.currentAlbum = path;
              close(path);
            },
          );
        },
      ),
    );
  }
}
