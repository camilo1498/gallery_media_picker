import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/provider/gallery_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dropdown.dart';

class SelectedPathDropdownButton extends StatelessWidget {
  /// picker provider
  final PhotoDataProvider provider;

  /// global key
  final GlobalKey? dropdownRelativeKey;
  final Color appBarColor;

  /// appBar TextColor
  final Color appBarTextColor;

  /// appBar icon Color
  final Color appBarIconColor;

  /// album background color
  final Color albumBackGroundColor;

  /// album text color
  final Color albumTextColor;

  /// album divider color
  final Color albumDividerColor;

  /// appBar leading widget
  final Widget? appBarLeadingWidget;

  const SelectedPathDropdownButton(
      {Key? key,
      required this.provider,
      required this.dropdownRelativeKey,
      required this.appBarTextColor,
      required this.appBarIconColor,
      required this.appBarColor,
      required this.albumBackGroundColor,
      required this.albumDividerColor,
      required this.albumTextColor,
      this.appBarLeadingWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arrowDownNotifier = ValueNotifier(false);
    return AnimatedBuilder(
      animation: provider.currentPathNotifier,
      builder: (_, __) => Row(
        children: [
          DropDown<AssetPathEntity>(
            relativeKey: dropdownRelativeKey!,
            child:
                ((context) => buildButton(context, arrowDownNotifier))(context),
            dropdownWidgetBuilder: (BuildContext context, close) {
              return ChangePathWidget(
                provider: provider as PickerDataProvider,
                close: close,
                albumBackGroundColor: albumBackGroundColor,
                albumDividerColor: albumDividerColor,
                albumTextColor: albumTextColor,
              );
            },
            onResult: (AssetPathEntity? value) {
              if (value != null) {
                provider.currentPath = value;
              }
            },
            onShow: (value) {
              arrowDownNotifier.value = value;
            },
          ),
          Container(
            width: MediaQuery.of(context).size.width / 1.7,
            alignment: Alignment.bottomLeft,
            child: appBarLeadingWidget ?? Container(),
          )
        ],
      ),
    );
  }

  Widget buildButton(
    BuildContext context,
    ValueNotifier<bool> arrowDownNotifier,
  ) {
    if (provider.pathList.isEmpty || provider.currentPath == null) {
      return Container();
    }

    final decoration = BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(35),
    );
    if (provider.currentPath == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: decoration,
      );
    } else {
      return Container(
        decoration: decoration,
        child: Container(
          width: MediaQuery.of(context).size.width / 2.43,
          padding: const EdgeInsets.only(left: 15, bottom: 15),
          alignment: Alignment.bottomLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.28,
                child: Text(
                  provider.currentPath!.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: appBarTextColor,
                      fontSize: 18,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: AnimatedBuilder(
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: appBarIconColor,
                  ),
                  animation: arrowDownNotifier,
                  builder: (BuildContext context, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: child,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class ChangePathWidget extends StatefulWidget {
  final PickerDataProvider provider;
  final ValueSetter<AssetPathEntity> close;

  /// album background color
  final Color albumBackGroundColor;

  /// album text color
  final Color albumTextColor;

  /// album divider color
  final Color albumDividerColor;
  const ChangePathWidget({
    Key? key,
    required this.provider,
    required this.close,
    required this.albumBackGroundColor,
    required this.albumDividerColor,
    required this.albumTextColor,
  }) : super(key: key);

  @override
  _ChangePathWidgetState createState() => _ChangePathWidgetState();
}

class _ChangePathWidgetState extends State<ChangePathWidget> {
  PickerDataProvider get provider => widget.provider;

  ScrollController? controller;
  double itemHeight = 65;

  @override
  void initState() {
    super.initState();
    final index = provider.pathList.indexOf(provider.currentPath!);
    controller = ScrollController(initialScrollOffset: itemHeight * index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.albumBackGroundColor,
      body: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: ListView.builder(
          controller: controller,
          itemCount: provider.pathList.length,
          itemBuilder: _buildItem,
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = provider.pathList[index];
    Widget w = SizedBox(
      height: 65.0,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            item.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: widget.albumTextColor, fontSize: 18),
          ),
        ),
      ),
    );
    w = Stack(
      children: <Widget>[
        /// list of album
        w,

        /// divider
        Positioned(
          height: 1,
          bottom: 0,
          right: 0,
          left: 1,
          child: IgnorePointer(
            child: Container(
              color: widget.albumDividerColor,
            ),
          ),
        ),
      ],
    );
    return GestureDetector(
      child: w,
      behavior: HitTestBehavior.translucent,
      onTap: () {
        widget.close.call(item);
      },
    );
  }
}
