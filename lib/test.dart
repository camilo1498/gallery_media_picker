import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// Un [ImageProvider] personalizado que decodifica una miniatura
/// de una entidad de tipo [AssetPathEntity] usando `photo_manager`.
class DecodeImage extends ImageProvider<DecodeImage> {
  /// Álbum o entidad que contiene los assets (imágenes/videos).
  final AssetPathEntity entity;

  /// Escala de la imagen.
  final double scale;

  /// Tamaño de la miniatura (ancho y alto).
  final int thumbSize;

  /// Índice del asset dentro del álbum.
  final int index;

  const DecodeImage(
      this.entity, {
        this.scale = 1.0,
        this.thumbSize = 120,
        this.index = 0,
      });

  @override
  Future<DecodeImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<DecodeImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(DecodeImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
    );
  }

  Future<ui.Codec> _loadAsync(
      DecodeImage key,
      ImageDecoderCallback decode,
      ) async {
    assert(key == this);

    final assetList = await key.entity.getAssetListRange(
      start: index,
      end: index + 1,
    );

    if (assetList.isEmpty) {
      throw StateError("No assets found at index $index.");
    }

    final asset = assetList.first;
    final thumbData = await asset.thumbnailDataWithSize(
      ThumbnailSize(thumbSize, thumbSize),
    );

    if (thumbData == null) {
      throw StateError(
        "Unable to load thumbnail data for asset at index $index.",
      );
    }

    final buffer = await ui.ImmutableBuffer.fromUint8List(thumbData);
    return decode(buffer);
  }
}


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/dropdown.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/overlay_drop_down.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryFunctions {
  /// Muestra un dropdown personalizado en un overlay con animación.
  static FeatureController<T> showDropDown<T>({
    required BuildContext context,
    required DropdownWidgetBuilder<T> builder,
    required TickerProvider tickerProvider,
    double height = 250.0,
    Duration animationDuration = const Duration(milliseconds: 250),
  }) {
    final animationController = AnimationController(
      vsync: tickerProvider,
      duration: animationDuration,
    );

    final completer = Completer<T?>();
    var isClosed = false;
    OverlayEntry? entry;

    void close(T? value) async {
      if (isClosed) return;
      isClosed = true;

      await animationController.reverse();
      await Future.delayed(const Duration(milliseconds: 16));
      completer.complete(value);
      entry?.remove();
    }

    entry = OverlayEntry(
      builder:
          (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => close(null),
        child: OverlayDropDown(
          height: height,
          close: close,
          animationController: animationController,
          builder: builder,
        ),
      ),
    );

    Overlay.of(context).insert(entry);
    animationController.forward();

    return FeatureController(completer, close);
  }

  /// Muestra un toast si se alcanza el número máximo de ítems seleccionados.
  static void onPickMax(GalleryMediaPickerController provider) {
    provider.onPickMax.addListener(() {
      showToast("You have already picked ${provider.max} items.");
    });
  }

  /// Solicita permisos y carga los álbumes si se autorizan.
  static Future<void> getPermission(
      void Function(VoidCallback fn) setState,
      GalleryMediaPickerController provider,
      ) async {
    final result = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        iosAccessLevel: IosAccessLevel.readWrite,
      ),
    );

    if (result.isAuth) {
      provider.setAssetCount();
      PhotoManager.startChangeNotify();
      PhotoManager.addChangeCallback((_) {
        _refreshPathList(setState, provider);
      });

      if (provider.pathList.isEmpty) {
        _refreshPathList(setState, provider);
      }
    } else {
      PhotoManager.openSetting();
    }
  }

  /// Refresca la lista de álbumes disponibles.
  static void _refreshPathList(
      void Function(VoidCallback fn) setState,
      GalleryMediaPickerController provider,
      ) {
    PhotoManager.getAssetPathList(
      type:
      provider.paramsModel.onlyVideos
          ? RequestType.video
          : provider.paramsModel.onlyImages
          ? RequestType.image
          : RequestType.all,
    ).then((pathList) {
      Future.microtask(() {
        setState(() {
          provider.resetPathList(pathList);
        });
      });
    });
  }

  /// Obtiene el path de un archivo [AssetEntity].
  static Future<String> getFile(AssetEntity asset) async {
    final file = await asset.file;
    if (file == null) throw Exception('Asset file is null');
    return file.path;
  }
}

