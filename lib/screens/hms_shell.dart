import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import 'hms/hms_dashboard_screen.dart';
import 'hms/hms_patients_screen.dart';
import 'hms/hms_beds_screen.dart';
import 'hms/hms_alerts_screen.dart';
import 'hms/hms_ems_screen.dart';
import 'hms/hms_staff_screen.dart';

class HmsShell extends StatefulWidget {
  final String role; // doctor, nurse, reception
  final String userName;
  const HmsShell({super.key, required this.role, required this.userName});
  @override
  State<HmsShell> createState() => _HmsShellState();
}

class _HmsShellState extends State<HmsShell> {
  int _index = 0;

  late final List<Widget> _screens;
  late final List<_NavItem> _navItems;

  @override
  void initState() {
    super.initState();
    _screens = [
      HmsDashboardScreen(
        role: widget.role,
        onSwitchTab: (i) => setState(() => _index = i),
      ),
      HmsPatientsScreen(role: widget.role),
      const HmsBedsScreen(),
      const HmsAlertsScreen(),
      const HmsEmsScreen(),
      const HmsStaffScreen(),
    ];
    _navItems = [
      const _NavItem(Icons.dashboard_rounded, 'لوحة القيادة'),
      const _NavItem(Icons.people_rounded, 'المرضى'),
      const _NavItem(Icons.bed_rounded, 'الأسرّة'),
      const _NavItem(Icons.warning_amber_rounded, 'التنبيهات'),
      const _NavItem(Icons.local_hospital_rounded, 'الطوارئ'),
      const _NavItem(Icons.badge_rounded, 'الكادر'),
    ];
  }

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
                              ? AppColors.primary.withAlpha(20)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _navItems[i].icon,
                              color: active
                                  ? AppColors.primary
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
                                    ? AppColors.primary
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
