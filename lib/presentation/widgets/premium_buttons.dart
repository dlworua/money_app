import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final ButtonType type;
  final ButtonSize size;
  final double? width;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    
    return SizedBox(
      width: width,
      child: _buildButton(context, isDisabled),
    );
  }

  Widget _buildButton(BuildContext context, bool isDisabled) {
    switch (type) {
      case ButtonType.primary:
        return _buildPrimaryButton(context, isDisabled);
      case ButtonType.secondary:
        return _buildSecondaryButton(context, isDisabled);
      case ButtonType.outline:
        return _buildOutlineButton(context, isDisabled);
      case ButtonType.ghost:
        return _buildGhostButton(context, isDisabled);
      case ButtonType.gradient:
        return _buildGradientButton(context, isDisabled);
    }
  }

  Widget _buildPrimaryButton(BuildContext context, bool isDisabled) {
    return FilledButton(
      onPressed: isDisabled ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isDisabled ? Colors.grey.shade300 : AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.radiusMedium,
        ),
        elevation: 0,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, bool isDisabled) {
    return FilledButton(
      onPressed: isDisabled ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isDisabled ? Colors.grey.shade200 : AppTheme.onSurfaceColor.withValues(alpha: 0.08),
        foregroundColor: isDisabled ? Colors.grey.shade500 : AppTheme.onSurfaceColor,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.radiusMedium,
        ),
        elevation: 0,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlineButton(BuildContext context, bool isDisabled) {
    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDisabled ? Colors.grey.shade500 : AppTheme.primaryColor,
        padding: _getPadding(),
        side: BorderSide(
          color: isDisabled ? Colors.grey.shade300 : AppTheme.primaryColor,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.radiusMedium,
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildGhostButton(BuildContext context, bool isDisabled) {
    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isDisabled ? Colors.grey.shade500 : AppTheme.primaryColor,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.radiusMedium,
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildGradientButton(BuildContext context, bool isDisabled) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDisabled ? null : AppTheme.primaryGradient,
        color: isDisabled ? Colors.grey.shade300 : null,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: isDisabled ? null : [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: AppTheme.radiusMedium,
          child: Container(
            padding: _getPadding(),
            child: _buildButtonContent(textColor: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent({Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spaceS),
        ] else if (icon != null) ...[
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: AppTheme.spaceS),
        ],
        Text(
          text,
          style: _getTextStyle().copyWith(color: textColor),
        ),
      ],
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600);
      case ButtonSize.medium:
        return AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600);
      case ButtonSize.large:
        return AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600);
    }
  }
}

enum ButtonType { primary, secondary, outline, ghost, gradient }
enum ButtonSize { small, medium, large }

class FloatingActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const FloatingActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryColor;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [effectiveColor, effectiveColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTheme.radiusLarge,
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTheme.radiusLarge,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceL,
              vertical: AppTheme.spaceM,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: AppTheme.spaceM),
                Text(
                  label,
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}