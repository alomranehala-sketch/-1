import 'package:flutter/material.dart';
import '../theme.dart';

class LabResultsScreen extends StatefulWidget {
  const LabResultsScreen({super.key});
  @override
  State<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends State<LabResultsScreen> {
  int _sortMode = 0; // 0=latest, 1=oldest, 2=by type
  int _selectedCategory = 0;

  final _categories = const ['الكل', 'دم', 'كلى', 'كبد', 'سكر', 'دهون'];

  final _results = [
    _Lab('تعداد الدم الكامل', 'CBC', 'دم', '2026-04-05', [
      _LabItem('خضاب الدم', '14.2', 'g/dL', '12-17', 'normal'),
      _LabItem('كريات الدم البيضاء', '11.8', 'K/uL', '4.5-11', 'high'),
      _LabItem('الصفائح', '245', 'K/uL', '150-400', 'normal'),
      _LabItem('كريات الدم الحمراء', '4.9', 'M/uL', '4.5-5.5', 'normal'),
    ]),
    _Lab('وظائف الكلى', 'KFT', 'كلى', '2026-04-03', [
      _LabItem('الكرياتينين', '1.1', 'mg/dL', '0.6-1.2', 'normal'),
      _LabItem('البولينا', '42', 'mg/dL', '10-50', 'normal'),
      _LabItem('حمض اليوريك', '7.8', 'mg/dL', '3.5-7.2', 'high'),
    ]),
    _Lab('وظائف الكبد', 'LFT', 'كبد', '2026-04-01', [
      _LabItem('ALT', '28', 'U/L', '7-56', 'normal'),
      _LabItem('AST', '22', 'U/L', '10-40', 'normal'),
      _LabItem('البيليروبين', '1.8', 'mg/dL', '0.1-1.2', 'high'),
    ]),
    _Lab('سكر الدم', 'Glucose', 'سكر', '2026-03-28', [
      _LabItem('سكر صائم', '108', 'mg/dL', '70-100', 'high'),
      _LabItem('HbA1c', '5.9', '%', '<5.7', 'high'),
    ]),
    _Lab('الدهون', 'Lipid Panel', 'دهون', '2026-03-25', [
      _LabItem('الكوليسترول', '195', 'mg/dL', '<200', 'normal'),
      _LabItem('LDL', '128', 'mg/dL', '<100', 'high'),
      _LabItem('HDL', '52', 'mg/dL', '>40', 'normal'),
      _LabItem('الدهون الثلاثية', '145', 'mg/dL', '<150', 'normal'),
    ]),
    _Lab('فيتامين D', 'Vit D', 'دم', '2026-03-20', [
      _LabItem('فيتامين D', '18', 'ng/mL', '30-100', 'critical'),
    ]),
  ];

  List<_Lab> get _filtered {
    var list = _selectedCategory == 0
        ? _results
        : _results
              .where((r) => r.category == _categories[_selectedCategory])
              .toList();
    if (_sortMode == 1) {
      list = List.from(list)..sort((a, b) => a.date.compareTo(b.date));
    } else if (_sortMode == 2) {
      list = List.from(list)..sort((a, b) => a.category.compareTo(b.category));
    }
    return list;
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
            _buildCategoryFilter(),
            Expanded(child: _buildResultsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double topPad) {
    final abnormalCount = _results.fold<int>(
      0,
      (sum, r) => sum + r.items.where((i) => i.status != 'normal').length,
    );
    return Container(
      padding: EdgeInsets.fromLTRB(8, topPad + 8, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withAlpha(40), width: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
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
                  'نتائج المختبر',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              PopupMenuButton<int>(
                onSelected: (v) => setState(() => _sortMode = v),
                icon: const Icon(
                  Icons.sort_rounded,
                  color: AppColors.textMedium,
                ),
                itemBuilder: (_) => [
                  _sortItem(0, 'الأحدث أولاً', Icons.arrow_downward_rounded),
                  _sortItem(1, 'الأقدم أولاً', Icons.arrow_upward_rounded),
                  _sortItem(2, 'حسب النوع', Icons.category_rounded),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 48),
              _statChip('${_results.length}', 'فحص', AppColors.primary),
              const SizedBox(width: 8),
              _statChip('$abnormalCount', 'غير طبيعي', AppColors.error),
              const SizedBox(width: 8),
              _statChip(_results.first.date, 'آخر فحص', AppColors.accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withAlpha(180)),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<int> _sortItem(int val, String text, IconData icon) {
    return PopupMenuItem(
      value: val,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: _sortMode == val ? AppColors.primary : AppColors.textLight,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: _sortMode == val
                  ? FontWeight.w700
                  : FontWeight.normal,
              color: _sortMode == val ? AppColors.primary : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SizedBox(
        height: 34,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          itemBuilder: (_, i) {
            final sel = _selectedCategory == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = i),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: sel ? null : Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: Text(
                  _categories[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : AppColors.textMedium,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    final results = _filtered;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: results.length,
      itemBuilder: (_, i) => _buildLabCard(results[i]),
    );
  }

  Widget _buildLabCard(_Lab lab) {
    final hasAbnormal = lab.items.any((i) => i.status != 'normal');
    final hasCritical = lab.items.any((i) => i.status == 'critical');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: hasCritical
              ? AppColors.error.withAlpha(50)
              : hasAbnormal
              ? AppColors.warning.withAlpha(40)
              : AppColors.border.withAlpha(40),
        ),
        boxShadow: AppShadows.card,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _categoryColor(lab.category).withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _categoryIcon(lab.category),
              size: 20,
              color: _categoryColor(lab.category),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  lab.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              if (hasCritical)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'حرج',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.error,
                    ),
                  ),
                )
              else if (hasAbnormal)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'مرتفع',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.warning,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            '${lab.code} • ${lab.date}',
            style: TextStyle(fontSize: 10, color: AppColors.textLight),
          ),
          children: lab.items.map((item) => _buildLabItem(item)).toList(),
        ),
      ),
    );
  }

  Widget _buildLabItem(_LabItem item) {
    final color = item.status == 'normal'
        ? AppColors.success
        : item.status == 'critical'
        ? AppColors.error
        : AppColors.warning;
    final icon = item.status == 'normal'
        ? Icons.check_circle_rounded
        : item.status == 'critical'
        ? Icons.error_rounded
        : Icons.warning_rounded;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(fontSize: 12, color: AppColors.textDark),
            ),
          ),
          Text(
            item.value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            item.unit,
            style: TextStyle(fontSize: 10, color: AppColors.textLight),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.range,
              style: TextStyle(fontSize: 9, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'دم':
        return const Color(0xFFEF4444);
      case 'كلى':
        return const Color(0xFF3B82F6);
      case 'كبد':
        return const Color(0xFF8B5CF6);
      case 'سكر':
        return const Color(0xFFF59E0B);
      case 'دهون':
        return const Color(0xFF10B981);
      default:
        return AppColors.primary;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'دم':
        return Icons.bloodtype_rounded;
      case 'كلى':
        return Icons.water_drop_rounded;
      case 'كبد':
        return Icons.health_and_safety_rounded;
      case 'سكر':
        return Icons.monitor_heart_rounded;
      case 'دهون':
        return Icons.favorite_rounded;
      default:
        return Icons.science_rounded;
    }
  }
}

class _Lab {
  final String name, code, category, date;
  final List<_LabItem> items;
  const _Lab(this.name, this.code, this.category, this.date, this.items);
}

class _LabItem {
  final String name, value, unit, range, status;
  const _LabItem(this.name, this.value, this.unit, this.range, this.status);
}
