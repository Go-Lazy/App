/// A GitHub release that is newer than the currently installed app version.
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.version,
    required this.apkDownloadUrl,
    this.releaseNotes,
  });

  /// The released version, e.g. "1.1.0".
  final String version;

  /// Direct download URL for the release's APK asset.
  final String apkDownloadUrl;

  /// Optional release notes (GitHub release body), shown to the user.
  final String? releaseNotes;
}
