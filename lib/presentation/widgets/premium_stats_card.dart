import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'premium_card.dart';

class PremiumStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color? valueColor;
  final String? trend;
  final bool showTrend;
  final VoidCallback? onTap;

  const PremiumStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.iconColor = AppTheme.primaryColor,
    this.valueColor,
    this.trend,
    this.showTrend = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.onSurfaceColor.withValues(alpha: 0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceS),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: AppTheme.radiusSmall,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceS),
          Text(
            value,
            style: AppTheme.headingLarge.copyWith(
              color: valueColor ?? AppTheme.onSurfaceColor,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXS),
          Row(
            children: [
              Text(
                subtitle,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.onSurfaceColor.withValues(alpha: 0.6),
                ),
              ),
              if (showTrend && trend != null) ...[
                const SizedBox(width: AppTheme.spaceS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceS,
                    vertical: AppTheme.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: trend!.startsWith('+') 
                        ? AppTheme.successColor.withValues(alpha: 0.1)
                        : AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trend!,
                    style: AppTheme.bodySmall.copyWith(
                      color: trend!.startsWith('+') 
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class PremiumProgressCard extends StatelessWidget {
  final String title;
  final String currentValue;
  final String targetValue;
  final double progress;
  final Color progressColor;
  final IconData icon;
  final VoidCallback? onTap;

  const PremiumProgressCard({
    super.key,
    required this.title,
    required this.currentValue,
    required this.targetValue,
    required this.progress,
    this.progressColor = AppTheme.primaryColor,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.onSurfaceColor.withValues(alpha: 0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceS),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.1),
                  borderRadius: AppTheme.radiusSmall,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currentValue,
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.onSurfaceColor,
                  fontSize: 24,
                ),
              ),
              Text(
                '/ $targetValue',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.onSurfaceColor.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceM),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '진행률',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.onSurfaceColor.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTheme.labelLarge.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceS),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: progressColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                borderRadius: BorderRadius.circular(4),
                minHeight: 6,
              ),
            ],
          ),
        ],
      ),
    );
  }
}