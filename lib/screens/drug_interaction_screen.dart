import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Drug Interaction Checker — كاشف تعارض الأدوية
class DrugInteractionScreen extends StatefulWidget {
  const DrugInteractionScreen({super.key});
  @override
  State<DrugInteractionScreen> createState() => _DrugInteractionScreenState();
}

class _DrugInteractionScreenState extends State<DrugInteractionScreen> {
  final List<String> _selectedDrugs = [];
  final _searchCtrl = TextEditingController();
  List<String> _searchResults = [];
  List<Map<String, dynamic>> _interactions = [];
  bool _checked = false;

  // Common medications database
  final _allDrugs = [
    'أسبرين (Aspirin)',
    'إيبوبروفين (Ibuprofen)',
    'باراسيتامول (Paracetamol)',
    'أموكسيسيلين (Amoxicillin)',
    'أزيثروميسين (Azithromycin)',
    'سيبروفلوكساسين (Ciprofloxacin)',
    'ميتفورمين (Metformin)',
    'جليميبيرايد (Glimepiride)',
    'إنسولين (Insulin)',
    'أملوديبين (Amlodipine)',
    'ليزينوبريل (Lisinopril)',
    'أتينولول (Atenolol)',
    'وارفارين (Warfarin)',
    'كلوبيدوقرل (Clopidogrel)',
    'هيبارين (Heparin)',
    'أوميبرازول (Omeprazole)',
    'رانيتيدين (Ranitidine)',
    'أنتاسيد (Antacid)',
    'سيرترالين (Sertraline)',
    'فلوكسيتين (Fluoxetine)',
    'ديازيبام (Diazepam)',
    'أتورفاستاتين (Atorvastatin)',
    'سيمفاستاتين (Simvastatin)',
    'بريدنيزون (Prednisone)',
    'ديكساميثازون (Dexamethasone)',
    'ثيروكسين (Thyroxine)',
    'ميتوبرولول (Metoprolol)',
    'ترامادول (Tramadol)',
    'مورفين (Morphine)',
    'كوديين (Codeine)',
  ];

  // Known interactions
  final List<Map<String, dynamic>> _knownInteractions = [
    {
      'drug1': 'وارفارين (Warfarin)',
      'drug2': 'أسبرين (Aspirin)',
      'severity': 'خطير',
      'level': 3,
      'desc': 'يزيد خطر النزيف بشكل كبير. تجنب الجمع بينهما.',
    },
    {
      'drug1': 'وارفارين (Warfarin)',
      'drug2': 'إيبوبروفين (Ibuprofen)',
      'severity': 'خطير',
      'level': 3,
      'desc': 'يزيد خطر النزيف المعوي. استخدم بديل آمن.',
    },
    {
      'drug1': 'وارفارين (Warfarin)',
      'drug2': 'أوميبرازول (Omeprazole)',
      'severity': 'متوسط',
      'level': 2,
      'desc': 'قد يزيد تأثير الوارفارين. يحتاج مراقبة INR.',
    },
    {
      'drug1': 'ميتفورمين (Metformin)',
      'drug2': 'إنسولين (Insulin)',
      'severity': 'تحذير',
      'level': 2,
      'desc': 'قد يسبب انخفاض حاد بالسكر. يحتاج تعديل الجرعة.',
    },
    {
      'drug1': 'أسبرين (Aspirin)',
      'drug2': 'إيبوبروفين (Ibuprofen)',
      'severity': 'متوسط',
      'level': 2,
      'desc': 'يقلل من تأثير الأسبرين الوقائي للقلب.',
    },
    {
      'drug1': 'سيرترالين (Sertraline)',
      'drug2': 'ترامادول (Tramadol)',
      'severity': 'خطير',
      'level': 3,
      'desc': 'خطر متلازمة السيروتونين. تجنب تماماً.',
    },
    {
      'drug1': 'فلوكسيتين (Fluoxetine)',
      'drug2': 'ترامادول (Tramadol)',
      'severity': 'خطير',
      'level': 3,
      'desc': 'خطر متلازمة السيروتونين المميتة.',
    },
    {
      'drug1': 'ليزينوبريل (Lisinopril)',
      'drug2': 'أتينولول (Atenolol)',
      'severity': 'تحذير',
      'level': 1,
      'desc': 'قد يسبب انخفاض ضغط مفرط. مراقبة الضغط.',
    },
    {
      'drug1': 'أتورفاستاتين (Atorvastatin)',
      'drug2': 'أزيثروميسين (Azithromycin)',
      'severity': 'متوسط',
      'level': 2,
      'desc': 'يزيد خطر آلام العضلات والتلف العضلي.',
    },
    {
      'drug1': 'ديازيبام (Diazepam)',
      'drug2': 'مورفين (Morphine)',
      'severity': 'خطير',
      'level': 3,
      'desc': 'خطر توقف التنفس. تجنب الجمع بينهما.',
    },
    {
      'drug1': 'ديازيبام (Diazepam)',
      'drug2': 'كوديين (Codeine)',
      'severity': 'خطير',
      'level': 3,
      'desc': 'تثبيط الجهاز العصبي المركزي. خطر مميت.',
    },
    {
      'drug1': 'سيبروفلوكساسين (Ciprofloxacin)',
      'drug2': 'أنتاسيد (Antacid)',
      'severity': 'متوسط',
      'level': 2,
      'desc': 'يقلل امتصاص المضاد الحيوي. فصل 2 ساعة.',
    },
    {
      'drug1': 'ثيروكسين (Thyroxine)',
      'drug2': 'أنتاسيد (Antacid)',
      'severity': 'متوسط',
      'level': 2,
      'desc': 'يقلل امتصاص الثيروكسين. فصل 4 ساعات.',
    },
    {
      'drug1': 'بريدنيزون (Prednisone)',
      'drug2': 'إيبوبروفين (Ibuprofen)',
      'severity': 'متوسط',
      'level': 2,
      'desc': 'يزيد خطر القرحة والنزيف المعوي.',
    },
    {
      'drug1': 'كلوبيدوقرل (Clopidogrel)',
      'drug2': 'أوميبرازول (Omeprazole)',
      'severity': 'متوسط',
      'level': 2,
      'desc': 'يقلل فعالية كلوبيدوقرل. استخدم بانتوبرازول بدلاً.',
    },
  ];

