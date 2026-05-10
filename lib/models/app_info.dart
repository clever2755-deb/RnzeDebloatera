class AppInfo {
  final String packageName;
  final String appName;
  final bool isSystemApp;
  final bool isRecommendedBloatware;
  final String category;
  AppStatus status;

  AppInfo({
    required this.packageName,
    required this.appName,
    required this.isSystemApp,
    required this.isRecommendedBloatware,
    required this.category,
    this.status = AppStatus.enabled,
  });

  factory AppInfo.fromMap(Map<String, dynamic> map) {
    return AppInfo(
      packageName: map['packageName'] ?? '',
      appName: map['appName'] ?? '',
      isSystemApp: map['isSystemApp'] ?? false,
      isRecommendedBloatware: map['isRecommendedBloatware'] ?? false,
      category: map['category'] ?? 'Other',
      status: AppStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'enabled'),
        orElse: () => AppStatus.enabled,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'isSystemApp': isSystemApp,
      'isRecommendedBloatware': isRecommendedBloatware,
      'category': category,
      'status': status.name,
    };
  }
}

enum AppStatus { enabled, disabled, uninstalled }
