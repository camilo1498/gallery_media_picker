part of '../../gallery_media_picker.dart';

class _AlbumDropdownOverlay extends StatelessWidget {
  const _AlbumDropdownOverlay({
    required this.offset,
    required this.height,
    required this.animation,
    required this.onClose,
  });

  final Offset offset;
  final double height;
  final Animation<double> animation;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final provider = MediaPickerController.instance;

    return Stack(
      children: [
        // Fondo transparente para cerrar al hacer tap fuera
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.transparent),
          ),
        ),

        // Lista desplegable animada
        Positioned(
          left: offset.dx + 5,
          top: offset.dy + height,
          child: Material(
            color: Colors.transparent,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: animation.value,
                child: Container(
                  width: MediaQuery.of(context).size.width / 2.2,
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color:
                        provider.paramsModel?.albumBackGroundColor ??
                        Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
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
                        ...provider.pathList.map((item) {
                          final isSelected =
                              provider.currentAlbum.value == item;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: AnimatedTapWidget(
                              maxScale: .98,
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
                                          ? Colors.white.withValues(alpha: 0.3)
                                          : Colors.transparent,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color:
                                              provider
                                                  .paramsModel
                                                  ?.albumTextColor ??
                                              Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    if (isSelected)
                                      Icon(
                                        Icons.check,
                                        color:
                                            provider
                                                .paramsModel
                                                ?.albumTextColor ??
                                            Colors.black,
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
