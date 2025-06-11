# 📸 Gallery Media Picker - Flutter Package

[![Author](https://img.shields.io/badge/Author-camilo1498-blue)](https://github.com/camilo1498)
![Pub Version](https://img.shields.io/pub/v/gallery_media_picker)
![License](https://img.shields.io/badge/license-MIT-blue)
![Platform](https://img.shields.io/badge/platform-Flutter-blue)
[![GitHub stars](https://img.shields.io/github/stars/camilo1498/gallery_media_picker?style=social)](https://github.com/camilo1498/gallery_media_picker/stargazers)



A powerful and customizable Flutter package that allows users to select multiple media files (images or videos) directly from the device's gallery, featuring an Instagram-style interface and performance-optimized thumbnail rendering.

Built on top of [`photo_manager`](https://pub.dev/packages/photo_manager), `gallery_media_picker` is ideal for apps requiring fast media access, beautiful UX, and fine-grained configuration.

---

## ✨ Features

- 📷 Pick single or multiple images / videos / GIF
- 🖼️ Scrollable grid with infinite loading
- 🔎 Album selector (dropdown style)
- 🎛️ Highly customizable UI
- ✅ Built for Android & iOS
- 🔍 Support for GIF and video duration tags

---

## 🚀 Getting Started

### 1. Install

```yaml
dependencies:
  gallery_media_picker: ^<latest_version>
````

---

### 2. Permissions Setup

Although [`photo_manager`](https://pub.dev/packages/photo_manager) handles media access and platform integration, it is **strongly recommended** to use [`permission_handler`](https://pub.dev/packages/permission_handler) to request permissions explicitly. This ensures better user experience, avoids permission-related issues, and complies with app store policies.

#### Android

Add the following permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
```

> On older Android versions (API < 33), you may need:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

#### iOS

In your `Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select media.</string>
```

#### Recommended Permission Request (with `permission_handler`)

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  final status = await Permission.photos.request();
  if (!status.isGranted) {
    // Optionally show a dialog or redirect to app settings
  }
}
```

> ⚠️ Call this function before using `GalleryMediaPicker`.


---

### 3. Basic Usage

```dart
GalleryMediaPicker(
  pathList: (List<PickedAssetModel> paths) {
    // Handle selected media
    media.setPickedFiles(paths);
  },
  appBarLeadingWidget: Icon(Icons.close),
  mediaPickerParams: MediaPickerParamsModel(
    appBarHeight: 50,
    maxPickImages: 2,
    crossAxisCount: 3,
    childAspectRatio: .5,
    singlePick: false,
    appBarColor: Colors.black,
    gridViewBgColor: Colors.red,
    albumTextColor: Colors.white,
    gridPadding: EdgeInsets.zero,
    thumbnailBgColor: Colors.cyan,
    thumbnailBoxFix: BoxFit.cover,
    selectedAlbumIcon: Icons.check,
    selectedCheckColor: Colors.black,
    albumSelectIconColor: Colors.blue,
    selectedCheckBgColor: Colors.blue,
    selectedAlbumBgColor: Colors.black,
    albumDropDownBgColor: Colors.green,
    albumSelectTextColor: Colors.orange,
    selectedAssetBgColor: Colors.orange,
    selectedAlbumTextColor: Colors.white,
    mediaType: GalleryMediaType.all,
    gridViewController: ScrollController(),
    thumbnailQuality: ThumbnailQuality.medium,
    gridViewPhysics: const BouncingScrollPhysics(),
  ),
),
```

---

## 🧩 MediaPickerParamsModel – Full Parameter Guide

###  `pathList Callback`
This callback is triggered whenever the user selects or deselects media items.

It returns a list of PickedAssetModel objects representing the currently selected files (images or videos), which you can store, preview, or process as needed.

---

###  `appBarLeadingWidget`

Optional widget to be displayed at the leading position of the album selector (top row).
Use this to insert a custom control like a back button, close icon, or any widget you'd like to show at the start of the toolbar.

---

###  `mediaPickerParams`

Each parameter lets you fine-tune the look and feel of the media picker.

| Parameter                | Description                                  | Type               | Default                   |
|--------------------------|----------------------------------------------|--------------------|---------------------------|
| `appBarHeight`           | Height of the top AppBar                     | `double`           | `50.0`                    |
| `appBarColor`            | Background color of the AppBar               | `Color`            | `Colors.black`            |
| `albumTextColor`         | Text color of the selected album             | `Color`            | `Colors.white`            |
| `albumDropDownBgColor`   | Background color of album dropdown           | `Color`            | `Colors.green`            |
| `albumSelectIconColor`   | Icon color in dropdown                       | `Color`            | `Colors.blue`             |
| `albumSelectTextColor`   | Text color in dropdown list                  | `Color`            | `Colors.orange`           |
| `selectedAlbumTextColor` | Color of selected album title                | `Color`            | `Colors.white`            |
| `selectedAlbumIcon`      | Icon shown when album is selected            | `IconData`         | `Icons.check`             |
| `selectedAlbumBgColor`   | Background of selected album                 | `Color`            | `Colors.black`            |
| `selectedAssetBgColor`   | Background color for selected media          | `Color`            | `Colors.orange`           |
| `selectedCheckColor`     | Checkmark color for selected assets          | `Color`            | `Colors.black`            |
| `selectedCheckBgColor`   | Checkmark background circle color            | `Color`            | `Colors.blue`             |
| `gridViewBgColor`        | GridView background color                    | `Color`            | `Colors.red`              |
| `gridPadding`            | Grid padding                                 | `EdgeInsets`       | `EdgeInsets.zero`         |
| `crossAxisCount`         | Number of columns                            | `int`              | `3`                       |
| `childAspectRatio`       | Ratio of width to height                     | `double`           | `.5`                      |
| `thumbnailBoxFix`        | Fit mode for thumbnails                      | `BoxFit`           | `BoxFit.cover`            |
| `thumbnailBgColor`       | Thumbnail container color                    | `Color`            | `Colors.cyan`             |
| `thumbnailQuality`       | Enum for quality: `low`, `medium`, `high`    | `ThumbnailQuality` | `ThumbnailQuality.medium` |
| `gridViewController`     | ScrollController for the GridView            | `ScrollController` | `ScrollController()`      |
| `gridViewPhysics`        | Scroll behavior                              | `ScrollPhysics`    | `BouncingScrollPhysics()` |
| `maxPickImages`          | Max number of assets to select               | `int`              | `2`                       |
| `singlePick`             | Whether only one image can be picked         | `bool`             | `false`                   |
| `mediaType`              | Type of media to display (all/images/videos) | `GalleryMediaType` | `GalleryMediaType.all`    |

## 🧠 Enum: ThumbnailQuality

| Value    | Description                    | Pixel size |
|----------|--------------------------------|------------|
| `low`    | Fastest loading, lowest detail | `100x100`  |
| `medium` | Good balance                   | `200x200`  |
| `high`   | Best quality, slower load      | `350x350`  |

---


## 📹 Screenshots / Demo

## *Album Selection*
<div style="display: flex; flex-wrap: wrap; gap: 20px;">
  <div>
    <img src="" width="120" alt="list_scroll_android">
  </div>
</div>

## *Pick single file*
<div style="display: flex; flex-wrap: wrap; gap: 20px;">
  <div>
    <img src="" width="120" alt="list_scroll_android">
  </div>
</div>

## *Pick multiple files*
<div style="display: flex; flex-wrap: wrap; gap: 20px;">
  <div>
    <img src="" width="120" alt="list_scroll_android">
  </div>
</div>

## *Select media type*
<div style="display: flex; flex-wrap: wrap; gap: 20px;">
  <div style="text-align: center;">
    <p><strong>Only videos</strong></p>
    <img src="" width="120" alt="list_scroll_android">
  </div>
  <div style="text-align: center;">
    <p><strong>Single widget</strong></p>
    <img src="" width="120" alt="list_scroll_android">
  </div>
</div>

## *Quality comparison*
<div style="display: flex; flex-wrap: wrap; gap: 10px;">
  <div style="text-align: center;">
    <p><strong>Low</strong></p>
    <img src="" width="120" alt="list_scroll_android">
  </div>

  <div style="text-align: center;">
    <p><strong>Medium</strong></p>
    <img src="" width="120" alt="list_scroll_android">
  </div>

  <div style="text-align: center;">
    <p><strong>High</strong></p>
    <img src="" width="120" alt="list_scroll_android">
  </div>
</div>

---

## 💬 Contributing

Pull requests are welcome! If you find bugs or have suggestions, feel free to open an issue.

---

## 📄 License

MIT License — see the [LICENSE](LICENSE) file for details.

---