/// Controlador para manejar el cierre del dropdown de selección de álbumes.
class FeatureController<T> {
  final Completer<T?> completer;
  final ValueSetter<T?> close;

  FeatureController(this.completer, this.close);

  Future<T?> get closed => completer.future;
}


import 'package:flutter/material.dart';

class MediaPickerParamsModel {
  MediaPickerParamsModel(
      {this.maxPickImages = 2,
        this.singlePick = true,
        this.appBarColor = Colors.black,
        this.albumBackGroundColor = Colors.black,
        this.albumDividerColor = Colors.white,
        this.albumTextColor = Colors.white,
        this.appBarIconColor,
        this.appBarTextColor = Colors.white,
        this.crossAxisCount = 3,
        this.gridViewBackgroundColor = Colors.black54,
        this.childAspectRatio = 0.5,
        this.appBarLeadingWidget,
        this.appBarHeight = 100,
        this.imageBackgroundColor = Colors.white,
        this.gridPadding,
        this.gridViewController,
        this.gridViewPhysics,
        this.selectedBackgroundColor = Colors.white,
        this.selectedCheckColor = Colors.white,
        this.thumbnailBoxFix = BoxFit.cover,
        this.selectedCheckBackgroundColor = Colors.white,
        this.onlyImages = true,
        this.onlyVideos = false,
        this.thumbnailQuality = 200});

  /// maximum images allowed (default 2)
  final int maxPickImages;

  /// picker mode
  final bool singlePick;

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
  final Color albumBackGroundColor;

  /// album text color
  final Color albumTextColor;

  /// album divider color
  final Color albumDividerColor;

  /// gallery gridview crossAxisCount
  final int crossAxisCount;

  /// gallery gridview aspect ratio
  final double childAspectRatio;

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

  /// thumbnail box fit
  final BoxFit thumbnailBoxFix;

  /// selected Check Background Color
  final Color selectedCheckBackgroundColor;

  /// load video
  final bool onlyVideos;

  /// load images
  final bool onlyImages;

  /// image quality thumbnail
  final int thumbnailQuality;
}


import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

class PickedAssetModel {
  String id;
  String path;
  String type;
  Duration videoDuration;
  DateTime createDateTime;
  double? latitude;
  double? longitude;
  Uint8List? thumbnail;
  int height;
  int width;
  int orientationHeight;
  int orientationWidth;
  Size orientationSize;
  File? file;
  DateTime modifiedDateTime;
  String? title;
  Size size;

  PickedAssetModel({
    required this.id,
    required this.path,
    required this.type,
    required this.videoDuration,
    required this.createDateTime,
    this.latitude,
    this.longitude,
    this.thumbnail,
    required this.height,
    required this.width,
    required this.orientationHeight,
    required this.orientationWidth,
    required this.orientationSize,
    this.file,
    required this.modifiedDateTime,
    this.title,
    required this.size,
  });

  factory PickedAssetModel.fromJson(Map<String, dynamic> json) =>
      PickedAssetModel(
        id: json["id"],
        path: json["path"],
        type: json["type"],
        videoDuration: json["videoDuration"],
        createDateTime: DateTime.parse(json["createDateTime"]),
        latitude: json["latitude"],
        longitude: json["longitude"],
        thumbnail: json["thumbnail"],
        height: json["height"],
        width: json["width"],
        orientationHeight: json["orientationHeight"],
        orientationWidth: json["orientationWidth"],
        orientationSize: json["orientationSize"],
        file: json["file"],
        modifiedDateTime: DateTime.parse(json["modifiedDateTime"]),
        title: json["title"],
        size: json["size"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "path": path,
    "type": type,
    "videoDuration": videoDuration,
    "createDateTime":
    "${createDateTime.year.toString().padLeft(4, '0')}-${createDateTime.month.toString().padLeft(2, '0')}-${createDateTime.day.toString().padLeft(2, '0')}",
    "latitude": latitude,
    "longitude": longitude,
    "thumbnail": thumbnail,
    "height": height,
    "width": width,
    "orientationHeight": orientationHeight,
    "orientationWidth": orientationWidth,
    "orientationSize": orientationSize,
    "file": file,
    "modifiedDateTime":
    "${modifiedDateTime.year.toString().padLeft(4, '0')}-${modifiedDateTime.month.toString().padLeft(2, '0')}-${modifiedDateTime.day.toString().padLeft(2, '0')}",
    "title": title,
    "size": size,
  };
}


import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/core/functions.dart';
import 'package:gallery_media_picker/src/data/models/gallery_params_model.dart';
import 'package:gallery_media_picker/src/data/models/picked_asset_model.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/presentation/widgets/gallery_grid/gallery_grid_view.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/current_path_selector.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryMediaPicker extends StatefulWidget {
  final MediaPickerParamsModel mediaPickerParams;
  final ValueChanged<List<PickedAssetModel>> pathList;

