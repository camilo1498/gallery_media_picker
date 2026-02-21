## 0.3.0

### New Features
* **Audio media support** — `GalleryMediaType.audio` filter for audio-only browsing.
* **Live gallery refresh** — Grid auto-updates when photos are added or deleted externally via `PhotoManager` change observer.
* **Album selector** — Fully styled album dropdown with dark-theme support.
* **i18n support** — `GalleryMediaPickerTranslations` for full localization of picker strings.

### Performance
* **O(1) rebuilds** — `ValueNotifier`-based state management eliminates unnecessary widget rebuilds.
* **Thumbnail caching** — `_assetCache` prevents redundant platform channel calls during scroll.
* **Cancel token support** — Ongoing native extractions are cancelled on deselection to save CPU.
* **Origin-first file loading** — Bypasses iOS HEIC/HEVC transcoding for faster file access.

### Bug Fixes
* Fixed `PlatformException` crash on iPad when using `share_plus` (missing `sharePositionOrigin`).
* Fixed race condition in `_processPickedFilesFor` where rapid taps caused preview to silently not display.
* Fixed stale `_assetCache` not invalidating when gallery observer detected changes.
* Replaced hardcoded `'recent'`/`'recents'` strings with centralized `AlbumConstants.isRecentAlbum()`.

### Breaking Changes
* `MediaPickerParamsModel` now uses nullable color parameters for M3 theming compatibility.
* `PickedAssetModel.fromAssetEntity` now accepts an optional `PMCancelToken` parameter.

---

## 0.2.0

* Major architecture refactor with `MediaPickerController` and `GalleryMediaProvider`.
* Added `ThumbnailQuality` enum and configurable grid parameters.
* Added permission handling with `PermissionState`.

---

## 0.0.1

* Initial release.
