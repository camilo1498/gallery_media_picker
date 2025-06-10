part of '../../gallery_media_picker.dart';

class _AlbumSelector extends StatefulWidget {
  const _AlbumSelector({this.appBarLeadingWidget});
  final Widget? appBarLeadingWidget;

  @override
  State<_AlbumSelector> createState() => _AlbumSelectorState();
}

class _AlbumSelectorState extends State<_AlbumSelector>
    with SingleTickerProviderStateMixin {
  final MediaPickerController provider = MediaPickerController.instance;

  late final AnimationController _animationController;
  late final Animation<double> _heightFactorAnimation;

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _heightFactorAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggleDropdown() => _isOpen ? _closeDropdown() : _openDropdown();

  void _openDropdown() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final height = renderBox?.size.height ?? 0;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => _AlbumDropdownOverlay(
            offset: offset,
            height: height,
            animation: _heightFactorAnimation,
            onClose: _closeDropdown,
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    _animationController
      ..addListener(() {
        _overlayEntry?.markNeedsBuild();
      })
      ..forward();

    setState(() => _isOpen = true);
  }

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
        color: params?.appBarColor,
        height: params?.appBarHeight ?? 50,
        child: ValueListenableBuilder<AssetPathEntity?>(
          valueListenable: provider.currentAlbum,
          builder: (_, album, _) {
            if (album == null) return const SizedBox.shrink();

            return _AlbumDropDown(
              name: album.name,
              isOpen: _isOpen,
              onTap: _toggleDropdown,
              appBarIconColor: params?.appBarIconColor,
              appBarTextColor: params?.appBarTextColor,
              appBarLeadingWidget: widget.appBarLeadingWidget,
            );
          },
        ),
      ),
    );
  }
}
