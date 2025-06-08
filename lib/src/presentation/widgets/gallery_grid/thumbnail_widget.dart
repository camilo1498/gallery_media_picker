import 'package:flutter/material.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:gallery_media_picker/src/core/decode_image.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:photo_manager/photo_manager.dart';

class ThumbnailWidget extends StatelessWidget {
  final AssetEntity asset;
  final int index;
  final GalleryMediaPickerController provider;

  const ThumbnailWidget({
    super.key,
    required this.index,
    required this.asset,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final params = provider.paramsModel!;
    final isSelected = provider.picked.contains(asset);

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildThumbnailImage(params),
        _buildSelectionOverlay(params, isSelected),
        if (isSelected) _buildCheckmark(params),
        if (asset.type == AssetType.video) _buildVideoDuration(),
      ],
    );
  }

  Widget _buildThumbnailImage(MediaPickerParamsModel params) {
    return Image(
      image: DecodeImage(
        provider.currentAlbum!,
        thumbSize: params.thumbnailQuality,
        index: index,
      ),
      fit: params.thumbnailBoxFix,
      gaplessPlayback: true,
    );
  }

  Widget _buildSelectionOverlay(
    MediaPickerParamsModel params,
    bool isSelected,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color:
          isSelected
              ? params.selectedBackgroundColor.withValues(alpha: 0.3)
              : Colors.transparent,
    );
  }

  Widget _buildCheckmark(MediaPickerParamsModel params) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: params.selectedCheckBackgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: params.selectedCheckColor, width: 1.5),
        ),
        child: Icon(Icons.check, size: 16, color: params.selectedCheckColor),
      ),
    );
  }

  Widget _buildVideoDuration() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _formatDuration(asset.videoDuration),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}'
      ':${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
}
