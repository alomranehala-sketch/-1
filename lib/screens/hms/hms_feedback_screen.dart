import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/hms_service.dart';
import '../../theme.dart';

class HmsFeedbackScreen extends StatefulWidget {
  const HmsFeedbackScreen({super.key});
  @override
  State<HmsFeedbackScreen> createState() => _HmsFeedbackScreenState();
}

class _HmsFeedbackScreenState extends State<HmsFeedbackScreen> {
  List<Map<String, dynamic>> _feedback = [];
  bool _loading = true;
  int _selectedRating = 0;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await HmsService.getFeedback();
    if (mounted) {
      setState(() {
        _feedback = data;
        _loading = false;
      });
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
            'تقييمات المرضى ⭐',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Submit new feedback
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'إضافة تقييم جديد',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Stars
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (i) => GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedRating = i + 1);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    i < _selectedRating
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    size: 40,
                                    color: i < _selectedRating
                                        ? const Color(0xFFF59E0B)
                                        : Colors.white.withAlpha(40),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _commentController,
                            maxLines: 3,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'اكتب ملاحظاتك هنا...',
                              hintStyle: TextStyle(
                                color: Colors.white.withAlpha(60),
                              ),
                              filled: true,
                              fillColor: Colors.white.withAlpha(5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _selectedRating == 0
                                ? null
                                : () async {
                                    HapticFeedback.mediumImpact();
                                    await HmsService.submitFeedback({
                                      'rating': _selectedRating,
                                      'comment': _commentController.text.trim(),
                                      'department': 'طوارئ',
                                    });
                                    if (!mounted) return;
                                    _commentController.clear();
                                    setState(() => _selectedRating = 0);
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('شكراً لتقييمك! ⭐'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                    _load();
                                  },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedRating > 0
                                    ? AppColors.primary
                                    : Colors.white.withAlpha(10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'إرسال التقييم',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedRating > 0
                                        ? Colors.white
                                        : Colors.white.withAlpha(40),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Summary
                    if (_feedback.isNotEmpty) ...[
                      _summaryCard(),
                      const SizedBox(height: 16),
                      Text(
                        'جميع التقييمات',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withAlpha(180),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._feedback.map(_buildFeedbackItem),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _summaryCard() {
    final avg = _feedback.isEmpty
        ? 0.0
        : _feedback
                  .map((f) => (f['rating'] as int?) ?? 0)
                  .reduce((a, b) => a + b) /
              _feedback.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF59E0B).withAlpha(15),
            const Color(0xFFF59E0B).withAlpha(5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF59E0B),
                ),
              ),
              Row(
                children: List.generate(
                  3,
                  (i) => Icon(
                    i < avg.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 18,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_feedback.length} تقييم',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                ...List.generate(3, (i) {
                  final star = 3 - i;
                  final count = _feedback
                      .where((f) => (f['rating'] as int?) == star)
                      .length;
                  final pct = _feedback.isEmpty
                      ? 0.0
                      : count / _feedback.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          '$star',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withAlpha(100),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.star_rounded,
                          size: 10,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: Colors.white.withAlpha(10),
                              color: const Color(0xFFF59E0B),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withAlpha(80),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackItem(Map<String, dynamic> fb) {
    final rating = (fb['rating'] as int?) ?? 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(
                3,
                (i) => Icon(
                  i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 16,
                  color: i < rating
                      ? const Color(0xFFF59E0B)
                      : Colors.white.withAlpha(30),
                ),
              ),
              const Spacer(),
              Text(
                fb['patientName'] ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if ((fb['comment'] as String?)?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '"${fb['comment']}"',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withAlpha(140),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            '${fb['doctor'] ?? ''} • ${fb['department'] ?? ''}',
            style: TextStyle(fontSize: 10, color: Colors.white.withAlpha(80)),
          ),
        ],
      ),
    );
  }
}
