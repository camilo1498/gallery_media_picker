import 'package:flutter/foundation.dart';

/// A configuration model for overriding default English strings within
/// the `GalleryMediaPicker` widget to support internationalization (i18n).
@immutable
class GalleryMediaPickerTranslations {
  /// Defines all translatable text values for the picker.
  const GalleryMediaPickerTranslations({
    this.noMediaFound = 'No media found.',
    this.recent = 'Recent',
    this.tapToOpenSettings = 'Tap to open settings',
    this.permissionDenied =
        'Permissions denied. Please grant access to your gallery.',
    this.maxItemsPicked = 'You have already picked %s items.',
    this.videoLabel = 'Video',
    this.imageLabel = 'Image',
    this.gifLabel = 'GIF',
    this.selectedLabel = 'Selected',
    this.notSelectedLabel = 'Not selected',
  });

  /// Text shown when an album has no assets.
  final String noMediaFound;

  /// Default text for the recents album.
  final String recent;

  /// Text for the open settings button when permissions are denied.
  final String tapToOpenSettings;

  /// Text shown when the user explicitly denies gallery permissions.
  final String permissionDenied;

  /// Text shown via toast when the maximum selection amount is reached.
  /// Use `%s` as a placeholder for the numerical limit.
  final String maxItemsPicked;

  /// Accessibility label used for videos.
  final String videoLabel;

  /// Accessibility label used for images.
  final String imageLabel;

  /// Accessibility label used for gifs.
  final String gifLabel;

  /// Accessibility label used when an item is selected.
  final String selectedLabel;

  /// Accessibility label used when an item is not selected.
  final String notSelectedLabel;
}
