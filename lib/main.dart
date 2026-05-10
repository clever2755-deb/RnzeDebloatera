import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'screens/dashboard_screen.dart';
import 'screens/app_list_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    navigationBarColor: AppTheme.background,
    navigationBarIconBrightness: Brightness.light,
  ));
  runApp(const DebloaterApp());
}

class DebloaterApp extends StatelessWidget {
  const DebloaterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debloater',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
              ),
              child: const Icon(Icons.cleaning_services_rounded, color: AppTheme.accent, size: 17),
            ),
            const SizedBox(width: 10),
            const Text('Debloater'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppTheme.textSecondary),
            onPressed: () => _showAboutDialog(),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.dashboard_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Dashboard'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.apps_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('All Apps'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DashboardScreen(),
          AppListScreen(),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cleaning_services_rounded, color: AppTheme.accent, size: 22),
            SizedBox(width: 10),
            Text('Debloater', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0', style: TextStyle(color: AppTheme.accent, fontSize: 13)),
            SizedBox(height: 12),
            Text(
              'A professional Android debloater powered by Shizuku. '
              'Safely disable or remove pre-installed system apps without root access.\n\n'
              'All operations run via pm shell commands under user 0. '
              'No data leaves your device.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
            ),
            SizedBox(height: 12),
            Text(
              '⚠ Requires Shizuku to be installed and running.',
              style: TextStyle(color: AppTheme.warning, fontSize: 12),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
