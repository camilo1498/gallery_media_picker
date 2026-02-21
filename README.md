# 📸 Gallery Media Picker

[![Author](https://img.shields.io/badge/Author-camilo1498-blue)](https://github.com/camilo1498)
![Pub Version](https://img.shields.io/pub/v/gallery_media_picker)
![License](https://img.shields.io/badge/license-MIT-blue)
![Platform](https://img.shields.io/badge/platform-Flutter-blue)
[![GitHub stars](https://img.shields.io/github/stars/camilo1498/gallery_media_picker?style=social)](https://github.com/camilo1498/gallery_media_picker/stargazers)

A powerful, high-performance Flutter media picker with an Instagram-style interface. Select images, videos, GIFs, and audio directly from the device gallery with fine-grained control over appearance, behavior, and accessibility.

Built on top of [`photo_manager`](https://pub.dev/packages/photo_manager) with native-level optimizations including `PMCancelToken` cancellation, automatic cache management, and O(1) selection rebuilds.

---

## 💫 Support the Project

If you find this package helpful, please consider giving it a ⭐ on [GitHub](https://github.com/camilo1498/gallery_media_picker) and liking it on [pub.dev](https://pub.dev/packages/gallery_media_picker)!

Your support helps improve and maintain this project! ❤️

---

## ✨ Features

- 📷 Pick single or multiple **images / videos / GIFs / audio**
- 🖼️ Scrollable grid with infinite loading and **persistent thumbnail caching**
- 🔎 Album selector (dropdown overlay style)
- 🎛️ Highly customizable UI (25+ parameters)
- ✅ Built for **Android & iOS**
- 🔍 Automatic GIF badge and video duration overlay
- ♿ Full **accessibility** support (semantic labels for screen readers)
- 🌐 **i18n-ready** with `GalleryMediaPickerTranslations`
- ⚡ **O(1) selection rebuilds** — selecting a photo doesn't rebuild the entire grid
- 🗑️ **Native cache cleanup** on dispose (`PhotoManager.clearFileCache()`)
- 🚫 **Background task cancellation** via `PMCancelToken` when items are deselected

---

## 🚀 Getting Started

### 1. Install

```yaml
dependencies:
  gallery_media_picker: ^0.2.0
```

### 2. Platform Requirements

| | Minimum |
|---|---|
| **Flutter** | `>= 3.41.0` |
| **Dart SDK** | `>= 3.11.0` |
| **photo_manager** | `^3.8.0` |

---

### 3. Permissions Setup

The package uses [`photo_manager`](https://pub.dev/packages/photo_manager) for native media access. It is **strongly recommended** to use [`permission_handler`](https://pub.dev/packages/permission_handler) to request permissions explicitly before displaying the picker.

#### Android

Add the following permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
```

> On older Android versions (API < 33), you may also need:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

#### iOS

In your `Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select media.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Allow access to your gallery</string>
```

#### Recommended Permission Request

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  final status = await Permission.photos.request();
  if (!status.isGranted) {
    // Optionally show a dialog or redirect to app settings
  }
}
```

> ⚠️ Call this function **before** using `GalleryMediaPicker`.

---

### 4. Basic Usage

```dart
GalleryMediaPicker(
  pathList: (List<PickedAssetModel> paths) {
    // Handle selected media files
    for (final asset in paths) {
      print('Selected: ${asset.path} (${asset.type})');
    }
  },
  appBarLeadingWidget: const Icon(Icons.close, color: Colors.white),
  mediaPickerParams: MediaPickerParamsModel(
    maxPickImages: 5,
    singlePick: false,
    mediaType: GalleryMediaType.all,
    thumbnailQuality: ThumbnailQuality.high,
  ),
)
```

---

### 5. Advanced Usage (Dark Theme Example)

```dart
GalleryMediaPicker(
  pathList: (List<PickedAssetModel> paths) {
    context.read<MediaProvider>().setPickedFiles(paths);
  },
  mediaPickerParams: MediaPickerParamsModel(
    appBarHeight: 50,
    maxPickImages: 10,
    crossAxisCount: 4,
    childAspectRatio: 1,
    singlePick: false,
    appBarColor: Colors.transparent,
    gridViewBgColor: const Color(0xFF09090B),
    albumTextColor: Colors.white,
    gridPadding: const EdgeInsets.all(2),
    thumbnailBgColor: const Color(0xFF18181B),
    thumbnailBoxFix: BoxFit.cover,
    selectedAlbumIcon: Icons.check_circle_rounded,
    mediaType: GalleryMediaType.image,
    selectedCheckColor: Colors.white,
    albumSelectIconColor: Colors.white,
    selectedCheckBgColor: const Color(0xFF3B82F6),
    selectedAlbumBgColor: Colors.white10,
    albumDropDownBgColor: const Color(0xFF18181B),
    albumSelectTextColor: Colors.white,
    selectedAssetBgColor: const Color(0xFF3B82F6).withOpacity(0.2),
    selectedAlbumTextColor: const Color(0xFF3B82F6),
    gridViewController: _scrollController, // Use a persistent controller!
    thumbnailQuality: ThumbnailQuality.high,
    gridViewPhysics: const BouncingScrollPhysics(),
    translations: const GalleryMediaPickerTranslations(
      noMediaFound: 'No hay archivos multimedia.',
      permissionDenied: 'Permisos denegados.',
    ),
  ),
)
```

---

## 🧩 API Reference

### `GalleryMediaPicker` Widget

| Property | Type | Description |
|---|---|---|
| `pathList` | `Function(List<PickedAssetModel>)` | **Required.** Callback triggered on selection change. |
| `appBarLeadingWidget` | `Widget?` | Optional widget at the leading position of the toolbar. |
| `mediaPickerParams` | `MediaPickerParamsModel` | **Required.** Configuration model for all picker behavior & styling. |

---

### `MediaPickerParamsModel`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `appBarHeight` | `double` | `50.0` | Height of the top AppBar. |
| `appBarColor` | `Color?` | `null` | Background color of the AppBar. Falls back to theme. |
| `maxPickImages` | `int` | `2` | Maximum number of items allowed to select. |
| `singlePick` | `bool` | `true` | Whether only a single item can be picked. |
| `crossAxisCount` | `int` | `3` | Number of columns in the grid. |
| `childAspectRatio` | `double` | `0.5` | Width-to-height ratio of each grid item. |
| `mediaType` | `GalleryMediaType` | `.all` | Type of media to display (all / image / video / audio). |
| `thumbnailQuality` | `ThumbnailQuality` | `.medium` | Quality of generated thumbnails. |
| `thumbnailBoxFix` | `BoxFit` | `.cover` | How thumbnails fit within their boxes. |
| `thumbnailBgColor` | `Color?` | `null` | Background color of thumbnail containers. |
| `gridViewBgColor` | `Color?` | `null` | Background color of the entire grid view. |
| `gridPadding` | `EdgeInsets?` | `null` | Padding applied to the grid view. |
| `gridViewPhysics` | `ScrollPhysics` | `BouncingScrollPhysics()` | Scroll behavior of the grid. |
| `gridViewController` | `ScrollController?` | `null` | External scroll controller for the grid. |
| `albumTextColor` | `Color?` | `null` | Text color of the selected album name. |
| `albumDropDownBgColor` | `Color?` | `null` | Background color of the album dropdown overlay. |
| `albumSelectIconColor` | `Color?` | `null` | Icon color inside the album dropdown. |
| `albumSelectTextColor` | `Color?` | `null` | Text color inside the album dropdown. |
| `selectedAlbumTextColor` | `Color?` | `null` | Text color of the currently selected album. |
| `selectedAlbumIcon` | `IconData` | `Icons.check` | Icon shown next to the selected album. |
| `selectedAlbumBgColor` | `Color?` | `null` | Background of the selected album row. |
| `selectedAssetBgColor` | `Color?` | `null` | Overlay color applied to selected thumbnails. |
| `selectedCheckColor` | `Color?` | `null` | Color of the checkmark icon on selected items. |
| `selectedCheckBgColor` | `Color?` | `null` | Background color behind the selection checkmark. |
| `translations` | `GalleryMediaPickerTranslations` | `(defaults)` | Override all user-facing strings for i18n. |

---

### `GalleryMediaType`

Controls which types of media assets are fetched from the device gallery.

| Value | Description |
|---|---|
| `all` | Show all media types (images, videos, GIFs, audio). |
| `image` | Show only image files (includes GIFs). |
| `video` | Show only video files. |
| `audio` | Show only audio files. |

---

### `ThumbnailQuality`

Controls the resolution of native thumbnail generation. Higher quality provides more detail but may impact performance with very large galleries.

| Value | Pixel Size | Description |
|---|---|---|
| `low` | `100×100` | Fastest loading, lowest detail. |
| `medium` | `250×250` | Good balance for most use cases. |
| `high` | `400×400` | Best quality, recommended for full-screen pickers. |

---

### `PickedAssetModel`

The data model returned for each selected asset via the `pathList` callback.

| Property | Type | Description |
|---|---|---|
| `id` | `String` | Unique native identifier of the asset. |
| `path` | `String` | File path to the asset on disk. |
| `type` | `PickedAssetType` | Asset type: `.image`, `.video`, or `.other`. |
| `file` | `File?` | File object, if available. |
| `title` | `String?` | Original filename or title. |
| `width` | `int` | Width in pixels. |
| `height` | `int` | Height in pixels. |
| `size` | `Size` | Original size. |
| `orientationWidth` | `int` | Orientation-corrected width. |
| `orientationHeight` | `int` | Orientation-corrected height. |
| `orientationSize` | `Size` | Orientation-corrected size. |
| `videoDuration` | `Duration` | Duration (zero for images). |
| `createDateTime` | `DateTime` | Creation timestamp. |
| `modifiedDateTime` | `DateTime` | Last modification timestamp. |
| `latitude` | `double?` | GPS latitude, if available. |
| `longitude` | `double?` | GPS longitude, if available. |
| `thumbnail` | `Uint8List?` | Thumbnail bytes, if generated. |

---

### `GalleryMediaPickerTranslations`

Override all user-facing strings for localization and accessibility.

| Property | Type | Default | Description |
|---|---|---|---|
| `noMediaFound` | `String` | `'No media found.'` | Shown when an album is empty. |
| `recent` | `String` | `'Recent'` | Label for the recents album. |
| `tapToOpenSettings` | `String` | `'Tap to open settings'` | Settings redirect label. |
| `permissionDenied` | `String` | `'Permissions denied...'` | Shown when gallery access is denied. |
| `maxItemsPicked` | `String` | `'You have already picked %s items.'` | Toast when selection limit is reached. Use `%s` for the number. |
| `videoLabel` | `String` | `'Video'` | Accessibility label for videos. |
| `imageLabel` | `String` | `'Image'` | Accessibility label for images. |
| `gifLabel` | `String` | `'GIF'` | Accessibility label for GIFs. |
| `selectedLabel` | `String` | `'Selected'` | Accessibility label for selected state. |
| `notSelectedLabel` | `String` | `'Not selected'` | Accessibility label for unselected state. |

---

## ⚡ Performance Architecture

The picker includes several performance optimizations built into its core:

### O(1) Selection Rebuilds
Each thumbnail uses an internal `_SelectionWatcher` widget that caches its own selection boolean. When the global selection list changes, only thumbnails whose ownership **actually flips** trigger a `setState`. This means selecting one photo in a grid of 10,000 items rebuilds exactly **1 widget**, not all visible items.

### Persistent Thumbnail Caching with `ValueKey`
Each grid item is keyed with `ValueKey(asset.id)`, ensuring Flutter's element tree correctly identifies and reuses cached images during rapid scrolling. This prevents the common "flicker on scroll back" issue where thumbnails would reload from disk.

### Native Background Task Cancellation
When a user deselects a media item, the in-flight native file extraction (`loadFile`) is automatically cancelled via `PMCancelToken.cancelRequest()`, preventing wasted CPU/battery on files the user no longer wants.

### Automatic Cache Cleanup
On dispose, `PhotoManager.clearFileCache()` is called to clean up temporary OS-generated cache files, preventing storage leaks especially on iOS where HEIC/HEVC transcoding creates temporary copies.

### Race Condition Protection
An internal `_albumChangeId` counter prevents race conditions when rapidly switching between albums or media types, ensuring only the most recent request completes and updates the UI.

---

## 📹 Screenshots / Demo

### *Personalization*
<div style="display: flex; flex-wrap: wrap; gap: 10px;">
  <div style="text-align: center;">
    <p><strong>Dark Setting</strong></p>
    <img src="https://github.com/camilo1498/gallery_media_picker/blob/master/media_doc/dark_settings.png?raw=true" width="120" alt="dark_settings">
  </div>

  <div style="text-align: center;">
    <p><strong>Light Setting</strong></p>
    <img src="https://github.com/camilo1498/gallery_media_picker/blob/master/media_doc/light_settings.png?raw=true" width="120" alt="light_settings">
  </div>

  <div style="text-align: center;">
    <p><strong>Custom Setting</strong></p>
    <img src="https://github.com/camilo1498/gallery_media_picker/blob/master/media_doc/demo_settings.png?raw=true" width="120" alt="custom_settings">
  </div>

  <div style="text-align: center;">
    <p><strong>No leading widget</strong></p>
    <img src="https://github.com/camilo1498/gallery_media_picker/blob/master/media_doc/no_leading_widget.png?raw=true" width="120" alt="no_leading_widget">
  </div>
</div>

### *Album Selection*
<div style="display: flex; flex-wrap: wrap; gap: 20px;">
  <div>
    <img src="https://github.com/camilo1498/gallery_media_picker/blob/master/media_doc/album_selection.gif?raw=true" width="120" alt="album_selection">
  </div>
</div>

### *Pick single file*
<div style="display: flex; flex-wrap: wrap; gap: 20px;">
  <div>
    <img src="https://github.com/camilo1498/gallery_media_picker/blob/master/media_doc/single_pick.gif?raw=true" width="120" alt="pick_single_file">
  </div>
</div>

### *Pick multiple files*
<div style="display: flex; flex-wrap: wrap; gap: 20px;">
  <div>
    <img src="https://github.com/camilo1498/gallery_media_picker/blob/master/media_doc/multi_pick.gif?raw=true" width="120" alt="pick_multiple_files">
  </div>
</div>

### *Select media type*
<div style="display: flex; flex-wrap: wrap; gap: 20px;">
  <div style="text-align: center;">
    <p><strong>Only videos</strong></p>
    <img src="https://github.com/camilo1498/gallery_media_picker/blob/master/media_doc/only_videos.gif?raw=true" width="120" alt="only_videos">
  </div>
  <div style="text-align: center;">
    <p><strong>Only images and GIF</strong></p>
    <img src="https://github.com/camilo1498/gallery_media_picker/blob/master/media_doc/only_images.gif?raw=true" width="120" alt="only_images">
  </div>
</div>

### *Quality comparison*
<div style="display: flex; flex-wrap: wrap; gap: 10px;">
  <div style="text-align: center;">
    <p><strong>Low</strong></p>
    <img src="https://github.com/camilo1498/gallery_media_picker/blob/master/media_doc/quality_low.png?raw=true" width="120" alt="low_quality">
  </div>

  <div style="text-align: center;">
    <p><strong>Medium</strong></p>
    <img src="https://github.com/camilo1498/gallery_media_picker/blob/master/media_doc/quality_medium.png?raw=true" width="120" alt="medium_quality">
  </div>

  <div style="text-align: center;">
    <p><strong>High</strong></p>
    <img src="https://github.com/camilo1498/gallery_media_picker/blob/master/media_doc/quality_high.png?raw=true" width="120" alt="high_quality">
  </div>
</div>

---

## 💬 Contributing

Pull requests are welcome! If you find bugs or have suggestions, feel free to open an issue.

---

## 📄 License

MIT License — see the [LICENSE](LICENSE) file for details.