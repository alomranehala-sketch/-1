import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/hms_service.dart';
import '../../theme.dart';

class HmsCheckinScreen extends StatefulWidget {
  const HmsCheckinScreen({super.key});
  @override
  State<HmsCheckinScreen> createState() => _HmsCheckinScreenState();
}

class _HmsCheckinScreenState extends State<HmsCheckinScreen> {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _complaintController = TextEditingController();
  String _gender = 'ذكر';
  String _department = 'طوارئ';
  bool _submitting = false;
  bool _success = false;

  final _departments = [
    'طوارئ',
    'باطنية',
    'جراحة',
    'أطفال',
    'قلب',
    'نسائية',
    'عظام',
    'أعصاب',
  ];

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty ||
        _complaintController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تعبئة الاسم والشكوى على الأقل'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    HapticFeedback.mediumImpact();

    await HmsService.checkinPatient({
      'nationalId': _idController.text.trim(),
      'name': _nameController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()) ?? 30,
      'gender': _gender,
      'complaint': _complaintController.text.trim(),
      'department': _department,
    });

    if (mounted) {
      setState(() {
        _submitting = false;
        _success = true;
      });
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _success = false);
        _idController.clear();
        _nameController.clear();
        _ageController.clear();
        _complaintController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'تسجيل دخول مريض 🏥',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: _success
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'تم تسجيل المريض بنجاح ✓',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سيتم إدراجه في قائمة الفرز',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withAlpha(120),
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // QR Code scan area
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ماسح QR: يتطلب كاميرا الجهاز 📷'),
                            backgroundColor: AppColors.info,
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner_rounded,
                                color: AppColors.primary,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'مسح رمز QR للمريض',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'أو أدخل البيانات يدوياً أدناه',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withAlpha(100),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Manual form
                    _sectionTitle('بيانات المريض'),
                    const SizedBox(height: 10),
                    _field(
                      'رقم الهوية الوطنية',
                      _idController,
                      Icons.badge_rounded,
                      TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      'الاسم الكامل *',
                      _nameController,
                      Icons.person_rounded,
                      TextInputType.name,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            'العمر',
                            _ageController,
                            Icons.calendar_today_rounded,
                            TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dropdown('الجنس', _gender, [
                            'ذكر',
                            'أنثى',
                          ], (v) => setState(() => _gender = v!)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle('معلومات طبية'),
                    const SizedBox(height: 10),
                    _dropdown(
                      'القسم',
                      _department,
                      _departments,
                      (v) => setState(() => _department = v!),
                    ),
                    const SizedBox(height: 12),
                    _field(
                      'الشكوى الرئيسية *',
                      _complaintController,
                      Icons.medical_information_rounded,
                      TextInputType.text,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    // Submit
                    GestureDetector(
                      onTap: _submitting ? null : _submit,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF6366F1)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: _submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'تسجيل الدخول ✓',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.white.withAlpha(180),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon,
    TextInputType type, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.white.withAlpha(60), size: 20),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white54,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
