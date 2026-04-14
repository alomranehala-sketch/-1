import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'moh/moh_dashboard_screen.dart';
import 'moh/moh_map_screen.dart';
import 'moh/moh_analytics_screen.dart';
import 'moh/moh_reports_screen.dart';
import 'moh/moh_epidemic_screen.dart';
import 'moh/moh_equity_screen.dart';

class MohShell extends StatefulWidget {
  final String userName;
  const MohShell({super.key, required this.userName});
  @override
  State<MohShell> createState() => _MohShellState();
}

class _MohShellState extends State<MohShell> {
  int _index = 0;

  late final List<Widget> _screens = [
    MohDashboardScreen(onTabSwitch: (i) => setState(() => _index = i)),
    const MohMapScreen(),
    const MohAnalyticsScreen(),
    const MohReportsScreen(),
    const MohEpidemicScreen(),
    const MohEquityScreen(),
  ];

  final _navItems = const [
    _NavItem(Icons.dashboard_rounded, 'القيادة'),
    _NavItem(Icons.map_rounded, 'خريطة حية'),
    _NavItem(Icons.analytics_rounded, 'التحليلات'),
    _NavItem(Icons.assessment_rounded, 'التقارير'),
    _NavItem(Icons.warning_amber_rounded, 'الأوبئة'),
    _NavItem(Icons.balance_rounded, 'العدالة'),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: _screens[_index],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            border: Border(top: BorderSide(color: Colors.white.withAlpha(10))),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: List.generate(_navItems.length, (i) {
                  final active = i == _index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _index = i);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF10B981).withAlpha(20)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _navItems[i].icon,
                              color: active
                                  ? const Color(0xFF10B981)
                                  : Colors.white.withAlpha(80),
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _navItems[i].label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: active
                                    ? const Color(0xFF10B981)
                                    : Colors.white.withAlpha(80),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
