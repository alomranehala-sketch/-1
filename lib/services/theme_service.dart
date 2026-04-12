import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Color palettes available in the app
enum AppThemeColor {
  indigo, // Default — Indigo/Purple
  emerald, // Green/Teal
  rose, // Pink/Rose
  amber, // Orange/Amber
  cyan, // Cyan/Blue
  slate, // Neutral Gray
}

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._();
  factory ThemeService() => _instance;
  ThemeService._();

  AppThemeColor _currentTheme = AppThemeColor.indigo;
  AppThemeColor get currentTheme => _currentTheme;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt('app_theme_color') ?? 0;
    _currentTheme =
        AppThemeColor.values[idx.clamp(0, AppThemeColor.values.length - 1)];
    notifyListeners();
  }

  Future<void> setTheme(AppThemeColor theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_theme_color', theme.index);
    notifyListeners();
  }

  Future<void> nextTheme() async {
    final next = AppThemeColor
        .values[(_currentTheme.index + 1) % AppThemeColor.values.length];
    await setTheme(next);
  }

  // ── Palette Data ──────────────────────────────────────────
  Color get primary => palettes[_currentTheme]!.primary;
  Color get primaryLight => palettes[_currentTheme]!.primaryLight;
  Color get primaryDark => palettes[_currentTheme]!.primaryDark;
  Color get accent => palettes[_currentTheme]!.accent;
  LinearGradient get gradient => palettes[_currentTheme]!.gradient;
  String get label => palettes[_currentTheme]!.label;
  String get labelAr => palettes[_currentTheme]!.labelAr;

  static const Map<AppThemeColor, ThemePalette> palettes = {
    AppThemeColor.indigo: ThemePalette(
      primary: Color(0xFF6366F1),
      primaryLight: Color(0xFF818CF8),
      primaryDark: Color(0xFF4F46E5),
      accent: Color(0xFF06B6D4),
      gradient: LinearGradient(
        colors: [Color(0xFF818CF8), Color(0xFF6366F1), Color(0xFF4F46E5)],
      ),
      label: 'Indigo',
      labelAr: 'نيلي',
    ),
    AppThemeColor.emerald: ThemePalette(
      primary: Color(0xFF10B981),
      primaryLight: Color(0xFF34D399),
      primaryDark: Color(0xFF059669),
      accent: Color(0xFF14B8A6),
      gradient: LinearGradient(
        colors: [Color(0xFF34D399), Color(0xFF10B981), Color(0xFF059669)],
      ),
      label: 'Emerald',
      labelAr: 'زمردي',
    ),
    AppThemeColor.rose: ThemePalette(
      primary: Color(0xFFF43F5E),
      primaryLight: Color(0xFFFB7185),
      primaryDark: Color(0xFFE11D48),
      accent: Color(0xFFEC4899),
      gradient: LinearGradient(
        colors: [Color(0xFFFB7185), Color(0xFFF43F5E), Color(0xFFE11D48)],
      ),
      label: 'Rose',
      labelAr: 'وردي',
    ),
    AppThemeColor.amber: ThemePalette(
      primary: Color(0xFFF59E0B),
      primaryLight: Color(0xFFFBBF24),
      primaryDark: Color(0xFFD97706),
      accent: Color(0xFFEF4444),
      gradient: LinearGradient(
        colors: [Color(0xFFFBBF24), Color(0xFFF59E0B), Color(0xFFD97706)],
      ),
      label: 'Amber',
      labelAr: 'كهرماني',
    ),
    AppThemeColor.cyan: ThemePalette(
      primary: Color(0xFF06B6D4),
      primaryLight: Color(0xFF22D3EE),
      primaryDark: Color(0xFF0891B2),
      accent: Color(0xFF3B82F6),
      gradient: LinearGradient(
        colors: [Color(0xFF22D3EE), Color(0xFF06B6D4), Color(0xFF0891B2)],
      ),
      label: 'Cyan',
      labelAr: 'سماوي',
    ),
    AppThemeColor.slate: ThemePalette(
      primary: Color(0xFF64748B),
      primaryLight: Color(0xFF94A3B8),
      primaryDark: Color(0xFF475569),
      accent: Color(0xFF94A3B8),
      gradient: LinearGradient(
        colors: [Color(0xFF94A3B8), Color(0xFF64748B), Color(0xFF475569)],
      ),
      label: 'Slate',
      labelAr: 'رمادي',
    ),
  };
}

class ThemePalette {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accent;
  final LinearGradient gradient;
  final String label;
  final String labelAr;

  const ThemePalette({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    required this.gradient,
    required this.label,
    required this.labelAr,
  });
}
