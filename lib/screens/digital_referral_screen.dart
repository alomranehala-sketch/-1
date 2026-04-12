import 'package:flutter/material.dart';
import '../theme.dart';

/// Digital Referral System — نظام الإحالة الرقمي
/// Doctor refers patient public→private or vice versa, all digital with real-time tracking
class DigitalReferralScreen extends StatefulWidget {
  const DigitalReferralScreen({super.key});
  @override
  State<DigitalReferralScreen> createState() => _DigitalReferralScreenState();
}

class _DigitalReferralScreenState extends State<DigitalReferralScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final _activeReferrals = [
    _Referral(
      'إحالة قلب — إيكو',
      'د. أحمد الحسن',
      'مستشفى البشير',
      'عام',
      'مستشفى الأردن',
      'خاص',
      'pending',
      '2026-04-10',
      'فحص إيكو قلب تأكيدي',
    ),
    _Referral(
      'إحالة عظام — رنين',
      'د. سارة المعايطة',
      'مستشفى الجامعة',
      'عام',
      'المركز العربي الطبي',
      'خاص',
      'approved',
      '2026-04-08',
      'رنين مغناطيسي للركبة',
    ),
  ];

  final _completedReferrals = [
    _Referral(
      'إحالة عيون',
      'د. خالد الزعبي',
      'مستشفى الأمير حمزة',
      'عام',
      'مستشفى العيون التخصصي',
      'خاص',
      'completed',
      '2026-03-20',
      'فحص شبكية متقدم',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
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
                'الإحالات الرقمية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildInfoCard()),
            SliverToBoxAdapter(child: _buildTabs()),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildReferralList(_activeReferrals),
                    _buildReferralList(_completedReferrals),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF0F172A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الإحالة الرقمية الموحدة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'عام ↔ خاص — رقمية 100%',
                      style: TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _miniStat(
                'إحالات نشطة',
                '${_activeReferrals.length}',
                const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              _miniStat(
                'مكتملة',
                '${_completedReferrals.length}',
                const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              _miniStat('متوسط الانتظار', '2 يوم', const Color(0xFF3B82F6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: AppColors.textLight, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabCtrl,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textLight,
        indicatorColor: AppColors.primary,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        tabs: const [
          Tab(text: 'نشطة'),
          Tab(text: 'مكتملة'),
        ],
      ),
    );
  }

  Widget _buildReferralList(List<_Referral> referrals) {
    if (referrals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz_rounded,
              color: AppColors.textLight,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد إحالات',
              style: TextStyle(color: AppColors.textLight, fontSize: 14),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: referrals.length,
      itemBuilder: (_, i) => _buildReferralCard(referrals[i]),
    );
  }

  Widget _buildReferralCard(_Referral r) {
    final statusColor = r.status == 'completed'
        ? const Color(0xFF10B981)
        : r.status == 'approved'
        ? const Color(0xFF3B82F6)
        : const Color(0xFFF59E0B);
    final statusText = r.status == 'completed'
        ? 'مكتملة'
        : r.status == 'approved'
        ? 'موافق عليها'
        : 'بانتظار الموافقة';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'الدكتور: ${r.doctorName}',
            style: const TextStyle(color: AppColors.textMedium, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            r.reason,
            style: const TextStyle(color: AppColors.textLight, fontSize: 11),
          ),
          const SizedBox(height: 12),
          // From → To
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _locationBadge(r.fromHospital, r.fromType)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                Expanded(child: _locationBadge(r.toHospital, r.toType)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Timeline steps
          _timelineStep('تم إنشاء الإحالة', r.date, true),
          _timelineStep(
            'موافقة المستشفى المستقبل',
            r.status != 'pending' ? 'تمت' : 'بانتظار...',
            r.status != 'pending',
          ),
          _timelineStep(
            'حجز الموعد تلقائياً',
            r.status == 'completed' ? 'تم' : 'قريباً',
            r.status == 'completed',
          ),
          if (r.status != 'completed') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.track_changes_rounded, size: 16),
                    label: const Text(
                      'تتبع الإحالة',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_rounded, size: 16),
                    label: const Text(
                      'تواصل مع الدكتور',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
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
        ],
      ),
    );
  }

  Widget _locationBadge(String hospital, String type) {
    final isPublic = type == 'عام';
    final color = isPublic ? const Color(0xFF10B981) : const Color(0xFF6366F1);
    return Column(
      children: [
        Icon(
          isPublic
              ? Icons.account_balance_rounded
              : Icons.local_hospital_rounded,
          color: color,
          size: 18,
        ),
        const SizedBox(height: 4),
        Text(
          hospital.replaceAll('مستشفى ', ''),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            type,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _timelineStep(String title, String sub, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: done
                  ? AppColors.success.withAlpha(30)
                  : AppColors.border.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              done ? Icons.check_rounded : Icons.circle_outlined,
              color: done ? AppColors.success : AppColors.textLight,
              size: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: done ? Colors.white : AppColors.textLight,
              fontSize: 12,
              fontWeight: done ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(sub, style: TextStyle(color: AppColors.textLight, fontSize: 10)),
        ],
      ),
    );
  }
}

class _Referral {
  final String title,
      doctorName,
      fromHospital,
      fromType,
      toHospital,
      toType,
      status,
      date,
      reason;
  const _Referral(
    this.title,
    this.doctorName,
    this.fromHospital,
    this.fromType,
    this.toHospital,
    this.toType,
    this.status,
    this.date,
    this.reason,
  );
}
