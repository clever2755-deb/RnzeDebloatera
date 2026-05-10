import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/shizuku_service.dart';
import '../theme/app_theme.dart';

class ShizukuStatusCard extends StatelessWidget {
  final ShizukuStatus status;
  final VoidCallback onRequestPermission;

  const ShizukuStatusCard({
    super.key,
    required this.status,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    return Animate(
      effects: [
        FadeEffect(duration: 400.ms),
        SlideEffect(begin: const Offset(0, -0.1), end: Offset.zero, duration: 400.ms),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: config.color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: config.color.withOpacity(0.25), width: 1.5),
        ),
        child: Row(
          children: [
            _buildPulsingIcon(config),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.title,
                    style: TextStyle(
                      color: config.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (status != ShizukuStatus.ready)
              _buildActionButton(config),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingIcon(_StatusConfig config) {
    if (status == ShizukuStatus.ready) {
      return Animate(
        onPlay: (controller) => controller.repeat(),
        effects: [
          ShimmerEffect(
            color: config.color.withOpacity(0.3),
            duration: 2000.ms,
          ),
        ],
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: config.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(config.icon, color: config.color, size: 22),
        ),
      );
    }
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(config.icon, color: config.color, size: 22),
    );
  }

  Widget _buildActionButton(_StatusConfig config) {
    return GestureDetector(
      onTap: onRequestPermission,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: config.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: config.color.withOpacity(0.4)),
        ),
        child: Text(
          config.actionLabel,
          style: TextStyle(
            color: config.color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  _StatusConfig _getConfig(ShizukuStatus status) {
    switch (status) {
      case ShizukuStatus.ready:
        return _StatusConfig(
          color: AppTheme.success,
          icon: Icons.shield_rounded,
          title: 'Shizuku Active',
          subtitle: 'Shell access granted — ready to debloat',
          actionLabel: '',
        );
      case ShizukuStatus.noPermission:
        return _StatusConfig(
          color: AppTheme.warning,
          icon: Icons.lock_outline_rounded,
          title: 'Permission Required',
          subtitle: 'Tap to grant Shizuku shell access',
          actionLabel: 'Grant',
        );
      case ShizukuStatus.notRunning:
        return _StatusConfig(
          color: AppTheme.warning,
          icon: Icons.power_settings_new_rounded,
          title: 'Shizuku Not Running',
          subtitle: 'Open Shizuku app and start the service',
          actionLabel: 'Open',
        );
      case ShizukuStatus.notInstalled:
        return _StatusConfig(
          color: AppTheme.danger,
          icon: Icons.error_outline_rounded,
          title: 'Shizuku Not Installed',
          subtitle: 'Install Shizuku from Play Store to continue',
          actionLabel: 'Install',
        );
    }
  }
}

class _StatusConfig {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;

  const _StatusConfig({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  });
}
