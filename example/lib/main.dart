import 'dart:io';

import 'package:better_video_player/better_video_player.dart';
import 'package:example/src/provider/imageProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  Paint.enableDithering = true;
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
  ));
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => PickerDataProvider())],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Example(),
    );
  }
}

class Example extends StatefulWidget {
  const Example({Key key}) : super(key: key);

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
                  child: media.pickedFile.isEmpty

                      /// no images selected
                      ? Container(
                          height: double.infinity,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Transform.scale(
                                scale: 8,
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                              const SizedBox(height: 50),
                              const Text(
                                'No images selected',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70),
                              )
                            ],
                          ),
                        )

                      /// selected images
                      : PageView(
                          children: [
                            ...media.pickedFile.map((data) {
                              /// show image
                              if (data.type == 'image') {
                                return Center(
                                  child: PhotoView.customChild(
                                    enablePanAlways: true,
                                    maxScale: 2.0,
                                    minScale: 1.0,
                                    child: Image.file(File(data.path)),
                                  ),
                                );
                              }

                              /// show video
                              else {
                                if (mounted) {
                                  return AspectRatio(
                                    aspectRatio: 16.0 / 9.0,
                                    child: BetterVideoPlayer(
                                      configuration:
                                          const BetterVideoPlayerConfiguration(
                                        looping: true,
                                        autoPlay: true,
                                        allowedScreenSleep: false,
                                        autoPlayWhenResume: true,
                                      ),
                                      controller: BetterVideoPlayerController(),
                                      dataSource: BetterVideoPlayerDataSource(
                                        BetterVideoPlayerDataSourceType.file,
                                        data.path,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              }
                            })
                          ],
                        ),
                ),

                /// gallery media picker
                Expanded(
                  child: GalleryMediaPicker(
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
                      gridViewBackgroundColor: Colors.grey[900],
                      selectedCheckBackgroundColor: Colors.white10,
                      appBarLeadingWidget: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15, bottom: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              /// select multiple / single
                              SizedBox(
                                height: 30,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _singlePick = !_singlePick;
                                          });
                                          debugPrint(_singlePick.toString());
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: Colors.blue, width: 1.5),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'Select multiple',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 10),
                                                ),
                                                const SizedBox(
                                                  width: 7,
                                                ),
                                                Transform.scale(
                                                  scale: 1.5,
                                                  child: Icon(
                                                    _singlePick
                                                        ? Icons
                                                            .check_box_outline_blank
                                                        : Icons
                                                            .check_box_outlined,
                                                    color: Colors.blue,
                                                    size: 10,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),

                              /// share
                              GestureDetector(
                                onTap: () async {
                                  List<String> mediaPath = [];
                                  media.pickedFile.map((p) {
                                    setState(() {
                                      mediaPath.add(p.path);
                                    });
                                  }).toString();
                                  if (mediaPath.isNotEmpty) {
                                    await Share.shareFiles(mediaPath);
                                  }
                                  mediaPath.clear();
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.blue, width: 1.5),
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
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    pathList: (paths) {
                      setState(() {
                        /// for this example i used provider, you can choose the state management that you prefer
                        media.pickedFile = paths;
                      });
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
