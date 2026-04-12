import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

// ═══════════════════════════════════════════════════════════════
//  TERYAQ SMART HEALTH — Medication Delivery Screen
//  In-app pharmacy delivery: order from prescription
//  Track delivery, reorder, and schedule chronic meds
// ═══════════════════════════════════════════════════════════════

class MedicationDeliveryScreen extends StatefulWidget {
  const MedicationDeliveryScreen({super.key});
  @override
  State<MedicationDeliveryScreen> createState() =>
      _MedicationDeliveryScreenState();
}

class _MedicationDeliveryScreenState extends State<MedicationDeliveryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<_CartItem> _cart = [];

  final _medications = <_MedItem>[
    _MedItem(
      'ميتفورمين 500mg',
      'أقراص للسكري',
      4.5,
      'سكري',
      Icons.bloodtype_rounded,
      const Color(0xFFF59E0B),
      true,
      60,
    ),
    _MedItem(
      'إنسولين نوفومكس',
      'حقن إنسولين',
      22.0,
      'سكري',
      Icons.vaccines_rounded,
      const Color(0xFFEF4444),
      true,
      1,
    ),
    _MedItem(
      'أملوديبين 5mg',
      'ضغط الدم',
      3.2,
      'قلب',
      Icons.favorite_rounded,
      const Color(0xFFEF4444),
      true,
      30,
    ),
    _MedItem(
      'أتورفاستاتين 20mg',
      'خفض الكوليسترول',
      8.5,
      'قلب',
      Icons.monitor_heart_rounded,
      const Color(0xFFEF4444),
      false,
      30,
    ),
    _MedItem(
      'أوميبرازول 20mg',
      'المعدة والحموضة',
      2.8,
      'معدة',
      Icons.medication_liquid_rounded,
      const Color(0xFF8B5CF6),
      false,
      14,
    ),
    _MedItem(
      'فيتامين D3 1000IU',
      'مكمل غذائي',
      5.0,
      'مكملات',
      Icons.wb_sunny_rounded,
      const Color(0xFFF59E0B),
      false,
      30,
    ),
    _MedItem(
      'أموكسيسيلين 500mg',
      'مضاد حيوي',
      3.5,
      'مضادات حيوية',
      Icons.medication_rounded,
      const Color(0xFF3B82F6),
      true,
      21,
    ),
    _MedItem(
      'سيتريزين 10mg',
      'مضاد حساسية',
      1.8,
      'حساسية',
      Icons.air_rounded,
      const Color(0xFF10B981),
      false,
      10,
    ),
  ];

  final _orders = <_Order>[
    _Order(
      'طلب #2206',
      'متفورمين + فيتامين D',
      'في الطريق',
      '45 دقيقة',
      14.5,
      const Color(0xFFF59E0B),
    ),
    _Order(
      'طلب #2194',
      'أملوديبين + أوميبرازول',
      'تم التسليم',
      '4 أبريل',
      6.0,
      const Color(0xFF10B981),
    ),
    _Order(
      'طلب #2178',
      'إنسولين نوفومكس',
      'تم التسليم',
      '28 مارس',
      22.0,
      const Color(0xFF10B981),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addToCart(_MedItem item) {
    HapticFeedback.lightImpact();
    setState(() {
      final idx = _cart.indexWhere((c) => c.item.name == item.name);
      if (idx >= 0) {
        _cart[idx] = _CartItem(_cart[idx].item, _cart[idx].qty + 1);
      } else {
        _cart.add(_CartItem(item, 1));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة ${item.name} للسلة'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double get _cartTotal => _cart.fold(0, (s, c) => s + c.item.price * c.qty);

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
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textLight,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              tabs: const [
                Tab(text: 'الأدوية'),
                Tab(text: 'وصفاتي'),
                Tab(text: 'طلباتي'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMedicationsBrowse(),
                  _buildPrescriptions(),
                  _buildOrders(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _cart.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: _showCart,
                backgroundColor: AppColors.primary,
                icon: const Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  'السلة (${_cart.length}) — ${_cartTotal.toStringAsFixed(1)} د.أ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : null,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'صيدلية ترياق',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'توصيل خلال 45-90 دقيقة',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_shipping_rounded,
                  color: AppColors.success,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'متاح الآن',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsBrowse() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _medications.length,
            itemBuilder: (_, i) => _MedCard(
              item: _medications[i],
              onAdd: () => _addToCart(_medications[i]),
              cartQty: _cart
                  .firstWhere(
                    (c) => c.item.name == _medications[i].name,
                    orElse: () => _CartItem(_medications[i], 0),
                  )
                  .qty,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withAlpha(60)),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.search_rounded,
                color: AppColors.textLight,
                size: 20,
              ),
            ),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث عن دواء...',
                  hintStyle: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PrescriptionCard(
          doctor: 'د. سارة المعاني',
          date: '2026-04-01',
          meds: ['ميتفورمين 500mg × 2/يوم', 'أملوديبين 5mg × 1/يوم'],
          onOrder: () => _showOrderConfirm(),
        ),
        const SizedBox(height: 12),
        _PrescriptionCard(
          doctor: 'د. محمد الزعبي',
          date: '2026-03-15',
          meds: ['فيتامين D3 1000IU × 1/يوم', 'أوميبرازول 20mg × 1/يوم'],
          onOrder: () => _showOrderConfirm(),
        ),
      ],
    );
  }

  Widget _buildOrders() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final order = _orders[i];
        return _OrderCard(order: order);
      },
    );
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CartSheet(
        cart: _cart,
        total: _cartTotal,
        onOrder: (addr) {
          Navigator.pop(context);
          setState(() => _cart.clear());
          _showOrderConfirm();
        },
        onRemove: (item) {
          setState(() => _cart.removeWhere((c) => c.item.name == item.name));
        },
      ),
    );
  }

  void _showOrderConfirm() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('✅', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('تم تأكيد الطلب'),
          ],
        ),
        content: const Text(
          'طلبك قيد التجهيز!\nسيصلك الدواء خلال 45-90 دقيقة.\nستتلقى إشعار عند مغادرة الطرد من الصيدلية.',
          style: TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────

class _MedCard extends StatelessWidget {
  final _MedItem item;
  final VoidCallback onAdd;
  final int cartQty;
  const _MedCard({
    required this.item,
    required this.onAdd,
    required this.cartQty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cartQty > 0
              ? AppColors.primary.withAlpha(60)
              : AppColors.border.withAlpha(40),
          width: cartQty > 0 ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: item.color.withAlpha(6),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: item.color.withAlpha(15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                Center(child: Icon(item.icon, color: item.color, size: 36)),
                if (item.isPrescription)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'وصفة',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.price.toStringAsFixed(1)} د.أ',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      GestureDetector(
                        onTap: onAdd,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final String doctor;
  final String date;
  final List<String> meds;
  final VoidCallback onOrder;
  const _PrescriptionCard({
    required this.doctor,
    required this.date,
    required this.meds,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(30), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...meds.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    m,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: const Icon(Icons.local_shipping_rounded, size: 16),
              label: const Text(
                'اطلب هذه الأدوية',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final _Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final isActive = order.status == 'في الطريق';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppColors.warning.withAlpha(60)
              : AppColors.border.withAlpha(40),
          width: isActive ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: order.statusColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isActive
                  ? Icons.local_shipping_rounded
                  : Icons.check_circle_rounded,
              color: order.statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.id,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  order.meds,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: order.statusColor.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: order.statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.eta,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartSheet extends StatelessWidget {
  final List<_CartItem> cart;
  final double total;
  final Function(String) onOrder;
  final Function(_MedItem) onRemove;
  final _addressController = TextEditingController();

  _CartSheet({
    required this.cart,
    required this.total,
    required this.onOrder,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.shopping_cart_rounded, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'سلة التسوق',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ...cart.map(
                  (c) => ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: c.item.color.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(c.item.icon, color: c.item.color, size: 18),
                    ),
                    title: Text(
                      c.item.name,
                      style: const TextStyle(fontSize: 13),
                    ),
                    subtitle: Text(
                      '${c.item.price.toStringAsFixed(1)} د.أ × ${c.qty}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                      ),
                      onPressed: () => onRemove(c.item),
                    ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'عنوان التوصيل',
                      prefixIcon: const Icon(Icons.location_on_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundAlt,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'المجموع:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${total.toStringAsFixed(2)} د.أ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onOrder(_addressController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'تأكيد الطلب والدفع',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data models ────────────────────────────────────────────────

class _MedItem {
  final String name;
  final String description;
  final double price;
  final String category;
  final IconData icon;
  final Color color;
  final bool isPrescription;
  final int daysSupply;
  const _MedItem(
    this.name,
    this.description,
    this.price,
    this.category,
    this.icon,
    this.color,
    this.isPrescription,
    this.daysSupply,
  );
}

class _CartItem {
  final _MedItem item;
  final int qty;
  const _CartItem(this.item, this.qty);
}

class _Order {
  final String id;
  final String meds;
  final String status;
  final String eta;
  final double total;
  final Color statusColor;
  const _Order(
    this.id,
    this.meds,
    this.status,
    this.eta,
    this.total,
    this.statusColor,
  );
}
