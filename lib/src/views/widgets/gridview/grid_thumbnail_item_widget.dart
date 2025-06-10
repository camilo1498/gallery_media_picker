import 'package:flutter/material.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:gallery_media_picker/src/core/decode_image.dart';
import 'package:gallery_media_picker/src/core/utils.dart';
import 'package:photo_manager/photo_manager.dart';

class ThumbnailWidget extends StatelessWidget {
  const ThumbnailWidget({
    required this.index,
    required this.asset,
    required this.params,
    required this.isSelected,
    required this.currentAlbum,
    super.key,
  });

  final int index;
  final bool isSelected;
  final AssetEntity asset;
  final AssetPathEntity currentAlbum;
  final MediaPickerParamsModel params;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(),
          if (isSelected) _buildOverlay(),
          if (isSelected) _buildCheckmark(),
          if (asset.type == AssetType.video) _buildVideoDuration(),
        ],
      ),
    );
  }

  Widget _buildImage() => FadeInImage(
    placeholder: MemoryImage(Utils.kTransparentImage),
    image: DecodeImage(
      currentAlbum,
      index: index,
      thumbSize: params.thumbnailQuality,
    ),
    fit: params.thumbnailBoxFix,
    fadeInDuration: const Duration(milliseconds: 200),
    placeholderFit: BoxFit.cover,
    imageErrorBuilder: (_, _, _) => const ColoredBox(color: Colors.grey),
  );

  Widget _buildOverlay() => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    color: params.selectedBackgroundColor.withValues(alpha: 0.4),
  );

  Widget _buildCheckmark() => Positioned(
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

  Widget _buildVideoDuration() => Positioned(
    bottom: 6,
    right: 6,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _formatDuration(asset.videoDuration),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          shadows: [Shadow(blurRadius: 1)],
        ),
      ),
    ),
  );

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }
}
