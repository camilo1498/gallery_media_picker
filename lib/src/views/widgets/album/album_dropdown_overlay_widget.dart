part of '../../gallery_media_picker.dart';

/// A dropdown overlay that displays a list of available albums.
///
/// This widget appears below the album selector
/// and allows users to switch albums.
/// It supports animated expansion and closes when tapping outside of it.
class _AlbumDropdownOverlay extends StatelessWidget {
  const _AlbumDropdownOverlay({
    required this.offset,
    required this.height,
    required this.animation,
    required this.onClose,
  });

  /// The position of the dropdown relative to the screen (top-left offset).
  final Offset offset;

  /// The height of the widget that triggered
  /// the overlay (used for positioning).
  final double height;

  /// Animation controlling the dropdown's height expansion.
  final Animation<double> animation;

  /// Callback to be invoked when the dropdown is dismissed.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final provider = MediaPickerController.instance;

    return Stack(
      children: [
        // Transparent background layer that closes the dropdown on tap outside.
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.transparent),
          ),
        ),

        // The animated dropdown positioned below the trigger widget.
        Positioned(
          left: offset.dx + 5,
          top: offset.dy + height,
          child: Material(
            color: Colors.transparent,
            child: ClipRect(
              child: Align(
                heightFactor: animation.value,
                alignment: Alignment.topCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width / 2.2,
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: provider.paramsModel.albumDropDownBgColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 4),

                        // Map through each album and create a list entry.
                        ...provider.pathList.map((item) {
                          final isSelected =
                              provider.currentAlbum.value == item;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: AnimatedTapWidget(
                              onTap: () {
                                provider.setAlbum(item);
                                onClose();
                              },
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      isSelected
                                          ? provider
                                              .paramsModel
                                              .selectedAlbumBgColor
                                          : Colors.transparent,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    // Album name.
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        maxLines: 2,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color:
                                              isSelected
                                                  ? provider
                                                      .paramsModel
                                                      .selectedAlbumTextColor
                                                  : provider
                                                      .paramsModel
                                                      .albumTextColor,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 4),

                                    // Checkmark icon if selected.
                                    if (isSelected)
                                      Icon(
                                        provider.paramsModel.selectedAlbumIcon,
                                        size: 15,
                                        color:
                                            provider
                                                .paramsModel
                                                .selectedAlbumTextColor,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
