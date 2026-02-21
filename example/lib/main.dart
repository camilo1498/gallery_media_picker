import 'dart:io';
import 'dart:ui';

import 'package:example/src/provider/image_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PickerDataProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery Media Picker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09090B), // Very dark zinc
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6), // Blue
          surface: Color(0xFF18181B),
        ),
        fontFamily: 'Inter',
      ),
      home: const Example(),
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
  GalleryMediaType _mediaType = GalleryMediaType.all;

  // Persistent scroll controller prevents internal grids from dumping cache
  // when parameters are re-evalued during parent UI rebuilds
  final ScrollController _gridScrollController = ScrollController();

  @override
  void dispose() {
    _gridScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Main Gallery Picker positioned below the preview overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 130,
            left: 0,
            right: 0,
            bottom: 0,
            child: GalleryMediaPicker(
              pathList: (List<PickedAssetModel> paths) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<PickerDataProvider>().setPickedFiles(paths);
                });
              },
              mediaPickerParams: MediaPickerParamsModel(
                appBarHeight: 45,
                maxPickImages: 10,
                crossAxisCount: 4,
                childAspectRatio: 1,
                singlePick: _singlePick,
                appBarColor: const Color(0xFF09090B),
                gridViewBgColor: const Color(0xFF09090B),
                gridPadding: const EdgeInsets.only(
                  bottom: 100, // Space for floating controls
                  left: 1.5,
                  right: 1.5,
                ),
                albumTextColor: Colors.white,
                albumSelectIconColor: Colors.white70,
                albumSelectTextColor: Colors.white,
                selectedAlbumTextColor: const Color(0xFF3B82F6),
                selectedAlbumBgColor: Colors.white.withValues(alpha: 0.08),
                albumDropDownBgColor: const Color(0xFF18181B),
                thumbnailBgColor: const Color(0xFF18181B),
                thumbnailBoxFix: BoxFit.cover,
                selectedAlbumIcon: Icons.check_circle_rounded,
                mediaType: _mediaType,
                selectedCheckColor: Colors.white,
                selectedCheckBgColor: const Color(0xFF3B82F6),
                selectedAssetBgColor: const Color(
                  0xFF3B82F6,
                ).withValues(alpha: 0.2),
                gridViewController: _gridScrollController, // Persistent
                thumbnailQuality: ThumbnailQuality.high,
                gridViewPhysics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
              ),
            ),
          ),

          // Floating Glassmorphism Preview Array at the Top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    bottom: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF09090B).withValues(alpha: 0.9),
                        const Color(0xFF09090B).withValues(alpha: 0.5),
                        const Color(0xFF09090B).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: Consumer<PickerDataProvider>(
                    builder: (context, media, _) {
                      return SizedBox(
                        height: 100,
                        child:
                            media.pickedFiles.isEmpty
                                ? _buildEmptyState()
                                : _buildMediaPreview(media.pickedFiles),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Floating Control Dock at the Bottom
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 0,
            right: 0,
            child: Center(child: _buildAppBarControls()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
            child: const Icon(
              Icons.photo_library_rounded,
              color: Colors.white54,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Select media below',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white54,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(List<PickedAssetModel> pickedFiles) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: pickedFiles.length,
      itemBuilder: (context, index) {
        final data = pickedFiles[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 12),
          width: 75, // Smaller previews
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            color: const Color(0xFF18181B),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (data.type == PickedAssetType.image)
                  Image.file(File(data.path), fit: BoxFit.cover)
                else
                  VideoPreview(filePath: data.path),

                // Overlay gradient for aesthetics
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBarControls() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMediaTypeSelector(),
              const SizedBox(width: 12),
              Container(width: 1, height: 20, color: Colors.white24),
              const SizedBox(width: 12),
              _buildToggleSelectionButton(),
              const SizedBox(width: 12),
              Container(width: 1, height: 20, color: Colors.white24),
              const SizedBox(width: 12),
              _buildShareButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaTypeSelector() {
    return PopupMenuButton<GalleryMediaType>(
      initialValue: _mediaType,
      color: const Color(0xFF18181B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      onSelected: (GalleryMediaType type) {
        setState(() {
          _mediaType = type;
        });
      },
      itemBuilder:
          (context) => [
            _buildPopupItem(
              GalleryMediaType.all,
              'All Media',
              Icons.dashboard_rounded,
            ),
            _buildPopupItem(
              GalleryMediaType.image,
              'Images',
              Icons.image_rounded,
            ),
            _buildPopupItem(
              GalleryMediaType.video,
              'Videos',
              Icons.videocam_rounded,
            ),
            _buildPopupItem(
              GalleryMediaType.audio,
              'Audio',
              Icons.audiotrack_rounded,
            ),
          ],
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.white.withValues(alpha: 0.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _mediaType == GalleryMediaType.all
                  ? Icons.dashboard_rounded
                  : _mediaType == GalleryMediaType.image
                  ? Icons.image_rounded
                  : _mediaType == GalleryMediaType.video
                  ? Icons.videocam_rounded
                  : Icons.audiotrack_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _mediaType.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<GalleryMediaType> _buildPopupItem(
    GalleryMediaType value,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
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
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color:
              _singlePick
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFF3B82F6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _singlePick
                  ? Icons.filter_none_rounded
                  : Icons.library_add_check_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _singlePick ? 'SINGLE' : 'MULTI',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
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
        final hasItems = media.pickedFiles.isNotEmpty;
        return Builder(
          builder: (builderContext) {
            return GestureDetector(
              onTap:
                  hasItems
                      ? () async {
                        final box =
                            builderContext.findRenderObject() as RenderBox?;
                        final mediaPaths =
                            media.pickedFiles.map((p) => p.path).toList();
                        final files = mediaPaths.map((e) => XFile(e)).toList();
                        await SharePlus.instance.share(
                          ShareParams(
                            files: files,
                            sharePositionOrigin:
                                box != null
                                    ? box.localToGlobal(Offset.zero) & box.size
                                    : null,
                          ),
                        );
                      }
                      : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color:
                      hasItems
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.ios_share_rounded,
                  color: hasItems ? Colors.black : Colors.white38,
                  size: 20,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class VideoPreview extends StatefulWidget {
  final String filePath;
  const VideoPreview({super.key, required this.filePath});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.setVolume(0);
          _controller.play();
          _controller.setLooping(true);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const ColoredBox(color: Color(0xFF18181B));
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
