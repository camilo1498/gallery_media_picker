part of '../../gallery_media_picker.dart';

/// A widget that displays the album selector bar (typically in the app bar).
/// When tapped, it toggles a dropdown overlay listing available albums.
class _AlbumSelector extends StatefulWidget {
  const _AlbumSelector({this.appBarLeadingWidget});

  /// Optional widget (e.g., back button) to be shown on
  /// the leading side of the app bar.
  final Widget? appBarLeadingWidget;

  @override
  State<_AlbumSelector> createState() => _AlbumSelectorState();
}

class _AlbumSelectorState extends State<_AlbumSelector>
    with SingleTickerProviderStateMixin {
  // Access to the singleton media picker controller.
  final MediaPickerController provider = MediaPickerController.instance;

  // Controls the animation for the dropdown height.
  late final AnimationController _animationController;

  // Defines the animation curve and progress for the dropdown.
  late final Animation<double> _heightFactorAnimation;

  // Overlay entry that represents the album dropdown list.
  OverlayEntry? _overlayEntry;

  // Tracks whether the dropdown is currently visible.
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();

    // Initializes the animation controller with a 250ms duration.
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Sets a smooth easing animation for the dropdown expand/collapse.
    _heightFactorAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    // Dispose animation controller to avoid memory leaks.
    _animationController.dispose();

    // Ensure overlay is removed on dispose.
    _overlayEntry?.remove();
    super.dispose();
  }

  /// Toggles the dropdown overlay.
  void _toggleDropdown() => _isOpen ? _closeDropdown() : _openDropdown();

  /// Opens the album dropdown overlay.
  void _openDropdown() {
    // Get the position and height of the selector widget.
    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final height = renderBox?.size.height ?? 0;

    // Create the overlay with the dropdown content.
    _overlayEntry = OverlayEntry(
      builder:
          (context) => _AlbumDropdownOverlay(
            offset: offset,
            height: height,
            animation: _heightFactorAnimation,
            onClose: _closeDropdown,
          ),
    );

    // Insert the overlay into the overlay stack.
    Overlay.of(context).insert(_overlayEntry!);

    // Start the dropdown expand animation and refresh the overlay on each tick.
    _animationController
      ..addListener(() {
        _overlayEntry?.markNeedsBuild();
      })
      ..forward();

    setState(() => _isOpen = true);
  }

  // Closes the dropdown and reverses the animation.
  Future<void> _closeDropdown() async {
    await _animationController.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (mounted) setState(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final params = provider.paramsModel;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isOpen) {
          _closeDropdown();
        }
      },
      child: Container(
        alignment: Alignment.bottomLeft,
        color: params.appBarColor,
        height: params.appBarHeight,
        child: ValueListenableBuilder<AssetPathEntity?>(
          valueListenable: provider.currentAlbum,
          builder: (_, album, _) {
            if (album == null) return const SizedBox.shrink();

            // Main tappable dropdown widget shown in the app bar.
            return _AlbumDropDown(
              name: album.name,
              isOpen: _isOpen,
              onTap: _toggleDropdown,
              appBarIconColor: params.albumSelectIconColor,
              appBarTextColor: params.albumSelectTextColor,
              appBarLeadingWidget: widget.appBarLeadingWidget,
            );
          },
        ),
      ),
    );
  }
}
