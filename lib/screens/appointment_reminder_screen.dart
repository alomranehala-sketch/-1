import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

// ═══════════════════════════════════════════════════════════════
//  TERYAQ SMART HEALTH — Appointment Reminder Settings
//  Customize when and how you get notified about appointments
//  Supports: week before, day before, 2h/1h/30min before
// ═══════════════════════════════════════════════════════════════

class AppointmentReminderScreen extends StatefulWidget {
  const AppointmentReminderScreen({super.key});
  @override
  State<AppointmentReminderScreen> createState() =>
      _AppointmentReminderScreenState();
}

class _AppointmentReminderScreenState extends State<AppointmentReminderScreen> {
  bool _weekBefore = true;
  bool _dayBefore = true;
  bool _twoHours = true;
  bool _oneHour = true;
  bool _thirtyMin = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _medicationReminders = true;
  bool _medicationMorning = true;
  bool _medicationNoon = false;
  bool _medicationEvening = true;
  bool _medicationNight = false;
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _noonTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _nightTime = const TimeOfDay(hour: 22, minute: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _weekBefore = p.getBool('rem_week') ?? true;
      _dayBefore = p.getBool('rem_day') ?? true;
      _twoHours = p.getBool('rem_2h') ?? true;
      _oneHour = p.getBool('rem_1h') ?? true;
      _thirtyMin = p.getBool('rem_30m') ?? true;
      _soundEnabled = p.getBool('rem_sound') ?? true;
      _vibrationEnabled = p.getBool('rem_vibration') ?? true;
      _medicationReminders = p.getBool('med_rem_enabled') ?? true;
      _medicationMorning = p.getBool('med_rem_morning') ?? true;
      _medicationNoon = p.getBool('med_rem_noon') ?? false;
      _medicationEvening = p.getBool('med_rem_evening') ?? true;
      _medicationNight = p.getBool('med_rem_night') ?? false;
      _loading = false;
    });
  }

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('rem_week', _weekBefore);
    await p.setBool('rem_day', _dayBefore);
    await p.setBool('rem_2h', _twoHours);
    await p.setBool('rem_1h', _oneHour);
    await p.setBool('rem_30m', _thirtyMin);
    await p.setBool('rem_sound', _soundEnabled);
    await p.setBool('rem_vibration', _vibrationEnabled);
    await p.setBool('med_rem_enabled', _medicationReminders);
    await p.setBool('med_rem_morning', _medicationMorning);
    await p.setBool('med_rem_noon', _medicationNoon);
    await p.setBool('med_rem_evening', _medicationEvening);
    await p.setBool('med_rem_night', _medicationNight);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader(topPad),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildSection(
                          '📅 تنبيهات المواعيد',
                          'حدد متى تريد التذكير بمواعيدك الطبية',
                          [
                            _buildToggle(
                              Icons.calendar_month_rounded,
                              'قبل أسبوع',
                              'إشعار مسبق للتحضير وإعادة الجدولة',
                              _weekBefore,
                              (v) => setState(() {
                                _weekBefore = v;
                                _savePrefs();
                              }),
                              const Color(0xFF8B5CF6),
                            ),
                            _buildToggle(
                              Icons.today_rounded,
                              'قبل يوم كامل',
                              'تذكير في مساء اليوم السابق',
                              _dayBefore,
                              (v) => setState(() {
                                _dayBefore = v;
                                _savePrefs();
                              }),
                              const Color(0xFF3B82F6),
                            ),
                            _buildToggle(
                              Icons.access_time_rounded,
                              'قبل ساعتين',
                              'وقت كافٍ للتنقل والتحضير',
                              _twoHours,
                              (v) => setState(() {
                                _twoHours = v;
                                _savePrefs();
                              }),
                              const Color(0xFF06B6D4),
                            ),
                            _buildToggle(
                              Icons.timer_rounded,
                              'قبل ساعة واحدة',
                              'تنبيه للانطلاق للمستشفى',
                              _oneHour,
                              (v) => setState(() {
                                _oneHour = v;
                                _savePrefs();
                              }),
                              const Color(0xFF10B981),
                            ),
                            _buildToggle(
                              Icons.alarm_rounded,
                              'قبل 30 دقيقة',
                              'آخر تنبيه قبيل الموعد',
                              _thirtyMin,
                              (v) => setState(() {
                                _thirtyMin = v;
                                _savePrefs();
                              }),
                              const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          '💊 تذكير الأدوية',
                          'إشعارات تلقائية مرتبطة بوصفاتك',
                          [
                            _buildToggle(
                              Icons.medication_rounded,
                              'تفعيل تذكير الأدوية',
                              'تنبيهات يومية لجرعاتك',
                              _medicationReminders,
                              (v) => setState(() {
                                _medicationReminders = v;
                                _savePrefs();
                              }),
                              AppColors.primary,
                            ),
                            if (_medicationReminders) ...[
                              _buildTimeToggle(
                                '🌅',
                                'صباح',
                                _morningTime,
                                _medicationMorning,
                                (v) => setState(() {
                                  _medicationMorning = v;
                                  _savePrefs();
                                }),
                                () async {
                                  final t = await showTimePicker(
                                    context: context,
                                    initialTime: _morningTime,
                                  );
                                  if (t != null) {
                                    setState(() => _morningTime = t);
                                  }
                                },
                              ),
                              _buildTimeToggle(
                                '☀️',
                                'ظهر',
                                _noonTime,
                                _medicationNoon,
                                (v) => setState(() {
                                  _medicationNoon = v;
                                  _savePrefs();
                                }),
                                () async {
                                  final t = await showTimePicker(
                                    context: context,
                                    initialTime: _noonTime,
                                  );
                                  if (t != null) {
                                    setState(() => _noonTime = t);
                                  }
                                },
                              ),
                              _buildTimeToggle(
                                '🌆',
                                'مساء',
                                _eveningTime,
                                _medicationEvening,
                                (v) => setState(() {
                                  _medicationEvening = v;
                                  _savePrefs();
                                }),
                                () async {
                                  final t = await showTimePicker(
                                    context: context,
                                    initialTime: _eveningTime,
                                  );
                                  if (t != null) {
                                    setState(() => _eveningTime = t);
                                  }
                                },
                              ),
                              _buildTimeToggle(
                                '🌙',
                                'ليل',
                                _nightTime,
                                _medicationNight,
                                (v) => setState(() {
                                  _medicationNight = v;
                                  _savePrefs();
                                }),
                                () async {
                                  final t = await showTimePicker(
                                    context: context,
                                    initialTime: _nightTime,
                                  );
                                  if (t != null) {
                                    setState(() => _nightTime = t);
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          '🔔 إعدادات الإشعارات',
                          'كيف تريد استقبال التنبيهات',
                          [
                            _buildToggle(
                              Icons.volume_up_rounded,
                              'الصوت',
                              'تشغيل صوت مع الإشعار',
                              _soundEnabled,
                              (v) => setState(() {
                                _soundEnabled = v;
                                _savePrefs();
                              }),
                              const Color(0xFF06B6D4),
                            ),
                            _buildToggle(
                              Icons.vibration_rounded,
                              'الاهتزاز',
                              'اهتزاز عند وصول الإشعار',
                              _vibrationEnabled,
                              (v) => setState(() {
                                _vibrationEnabled = v;
                                _savePrefs();
                              }),
                              const Color(0xFF8B5CF6),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildTestButton(),
                        const SizedBox(height: 80),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double topPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, topPad + 8, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withAlpha(40), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.textDark,
            ),
          ),
          const Expanded(
            child: Text(
              'إعدادات التنبيهات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
          Icon(
            Icons.notifications_active_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withAlpha(40), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            indent: 16,
            endIndent: 16,
            height: 12,
            color: AppColors.borderLight,
          ),
          ...items,
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildToggle(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeToggle(
    String emoji,
    String label,
    TimeOfDay time,
    bool enabled,
    Function(bool) onToggle,
    VoidCallback onEditTime,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          if (enabled)
            GestureDetector(
              onTap: onEditTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: enabled,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onToggle(v);
            },
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إرسال تنبيه تجريبي! ✅'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'إرسال تنبيه تجريبي',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
