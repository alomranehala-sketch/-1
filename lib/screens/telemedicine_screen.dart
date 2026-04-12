import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Telemedicine Bridge — جسر التطبيب عن بعد
/// Video call with public or private doctor from within the app
class TelemedicineScreen extends StatefulWidget {
  const TelemedicineScreen({super.key});
  @override
  State<TelemedicineScreen> createState() => _TelemedicineScreenState();
}

class _TelemedicineScreenState extends State<TelemedicineScreen> {
  final String _selectedSpecialty = '';
  String _selectedType = 'الكل';

  final _availableDoctors = [
    _TeleDoc(
      'د. محمد الشريف',
      'طب عام',
      'عام',
      4.9,
      15,
      true,
      'مجاني',
      'مستشفى الجامعة',
    ),
    _TeleDoc(
      'د. أمل الخطيب',
      'جلدية',
      'خاص',
      4.8,
      5,
      true,
      '20 د.أ',
      'مستشفى الأردن',
    ),
    _TeleDoc(
      'د. زيد العمري',
      'باطنية',
      'عام',
      4.7,
      30,
      true,
      'مجاني',
      'مستشفى البشير',
    ),
    _TeleDoc(
      'د. نور حداد',
      'نفسية',
      'خاص',
      4.9,
      10,
      true,
      '35 د.أ',
      'مركز الأمل',
    ),
    _TeleDoc(
      'د. فاطمة الرواشدة',
      'أطفال',
      'عام',
      4.6,
      20,
      false,
      'مجاني',
      'مستشفى الأمير حمزة',
    ),
    _TeleDoc(
      'د. سامي بطاينة',
      'عظام',
      'خاص',
      4.8,
      10,
      true,
      '25 د.أ',
      'المستشفى العبدلي',
    ),
  ];

  List<_TeleDoc> get _filteredDoctors {
    return _availableDoctors.where((d) {
      if (_selectedType != 'الكل' && d.type != _selectedType) return false;
      if (_selectedSpecialty.isNotEmpty && d.specialty != _selectedSpecialty) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'التطبيب عن بعد 📹',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildHeroCard()),
            SliverToBoxAdapter(child: _buildFilters()),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _buildDoctorCard(_filteredDoctors[i], i),
                childCount: _filteredDoctors.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF6366F1)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'استشر طبيبك من البيت 🏠',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'كول فيديو مع دكتور عام أو خاص — بدون طابور',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white70,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'مستشفيات عامة مجاني',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white70,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'مستشفيات خاصة من 15 د.أ',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.videocam_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Type filter
          Row(
            children: ['الكل', 'عام', 'خاص'].map((t) {
              final selected = _selectedType == t;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedType = t),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.border.withAlpha(40),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      t,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.textMedium,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Results count
          Row(
            children: [
              Text(
                '${_filteredDoctors.length} دكتور متاح الآن',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Icon(Icons.circle, color: AppColors.success, size: 8),
              const SizedBox(width: 4),
              const Text(
                'أونلاين',
                style: TextStyle(color: AppColors.success, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(_TeleDoc doc, int index) {
    final isPublic = doc.type == 'عام';
    final typeColor = isPublic
        ? const Color(0xFF10B981)
        : const Color(0xFF6366F1);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withAlpha(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: typeColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    doc.name[2],
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            doc.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (doc.isAvailable)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${doc.specialty} — ${doc.hospital}',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: typeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  doc.price,
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: const Color(0xFFF59E0B),
                size: 14,
              ),
              const SizedBox(width: 2),
              Text(
                '${doc.rating}',
                style: const TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.access_time_rounded,
                color: AppColors.textLight,
                size: 14,
              ),
              const SizedBox(width: 2),
              Text(
                'انتظار ~${doc.waitMinutes} د',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withAlpha(10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  doc.type,
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_rounded, size: 16),
                  label: const Text('محادثة', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: doc.isAvailable
                      ? () {
                          HapticFeedback.mediumImpact();
                          _showCallDialog(doc);
                        }
                      : null,
                  icon: const Icon(Icons.videocam_rounded, size: 18),
                  label: Text(
                    doc.isAvailable ? 'كول فيديو الآن' : 'غير متصل',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.border.withAlpha(40),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCallDialog(_TeleDoc doc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.videocam_rounded,
                color: Color(0xFF06B6D4),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'بدء مكالمة فيديو مع',
              style: TextStyle(color: AppColors.textMedium, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              doc.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              doc.specialty,
              style: const TextStyle(color: AppColors.textLight, fontSize: 12),
            ),
            if (doc.price != 'مجاني') ...[
              const SizedBox(height: 8),
              Text(
                'التكلفة: ${doc.price}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textLight),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showInCallScreen(doc);
            },
            icon: const Icon(Icons.videocam_rounded, size: 18),
            label: const Text('ابدأ المكالمة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06B6D4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInCallScreen(_TeleDoc doc) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _InCallScreen(doc: doc)),
    );
  }
}

class _InCallScreen extends StatelessWidget {
  final _TeleDoc doc;
  const _InCallScreen({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // Simulated video area
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          doc.name[2],
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      doc.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'جاري الاتصال...',
                      style: TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Self view
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.textLight,
                    size: 40,
                  ),
                ),
              ),
            ),
            // Controls
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _callBtn(
                    Icons.mic_off_rounded,
                    'كتم',
                    AppColors.surface,
                    Colors.white,
                  ),
                  _callBtn(
                    Icons.videocam_off_rounded,
                    'كاميرا',
                    AppColors.surface,
                    Colors.white,
                  ),
                  _callBtn(
                    Icons.call_end_rounded,
                    'إنهاء',
                    const Color(0xFFEF4444),
                    Colors.white,
                    onTap: () => Navigator.pop(context),
                  ),
                  _callBtn(
                    Icons.chat_rounded,
                    'دردشة',
                    AppColors.surface,
                    Colors.white,
                  ),
                  _callBtn(
                    Icons.more_horiz_rounded,
                    'المزيد',
                    AppColors.surface,
                    Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _callBtn(
    IconData icon,
    String label,
    Color bg,
    Color fg, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: fg, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}

class _TeleDoc {
  final String name, specialty, type, price, hospital;
  final double rating;
  final int waitMinutes;
  final bool isAvailable;
  const _TeleDoc(
    this.name,
    this.specialty,
    this.type,
    this.rating,
    this.waitMinutes,
    this.isAvailable,
    this.price,
    this.hospital,
  );
}
