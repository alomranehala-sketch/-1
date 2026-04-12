import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  List<_SearchResult> _results = [];
  bool _loading = false;
  String _query = '';

  final _recentSearches = [
    'دكتور قلب',
    'مستشفى الأردن',
    'فحص دم',
    'دكتور عيون',
    'أموكسيسيلين',
  ];

  final _quickCategories = [
    _Cat(Icons.local_hospital_rounded, 'مستشفيات', const Color(0xFF3B82F6)),
    _Cat(Icons.person_rounded, 'أطباء', const Color(0xFF10B981)),
    _Cat(Icons.medication_rounded, 'أدوية', const Color(0xFFF59E0B)),
    _Cat(Icons.biotech_rounded, 'تحاليل', const Color(0xFF8B5CF6)),
    _Cat(Icons.emergency_rounded, 'طوارئ', const Color(0xFFEF4444)),
    _Cat(Icons.bloodtype_rounded, 'تبرع بالدم', const Color(0xFFEC4899)),
  ];

  @override
  void initState() {
    super.initState();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _query = '';
      });
      return;
    }
    setState(() {
      _loading = true;
      _query = query;
    });

    try {
      final q = query.trim().toLowerCase();
      final List<_SearchResult> results = [];

      // Search hospitals
      final hospitals = await ApiService.getHospitals(search: query);
      for (final h in hospitals) {
        results.add(
          _SearchResult(
            title: h['name'] as String? ?? '',
            subtitle: '${h['governorate'] ?? ''} — ${h['type'] ?? ''}',
            icon: Icons.local_hospital_rounded,
            color: const Color(0xFF3B82F6),
            type: 'hospital',
          ),
        );
      }

      // Search doctors
      final doctors = await ApiService.getDoctors(search: query);
      for (final d in doctors) {
        results.add(
          _SearchResult(
            title: d['name'] as String? ?? '',
            subtitle:
                '${d['specialization'] ?? ''} — ${d['hospitalName'] ?? ''}',
            icon: Icons.person_rounded,
            color: const Color(0xFF10B981),
            type: 'doctor',
          ),
        );
      }

      // Local keyword matching for services
      final services = [
        _SearchResult(
          title: 'سجلي الطبي',
          subtitle: 'عرض السجل الطبي الكامل',
          icon: Icons.folder_shared_rounded,
          color: const Color(0xFF6366F1),
          type: 'service',
        ),
        _SearchResult(
          title: 'التحاليل',
          subtitle: 'نتائج الفحوصات المخبرية',
          icon: Icons.biotech_rounded,
          color: const Color(0xFF3B82F6),
          type: 'service',
        ),
        _SearchResult(
          title: 'الأدوية',
          subtitle: 'إدارة الأدوية والتذكيرات',
          icon: Icons.medication_rounded,
          color: const Color(0xFF10B981),
          type: 'service',
        ),
        _SearchResult(
          title: 'المحفظة',
          subtitle: 'المدفوعات والتأمين',
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFFF59E0B),
          type: 'service',
        ),
        _SearchResult(
          title: 'التبرع بالدم',
          subtitle: 'سجل كمتبرع أو تبرع الآن',
          icon: Icons.bloodtype_rounded,
          color: const Color(0xFFEF4444),
          type: 'service',
        ),
        _SearchResult(
          title: 'المواعيد',
          subtitle: 'حجز وإدارة المواعيد',
          icon: Icons.calendar_month_rounded,
          color: const Color(0xFF8B5CF6),
          type: 'service',
        ),
        _SearchResult(
          title: 'طوارئ',
          subtitle: 'أقرب مستشفى طوارئ',
          icon: Icons.emergency_rounded,
          color: const Color(0xFFEF4444),
          type: 'service',
        ),
        _SearchResult(
          title: 'توصيل الدواء',
          subtitle: 'اطلب توصيل أدويتك',
          icon: Icons.delivery_dining_rounded,
          color: const Color(0xFF06B6D4),
          type: 'service',
        ),
        _SearchResult(
          title: 'نصائح صحية',
          subtitle: 'نصائح ومقالات صحية',
          icon: Icons.lightbulb_rounded,
          color: const Color(0xFF10B981),
          type: 'service',
        ),
      ];
      for (final s in services) {
        if (s.title.contains(q) || s.subtitle.contains(q)) {
          results.add(s);
        }
      }

      if (mounted) {
        setState(() {
          _results = results;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Column(
          children: [
            _buildSearchHeader(top),
            Expanded(
              child: _query.isEmpty ? _buildSuggestions() : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(double topPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF6366F1).withAlpha(30),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'ابحث عن طبيب، مستشفى، أو خدمة...',
                        hintStyle: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => _search(v),
                      onSubmitted: (v) => _search(v),
                    ),
                  ),
                  if (_ctrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _ctrl.clear();
                        _search('');
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.close_rounded,
                          color: Color(0xFF64748B),
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick categories
        const Text(
          'تصفح حسب القسم',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickCategories
              .map(
                (c) => GestureDetector(
                  onTap: () {
                    _ctrl.text = c.label;
                    _search(c.label);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: c.color.withAlpha(15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: c.color.withAlpha(25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(c.icon, color: c.color, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          c.label,
                          style: TextStyle(
                            color: c.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        // Recent searches
        const Text(
          'عمليات البحث الأخيرة',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ..._recentSearches.map(
          (s) => GestureDetector(
            onTap: () {
              _ctrl.text = s;
              _search(s);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.history_rounded,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    s,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: Color(0xFF64748B),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'لا نتائج لـ "$_query"',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (_, i) {
        final r = _results[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withAlpha(6)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: r.color.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(r.icon, color: r.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      r.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: r.color.withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  r.type == 'hospital'
                      ? 'مستشفى'
                      : r.type == 'doctor'
                      ? 'طبيب'
                      : 'خدمة',
                  style: TextStyle(
                    color: r.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchResult {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String type;
  const _SearchResult({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class _Cat {
  final IconData icon;
  final String label;
  final Color color;
  const _Cat(this.icon, this.label, this.color);
}