  const GalleryMediaPicker({
    Key? key,
    required this.mediaPickerParams,
    required this.pathList,
  }) : super(key: key);

  @override
  State<GalleryMediaPicker> createState() => _GalleryMediaPickerState();
}

class _GalleryMediaPickerState extends State<GalleryMediaPicker> {
  final GalleryMediaPickerController provider = GalleryMediaPickerController();

  @override
  void initState() {
    super.initState();
    provider.paramsModel = widget.mediaPickerParams;
    _initPicker();
  }

  void _initPicker() {
    GalleryFunctions.getPermission(setState, provider);
    provider.onPickMax.addListener(_onPickMaxReached);
  }

  void _onPickMaxReached() {
    showToast("You have already picked ${provider.max} items.");
  }

  @override
  void dispose() {
    provider.onPickMax.removeListener(_onPickMaxReached);
    provider.pickedFile.clear();
    provider.picked.clear();
    provider.pathList.clear();
    PhotoManager.stopChangeNotify();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    provider.max = widget.mediaPickerParams.maxPickImages;
    provider.singlePickMode = widget.mediaPickerParams.singlePick;

    return OKToast(
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return false;
        },
        child: Column(
          children: [
            _buildAlbumSelector(),
            Expanded(child: _buildGalleryGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumSelector() {
    return Container(
      color: widget.mediaPickerParams.appBarColor,
      alignment: Alignment.bottomLeft,
      height: widget.mediaPickerParams.appBarHeight,
      child: SelectedPathDropdownButton(
        provider: provider,
        mediaPickerParams: widget.mediaPickerParams,
      ),
    );
  }

  Widget _buildGalleryGrid() {
    return AnimatedBuilder(
      animation: provider.currentAlbumNotifier,
      builder: (_, __) {
        final album = provider.currentAlbum;
        return GalleryGridView(
          provider: provider,
          path: album,
          onAssetItemClick: _onAssetItemClick,
        );
      },
    );
  }

  Future<void> _onAssetItemClick(AssetEntity asset, int index) async {
    provider.pickEntity(asset);
    final path = await GalleryFunctions.getFile(asset);

    final pickedModel = PickedAssetModel(
      id: asset.id,
      path: path,
      type: asset.typeInt == 1 ? 'image' : 'video',
      videoDuration: asset.videoDuration,
      createDateTime: asset.createDateTime,
      latitude: asset.latitude,
      longitude: asset.longitude,
      thumbnail: await asset.thumbnailData,
      height: asset.height,
      width: asset.width,
      orientationHeight: asset.orientatedHeight,
      orientationWidth: asset.orientatedWidth,
      orientationSize: asset.orientatedSize,
      file: await asset.file,
      modifiedDateTime: asset.modifiedDateTime,
      title: asset.title,
      size: asset.size,
    );

    provider.pickPath(pickedModel);
    widget.pathList(provider.pickedFile);
  }
}


class GalleryMediaPickerController extends ChangeNotifier
    with PhotoDataController {
  final maxNotifier = ValueNotifier<int>(0);
  int get max => maxNotifier.value;
  set max(int value) => maxNotifier.value = value;

  final onPickMax = ChangeNotifier();

  bool _singlePickMode = false;
  bool get singlePickMode => _singlePickMode;
  set singlePickMode(bool value) {
    if (_singlePickMode != value) {
      _singlePickMode = value;
      maxNotifier.value = value ? 1 : maxNotifier.value;
      notifyListeners();
    }
  }

  final pickedNotifier = ValueNotifier<List<AssetEntity>>([]);
  final List<AssetEntity> picked = [];

  void pickEntity(AssetEntity entity) {
    if (_singlePickMode) {
      if (picked.contains(entity)) {
        picked.remove(entity);
      } else {
        picked
          ..clear()
          ..add(entity);
      }
    } else {
      if (picked.contains(entity)) {
        picked.remove(entity);
      } else {
        if (picked.length >= max) {
          onPickMax.notifyListeners();
          return;
        }
        picked.add(entity);
      }
    }
    pickedNotifier.value = List.unmodifiable(picked);
    notifyListeners();
  }

  final pickedFileNotifier = ValueNotifier<List<PickedAssetModel>>([]);
  final List<PickedAssetModel> pickedFile = [];

  void pickPath(PickedAssetModel path) {
    final exists = pickedFile.any((e) => e.id == path.id);
    if (_singlePickMode) {
      if (exists) {
        pickedFile.removeWhere((e) => e.id == path.id);
      } else {
        pickedFile
          ..clear()
          ..add(path);
      }
    } else {
      if (exists) {
        pickedFile.removeWhere((e) => e.id == path.id);
      } else {
        if (pickedFile.length >= max) {
          onPickMax.notifyListeners();
          return;
        }
        pickedFile.add(path);
      }
    }
    pickedFileNotifier.value = List.unmodifiable(pickedFile);
    notifyListeners();
  }

  int pickIndex(AssetEntity entity) => picked.indexOf(entity);

  int _assetCount = 0;
  int get assetCount => _assetCount;

  final assetCountNotifier = ValueNotifier<int>(0);

  Future<void> setAssetCount() async {
    await Future.delayed(const Duration(seconds: 1));
    if (_currentAlbum != null) {
      _assetCount = await _currentAlbum!.assetCountAsync;
    } else {
      _assetCount = 0;
    }
    assetCountNotifier.value = _assetCount;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/core/decode_image.dart';
import 'package:gallery_media_picker/src/core/functions.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:photo_manager/photo_manager.dart';

class CoverThumbnail extends StatefulWidget {
  final int thumbnailQuality;
  final double thumbnailScale;
  final BoxFit thumbnailFit;

  const CoverThumbnail({
    Key? key,
    this.thumbnailQuality = 120,
    this.thumbnailScale = 1.0,
    this.thumbnailFit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<CoverThumbnail> createState() => _CoverThumbnailState();
}

class _CoverThumbnailState extends State<CoverThumbnail> {
  final GalleryMediaPickerController _provider = GalleryMediaPickerController();

  @override
  void initState() {
    super.initState();
    GalleryFunctions.getPermission((callback) {
      if (mounted) setState(callback);
    }, _provider);
  }

  @override
  void dispose() {
    // Solo limpiar si el widget está montado.
    if (mounted) {
      _provider.pickedFile.clear();
      _provider.picked.clear();
      _provider.pathList.clear();
      PhotoManager.stopChangeNotify();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_provider.pathList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Image(
      image: DecodeImage(
        _provider.pathList[0],
        thumbSize: widget.thumbnailQuality,
        index: 0,
        scale: widget.thumbnailScale,
      ),
      fit: widget.thumbnailFit,
      filterQuality: FilterQuality.high,
    );
  }
}


import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/presentation/widgets/gallery_grid/thumbnail_widget.dart';
import 'package:photo_manager/photo_manager.dart';

typedef OnAssetItemClick = void Function(AssetEntity entity, int index);

class GalleryGridView extends StatefulWidget {
  final AssetPathEntity? path;
  final OnAssetItemClick? onAssetItemClick;
  final GalleryMediaPickerController provider;

  const GalleryGridView({
    Key? key,
    required this.path,
    required this.provider,
    this.onAssetItemClick,
  }) : super(key: key);

  @override
  GalleryGridViewState createState() => GalleryGridViewState();
}

class GalleryGridViewState extends State<GalleryGridView> {
  final Map<int, AssetEntity> _cacheMap = {};
  final ValueNotifier<bool> _scrolling = ValueNotifier(false);

  @override
  void didUpdateWidget(covariant GalleryGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _cacheMap.clear();
      _scrolling.value = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.path == null) return const SizedBox.shrink();

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: AnimatedBuilder(
        animation: widget.provider.assetCountNotifier,
        builder:
            (_, __) => Container(
          color: widget.provider.paramsModel.gridViewBackgroundColor,
          child: GridView.builder(
            key: ValueKey(widget.path),
            shrinkWrap: true,
            padding:
            widget.provider.paramsModel.gridPadding ?? EdgeInsets.zero,
            physics:
            widget.provider.paramsModel.gridViewPhysics ??
                const ScrollPhysics(),
            controller:
            widget.provider.paramsModel.gridViewController ??
                ScrollController(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.provider.paramsModel.crossAxisCount,
              childAspectRatio:
              widget.provider.paramsModel.childAspectRatio,
              mainAxisSpacing: 2.5,
              crossAxisSpacing: 2.5,
            ),
            itemCount: widget.provider.assetCount,
            addRepaintBoundaries: true,
            itemBuilder: (context, index) => _buildItem(context, index),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    return GestureDetector(
      onTap: () async {
        AssetEntity? asset = _cacheMap[index];
        if (asset == null ||
            asset.type == AssetType.audio ||
            asset.type == AssetType.other)
          return;

        // Refetch asset for fresh data
        final assetList = await widget.path!.getAssetListRange(
          start: index,
          end: index + 1,
        );
        if (assetList.isEmpty) return;

        asset = assetList.first;
        _cacheMap[index] = asset;
        widget.onAssetItemClick?.call(asset, index);
      },
      child: _buildScrollItem(context, index),
    );
  }

  Widget _buildScrollItem(BuildContext context, int index) {
    final cachedAsset = _cacheMap[index];
    if (cachedAsset != null) {
      return ThumbnailWidget(
        asset: cachedAsset,
        provider: widget.provider,
        index: index,
      );
    }

    return FutureBuilder<List<AssetEntity>>(
      future: widget.path!.getAssetListRange(start: index, end: index + 1),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            color: widget.provider.paramsModel.gridViewBackgroundColor,
            width: double.infinity,
            height: double.infinity,
          );
        }

        final asset = snapshot.data!.first;
        _cacheMap[index] = asset;

        return ThumbnailWidget(
          asset: asset,
          index: index,
          provider: widget.provider,
        );
      },
    );
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _scrolling.value = true;
    } else if (notification is ScrollEndNotification) {
      _scrolling.value = false;
    }
    return false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is GalleryGridViewState && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}


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


import 'package:flutter/material.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:photo_manager/photo_manager.dart';

class ChangePathWidget extends StatefulWidget {
  final GalleryMediaPickerController provider;
  final ValueSetter<AssetPathEntity> close;
  final MediaPickerParamsModel mediaPickerParams;

  const ChangePathWidget({
    Key? key,
    required this.provider,
    required this.close,
    required this.mediaPickerParams,
  }) : super(key: key);

  @override
  ChangePathWidgetState createState() => ChangePathWidgetState();
}

class ChangePathWidgetState extends State<ChangePathWidget> {
  late final ScrollController controller;
  static const double itemHeight = 65;

  GalleryMediaPickerController get provider => widget.provider;

  late final TextStyle albumTextStyle;

  @override
  void initState() {
    super.initState();
    final index = provider.pathList.indexOf(provider.currentAlbum!);
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
            itemCount: provider.pathList.length,
            itemBuilder: _buildItem,
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = provider.pathList[index];
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


import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/data/models/gallery_params_model.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/change_path_widget.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/dropdown.dart';
import 'package:photo_manager/photo_manager.dart';

class SelectedPathDropdownButton extends StatefulWidget {
  final GalleryMediaPickerController provider;
  final MediaPickerParamsModel mediaPickerParams;

  const SelectedPathDropdownButton({
    Key? key,
    required this.provider,
    required this.mediaPickerParams,
  }) : super(key: key);

  @override
  _SelectedPathDropdownButtonState createState() =>
      _SelectedPathDropdownButtonState();
}

class _SelectedPathDropdownButtonState
    extends State<SelectedPathDropdownButton> {
  final ValueNotifier<bool> arrowDownNotifier = ValueNotifier(false);
  final GlobalKey dropDownKey = GlobalKey();

  @override
  void dispose() {
    arrowDownNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.provider.currentAlbumNotifier,
      builder:
          (_, __) => Row(
        children: [
          Expanded(
            child: DropDown<AssetPathEntity>(
              relativeKey: dropDownKey,
              child: _buildButton(
                context,
              ), // Solo pasar el Widget directamente
              dropdownWidgetBuilder:
                  (context, close) => ChangePathWidget(
                provider: widget.provider,
                close: close,
                mediaPickerParams: widget.mediaPickerParams,
              ),
              onResult: (value) {
                if (value != null) {
                  widget.provider.currentAlbum = value;
                }
              },
              onShow: (value) {
                arrowDownNotifier.value = value;
              },
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            alignment: Alignment.bottomLeft,
            child:
            widget.mediaPickerParams.appBarLeadingWidget ??
                const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    final decoration = BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(35),
    );

    final currentAlbum = widget.provider.currentAlbum;

    if (widget.provider.pathList.isEmpty || currentAlbum == null) {
      return const SizedBox.shrink();
    }

    final textStyle = TextStyle(
      color: widget.mediaPickerParams.appBarTextColor,
      fontSize: 18,
      letterSpacing: 0.8,
      fontWeight: FontWeight.w500,
    );

    return Container(
      decoration: decoration,
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      alignment: Alignment.bottomLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.28,
            child: Text(
              currentAlbum.name,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: AnimatedBuilder(
              animation: arrowDownNotifier,
              builder: (context, child) {
                return AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: arrowDownNotifier.value ? 0.5 : 0,
                  child: child,
                );
              },
              child: Icon(
                Icons.keyboard_arrow_down,
                color: widget.mediaPickerParams.appBarIconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/core/functions.dart';

typedef DropdownWidgetBuilder<T> =
Widget Function(BuildContext context, ValueSetter<T> close);

class DropDown<T> extends StatefulWidget {
  final Widget child;
  final DropdownWidgetBuilder<T> dropdownWidgetBuilder;
  final ValueChanged<T?>? onResult;
  final ValueChanged<bool>? onShow;
  final GlobalKey? relativeKey;

  const DropDown({
    Key? key,
    required this.child,
    required this.dropdownWidgetBuilder,
    this.onResult,
    this.onShow,
    this.relativeKey,
  }) : super(key: key);

  @override
  DropDownState<T> createState() => DropDownState<T>();
}

class DropDownState<T> extends State<DropDown<T>>
    with TickerProviderStateMixin {
  FeatureController<T?>? controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: widget.child,
      onTap: () async {
        if (controller != null) {
          controller!.close(null);
          return;
        }

        final height = MediaQuery.of(context).size.height;
        final ctx = widget.relativeKey?.currentContext ?? context;
        final box = ctx.findRenderObject() as RenderBox;
        final offsetStart = box.localToGlobal(Offset.zero);
        final dialogHeight = height - (offsetStart.dy + box.paintBounds.bottom);

        widget.onShow?.call(true);

        controller = GalleryFunctions.showDropDown<T>(
          context: context,
          height: dialogHeight,
          builder: (_, close) {
            return widget.dropdownWidgetBuilder(context, close);
          },
          tickerProvider: this,
        );

        final result = await controller!.closed;
        controller = null;
        widget.onResult?.call(result);
        widget.onShow?.call(false);
      },
    );
  }
}


import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/dropdown.dart';

class OverlayDropDown<T> extends StatelessWidget {
  final double height;
  final ValueChanged<T?> close;
  final AnimationController animationController;
  final DropdownWidgetBuilder<T> builder;

  const OverlayDropDown({
    Key? key,
    required this.height,
    required this.close,
    required this.animationController,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double screenHeight = size.height;
    final double screenWidth = size.width;
    final double topPadding = screenHeight - height;

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Align(
        alignment: Alignment.topLeft,
        child: Builder(
          builder:
              (ctx) => Stack(
            children: [
              // Transparent full screen GestureDetector to close overlay on tap outside
              GestureDetector(
                onTap: () => close(null),
                child: Container(
                  color: Colors.transparent,
                  height: height * animationController.value,
                  width: screenWidth,
                ),
              ),

              // Dropdown content area
              SizedBox(
                height: height * animationController.value,
                width: screenWidth * 0.5,
                child: AnimatedBuilder(
                  animation: animationController,
                  builder: (context, _) {
                    return builder(ctx, close);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
