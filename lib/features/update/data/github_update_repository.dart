import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/config/app_config.dart';
import '../../../shared/models/app_update_info.dart';
import 'update_repository.dart';

/// Checks the public GitHub Releases API for the latest published GoLazy
/// APK and installs it via the system package installer.
class GithubUpdateRepository implements UpdateRepository {
  static final Uri _latestReleaseUri = Uri.parse(
    'https://api.github.com/repos/'
    '${AppConfig.githubRepoOwner}/${AppConfig.githubRepoName}/releases/latest',
  );

  @override
  Future<AppUpdateInfo?> getLatestRelease() async {
    final response = await http
        .get(_latestReleaseUri, headers: {'Accept': 'application/vnd.github+json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final tagName = json['tag_name'] as String?;
    if (tagName == null) return null;

    final assets = (json['assets'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final apkAsset = _pickApkAsset(assets);
    if (apkAsset == null) return null;

    return AppUpdateInfo(
      version: tagName.startsWith('v') ? tagName.substring(1) : tagName,
      apkDownloadUrl: apkAsset['browser_download_url'] as String,
      releaseNotes: json['body'] as String?,
    );
  }

  Map<String, dynamic>? _pickApkAsset(List<Map<String, dynamic>> assets) {
    final apkAssets = assets.where(
      (asset) => (asset['name'] as String? ?? '').endsWith('.apk'),
    );
    if (apkAssets.isEmpty) return null;

    return apkAssets.firstWhere(
      (asset) => (asset['name'] as String).contains('arm64-v8a'),
      orElse: () => apkAssets.first,
    );
  }

  @override
  Future<void> downloadAndInstall(AppUpdateInfo update) async {
    final response = await http.get(Uri.parse(update.apkDownloadUrl));
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/golazy_update.apk');
    await file.writeAsBytes(response.bodyBytes);
    await OpenFilex.open(file.path);
  }
}
