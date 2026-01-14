import 'package:new_version_plus/model/version_status.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract class VersionSource {
  Future<VersionStatus?> checkVersion(PackageInfo packageInfo);
}
