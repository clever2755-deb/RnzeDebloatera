import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/app_info.dart';
import '../services/shizuku_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_tile.dart';

class AppListScreen extends StatefulWidget {
  const AppListScreen({super.key});

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
  List<AppInfo> _apps = [];
  List<AppInfo> _filtered = [];
  Set<String> _selectedPackages = {};
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showOnlyEnabled = false;
  final TextEditingController _searchController = TextEditingController();

  List<String> get _categories {
    final cats = {'All', ..._apps.map((a) => a.category)};
    return cats.toList()..sort();
  }

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    setState(() => _isLoading = true);
    final apps = await ShizukuService.getSystemApps();
    setState(() {
      _apps = apps;
      _isLoading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filtered = _apps.where((app) {
        final matchesSearch = _searchQuery.isEmpty ||
            app.appName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            app.packageName.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCategory = _selectedCategory == 'All' || app.category == _selectedCategory;
        final matchesEnabled = !_showOnlyEnabled || app.status == AppStatus.enabled;
        return matchesSearch && matchesCategory && matchesEnabled;
      }).toList();
    });
  }

  Future<void> _executeAction(DebloatAction action) async {
    if (_selectedPackages.isEmpty) return;
    final toProcess = List<String>.from(_selectedPackages);

    setState(() => _selectedPackages = {});

    for (final pkg in toProcess) {
      DebloatResult result;
      if (action == DebloatAction.disable) {
        result = await ShizukuService.disableApp(pkg);
      } else if (action == DebloatAction.uninstall) {
        result = await ShizukuService.uninstallApp(pkg);
      } else {
        result = await ShizukuService.enableApp(pkg);
      }

      if (result.success) {
        final idx = _apps.indexWhere((a) => a.packageName == pkg);
        if (idx != -1) {
          setState(() {
            _apps[idx].status = action == DebloatAction.disable
                ? AppStatus.disabled
                : action == DebloatAction.uninstall
                    ? AppStatus.uninstalled
                    : AppStatus.enabled;
          });
        }
      }
    }
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildCategoryFilter(),
        _buildToggle(),
        if (_selectedPackages.isNotEmpty) _buildSelectionBar(),
        Expanded(
          child: _isLoading
              ? _buildLoadingState()
              : _filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final app = _filtered[index];
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
                    ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) {
          _searchQuery = v;
          _applyFilters();
        },
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search apps or packages...',
          hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _searchQuery = '';
                    _applyFilters();
                  },
                  child: const Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 18),
                )
              : null,
          filled: true,
          fillColor: AppTheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () {
              _selectedCategory = cat;
              _applyFilters();
            },
            child: AnimatedContainer(
              duration: 200.ms,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accent.withOpacity(0.15) : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.accent : AppTheme.cardBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '${_filtered.length} apps found',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const Spacer(),
          const Text(
            'Enabled only',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Switch(
            value: _showOnlyEnabled,
            onChanged: (v) {
              _showOnlyEnabled = v;
              _applyFilters();
            },
            activeColor: AppTheme.accent,
            activeTrackColor: AppTheme.accent.withOpacity(0.3),
            inactiveThumbColor: AppTheme.textSecondary,
            inactiveTrackColor: AppTheme.surfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar() {
    return Animate(
      effects: [SlideEffect(begin: const Offset(0, -0.5), end: Offset.zero, duration: 200.ms)],
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Text(
              '${_selectedPackages.length} selected',
              style: const TextStyle(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            _ActionIconBtn(
              icon: Icons.play_circle_outline_rounded,
              color: AppTheme.success,
              tooltip: 'Enable',
              onTap: () => _executeAction(DebloatAction.enable),
            ),
            _ActionIconBtn(
              icon: Icons.block_rounded,
              color: AppTheme.warning,
              tooltip: 'Disable',
              onTap: () => _executeAction(DebloatAction.disable),
            ),
            _ActionIconBtn(
              icon: Icons.delete_outline_rounded,
              color: AppTheme.danger,
              tooltip: 'Remove',
              onTap: () => _executeAction(DebloatAction.uninstall),
            ),
            _ActionIconBtn(
              icon: Icons.close_rounded,
              color: AppTheme.textSecondary,
              tooltip: 'Clear',
              onTap: () => setState(() => _selectedPackages = {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) => Animate(
        effects: [ShimmerEffect(duration: 1200.ms, delay: (index * 80).ms)],
        onPlay: (c) => c.repeat(),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cardBorder),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_rounded, color: AppTheme.textSecondary, size: 48),
          const SizedBox(height: 16),
          const Text('No apps match your filters', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _searchController.clear();
              _searchQuery = '';
              _selectedCategory = 'All';
              _showOnlyEnabled = false;
              _applyFilters();
            },
            child: const Text('Clear filters', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }
}

class _ActionIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIconBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
