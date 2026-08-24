import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/utils/version_compare.dart';
import '../../../shared/models/app_update_info.dart';
import '../data/github_update_repository.dart';
import '../data/update_repository.dart';

final updateRepositoryProvider = Provider<UpdateRepository>((ref) {
  return GithubUpdateRepository();
});

/// Resolves to the latest release if it's newer than the installed app,
/// or null if the app is already up to date (or the check failed). Kicked
/// off as soon as the app launches so the result is ready by the time Home
/// can show it; cached for the rest of the session since it's a plain
/// (non-autoDispose) provider.
final appUpdateCheckProvider = FutureProvider<AppUpdateInfo?>((ref) async {
  final repository = ref.watch(updateRepositoryProvider);
  final latestRelease = await repository.getLatestRelease();
  if (latestRelease == null) return null;

  final packageInfo = await PackageInfo.fromPlatform();
  if (isNewerVersion(latestRelease.version, packageInfo.version)) {
    return latestRelease;
  }
  return null;
});

/// Whether the "update available" dialog has already been shown this
/// session, so returning to Home doesn't keep re-prompting.
final updatePromptShownProvider = StateProvider<bool>((ref) => false);
