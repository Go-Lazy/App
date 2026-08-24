import '../../../shared/models/app_update_info.dart';

/// Data contract for checking and installing app updates. Backed today by
/// [GithubUpdateRepository]; a future release could point this at a
/// dedicated update service without changing any calling code.
abstract class UpdateRepository {
  /// Returns the latest published release, or null if it can't be
  /// determined (e.g. no releases yet, or the check failed).
  Future<AppUpdateInfo?> getLatestRelease();

  /// Downloads the release APK and hands it to the system installer.
  Future<void> downloadAndInstall(AppUpdateInfo update);
}
