import 'package:flutter/material.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:gallery_media_picker/src/core/decode_image.dart';
import 'package:gallery_media_picker/src/core/utils.dart';
import 'package:photo_manager/photo_manager.dart';

/// A widget that displays a thumbnail of a media [AssetEntity]
/// (image or video),including optional overlay for selection,
/// a GIF badge, and video duration.
class ThumbnailWidget extends StatelessWidget {
  /// Creates a [ThumbnailWidget] to show a media preview with selection UI.
  ///
  /// - [asset]: The media asset to display (image, video, or GIF).
  /// - [params]: Styling and behavior options for the thumbnail.
  /// - [isSelected]: Whether the current asset is selected.
  const ThumbnailWidget({
    required this.asset,
    required this.params,
    required this.isSelected,
    super.key,
  });

  /// Indicates if the asset is currently selected.
  final bool isSelected;

  /// The media asset to render as a thumbnail.
  final AssetEntity asset;

  /// Parameters that define style and behavior for the thumbnail.
  final MediaPickerParamsModel params;

  // Returns `true` if the asset is identified as a GIF.
  bool get _isGif {
    final title = asset.title?.toLowerCase() ?? '';
    return title.endsWith('.gif') || asset.mimeType == 'image/gif';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: DecoratedBox(
        decoration: BoxDecoration(color: params.thumbnailBgColor),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(),
            if (isSelected) _buildOverlay(),
            if (isSelected) _buildCheckmark(),
            if (asset.type == AssetType.video) _buildVideoDuration(),
            if (_isGif) _buildGifBadge(),
          ],
        ),
      ),
    );
  }

  // Builds the main thumbnail image using a fade-in effect.
  Widget _buildImage() => FadeInImage(
        placeholderFit: BoxFit.cover,
        fit: params.thumbnailBoxFix,
        placeholder: MemoryImage(Utils.kTransparentImage),
        fadeInDuration: const Duration(milliseconds: 200),
        image:
            DecodeImage(asset: asset, thumbSize: params.thumbnailQuality.size),
        imageErrorBuilder: (_, __, ___) =>
            const ColoredBox(color: Colors.black),
        filterQuality: FilterQuality.high,
        placeholderColor: params.thumbnailBgColor,
      );

  // Builds the semi-transparent selection overlay.
  Widget _buildOverlay() => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: params.selectedAssetBgColor.withValues(alpha: 0.4),
      );

  // Builds the checkmark indicator when the asset is selected.
  Widget _buildCheckmark() => Positioned(
        top: 8,
        right: 8,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: params.selectedCheckBgColor,
            border: Border.all(color: params.selectedCheckColor, width: 1.5),
          ),
          child: Icon(Icons.check, size: 16, color: params.selectedCheckColor),
        ),
      );

  // Builds the duration badge shown on videos.
  Widget _buildVideoDuration() => Positioned(
        right: 6,
        bottom: 6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.black.withValues(alpha: 0.5),
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

  // Builds a small badge indicating the media is a GIF.
  Widget _buildGifBadge() => Positioned(
        left: 6,
        bottom: 6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.black.withValues(alpha: 0.5),
          ),
          child: const Text(
            'GIF',
            style: TextStyle(
              fontSize: 8,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  // Formats a [Duration] into a human-readable string.
  //
  // - If duration > 1 hour: returns `HH:MM:SS`
  // - Otherwise: returns `MM:SS`
  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }
}
