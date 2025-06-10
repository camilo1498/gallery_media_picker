import 'dart:io';

import 'package:example/src/provider/imageProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  // Paint.enableDithering = true;
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.black),
  );
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PickerDataProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Example(),
    );
  }
}

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  bool _singlePick = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<PickerDataProvider>(
        builder: (context, media, _) {
          return Scaffold(
            body: Column(
              children: [
                Container(
                  height: 300,
                  color: Colors.black,
                  child:
                      media.pickedFiles.isEmpty
                          ? _buildEmptyState()
                          : _buildMediaPreview(media.pickedFiles),
                ),
                // Gallery media picker
                Expanded(
                  child: GalleryMediaPicker(
                    appBarLeadingWidget: _buildAppBarControls(),
                    mediaPickerParams: MediaPickerParamsModel(
                      appBarHeight: 60,
                      maxPickImages: 5,
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      thumbnailQuality: 200,
                      singlePick: _singlePick,
                      thumbnailBoxFix: BoxFit.cover,
                      imageBackgroundColor: Colors.black,
                      selectedCheckColor: Colors.black87,
                      selectedBackgroundColor: Colors.black,
                      appBarColor: Colors.yellow,
                      gridViewBackgroundColor: Colors.grey[900]!,
                      selectedCheckBackgroundColor: Colors.white10,
                    ),
                    pathList: (List<PickedAssetModel> paths) {
                      media.setPickedFiles(paths);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.scale(
            scale: 8,
            child: Icon(Icons.image_outlined, color: Colors.white, size: 10),
          ),
          SizedBox(height: 50),
          Text(
            'No images selected',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(List<PickedAssetModel> pickedFiles) {
    return PageView(
      children:
          pickedFiles.map((data) {
            if (data.type == PickedAssetTypeEnum.image) {
              return Center(
                child: PhotoView.customChild(
                  enablePanAlways: true,
                  maxScale: 2.0,
                  minScale: 1.0,
                  child: Image.file(File(data.path)),
                ),
              );
            } else {
              // You can implement video preview here if needed
              return Container();
            }
          }).toList(),
    );
  }

  Widget _buildAppBarControls() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 15, bottom: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleSelectionButton(),
            const SizedBox(width: 10),
            _buildShareButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSelectionButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _singlePick = !_singlePick;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blue, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select multiple',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 7),
            Transform.scale(
              scale: 1.5,
              child: Icon(
                _singlePick
                    ? Icons.check_box_outline_blank
                    : Icons.check_box_outlined,
                color: Colors.blue,
                size: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return Consumer<PickerDataProvider>(
      builder: (context, media, _) {
        return GestureDetector(
          onTap: () async {
            final mediaPaths = media.pickedFiles.map((p) => p.path).toList();
            if (mediaPaths.isNotEmpty) {
              final files = mediaPaths.map((e) => XFile(e)).toList();
              await Share.shareXFiles(files, text: 'Share');
            }
          },
          child: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue, width: 1.5),
            ),
            child: Transform.scale(
              scale: 2,
              child: const Icon(
                Icons.share_outlined,
                color: Colors.blue,
                size: 10,
              ),
            ),
          ),
        );
      },
    );
  }
}
