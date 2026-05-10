import 'package:flutter/services.dart';
import '../models/app_info.dart';
import '../utils/bloatware_list.dart';

class ShizukuService {
  static const MethodChannel _channel = MethodChannel('com.debloater.app/shizuku');

  static Future<ShizukuStatus> getStatus() async {
    try {
      final int code = await _channel.invokeMethod('getShizukuStatus');
      switch (code) {
        case 0:
          return ShizukuStatus.notInstalled;
        case 1:
          return ShizukuStatus.notRunning;
        case 2:
          return ShizukuStatus.noPermission;
        case 3:
          return ShizukuStatus.ready;
        default:
          return ShizukuStatus.notInstalled;
      }
    } on PlatformException catch (_) {
      return ShizukuStatus.notInstalled;
    }
  }

  static Future<bool> requestPermission() async {
    try {
      final bool granted = await _channel.invokeMethod('requestShizukuPermission');
      return granted;
    } on PlatformException catch (_) {
      return false;
    }
  }

  static Future<List<AppInfo>> getSystemApps() async {
    try {
      final List<dynamic> rawList = await _channel.invokeMethod('getSystemApps');
      return rawList.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        final packageName = map['packageName'] as String;
        final bloatwareEntry = BloatwareList.lookup(packageName);
        return AppInfo(
          packageName: packageName,
          appName: map['appName'] as String,
          isSystemApp: true,
          isRecommendedBloatware: bloatwareEntry != null,
          category: bloatwareEntry?.category ?? 'System',
          status: _parseStatus(map['status'] as String? ?? 'enabled'),
        );
      }).toList();
    } on PlatformException catch (_) {
      return _mockSystemApps();
    }
  }

  static Future<DebloatResult> disableApp(String packageName) async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'disableApp',
        {'packageName': packageName},
      );
      return DebloatResult(
        success: result['success'] as bool,
        message: result['message'] as String,
        action: DebloatAction.disable,
      );
    } on PlatformException catch (e) {
      return DebloatResult(
        success: false,
        message: e.message ?? 'Unknown error',
        action: DebloatAction.disable,
      );
    }
  }

  static Future<DebloatResult> uninstallApp(String packageName) async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'uninstallApp',
        {'packageName': packageName},
      );
      return DebloatResult(
        success: result['success'] as bool,
        message: result['message'] as String,
        action: DebloatAction.uninstall,
      );
    } on PlatformException catch (e) {
      return DebloatResult(
        success: false,
        message: e.message ?? 'Unknown error',
        action: DebloatAction.uninstall,
      );
    }
  }

  static Future<DebloatResult> enableApp(String packageName) async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'enableApp',
        {'packageName': packageName},
      );
      return DebloatResult(
        success: result['success'] as bool,
        message: result['message'] as String,
        action: DebloatAction.enable,
      );
    } on PlatformException catch (e) {
      return DebloatResult(
        success: false,
        message: e.message ?? 'Unknown error',
        action: DebloatAction.enable,
      );
    }
  }

  static AppStatus _parseStatus(String status) {
    switch (status) {
      case 'disabled':
        return AppStatus.disabled;
      case 'uninstalled':
        return AppStatus.uninstalled;
      default:
        return AppStatus.enabled;
    }
  }

  static List<AppInfo> _mockSystemApps() {
    return BloatwareList.packages.entries.take(12).map((entry) {
      return AppInfo(
        packageName: entry.key,
        appName: entry.value.name,
        isSystemApp: true,
        isRecommendedBloatware: entry.value.risk == RiskLevel.safe,
        category: entry.value.category,
        status: AppStatus.enabled,
      );
    }).toList();
  }
}

class DebloatResult {
  final bool success;
  final String message;
  final DebloatAction action;

  DebloatResult({
    required this.success,
    required this.message,
    required this.action,
  });
}

enum DebloatAction { disable, uninstall, enable }

enum ShizukuStatus { notInstalled, notRunning, noPermission, ready }
