import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/app_info.dart';
import '../services/shizuku_service.dart';
import '../theme/app_theme.dart';
import '../utils/bloatware_list.dart';
import '../widgets/app_tile.dart';
import '../widgets/status_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  ShizukuStatus _shizukuStatus = ShizukuStatus.notInstalled;
  List<AppInfo> _allApps = [];
  List<AppInfo> _recommendedApps = [];
  Set<String> _selectedPackages = {};
  bool _isScanning = false;
  bool _isProcessing = false;
  String _scanStatus = '';
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _checkShizuku();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _checkShizuku() async {
    final status = await ShizukuService.getStatus();
    if (mounted) setState(() => _shizukuStatus = status);
  }

  Future<void> _requestPermission() async {
    final granted = await ShizukuService.requestPermission();
    if (granted) await _checkShizuku();
  }

  Future<void> _scanBloatware() async {
    if (_shizukuStatus != ShizukuStatus.ready) {
      _showSnack('Shizuku must be active to scan apps', isError: true);
      return;
    }
    setState(() {
      _isScanning = true;
      _scanStatus = 'Loading installed system apps...';
      _allApps = [];
      _recommendedApps = [];
      _selectedPackages = {};
    });
    _scanController.repeat();

    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _scanStatus = 'Analyzing packages...');

    final apps = await ShizukuService.getSystemApps();
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _scanStatus = 'Filtering safe-to-remove apps...');

    await Future.delayed(const Duration(milliseconds: 500));
    _scanController.stop();
    _scanController.reset();

    final recommended = apps.where((a) => a.isRecommendedBloatware).toList();

    setState(() {
      _allApps = apps;
      _recommendedApps = recommended;
      _isScanning = false;
      _scanStatus = '';
    });
  }

  Future<void> _disableSelected() async {
    if (_selectedPackages.isEmpty) return;
    setState(() => _isProcessing = true);

    int success = 0;
    int failed = 0;

    for (final pkg in _selectedPackages) {
      final result = await ShizukuService.disableApp(pkg);
      if (result.success) {
        success++;
        final idx = _recommendedApps.indexWhere((a) => a.packageName == pkg);
        if (idx != -1) {
          setState(() => _recommendedApps[idx].status = AppStatus.disabled);
        }
      } else {
        failed++;
      }
    }

    setState(() {
      _isProcessing = false;
      _selectedPackages = {};
    });

    _showSnack(
      '$success app(s) disabled${failed > 0 ? ', $failed failed' : ''}',
      isError: failed > 0,
    );
  }

  Future<void> _uninstallSelected() async {
    if (_selectedPackages.isEmpty) return;
    final confirmed = await _showConfirmDialog();
    if (!confirmed) return;

    setState(() => _isProcessing = true);
    int success = 0;
    int failed = 0;

    for (final pkg in _selectedPackages) {
      final result = await ShizukuService.uninstallApp(pkg);
      if (result.success) {
        success++;
        final idx = _recommendedApps.indexWhere((a) => a.packageName == pkg);
        if (idx != -1) {
          setState(() => _recommendedApps[idx].status = AppStatus.uninstalled);
        }
      } else {
        failed++;
      }
    }

    setState(() {
      _isProcessing = false;
      _selectedPackages = {};
    });

    _showSnack(
      '$success app(s) removed${failed > 0 ? ', $failed failed' : ''}',
      isError: failed > 0,
    );
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.surfaceVariant,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Confirm Debloat',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
            ),
            content: Text(
              'This will safely uninstall ${_selectedPackages.length} app(s) for the current user only. '
              'Apps can be restored via ADB. Continue?',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                child: const Text('Debloat'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.danger.withOpacity(0.9) : AppTheme.success.withOpacity(0.9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(),
        SliverToBoxAdapter(
          child: ShizukuStatusCard(
            status: _shizukuStatus,
            onRequestPermission: _requestPermission,
          ),
        ),
        SliverToBoxAdapter(child: _buildStatsRow()),
        SliverToBoxAdapter(child: _buildScanButton()),
        if (_isScanning) SliverToBoxAdapter(child: _buildScanningState()),
        if (!_isScanning && _recommendedApps.isNotEmpty) ...[
          SliverToBoxAdapter(child: _buildSectionHeader()),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final app = _recommendedApps[index];
                return AppTile(
                  app: app,
                  isSelected: _selectedPackages.contains(app.packageName),
                  index: index,
                  onTap: () => setState(() {
                    if (_selectedPackages.contains(app.packageName)) {
                      _selectedPackages.remove(app.packageName);
                    } else {
                      _selectedPackages.add(app.packageName);
                    }
                  }),
                  onDisable: () {},
                  onUninstall: () {},
                );
              },
              childCount: _recommendedApps.length,
            ),
          ),
          SliverToBoxAdapter(child: _buildActionBar()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
        if (!_isScanning && _allApps.isEmpty)
          SliverToBoxAdapter(child: _buildEmptyState()),
      ],
    );
  }

  Widget _buildSliverHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Animate(
              effects: [FadeEffect(duration: 600.ms)],
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.1),
                  children: [
                    TextSpan(text: 'System\n', style: TextStyle(color: AppTheme.textPrimary)),
                    TextSpan(text: 'Debloater', style: TextStyle(color: AppTheme.accent)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Animate(
              effects: [FadeEffect(duration: 600.ms, delay: 100.ms)],
              child: const Text(
                'Remove bloatware safely — no root required',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final disabled = _allApps.where((a) => a.status == AppStatus.disabled).length;
    final removed = _allApps.where((a) => a.status == AppStatus.uninstalled).length;
    final total = _allApps.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _StatChip(label: 'System Apps', value: total.toString(), color: AppTheme.accent),
          const SizedBox(width: 10),
          _StatChip(label: 'Disabled', value: disabled.toString(), color: AppTheme.warning),
          const SizedBox(width: 10),
          _StatChip(label: 'Removed', value: removed.toString(), color: AppTheme.danger),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isScanning ? null : _scanBloatware,
          icon: const Icon(Icons.radar_rounded, size: 20),
          label: const Text('Scan for Bloatware'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }

  Widget _buildScanningState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Animate(
            onPlay: (c) => c.repeat(),
            effects: [RotateEffect(duration: 1200.ms, curve: Curves.linear)],
            child: const Icon(Icons.radar_rounded, color: AppTheme.accent, size: 48),
          ),
          const SizedBox(height: 20),
          Animate(
            effects: [FadeEffect(duration: 300.ms)],
            key: ValueKey(_scanStatus),
            child: Text(
              _scanStatus,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Container(width: 3, height: 18, decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Text(
            'Recommended Removals (${_recommendedApps.length})',
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() {
              if (_selectedPackages.length == _recommendedApps.length) {
                _selectedPackages.clear();
              } else {
                _selectedPackages = _recommendedApps.map((a) => a.packageName).toSet();
              }
            }),
            child: Text(
              _selectedPackages.length == _recommendedApps.length ? 'Deselect All' : 'Select All',
              style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    if (_selectedPackages.isEmpty) return const SizedBox.shrink();
    return Animate(
      effects: [SlideEffect(begin: const Offset(0, 1), end: Offset.zero, duration: 250.ms)],
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          children: [
            Text(
              '${_selectedPackages.length} app(s) selected',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _disableSelected,
                    icon: const Icon(Icons.block_rounded, size: 16),
                    label: const Text('Disable'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _uninstallSelected,
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Remove'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: [
          const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 52),
          const SizedBox(height: 16),
          const Text(
            'Tap "Scan for Bloatware" to begin',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Shizuku must be running and permission granted',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Animate(
        effects: [FadeEffect(duration: 400.ms)],
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
