import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:new_version_plus/model/version_status.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'version_source.dart';

class ApiVersionSource implements VersionSource {
  final Uri apiUrl;
  final Map<String, String>? additionalHeaders;

  ApiVersionSource({required this.apiUrl, this.additionalHeaders});

  @override
  Future<VersionStatus?> checkVersion(PackageInfo packageInfo) async {
    final response = await http.get(
      apiUrl,
      headers: {
        'X-App-Version': packageInfo.version,
        'X-Platform': _getPlatform(),
        ...?additionalHeaders,
      },
    );

    if (response.statusCode != 200) {
      throw HttpException('HTTP error: ${response.statusCode}');
    }

    final latestVersion = response.headers['x-latest-app-version'];
    final forceUpdate = response.headers['x-force-update']?.toLowerCase() == 'true';
    final note = response.headers['x-release-notes'];
    final storeUrl = response.headers['x-store-url'];

    if (latestVersion == null) {
      throw Exception('Header "x-latest-app-version" missing in response');
    }

    if (_compareVersions(packageInfo.version, latestVersion) >= 0) {
      // Ya está actualizado, no hay actualización disponible.
      return null;
    }

    return VersionStatus(
      localVersion: packageInfo.version,
      storeVersion: latestVersion,
      appStoreLink: storeUrl ?? '',
      releaseNotes: note,
      forceUpdate: forceUpdate,
    );
  }

  String _getPlatform() {
    if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isAndroid) {
      return 'android';
    }
    return 'unknown';
  }

  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.tryParse).toList();
    final parts2 = v2.split('.').map(int.tryParse).toList();
    for (int i = 0; i < parts1.length && i < parts2.length; i++) {
      final a = parts1[i] ?? 0;
      final b = parts2[i] ?? 0;
      if (a != b) return a - b;
    }
    return parts1.length - parts2.length;
  }
}
