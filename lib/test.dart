import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class DecodeImage extends ImageProvider<DecodeImage> {
  final AssetPathEntity entity;
  final double scale;
  final int thumbSize;
  final int index;

  const DecodeImage(
      this.entity, {
        this.scale = 1.0,
        this.thumbSize = 200,
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
      chunkEvents: Stream<ImageChunkEvent>.empty(),
      informationCollector:
          () => [
        DiagnosticsProperty<AssetPathEntity>('AssetPath', key.entity),
        DiagnosticsProperty<int>('Index', key.index),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
      DecodeImage key,
      ImageDecoderCallback decode,
      ) async {
    try {
      final assetList = await key.entity.getAssetListRange(
        start: key.index,
        end: key.index + 1,
      );

      if (assetList.isEmpty) {
        throw StateError('No asset found at index ${key.index}');
      }

      final thumbData = await assetList.first.thumbnailDataWithSize(
        ThumbnailSize(key.thumbSize, key.thumbSize),
        quality: 85,
      );

      if (thumbData == null) {
        throw StateError('Failed to load thumbnail data');
      }

      final buffer = await ui.ImmutableBuffer.fromUint8List(thumbData);
      return decode(buffer);
    } catch (e) {
      debugPrint('Error loading image: $e');
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DecodeImage &&
            runtimeType == other.runtimeType &&
            entity == other.entity &&
            index == other.index &&
            thumbSize == other.thumbSize;
  }

  @override
  int get hashCode => Object.hash(entity, index, thumbSize);
}


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/dropdown.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/overlay_drop_down.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryFunctions {
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

  static void onPickMax(GalleryMediaPickerController provider) {
    provider.onPickMax.addListener(() {
      showToast("You have already picked ${provider.max} items.");
    });
  }

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
      PhotoManager.addChangeCallback(
            (_) => _refreshPathList(setState, provider),
      );

      if (provider.pathList.isEmpty) {
        _refreshPathList(setState, provider);
      }
    } else {
      PhotoManager.openSetting();
    }
  }

  static void _refreshPathList(
      void Function(VoidCallback fn) setState,
      GalleryMediaPickerController provider,
      ) {
    PhotoManager.getAssetPathList(
      type:
      (provider.paramsModel?.onlyVideos == true)
          ? RequestType.video
          : (provider.paramsModel?.onlyImages ?? true)
          ? RequestType.image
          : RequestType.all,
    ).then((pathList) {
      Future.microtask(() => setState(() => provider.resetPathList(pathList)));
    });
  }

  static Future<String> getFile(AssetEntity asset) async {
    final file = await asset.file;
    if (file == null) throw Exception('Asset file is null');
    return file.path;
  }
}

class FeatureController<T> {
  final Completer<T?> completer;
  final ValueSetter<T?> close;

  FeatureController(this.completer, this.close);

  Future<T?> get closed => completer.future;
}
import 'package:flutter/material.dart';

class MediaPickerParamsModel {
  final int maxPickImages;
  final bool singlePick;
  final Color appBarColor;
  final Color albumBackGroundColor;
  final Color albumDividerColor;
  final Color albumTextColor;
  final Color? appBarIconColor;
  final Color appBarTextColor;
  final int crossAxisCount;
  final Color gridViewBackgroundColor;
  final double childAspectRatio;
  final Widget? appBarLeadingWidget;
  final double appBarHeight;
  final Color imageBackgroundColor;
  final EdgeInsets? gridPadding;
  final ScrollPhysics? gridViewPhysics;
  final ScrollController? gridViewController;
  final Color selectedBackgroundColor;
  final Color selectedCheckColor;
  final BoxFit thumbnailBoxFix;
  final Color selectedCheckBackgroundColor;
  final bool onlyImages;
  final bool onlyVideos;
  final int thumbnailQuality;

  const MediaPickerParamsModel({
    this.maxPickImages = 2,
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
    this.gridViewPhysics,
    this.gridViewController,
    this.selectedBackgroundColor = Colors.white,
    this.selectedCheckColor = Colors.white,
    this.thumbnailBoxFix = BoxFit.cover,
    this.selectedCheckBackgroundColor = Colors.white,
    this.onlyImages = true,
    this.onlyVideos = false,
    this.thumbnailQuality = 200,
  });
}


import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

class PickedAssetModel {
  final String id;
  final String path;
  final String type;
  final Duration videoDuration;
  final DateTime createDateTime;
  final double? latitude;
  final double? longitude;
  final Uint8List? thumbnail;
  final int height;
  final int width;
  final int orientationHeight;
  final int orientationWidth;
  final Size orientationSize;
  final File? file;
  final DateTime modifiedDateTime;
  final String? title;
  final Size size;

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
    "createDateTime": createDateTime.toIso8601String(),
    "latitude": latitude,
    "longitude": longitude,
    "thumbnail": thumbnail,
    "height": height,
    "width": width,
    "orientationHeight": orientationHeight,
    "orientationWidth": orientationWidth,
    "orientationSize": orientationSize,
    "file": file,
    "modifiedDateTime": modifiedDateTime.toIso8601String(),
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
    super.key,
    required this.mediaPickerParams,
    required this.pathList,
  });

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
      child: Column(
        children: [
          _buildAlbumSelector(),
          Expanded(
            child: RepaintBoundary(
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return false;
                },
                child: AnimatedBuilder(
                  animation: provider.currentAlbumNotifier,
                  builder: (_, __) {
                    return GalleryGridView(
                      provider: provider,
                      path: provider.currentAlbum,
                      onAssetItemClick: _onAssetItemClick,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
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


import 'package:flutter/material.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryMediaPickerController extends ChangeNotifier {
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

  final pickedFileNotifier = ValueNotifier<List<PickedAssetModel>>([]);
  final List<PickedAssetModel> pickedFile = [];

  final currentAlbumNotifier = ValueNotifier<AssetPathEntity?>(null);
  AssetPathEntity? get currentAlbum => currentAlbumNotifier.value;
  set currentAlbum(AssetPathEntity? value) {
    if (currentAlbumNotifier.value != value) {
      currentAlbumNotifier.value = value;
      setAssetCount();
      notifyListeners();
    }
  }

  final List<AssetPathEntity> pathList = [];

  MediaPickerParamsModel? paramsModel;

  void resetPathList(List<AssetPathEntity> newPathList) {
    pathList.clear();
    pathList.addAll(newPathList);
    if (pathList.isNotEmpty && currentAlbum == null) {
      currentAlbum = pathList.first;
    }
    notifyListeners();
  }

  void pickEntity(AssetEntity entity) {
    if (singlePickMode) {
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
    // Actualiza ambos notificadores
    pickedNotifier.value = List.from(picked);
    notifyListeners();
  }

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
    if (currentAlbum != null) {
      _assetCount = await currentAlbum!.assetCountAsync;
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
    super.key,
    this.thumbnailQuality = 120,
    this.thumbnailScale = 1.0,
    this.thumbnailFit = BoxFit.cover,
  });

  @override
  State<CoverThumbnail> createState() => _CoverThumbnailState();
}

class _CoverThumbnailState extends State<CoverThumbnail> {
  final GalleryMediaPickerController _provider = GalleryMediaPickerController();

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    await GalleryFunctions.getPermission((callback) {
      if (mounted) setState(callback);
    }, _provider);
  }

  @override
  void dispose() {
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
    if (_provider.pathList.isEmpty) return const SizedBox.shrink();

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
  final OnAssetItemClick? onAssetItemClick; // Parámetro añadido
  final GalleryMediaPickerController provider;

  const GalleryGridView({
    Key? key,
    required this.path,
    required this.provider,
    this.onAssetItemClick, // Parámetro añadido
  }) : super(key: key);

  @override
  State<GalleryGridView> createState() => _GalleryGridViewState();
}

class _GalleryGridViewState extends State<GalleryGridView> {
  final Map<int, AssetEntity> _assetCache = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _preloadInitialAssets();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _preloadMoreAssets();
    }
  }

  Future<void> _preloadInitialAssets() async {
    if (widget.path == null) return;

    final assets = await widget.path!.getAssetListRange(start: 0, end: 20);
    for (var i = 0; i < assets.length; i++) {
      _assetCache[i] = assets[i];
    }
    if (mounted) setState(() {});
  }

  Future<void> _preloadMoreAssets() async {
    if (widget.path == null) return;

    final start = _assetCache.length;
    final assets = await widget.path!.getAssetListRange(
      start: start,
      end: start + 20,
    );
    for (var i = 0; i < assets.length; i++) {
      _assetCache[start + i] = assets[i];
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.provider.assetCountNotifier,
      builder: (_, count, __) {
        return GridView.builder(
          controller: _scrollController,
          itemCount: count,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.provider.paramsModel!.crossAxisCount,
            childAspectRatio: widget.provider.paramsModel!.childAspectRatio,
          ),
          itemBuilder: (context, index) {
            return _buildGridItem(index);
          },
        );
      },
    );
  }

  Widget _buildGridItem(int index) {
    if (_assetCache.containsKey(index)) {
      return GestureDetector(
        onTap: () => widget.onAssetItemClick?.call(_assetCache[index]!, index),
        child: ThumbnailWidget(
          asset: _assetCache[index]!,
          index: index,
          provider: widget.provider,
        ),
      );
    }

    return FutureBuilder<List<AssetEntity>>(
      future: widget.path!.getAssetListRange(start: index, end: index + 1),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          _assetCache[index] = snapshot.data!.first;
          return GestureDetector(
            onTap:
                () =>
                widget.onAssetItemClick?.call(snapshot.data!.first, index),
            child: ThumbnailWidget(
              asset: snapshot.data!.first,
              index: index,
              provider: widget.provider,
            ),
          );
        }
        return Container(color: Colors.grey[200]);
      },
    );
  }
}


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
    super.key,
    required this.provider,
    required this.mediaPickerParams,
  });

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
              child: _buildButton(context),
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
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(35),
      ),
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
    super.key,
    required this.child,
    required this.dropdownWidgetBuilder,
    this.onResult,
    this.onShow,
    this.relativeKey,
  });

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
          builder: (_, close) => widget.dropdownWidgetBuilder(context, close),
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
    super.key,
    required this.height,
    required this.close,
    required this.animationController,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPadding = size.height - height;

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Align(
        alignment: Alignment.topLeft,
        child: Builder(
          builder:
              (ctx) => Stack(
            children: [
              GestureDetector(
                onTap: () => close(null),
                child: Container(
                  color: Colors.transparent,
                  height: height * animationController.value,
                  width: size.width,
                ),
              ),
              SizedBox(
                height: height * animationController.value,
                width: size.width * 0.5,
                child: AnimatedBuilder(
                  animation: animationController,
                  builder: (context, _) => builder(ctx, close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
