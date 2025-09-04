import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool elevated;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.spaceM),
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.shadows,
    this.borderRadius = AppTheme.radiusMedium,
    this.onTap,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveShadows =
        shadows ?? (elevated ? AppTheme.elevatedShadow : AppTheme.cardShadow);

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null
            ? (backgroundColor ?? AppTheme.surfaceColor)
            : null,
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: effectiveShadows,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(padding: padding, child: child),
      ),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, borderRadius: borderRadius, child: card);
    }

    return card;
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.spaceM),
    this.margin,
    this.borderRadius = AppTheme.radiusMedium,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: borderRadius,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Container(padding: padding, child: child),
      ),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, borderRadius: borderRadius, child: card);
    }

    return card;
  }
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient gradient;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding = const EdgeInsets.all(AppTheme.spaceM),
    this.margin,
    this.borderRadius = AppTheme.radiusMedium,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(padding: padding, child: child),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, borderRadius: borderRadius, child: card);
    }

    return card;
  }
}
