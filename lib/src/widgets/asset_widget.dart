import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/provider/gallery_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class AssetWidget extends StatelessWidget {
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
  const AssetWidget({
    Key? key,
    required this.asset,
    required this.provider,
    this.thumbSize = 200,
    this.imageBackgroundColor = Colors.white,
    this.selectedBackgroundColor =Colors.white,
    this.selectedCheckColor = Colors.white
  }) : super(key: key);

  static AssetWidget buildWidget(
      BuildContext context, AssetEntity asset, int thumbSize, PickerDataProvider provider) {
    return AssetWidget(
      asset: asset,
      thumbSize: thumbSize,
      provider: provider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        /// background gradient from image
        Container(
          decoration: BoxDecoration(
              color: imageBackgroundColor
          ) ,
        ),

        /// thumbnail image
        Image(
          image: AssetEntityThumbImage(
            entity: asset,
            width: thumbSize,
            height: thumbSize,
          ),
          fit: BoxFit.cover,
        ),
        /// selected image color mask
        AnimatedBuilder(
            animation: provider,
            builder: (_, __){
              final pickIndex = provider.pickIndex(asset);
              final picked = pickIndex >= 0;
              return Container(
                decoration: BoxDecoration(
                  color: picked ? Colors.black.withOpacity(0.3) : Colors.transparent,

                ) ,
              );
            }
        ),
        /// selected image check
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 5,top: 5),
            child: AnimatedBuilder(
                animation: provider,
                builder: (_, __){
                  final pickIndex = provider.pickIndex(asset);
                  final picked = pickIndex >= 0;
                  return picked ? Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: picked ? selectedBackgroundColor.withOpacity(0.3) : Colors.transparent,
                      border: Border.all(
                          width: 1.5,
                          color: selectedCheckColor
                      ),
                    ) ,
                    child: Icon(
                      Icons.check,
                      color: selectedCheckColor,
                      size: 14,
                    ),
                  ) : Container();
                }
            ),
          ),
        ),

        /// video duration widget
        if(asset.type == AssetType.video)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 5,bottom: 5),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white,
                          width: 1
                      )
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 3),
                  child:  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 10,
                      ),
                      const SizedBox(width: 3,),
                      Text(
                        _parseDuration(asset.videoDuration.inSeconds),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 8
                        ),
                      ),
                    ],
                  )
              ),
            ),
          )

      ],
    );
  }
}

/// parse second to duration
_parseDuration(int seconds){
  if(seconds < 600  ){
    return  '${Duration(seconds: seconds)}'.toString().substring(3,7);
  } else if(seconds > 600 && seconds < 3599){
    return  '${Duration(seconds: seconds)}'.toString().substring(2,7);
  } else {
    return  '${Duration(seconds: seconds)}'.toString().substring(1,7);
  }
}


class AssetEntityThumbImage extends ImageProvider<AssetEntityThumbImage> {
  final AssetEntity entity;
  final int width;
  final int height;
  final double scale;

  AssetEntityThumbImage({
    required this.entity,
    int? width,
    int? height,
    this.scale = 1.0,
  })  : width = width ?? entity.width,
        height = height ?? entity.height;

  @override
  ImageStreamCompleter load(AssetEntityThumbImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
    );
  }

  Future<ui.Codec> _loadAsync(
      AssetEntityThumbImage key, DecoderCallback decode) async {
    assert(key == this);
    final bytes = await entity.thumbDataWithSize(width, height);
    return decode(bytes!);
  }

  @override
  Future<AssetEntityThumbImage> obtainKey(
      ImageConfiguration configuration) async {
    return this;
  }

}
