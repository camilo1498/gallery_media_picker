import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/provider/gallery_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class ThumbnailWidget extends StatelessWidget {
  /// asset entity
  final AssetEntity asset;

  /// size of image thumbnail
  final int thumbSize;

  /// background image color
  final Color imageBackgroundColor;

  /// iamge provider
  final PickerDataProvider provider;

  /// selected background color
  final Color selectedBackgroundColor;

  /// selected check color
  final Color selectedCheckColor;

  /// selected Check Background Color
  final Color selectedCheckBackgroundColor;

  /// thumbnail box fit
  final BoxFit thumbnailBoxFix;
  const ThumbnailWidget(
      {Key? key,
      required this.asset,
      required this.provider,
      this.thumbSize = 200,
      this.imageBackgroundColor = Colors.white,
      this.selectedBackgroundColor = Colors.white,
      this.selectedCheckColor = Colors.white,
      this.thumbnailBoxFix = BoxFit.cover,
      this.selectedCheckBackgroundColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        /// background gradient from image
        Container(
          decoration: BoxDecoration(color: imageBackgroundColor),
        ),

        /// thumbnail image
        FutureBuilder<Uint8List?>(
          future: asset.thumbData,
          builder: (_, data) {
            if (data.hasData) {
              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.memory(
                  data.data!,
                  gaplessPlayback: true,
                  fit: thumbnailBoxFix,
                ),
              );
            } else {
              return Container();
            }
          },
        ),

        /// selected image color mask
        AnimatedBuilder(
            animation: provider,
            builder: (_, __) {
              final pickIndex = provider.pickIndex(asset);
              final picked = pickIndex >= 0;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: picked
                      ? selectedBackgroundColor.withOpacity(0.3)
                      : Colors.transparent,
                ),
              );
            }),

        /// selected image check
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 5, top: 5),
            child: AnimatedBuilder(
                animation: provider,
                builder: (_, __) {
                  final pickIndex = provider.pickIndex(asset);
                  final picked = pickIndex >= 0;
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: picked ? 1 : 0,
                    child: Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: picked
                            ? selectedCheckBackgroundColor.withOpacity(0.6)
                            : Colors.transparent,
                        border:
                            Border.all(width: 1.5, color: selectedCheckColor),
                      ),
                      child: Icon(
                        Icons.check,
                        color: selectedCheckColor,
                        size: 14,
                      ),
                    ),
                  );
                }),
          ),
        ),

        /// video duration widget
        if (asset.type == AssetType.video)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 5),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 10,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      Text(
                        _parseDuration(asset.videoDuration.inSeconds),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 8),
                      ),
                    ],
                  )),
            ),
          )
      ],
    );
  }
}

/// parse second to duration
_parseDuration(int seconds) {
  if (seconds < 600) {
    return '${Duration(seconds: seconds)}'.toString().substring(3, 7);
  } else if (seconds > 600 && seconds < 3599) {
    return '${Duration(seconds: seconds)}'.toString().substring(2, 7);
  } else {
    return '${Duration(seconds: seconds)}'.toString().substring(1, 7);
  }
}
