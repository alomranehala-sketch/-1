import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme.dart';
import '../services/api_service.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  bool _emergencyMode = false;
  Map<String, dynamic> _profile = {};
  Map<String, dynamic> _record = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      ApiService.getProfile(),
      ApiService.getHealthRecord(),
    ]);
    if (!mounted) return;
    setState(() {
      _profile = results[0];
      _record = results[1];
    });
  }

  String get _name => (_profile['name'] as String?) ?? 'مستخدم';
  String get _nationalId => (_profile['nationalId'] as String?) ?? '';
  String get _bloodType => (_record['bloodType'] as String?) ?? '';

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(
                color: AppColors.border.withAlpha(40),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              const Text(
                'المحفظة الطبية',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _shareWallet,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.share_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildQRCard(),
                const SizedBox(height: 12),
                _buildEmergencyModeButton(),
                const SizedBox(height: 16),
                _buildPatientInfo(),
                const SizedBox(height: 16),
                _buildAllergies(),
                const SizedBox(height: 16),
                _buildChronicConditions(),
                const SizedBox(height: 16),
                _buildEmergencyContacts(),
                const SizedBox(height: 16),
                _buildInsurance(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQRCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.credit_card_rounded,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'البطاقة الطبية الرقمية',
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'يعمل بدون إنترنت',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // QR Code
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(10),
            child: QrImageView(
              data: 'TERYAQ-HEALTH|$_nationalId|$_bloodType|$_name',
              version: QrVersions.auto,
              size: 140,
              gapless: true,
              embeddedImage: null,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'الرقم الوطني: $_nationalId',
            style: TextStyle(color: Colors.white.withAlpha(160), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'فصيلة الدم: $_bloodType',
            style: TextStyle(
              color: Colors.white.withAlpha(160),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo() {
    return _InfoCard(
      title: 'المعلومات الشخصية',
      icon: Icons.person_rounded,
      children: [
        _infoRow('الاسم الكامل', _name),
        _infoRow('تاريخ الميلاد', '15/03/1993'),
        _infoRow('الجنس', 'أنثى'),
        _infoRow('الرقم الوطني', '9951234567'),
        _infoRow('رقم الهاتف', '0791234567'),
      ],
    );
  }

  Widget _buildAllergies() {
    final allergies = [
      _AllergyItem('بنسلين', 'شديد', AppColors.error),
      _AllergyItem('الفول السوداني', 'متوسط', AppColors.warning),
    ];

    return _InfoCard(
      title: 'الحساسية',
      icon: Icons.warning_amber_rounded,
      children: allergies.map((a) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: a.color.withAlpha(8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: a.color.withAlpha(25)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_rounded, size: 16, color: a.color),
              const SizedBox(width: 8),
              Text(
                a.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: a.color.withAlpha(18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  a.severity,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: a.color,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChronicConditions() {
    return _InfoCard(
      title: 'الأمراض المزمنة',
      icon: Icons.monitor_heart_rounded,
      children: [
        _conditionRow('السكري من النوع 2', 'منذ 2020'),
        _conditionRow('نقص فيتامين D', 'منذ 2024'),
      ],
    );
  }

  Widget _conditionRow(String name, String since) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Text(
            since,
            style: TextStyle(fontSize: 11, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return _InfoCard(
      title: 'جهات الطوارئ',
      icon: Icons.emergency_rounded,
      children: [
        _emergencyRow('أحمد محمد (الأب)', '0791112233'),
        _emergencyRow('نور أحمد (الأخت)', '0799998877'),
      ],
    );
  }

  Widget _emergencyRow(String name, String phone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withAlpha(18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone_rounded, size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Text(
            phone,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsurance() {
    return _InfoCard(
      title: 'التأمين الصحي',
      icon: Icons.health_and_safety_rounded,
      children: [
        _infoRow('الشركة', 'التأمين الصحي الحكومي'),
        _infoRow('رقم البوليصة', 'JOR-2025-456789'),
        _infoRow('الصلاحية', '01/01/2025 - 31/12/2025'),
        _infoRow('نوع التغطية', 'شامل'),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyModeButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        setState(() => _emergencyMode = !_emergencyMode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          gradient: _emergencyMode
              ? const LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                )
              : null,
          color: _emergencyMode ? null : AppColors.error.withAlpha(10),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: _emergencyMode
              ? null
              : Border.all(color: AppColors.error.withAlpha(30)),
          boxShadow: _emergencyMode
              ? [
                  BoxShadow(
                    color: AppColors.error.withAlpha(50),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _emergencyMode
                  ? Icons.emergency_rounded
                  : Icons.emergency_outlined,
              color: _emergencyMode ? Colors.white : AppColors.error,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              _emergencyMode ? '🔴 وضع الطوارئ مفعّل' : 'تفعيل وضع الطوارئ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _emergencyMode ? Colors.white : AppColors.error,
              ),
            ),
            if (_emergencyMode) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'إيقاف',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _shareWallet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'مشاركة البطاقة الطبية',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _shareOption(
                  Icons.qr_code_rounded,
                  'رمز QR',
                  AppColors.primary,
                ),
                _shareOption(Icons.copy_rounded, 'نسخ', AppColors.info),
                _shareOption(
                  Icons.bluetooth_rounded,
                  'بلوتوث',
                  AppColors.textMedium,
                ),
                _shareOption(Icons.nfc_rounded, 'NFC', AppColors.warning),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _shareOption(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withAlpha(12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _AllergyItem {
  final String name, severity;
  final Color color;
  const _AllergyItem(this.name, this.severity, this.color);
}
