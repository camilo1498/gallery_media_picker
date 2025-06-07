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
