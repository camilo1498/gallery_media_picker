import 'package:flutter/material.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final thumbnailBg =
        params.thumbnailBgColor ?? colorScheme.surfaceContainerHighest;
    final selectedAssetBg = params.selectedAssetBgColor ?? colorScheme.primary;
    final selectedCheckBg = params.selectedCheckBgColor ?? Colors.transparent;
    final selectedCheck = params.selectedCheckColor ?? colorScheme.onPrimary;

    return Semantics(
      label: _getSemanticLabel(),
      selected: isSelected,
      child: ClipRRect(
        child: DecoratedBox(
          decoration: BoxDecoration(color: thumbnailBg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(thumbnailBg),
              if (isSelected) _buildOverlay(selectedAssetBg),
              if (isSelected) _buildCheckmark(selectedCheckBg, selectedCheck),
              if (asset.type == AssetType.video) _buildVideoDuration(),
              if (_isGif) _buildGifBadge(),
            ],
          ),
        ),
      ),
    );
  }

  String _getSemanticLabel() {
    final trans = params.translations;
    final typeLabel = _isGif
        ? trans.gifLabel
        : asset.type == AssetType.video
        ? trans.videoLabel
        : trans.imageLabel;

    final statusLabel = isSelected
        ? trans.selectedLabel
        : trans.notSelectedLabel;

    if (asset.type == AssetType.video) {
      return '$typeLabel, $statusLabel, ${_formatDuration(asset.videoDuration)}';
    }
    return '$typeLabel, $statusLabel';
  }

  // Builds the main thumbnail image using a native fade-in effect.
  Widget _buildImage(Color thumbnailBg) => Image(
    fit: params.thumbnailBoxFix,
    errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
    filterQuality: FilterQuality.high,
    image: AssetEntityImageProvider(
      asset,
      isOriginal: false,
      thumbnailSize: ThumbnailSize.square(params.thumbnailQuality.size),
    ),
    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
      if (wasSynchronouslyLoaded) return child;
      return AnimatedOpacity(
        opacity: frame == null ? 0 : 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: child,
      );
    },
  );

  // Builds the semi-transparent selection overlay.
  Widget _buildOverlay(Color selectedAssetBg) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    color: selectedAssetBg.withValues(alpha: 0.4),
  );

  // Builds the checkmark indicator when the asset is selected.
  Widget _buildCheckmark(Color selectedCheckBg, Color selectedCheck) =>
      Positioned(
        top: 8,
        right: 8,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selectedCheckBg,
            border: Border.all(color: selectedCheck, width: 1.5),
          ),
          child: Icon(Icons.check, size: 16, color: selectedCheck),
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
