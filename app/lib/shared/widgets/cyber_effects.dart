import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

/// 霓虹辉光装饰器
class NeonGlow extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double intensity;
  final double spreadRadius;
  final double blurRadius;

  const NeonGlow({
    super.key,
    required this.child,
    this.glowColor = AppColors.primary,
    this.intensity = 0.6,
    this.spreadRadius = 0,
    this.blurRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: intensity * 0.5),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: intensity * 0.3),
            blurRadius: blurRadius * 2,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 磨砂玻璃面板
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const GlassPanel({
    super.key,
    required this.child,
    this.blur = 10,
    this.borderColor,
    this.borderRadius = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.background.withValues(alpha: 0.5),
              blurRadius: blur,
            ),
          ],
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// 赛博朋克风格卡片
class CyberCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color glowColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool enableGlow;

  const CyberCard({
    super.key,
    required this.child,
    this.onTap,
    this.glowColor = AppColors.primary,
    this.borderRadius = 8,
    this.padding,
    this.enableGlow = true,
  });

  @override
  State<CyberCard> createState() => _CyberCardState();
}

class _CyberCardState extends State<CyberCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoverChange(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverChange(true),
      onExit: (_) => _onHoverChange(false),
      child: GestureDetector(
        onTapDown: (_) => _onHoverChange(true),
        onTapUp: (_) => _onHoverChange(false),
        onTapCancel: () => _onHoverChange(false),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: widget.glowColor.withValues(
                    alpha: widget.enableGlow ? 0.3 + _glowAnimation.value * 0.4 : 0.2,
                  ),
                  width: 1.5,
                ),
                boxShadow: widget.enableGlow
                    ? [
                        BoxShadow(
                          color: widget.glowColor.withValues(alpha: _glowAnimation.value * 0.3),
                          blurRadius: 15 + _glowAnimation.value * 10,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              padding: widget.padding,
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// 赛博朋克风格按钮
class CyberButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final bool isOutlined;
  final double width;
  final double height;

  const CyberButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color = AppColors.primary,
    this.isOutlined = false,
    this.width = double.infinity,
    this.height = 50,
  });

  @override
  State<CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends State<CyberButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, _) {
            return Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.isOutlined 
                    ? Colors.transparent 
                    : widget.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.color,
                  width: widget.isOutlined ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.3 + _glowAnimation.value * 0.4),
                    blurRadius: 10 + _glowAnimation.value * 15,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.isOutlined ? widget.color : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.isOutlined ? widget.color : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 渐变文字
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final List<Color> colors;

  const GradientText({
    super.key,
    required this.text,
    this.style,
    this.colors = const [AppColors.primary, AppColors.secondary],
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}

/// 霓虹边框装饰
class NeonBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderRadius;
  final double borderWidth;

  const NeonBorder({
    super.key,
    required this.child,
    this.color = AppColors.secondary,
    this.borderRadius = 8,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: color, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        child: child,
      ),
    );
  }
}

/// 赛博广告灯箱
class CyberAdBanner extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? label;

  const CyberAdBanner({
    super.key,
    required this.child,
    this.onTap,
    this.label,
  });

  @override
  State<CyberAdBanner> createState() => _CyberAdBannerState();
}

class _CyberAdBannerState extends State<CyberAdBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: _pulseAnimation.value),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: _pulseAnimation.value * 0.5),
                  blurRadius: 15,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: _pulseAnimation.value * 0.3),
                  blurRadius: 25,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: child,
                ),
                if (widget.label != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.label!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
