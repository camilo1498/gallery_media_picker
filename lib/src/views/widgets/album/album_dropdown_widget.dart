part of '../../gallery_media_picker.dart';

class _AlbumDropDown extends StatelessWidget {
  const _AlbumDropDown({
    required this.name,
    required this.isOpen,
    required this.onTap,
    this.appBarIconColor,
    this.appBarTextColor,
    this.appBarLeadingWidget,
  });

  final String name;
  final bool isOpen;
  final VoidCallback onTap;
  final Color? appBarIconColor;
  final Color? appBarTextColor;
  final Widget? appBarLeadingWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedTapWidget(
            onTap: onTap,
            maxScale: .98,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(color: appBarTextColor, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: appBarIconColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(child: appBarLeadingWidget ?? const SizedBox.shrink()),
      ],
    );
  }
}