  void _search(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() {
      _searchResults = _allDrugs
          .where(
            (d) =>
                d.toLowerCase().contains(query.toLowerCase()) &&
                !_selectedDrugs.contains(d),
          )
          .toList();
    });
  }

  void _addDrug(String drug) {
    setState(() {
      _selectedDrugs.add(drug);
      _searchResults = [];
      _searchCtrl.clear();
      _checked = false;
      _interactions = [];
    });
  }

  void _removeDrug(String drug) {
    setState(() {
      _selectedDrugs.remove(drug);
      _checked = false;
      _interactions = [];
    });
  }

  void _checkInteractions() {
    HapticFeedback.mediumImpact();
    final found = <Map<String, dynamic>>[];
    for (var inter in _knownInteractions) {
      if (_selectedDrugs.contains(inter['drug1']) &&
          _selectedDrugs.contains(inter['drug2'])) {
        found.add(inter);
      }
    }
    setState(() {
      _interactions = found;
      _checked = true;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 16),
            color: const Color(0xFF1E293B),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('💊', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    const Text(
                      'كاشف تعارض الأدوية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'أضف أدويتك وتحقق من التعارضات',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(120),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withAlpha(15)),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _search,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن دواء...',
                        hintStyle: TextStyle(color: Colors.white.withAlpha(60)),
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.search_rounded,
                          color: Colors.white.withAlpha(60),
                        ),
                      ),
                    ),
                  ),
                  // Search results
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      constraints: const BoxConstraints(maxHeight: 180),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withAlpha(15)),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (_, i) => ListTile(
                          dense: true,
                          title: Text(
                            _searchResults[i],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.add_circle_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          onTap: () => _addDrug(_searchResults[i]),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Selected drugs
                  if (_selectedDrugs.isNotEmpty) ...[
                    Text(
                      'الأدوية المختارة (${_selectedDrugs.length})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withAlpha(180),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedDrugs
                          .map(
                            (d) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primary.withAlpha(40),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    d.split(' ').first,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => _removeDrug(d),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white54,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    // Check button
                    if (_selectedDrugs.length >= 2)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _checkInteractions,
                          icon: const Icon(Icons.shield_rounded, size: 18),
                          label: const Text(
                            'فحص التعارضات',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                  ],

                  if (_selectedDrugs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Text('💊', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            'أضف دوائين على الأقل للفحص',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withAlpha(100),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Results
                  if (_checked) ...[
                    const SizedBox(height: 20),
                    if (_interactions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withAlpha(12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF22C55E).withAlpha(30),
                          ),
                        ),
                        child: const Column(
                          children: [
                            Text('✅', style: TextStyle(fontSize: 40)),
                            SizedBox(height: 8),
                            Text(
                              'لا يوجد تعارضات معروفة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF22C55E),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'الأدوية المختارة آمنة للاستخدام معاً',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF22C55E),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_rounded,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'تم العثور على ${_interactions.length} تعارض',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._interactions.map((inter) => _interactionCard(inter)),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white38,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'هذه المعلومات للتثقيف فقط. استشر طبيبك أو الصيدلي قبل تغيير أي دواء.',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withAlpha(80),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _interactionCard(Map<String, dynamic> inter) {
    final level = inter['level'] as int;
    final color = level >= 3
        ? const Color(0xFFEF4444)
        : level >= 2
        ? const Color(0xFFF59E0B)
        : const Color(0xFF3B82F6);
    final icon = level >= 3
        ? Icons.dangerous_rounded
        : level >= 2
        ? Icons.warning_rounded
        : Icons.info_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  inter['severity'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (inter['drug1'] as String).split(' ').first,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.flash_on_rounded, color: color, size: 18),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (inter['drug2'] as String).split(' ').first,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            inter['desc'] as String,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withAlpha(160),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
