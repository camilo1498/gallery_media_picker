import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/core/decode_image.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:photo_manager/photo_manager.dart';

class ThumbnailWidget extends StatelessWidget {
  final AssetEntity asset;
  final int index;
  final GalleryMediaPickerController provider;

  const ThumbnailWidget({
    Key? key,
    required this.index,
    required this.asset,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentAlbumIndex = provider.pathList.indexOf(provider.currentAlbum!);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: provider.paramsModel.imageBackgroundColor,
          ),
        ),

        // Imagen del thumbnail usando DecodeImage directamente
        if (asset.type == AssetType.image || asset.type == AssetType.video)
          Image(
            image: DecodeImage(
              provider.pathList[currentAlbumIndex],
              thumbSize: provider.paramsModel.thumbnailQuality,
              index: index,
            ),
            gaplessPlayback: true,
            fit: provider.paramsModel.thumbnailBoxFix,
            filterQuality: FilterQuality.high,
            width: double.infinity,
            height: double.infinity,
          ),

        // Máscara semitransparente para selección
        AnimatedBuilder(
          animation: provider,
          builder: (_, __) {
            final pickIndex = provider.pickIndex(asset);
            final picked = pickIndex >= 0;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color:
                    picked
                        ? provider.paramsModel.selectedBackgroundColor
                            .withOpacity(0.3)
                        : Colors.transparent,
              ),
            );
          },
        ),

        // Check de selección en la esquina superior derecha
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
                      color:
                          picked
                              ? provider
                                  .paramsModel
                                  .selectedCheckBackgroundColor
                                  .withOpacity(0.6)
                              : Colors.transparent,
                      border: Border.all(
                        width: 1.5,
                        color: provider.paramsModel.selectedCheckColor,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      color: provider.paramsModel.selectedCheckColor,
                      size: 14,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Duración del video en esquina inferior derecha
        if (asset.type == AssetType.video)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 10,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _parseDuration(asset.videoDuration.inSeconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Convierte segundos a formato mm:ss
String _parseDuration(int seconds) {
  final duration = Duration(seconds: seconds);
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$secs';
}
