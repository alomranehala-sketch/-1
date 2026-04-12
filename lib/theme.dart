import 'dart:ui';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
//  TERYAQ SMART HEALTH — Design System
//  3D Glassmorphism · Depth · Modern Medical
// ═══════════════════════════════════════════════════════════════

class AppColors {
  // ── Brand — Deep Indigo/Purple Medical ───────────────────
  static const primary = Color(0xFF6366F1); // Indigo-500
  static const primaryLight = Color(0xFF818CF8); // Indigo-400
  static const primaryDark = Color(0xFF4F46E5); // Indigo-600
  static const primaryDeep = Color(0xFF3730A3); // Indigo-800
  static const accent = Color(0xFF06B6D4); // Cyan-500
  static const accentLight = Color(0xFF67E8F9); // Cyan-300

  // ── Surfaces (Dark Theme) ──────────────────────────────────
  static const background = Color(0xFF0F172A); // Slate-900
  static const backgroundAlt = Color(0xFF1E293B); // Slate-800
  static const surface = Color(0xFF1E293B); // Slate-800
  static const card = Color(0xFF1E293B); // Slate-800
  static const surfaceGlass = Color(0x33FFFFFF); // 20% white
  static const surfaceGlassDark = Color(0x1AFFFFFF); // 10% white

  // ── Text (Dark Theme) ────────────────────────────────────
  static const textDark = Color(0xFFFFFFFF); // White
  static const textMedium = Color(0xFFCBD5E1); // Slate-300
  static const textLight = Color(0xFF94A3B8); // Slate-400
  static const textOnPrimary = Color(0xFFFFFFFF);

  // ── Borders (Dark Theme) ─────────────────────────────────
  static const border = Color(0xFF334155); // Slate-700
  static const borderLight = Color(0xFF1E293B); // Slate-800
  static const glassBorder = Color(0x33FFFFFF); // 20% white

  // ── Semantic ─────────────────────────────────────────────
  static const success = Color(0xFF10B981); // Emerald-500
  static const successBg = Color(0xFF064E3B); // Emerald-900
  static const warning = Color(0xFFF59E0B); // Amber-500
  static const warningBg = Color(0xFF78350F); // Amber-900
  static const error = Color(0xFFEF4444); // Red-500
  static const errorBg = Color(0xFF7F1D1D); // Red-900
  static const info = Color(0xFF3B82F6); // Blue-500
  static const infoBg = Color(0xFF1E3A5F); // Blue-900

  // ── Gradients ────────────────────────────────────────────
  static const gradientPrimary = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF818CF8), Color(0xFF6366F1), Color(0xFF4F46E5)],
  );
  static const gradientAccent = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF06B6D4), Color(0xFF6366F1)],
  );
  static const gradientGlass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FFFFFF), Color(0x0DFFFFFF)],
  );
  static const gradientDark = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
  );
  static const gradientEmergency = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );
}

class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withAlpha(30),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withAlpha(40),
      blurRadius: 32,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
  static List<BoxShadow> get glow => [
    BoxShadow(
      color: const Color(0xFF6366F1).withAlpha(30),
      blurRadius: 40,
      offset: const Offset(0, 12),
      spreadRadius: -8,
    ),
  ];
  static List<BoxShadow> get glass => [
    BoxShadow(
      color: Colors.black.withAlpha(20),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  static List<BoxShadow> get bottomNav => [
    BoxShadow(
      color: Colors.black.withAlpha(30),
      blurRadius: 30,
      offset: const Offset(0, -8),
    ),
  ];
}

class AppRadius {
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 22.0;
  static const xxl = 28.0;
  static const pill = 100.0;
}

// ── Glass Effect Helper ────────────────────────────────────
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? color;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 20,
    this.color,
    this.opacity = 0.7,
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.xl);
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (color ?? Colors.white).withAlpha((opacity * 255).round()),
              borderRadius: radius,
              border:
                  border ??
                  Border.all(color: AppColors.glassBorder, width: 1.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ── Gradient Icon Container ────────────────────────────────
class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color bgColor;
  final Color iconColor;
  final double containerSize;

  const GradientIcon({
    super.key,
    required this.icon,
    this.size = 22,
    this.bgColor = const Color(0x1A0D9488),
    this.iconColor = AppColors.primary,
    this.containerSize = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: iconColor, size: size),
    );
  }
}

// ── Section Header ─────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── 3D-Style Card with perspective and depth ───────────────
class Card3D extends StatefulWidget {
  final Widget child;
  final double depth;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const Card3D({
    super.key,
    required this.child,
    this.depth = 8,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.color,
    this.padding,
    this.margin,
  });

  @override
  State<Card3D> createState() => _Card3DState();
}

class _Card3DState extends State<Card3D> {
  double _rotateX = 0;
  double _rotateY = 0;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(AppRadius.xl);
    return GestureDetector(
      onPanUpdate: (d) {
        setState(() {
          _rotateY = (d.localPosition.dx - 100) / 800;
          _rotateX = -(d.localPosition.dy - 80) / 800;
        });
      },
      onPanEnd: (_) => setState(() {
        _rotateX = 0;
        _rotateY = 0;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: widget.margin,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_rotateX)
          ..rotateY(_rotateY),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.color ?? AppColors.surface,
          gradient: widget.gradient,
          borderRadius: radius,
          boxShadow:
              widget.boxShadow ??
              [
                BoxShadow(
                  color: AppColors.primary.withAlpha(12),
                  blurRadius: 24 + widget.depth,
                  offset: Offset(0, widget.depth),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Colors.white.withAlpha(80),
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                ),
              ],
          border: Border.all(color: Colors.white.withAlpha(40), width: 1),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Padding(
            padding: widget.padding ?? EdgeInsets.zero,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
