/// Centralized constants and helpers for album name normalization.
///
/// This class prevents hardcoded string comparisons scattered across
/// widgets by providing a single source of truth for OS-specific
/// album name aliases (e.g. iOS uses "Recents", Android uses "Recent").
abstract final class AlbumConstants {
  /// Known OS-specific aliases for the "Recents" album.
  ///
  /// Both iOS and Android use slightly different names for the default
  /// camera roll / recent photos album. This set covers all known variants.
  static const Set<String> recentAliases = {
    'recent',
    'recents',
  };

  /// Returns `true` if [albumName] matches any known "Recents" alias,
  /// performing a case-insensitive comparison.
  static bool isRecentAlbum(String albumName) =>
      recentAliases.contains(albumName.toLowerCase());
}
