import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Insurance Smart Calculator — حاسبة التأمين الذكية
/// Before booking, see exactly how much you'll pay after insurance
class InsuranceCalculatorScreen extends StatefulWidget {
  const InsuranceCalculatorScreen({super.key});
  @override
  State<InsuranceCalculatorScreen> createState() =>
      _InsuranceCalculatorScreenState();
}

class _InsuranceCalculatorScreenState extends State<InsuranceCalculatorScreen> {
  String _selectedInsurance = '';
  String _selectedService = '';
  String _selectedHospital = '';
  bool _calculated = false;
  double _totalCost = 0;
  double _insuranceCover = 0;
  double _youPay = 0;

  final _insuranceProviders = [
    'التأمين الحكومي',
    'ميدنت',
    'غلوب مد',
    'نيكست كير',
    'المتحدة للتأمين',
    'الشرق العربي',
    'التأمين العربي',
    'بدون تأمين',
  ];

  final _services = [
    _Service('زيارة طب عام', 15, 30),
    _Service('فحص قلب + إيكو', 50, 120),
    _Service('تحاليل مخبرية شاملة', 20, 55),
    _Service('أشعة سينية', 15, 40),
    _Service('رنين مغناطيسي', 80, 250),
    _Service('عملية لوز', 200, 800),
    _Service('ولادة طبيعية', 300, 1500),
    _Service('ولادة قيصرية', 500, 2500),
    _Service('عملية منظار ركبة', 400, 1800),
    _Service('زيارة أسنان + تنظيف', 15, 40),
  ];

  final _hospitals = [
    'مستشفى الأردن',
    'مستشفى العبدلي',
    'المركز العربي الطبي',
    'مستشفى الإسراء',
    'مستشفى الاستقلال',
  ];

  void _calculate() {
    if (_selectedInsurance.isEmpty || _selectedService.isEmpty) return;
    HapticFeedback.mediumImpact();
    final service = _services.firstWhere((s) => s.name == _selectedService);
    final isGov = _selectedInsurance == 'التأمين الحكومي';
    final noInsurance = _selectedInsurance == 'بدون تأمين';

    setState(() {
      _totalCost = service.privateCost.toDouble();
      if (noInsurance) {
        _insuranceCover = 0;
        _youPay = _totalCost;
      } else if (isGov) {
        _insuranceCover = _totalCost * 0.85;
        _youPay = _totalCost * 0.15;
      } else {
        _insuranceCover = _totalCost * 0.70;
        _youPay = _totalCost * 0.30;
      }
      _calculated = true;
    });
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
                'حاسبة التأمين 🧮',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildHeroCard()),
            SliverToBoxAdapter(child: _buildForm()),
            if (_calculated) SliverToBoxAdapter(child: _buildResult()),
            SliverToBoxAdapter(child: _buildComparison()),
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
          colors: [Color(0xFF10B981), Color(0xFF059669)],
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
                  'اعرف كم ستدفع قبل ما تحجز! 💰',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'حاسبة دقيقة تحسب التكلفة بعد التأمين فوراً',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calculate_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'بيانات الحساب',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            'شركة التأمين',
            _selectedInsurance,
            _insuranceProviders,
            (v) => setState(() => _selectedInsurance = v ?? ''),
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            'الخدمة الطبية',
            _selectedService,
            _services.map((s) => s.name).toList(),
            (v) => setState(() => _selectedService = v ?? ''),
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            'المستشفى (اختياري)',
            _selectedHospital,
            _hospitals,
            (v) => setState(() => _selectedHospital = v ?? ''),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate_rounded, size: 20),
              label: const Text(
                'احسب التكلفة',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withAlpha(40)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isEmpty ? null : value,
          hint: Text(
            label,
            style: const TextStyle(color: AppColors.textLight, fontSize: 13),
          ),
          isExpanded: true,
          dropdownColor: AppColors.surface,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontFamily: 'Tajawal',
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withAlpha(40)),
      ),
      child: Column(
        children: [
          const Text(
            'نتيجة الحساب',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _costRow(
            'التكلفة الإجمالية',
            '${_totalCost.toStringAsFixed(0)} د.أ',
            const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 8),
          _costRow(
            'يغطيها التأمين',
            '- ${_insuranceCover.toStringAsFixed(0)} د.أ',
            const Color(0xFF10B981),
          ),
          const Divider(color: AppColors.border, height: 24),
          _costRow(
            'أنت تدفع فقط',
            '${_youPay.toStringAsFixed(0)} د.أ',
            const Color(0xFFF59E0B),
            big: true,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.savings_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'وفرت ${_insuranceCover.toStringAsFixed(0)} د.أ مع التأمين! 🎉',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال طلب الحجز بنجاح ✅'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: const Text(
                'احجز بهذا السعر',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _costRow(String label, String value, Color color, {bool big = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMedium,
            fontSize: big ? 15 : 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: big ? 22 : 15,
            fontWeight: big ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildComparison() {
    if (!_calculated || _selectedService.isEmpty) return const SizedBox();
    final service = _services.firstWhere((s) => s.name == _selectedService);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مقارنة عام vs خاص',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _compareRow(
            'المستشفى العام',
            '${service.publicCost} د.أ',
            'مجاني بالتأمين الحكومي',
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 8),
          _compareRow(
            'المستشفى الخاص',
            '${service.privateCost} د.أ',
            'بعد التأمين: ${_youPay.toStringAsFixed(0)} د.أ',
            const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _compareRow(String hospital, String price, String note, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.local_hospital_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  note,
                  style: TextStyle(color: AppColors.textLight, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Service {
  final String name;
  final int publicCost, privateCost;
  const _Service(this.name, this.publicCost, this.privateCost);
}
