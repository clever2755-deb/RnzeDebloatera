class BloatwareList {
  static const Map<String, BloatwareEntry> packages = {
    // Samsung Bloatware
    'com.samsung.android.game.gametools': BloatwareEntry(name: 'Game Tools', category: 'Samsung', risk: RiskLevel.safe),
    'com.samsung.android.game.gamehome': BloatwareEntry(name: 'Game Launcher', category: 'Samsung', risk: RiskLevel.safe),
    'com.samsung.android.bixby.agent': BloatwareEntry(name: 'Bixby Voice', category: 'Samsung', risk: RiskLevel.safe),
    'com.samsung.android.bixby.wakeup': BloatwareEntry(name: 'Bixby Wakeup', category: 'Samsung', risk: RiskLevel.safe),
    'com.samsung.android.bixbyvision.framework': BloatwareEntry(name: 'Bixby Vision', category: 'Samsung', risk: RiskLevel.safe),
    'com.samsung.android.app.spage': BloatwareEntry(name: 'Bixby Home', category: 'Samsung', risk: RiskLevel.safe),
    'com.samsung.android.Samsung Pay Framework': BloatwareEntry(name: 'Samsung Pay Framework', category: 'Samsung', risk: RiskLevel.caution),
    'com.samsung.android.samsungpay.gear': BloatwareEntry(name: 'Samsung Pay Gear', category: 'Samsung', risk: RiskLevel.safe),
    'com.sec.android.app.sbrowser': BloatwareEntry(name: 'Samsung Browser', category: 'Browser', risk: RiskLevel.safe),
    'com.samsung.android.app.tips': BloatwareEntry(name: 'Samsung Tips', category: 'Samsung', risk: RiskLevel.safe),
    'com.samsung.android.themestore': BloatwareEntry(name: 'Galaxy Themes Store', category: 'Samsung', risk: RiskLevel.safe),
    'com.samsung.android.weather': BloatwareEntry(name: 'Samsung Weather', category: 'Samsung', risk: RiskLevel.safe),
    'com.samsung.android.app.galaxyfinder': BloatwareEntry(name: 'Galaxy Finder', category: 'Samsung', risk: RiskLevel.safe),
    'com.samsung.android.rubin.app': BloatwareEntry(name: 'Samsung Daily', category: 'Samsung', risk: RiskLevel.safe),
    'com.samsung.android.fast.booster': BloatwareEntry(name: 'Fast Booster', category: 'Samsung', risk: RiskLevel.safe),

    // Google Bloatware
    'com.google.android.apps.tachyon': BloatwareEntry(name: 'Google Duo', category: 'Google', risk: RiskLevel.safe),
    'com.google.android.apps.youtube.music': BloatwareEntry(name: 'YouTube Music', category: 'Google', risk: RiskLevel.safe),
    'com.google.android.videos': BloatwareEntry(name: 'Google Videos', category: 'Google', risk: RiskLevel.safe),
    'com.google.android.apps.magazines': BloatwareEntry(name: 'Google News', category: 'Google', risk: RiskLevel.safe),
    'com.google.android.apps.books': BloatwareEntry(name: 'Google Play Books', category: 'Google', risk: RiskLevel.safe),
    'com.google.android.apps.podcasts': BloatwareEntry(name: 'Google Podcasts', category: 'Google', risk: RiskLevel.safe),
    'com.google.android.apps.fitness': BloatwareEntry(name: 'Google Fit', category: 'Google', risk: RiskLevel.safe),
    'com.google.android.gm': BloatwareEntry(name: 'Gmail', category: 'Google', risk: RiskLevel.caution),
    'com.google.android.apps.maps': BloatwareEntry(name: 'Google Maps', category: 'Google', risk: RiskLevel.caution),
    'com.google.android.googlequicksearchbox': BloatwareEntry(name: 'Google App', category: 'Google', risk: RiskLevel.caution),

    // Xiaomi / MIUI Bloatware
    'com.miui.weather2': BloatwareEntry(name: 'MIUI Weather', category: 'Xiaomi', risk: RiskLevel.safe),
    'com.miui.compass': BloatwareEntry(name: 'MIUI Compass', category: 'Xiaomi', risk: RiskLevel.safe),
    'com.miui.cleanmaster': BloatwareEntry(name: 'MIUI Cleaner', category: 'Xiaomi', risk: RiskLevel.safe),
    'com.miui.player': BloatwareEntry(name: 'MIUI Music', category: 'Xiaomi', risk: RiskLevel.safe),
    'com.miui.video': BloatwareEntry(name: 'MIUI Video', category: 'Xiaomi', risk: RiskLevel.safe),
    'com.miui.gaming': BloatwareEntry(name: 'MIUI Game Speed Booster', category: 'Xiaomi', risk: RiskLevel.safe),
    'com.miui.bugreport': BloatwareEntry(name: 'MIUI Bug Report', category: 'Xiaomi', risk: RiskLevel.safe),
    'com.miui.analytics': BloatwareEntry(name: 'MIUI Analytics', category: 'Xiaomi', risk: RiskLevel.safe),
    'com.mi.globalbrowser': BloatwareEntry(name: 'Mi Browser', category: 'Xiaomi', risk: RiskLevel.safe),

    // OnePlus Bloatware
    'com.oneplus.weather': BloatwareEntry(name: 'OnePlus Weather', category: 'OnePlus', risk: RiskLevel.safe),
    'com.oneplus.games': BloatwareEntry(name: 'OnePlus Game Space', category: 'OnePlus', risk: RiskLevel.safe),
    'com.oneplus.bugreport': BloatwareEntry(name: 'OnePlus Bug Report', category: 'OnePlus', risk: RiskLevel.safe),

    // Common Carrier Bloatware
    'com.facebook.appmanager': BloatwareEntry(name: 'Facebook App Manager', category: 'Social', risk: RiskLevel.safe),
    'com.facebook.services': BloatwareEntry(name: 'Facebook Services', category: 'Social', risk: RiskLevel.safe),
    'com.facebook.system': BloatwareEntry(name: 'Facebook System', category: 'Social', risk: RiskLevel.safe),
    'com.netflix.mediaclient': BloatwareEntry(name: 'Netflix (Pre-installed)', category: 'Entertainment', risk: RiskLevel.safe),
    'com.amazon.mShop.android.shopping': BloatwareEntry(name: 'Amazon Shopping', category: 'Shopping', risk: RiskLevel.safe),
    'com.spotify.music': BloatwareEntry(name: 'Spotify (Pre-installed)', category: 'Entertainment', risk: RiskLevel.safe),
    'com.linkedin.android': BloatwareEntry(name: 'LinkedIn (Pre-installed)', category: 'Social', risk: RiskLevel.safe),
  };

  static BloatwareEntry? lookup(String packageName) => packages[packageName];

  static bool isKnownBloatware(String packageName) => packages.containsKey(packageName);
}

class BloatwareEntry {
  final String name;
  final String category;
  final RiskLevel risk;

  const BloatwareEntry({
    required this.name,
    required this.category,
    required this.risk,
  });
}

enum RiskLevel { safe, caution, dangerous }
