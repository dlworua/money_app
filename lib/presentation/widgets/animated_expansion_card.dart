import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AnimatedExpansionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final bool initiallyExpanded;
  final EdgeInsetsGeometry? padding;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedExpansionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.initiallyExpanded = false,
    this.padding,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOutCubic,
  });

  @override
  State<AnimatedExpansionCard> createState() => _AnimatedExpansionCardState();
}

class _AnimatedExpansionCardState extends State<AnimatedExpansionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _elevationAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnimation = ColorTween(
      begin: widget.iconColor.withValues(alpha: 0.7),
      end: widget.iconColor,
    ).animate(_controller);

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spaceS),
          child: Material(
            elevation: _elevationAnimation.value,
            borderRadius: BorderRadius.circular(16),
            color: Colors.transparent,
            shadowColor: widget.iconColor.withValues(alpha: 0.1),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isExpanded
                      ? widget.iconColor.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.1),
                  width: _isExpanded ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.iconColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    // 헤더 (클릭 가능한 부분)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleTap,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                          bottom: Radius.circular(16),
                        ),
                        child: AnimatedContainer(
                          duration: widget.animationDuration,
                          curve: widget.animationCurve,
                          padding: const EdgeInsets.all(AppTheme.spaceM),
                          decoration: BoxDecoration(
                            gradient: _isExpanded
                                ? LinearGradient(
                                    colors: [
                                      widget.iconColor.withValues(alpha: 0.05),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              // 아이콘 컨테이너
                              AnimatedContainer(
                                duration: widget.animationDuration,
                                curve: widget.animationCurve,
                                padding: const EdgeInsets.all(AppTheme.spaceS),
                                decoration: BoxDecoration(
                                  color:
                                      (_colorAnimation.value ??
                                              widget.iconColor)
                                          .withValues(
                                            alpha: _isExpanded ? 0.15 : 0.1,
                                          ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: AnimatedScale(
                                  duration: widget.animationDuration,
                                  scale: _isExpanded ? 1.1 : 1.0,
                                  child: Icon(
                                    widget.icon,
                                    color: _colorAnimation.value,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppTheme.spaceM),
                              // 제목
                              Expanded(
                                child: AnimatedDefaultTextStyle(
                                  duration: widget.animationDuration,
                                  style: AppTheme.headingSmall.copyWith(
                                    color: _isExpanded
                                        ? widget.iconColor
                                        : AppTheme.onSurfaceColor,
                                    fontWeight: _isExpanded
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                  ),
                                  child: Text(widget.title),
                                ),
                              ),
                              // 상태 표시 점
                              AnimatedContainer(
                                duration: widget.animationDuration,
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _isExpanded
                                      ? widget.iconColor
                                      : Colors.grey.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 확장되는 콘텐츠
                    SizeTransition(
                      sizeFactor: _expandAnimation,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: widget.iconColor.withValues(alpha: 0.02),
                          border: Border(
                            top: BorderSide(
                              color: widget.iconColor.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding:
                              widget.padding ??
                              const EdgeInsets.all(AppTheme.spaceM),
                          child: widget.child,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// 글로우 효과가 있는 버전
class GlowExpansionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final bool initiallyExpanded;
  final EdgeInsetsGeometry? padding;

  const GlowExpansionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.initiallyExpanded = false,
    this.padding,
  });

  @override
  State<GlowExpansionCard> createState() => _GlowExpansionCardState();
}

class _GlowExpansionCardState extends State<GlowExpansionCard>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _glowController;
  late Animation<double> _expandAnimation;
  late Animation<double> _glowAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (_isExpanded) {
      _expandController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
        _glowController.repeat(reverse: true);
      } else {
        _expandController.reverse();
        _glowController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_expandController, _glowController]),
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spaceS),
          child: Material(
            elevation: _isExpanded ? 8 : 2,
            borderRadius: BorderRadius.circular(20),
            color: Colors.transparent,
            shadowColor: widget.iconColor.withValues(alpha: 0.3),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    _isExpanded
                        ? widget.iconColor.withValues(alpha: 0.05)
                        : Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: _isExpanded
                      ? widget.iconColor.withValues(alpha: 0.5)
                      : Colors.grey.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: _isExpanded
                    ? [
                        BoxShadow(
                          color: widget.iconColor.withValues(
                            alpha: 0.2 * _glowAnimation.value,
                          ),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 0),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleTap,
                        child: Container(
                          padding: const EdgeInsets.all(AppTheme.spaceL),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppTheme.spaceM),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      widget.iconColor.withValues(
                                        alpha: _isExpanded ? 0.8 : 0.6,
                                      ),
                                      widget.iconColor.withValues(
                                        alpha: _isExpanded ? 0.6 : 0.4,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.iconColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: _isExpanded ? 10 : 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  widget.icon,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spaceL),
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: AppTheme.headingMedium.copyWith(
                                    color: _isExpanded
                                        ? widget.iconColor
                                        : AppTheme.onSurfaceColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizeTransition(
                      sizeFactor: _expandAnimation,
                      child: Container(
                        width: double.infinity,
                        padding:
                            widget.padding ??
                            const EdgeInsets.all(AppTheme.spaceL),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.iconColor.withValues(alpha: 0.03),
                              widget.iconColor.withValues(alpha: 0.01),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
