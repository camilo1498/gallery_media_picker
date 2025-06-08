# Gallery Media Picker - Flutter Package

![Pub Version](https://img.shields.io/pub/v/gallery_media_picker)
![License](https://img.shields.io/badge/license-MIT-blue)

A customizable and efficient Flutter package for picking multiple images and videos from the user's device, inspired by Instagram's media picker.

Built on top of [`photo_manager`](https://pub.dev/packages/photo_manager), this package provides scrollable grid views, album navigation, thumbnail previews, and optimized asset management for high-performance and high-quality media handling.

---

## Features

- 📷 Pick single or multiple images/videos
- 🖼️ Scrollable grid with infinite loading
- 🔎 Album selector (with dropdown menu)
- 🎛️ Full UI customization (colors, layout, app bar, etc.)
- 🖌️ High-quality thumbnails with performance optimization
- ⚙️ Custom image provider for thumbnail rendering (`DecodeImage`)
- 🌙 Light and dark theme support
- ✅ Supports both iOS and Android
- 🧱 Built using `photo_manager`, `share_plus`, and `photo_view`

---

## Screenshots

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/camilo1498/gallery_media_picker/master/doc/grid_android.gif" width="250"/></td>
    <td><img src="https://raw.githubusercontent.com/camilo1498/gallery_media_picker/master/doc/album_switch.gif" width="250"/></td>
  </tr>
</table>

---

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  gallery_media_picker: ^latest_version
````

Then run:

```bash
flutter pub get
```

---

## Full Example

```dart
class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  bool _singlePick = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Media picker view
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
                gridViewBackgroundColor: Colors.grey[900]!,
                selectedCheckBackgroundColor: Colors.white10,
                appBarLeadingWidget: _buildAppBarControls(),
              ),
              pathList: (List<PickedAssetModel> paths) {
                media.setPickedFiles(paths);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Usage Summary

### 1. Show the picker

```dart
GalleryMediaPicker(
  mediaPickerParams: MediaPickerParamsModel(
    maxPickImages: 5,
    singlePick: false,
    crossAxisCount: 4,
    thumbnailQuality: 200,
  ),
  pathList: (pickedAssets) {
    // Handle result
  },
);
```

### 2. Show thumbnails with `DecodeImage`

```dart
Image(
  image: DecodeImage(entity, index: 0, thumbSize: 200),
  fit: BoxFit.cover,
);
```

---

## MediaPickerParamsModel

| Parameter                 | Description                          | Default        |
| ------------------------- | ------------------------------------ | -------------- |
| `maxPickImages`           | Maximum number of assets selectable  | `5`            |
| `singlePick`              | Toggle for single/multiple selection | `false`        |
| `thumbnailQuality`        | Pixel size for thumbnail             | `200`          |
| `crossAxisCount`          | Number of columns in grid view       | `3`            |
| `gridViewBackgroundColor` | Background color for grid            | `Colors.white` |
| `thumbnailBoxFix`         | BoxFit for thumbnails                | `BoxFit.cover` |
| `appBarLeadingWidget`     | Custom widget to place on top right  | `null`         |

---

## Platform Permissions

### iOS (`Info.plist`)

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photos.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs access to your gallery</string>
```

### Android (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
```

> ⚠️ For Android SDK < 33, use `READ_EXTERNAL_STORAGE`.

---

## FAQ

**Q: Can it load assets with infinite scroll?**
A: Yes! Uses lazy loading with `getAssetListRange()` from `photo_manager`.

**Q: Can I share selected media?**
A: Yes, using [`share_plus`](https://pub.dev/packages/share_plus).

**Q: Does it support dark mode?**
A: Absolutely. Fully theme-customizable.

---

## Roadmap

* [x] Album switching
* [x] Scrollable grid
* [x] High-quality thumbnails
* [x] Video preview support
* [ ] Camera integration

---

## License

MIT – see [LICENSE](LICENSE)

---

## Author

Camilo Velandia
[GitHub](https://github.com/camilo1498)
