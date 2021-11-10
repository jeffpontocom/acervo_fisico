import 'package:package_info_plus/package_info_plus.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class AppData {
  static late final String appName;
  static late final String packageName;
  static late final String version;
  static late final String buildNumber;
  static ParseUser? currentUser;
  AppData();

  Future<void> init() async {
    // App info
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    // Parse User
    currentUser = await ParseUser.currentUser() as ParseUser?;
  }
}
