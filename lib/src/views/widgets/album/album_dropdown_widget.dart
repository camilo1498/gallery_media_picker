part of '../../gallery_media_picker.dart';

/// A widget that displays the selected album name with a dropdown arrow,
/// typically shown in the top app bar.
///
/// When tapped, it triggers a callback
/// (usually to open or close the album list).
class _AlbumDropDown extends StatelessWidget {
  const _AlbumDropDown({
    required this.name,
    required this.isOpen,
    required this.onTap,
    this.appBarIconColor,
    this.appBarTextColor,
    this.appBarLeadingWidget,
  });

  /// The name of the currently selected album.
  final String name;

  /// Whether the dropdown is currently open or not.
  final bool isOpen;

  /// Callback triggered when the user taps the dropdown.
  final VoidCallback onTap;

  /// Color used for the dropdown arrow icon.
  final Color? appBarIconColor;

  /// Color used for the album name text.
  final Color? appBarTextColor;

  /// Optional widget to show on the right side
  /// (e.g., a back button or settings icon).
  final Widget? appBarLeadingWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedTapWidget(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Album name with optional color and ellipsis overflow.
                  Expanded(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: appBarTextColor, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Dropdown arrow icon that changes based on the open state.
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

        // Optional leading widget placed at the end of the row.
        Flexible(child: appBarLeadingWidget ?? const SizedBox.shrink()),
      ],
    );
  }
}
