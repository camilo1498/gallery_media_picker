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
