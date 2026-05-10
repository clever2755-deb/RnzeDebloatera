import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/app_info.dart';
import '../theme/app_theme.dart';

class AppTile extends StatelessWidget {
  final AppInfo app;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDisable;
  final VoidCallback onUninstall;
  final int index;

  const AppTile({
    super.key,
    required this.app,
    required this.isSelected,
    required this.onTap,
    required this.onDisable,
    required this.onUninstall,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(duration: 250.ms, delay: (index * 30).ms),
        SlideEffect(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
          duration: 300.ms,
          delay: (index * 30).ms,
          curve: Curves.easeOut,
        ),
      ],
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accent.withOpacity(0.08)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.accent.withOpacity(0.4) : AppTheme.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _buildAppIcon(),
                const SizedBox(width: 14),
                Expanded(child: _buildAppInfo()),
                const SizedBox(width: 8),
                _buildStatusBadge(),
                const SizedBox(width: 8),
                _buildCheckbox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Center(
        child: Text(
          app.appName.isNotEmpty ? app.appName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppTheme.accent,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                app.appName,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (app.isRecommendedBloatware) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'SAFE',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Text(
          app.packageName,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          app.category,
          style: const TextStyle(
            color: AppTheme.accentDim,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    if (app.status == AppStatus.enabled) return const SizedBox.shrink();
    final color = app.status == AppStatus.disabled ? AppTheme.warning : AppTheme.danger;
    final label = app.status == AppStatus.disabled ? 'DISABLED' : 'REMOVED';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return AnimatedContainer(
      duration: 200.ms,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? AppTheme.accent : AppTheme.textSecondary.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, color: Colors.black, size: 14)
          : null,
    );
  }
}
