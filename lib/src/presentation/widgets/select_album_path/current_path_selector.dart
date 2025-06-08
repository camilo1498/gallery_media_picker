import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/data/models/gallery_params_model.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/change_path_widget.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/dropdown.dart';
import 'package:photo_manager/photo_manager.dart';

class SelectedPathDropdownButton extends StatefulWidget {
  const SelectedPathDropdownButton({
    required this.provider,
    required this.mediaPickerParams,
    super.key,
  });

  final GalleryMediaPickerController provider;
  final MediaPickerParamsModel mediaPickerParams;

  @override
  State<SelectedPathDropdownButton> createState() =>
      _SelectedPathDropdownButtonState();
}

class _SelectedPathDropdownButtonState extends State<SelectedPathDropdownButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final GlobalKey<DropDownState<AssetPathEntity>> _dropdownKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.provider.currentAlbumNotifier,
      builder: (context, _) {
        final currentAlbum = widget.provider.currentAlbum;
        if (currentAlbum == null || widget.provider.pathList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Row(
          children: [
            Expanded(
              child: DropDown<AssetPathEntity>(
                key: _dropdownKey,
                animationController: _animationController,
                dropdownBuilder:
                    (onClose) => ChangePathWidget(
                      provider: widget.provider,
                      close: onClose,
                      mediaPickerParams: widget.mediaPickerParams,
                    ),
                child: _buildDropdownButton(currentAlbum),
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
        );
      },
    );
  }

  Widget _buildDropdownButton(AssetPathEntity currentAlbum) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _dropdownKey.currentState?.toggleDropdown(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.4,
                ),
                child: Text(
                  currentAlbum.name,
                  style: TextStyle(
                    color: widget.mediaPickerParams.appBarTextColor,
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RotationTransition(
                turns: Tween(
                  begin: 0.0,
                  end: 0.5,
                ).animate(_animationController),
                child: Icon(
                  Icons.arrow_drop_down,
                  color: widget.mediaPickerParams.appBarIconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
