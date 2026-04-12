import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static final LocaleService _instance = LocaleService._();
  factory LocaleService() => _instance;
  LocaleService._();

  Locale _locale = const Locale('ar');
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  TextDirection get direction =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_locale') ?? 'ar';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', locale.languageCode);
    notifyListeners();
  }

  Future<void> toggle() async {
    await setLocale(isArabic ? const Locale('en') : const Locale('ar'));
  }

  String tr(String key) => _strings[_locale.languageCode]?[key] ?? key;

  static const Map<String, Map<String, String>> _strings = {
    'ar': {
      // App
      'app_name': 'ترياق',
      'app_subtitle': 'Smart Health',
      'app_full': 'ترياق — Teryaq Smart Health',

      // Nav
      'home': 'الرئيسية',
      'appointments': 'المواعيد',
      'map': 'الخريطة',
      'more': 'المزيد',
      'teryaq': 'ترياق',

      // Home
      'good_morning': 'صباح الخير',
      'good_afternoon': 'مساء النور',
      'good_evening': 'مساء الخير',
      'vitals': 'المؤشرات الحيوية',
      'normal': 'طبيعي ✓',
      'heart_rate': 'نبض القلب',
      'blood_pressure': 'ضغط الدم',
      'oxygen': 'الأكسجين',
      'temperature': 'الحرارة',
      'ai_agent': 'وكيل ترياق الذكي',
      'ai_desc': 'أطلب أي شيء... حجز، فحوصات، أدوية، طوارئ',
      'online_24': 'متصل 24/7',
      'book_appointment': 'حجز\nموعد',
      'lab_results': 'نتائج\nالفحوصات',
      'my_meds': 'أدويتي',
      'map_btn': 'الخريطة',
      'upcoming_apt': 'الموعد القادم',
      'view_all': 'عرض الكل',
      'book_apt': 'حجز موعد',
      'no_upcoming': 'لا يوجد مواعيد قادمة',
      'confirmed': 'مؤكد ✓',
      'med_tracker': 'تتبع الأدوية',
      'manage': 'إدارة',
      'latest_labs': 'آخر الفحوصات',
      'all': 'الكل',
      'ready': 'جاهز',
      'health_insights': 'رؤى صحية ذكية',

      // More
      'account': 'الحساب',
      'medical_record': 'السجل الطبي',
      'health_wallet': 'المحفظة الصحية',
      'profile': 'الملف الشخصي',
      'family_sharing': 'مشاركة العائلة',
      'notifications': 'الإشعارات',
      'payments': 'المدفوعات',
      'payment_methods': 'طرق الدفع',
      'invoices': 'الفواتير',
      'health_devices': 'الأجهزة الصحية',
      'connected_devices': 'الأجهزة المتصلة',
      'fitness_data': 'بيانات اللياقة',
      'health_services': 'الخدمات الصحية',
      'home_services': 'خدمات منزلية',
      'care_programs': 'برامج الرعاية',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'language_value': 'العربية',
      'theme_mode': 'المظهر',
      'theme_value': 'فاتح',
      'security': 'الأمان والخصوصية',
      'help': 'المساعدة والدعم',
      'about': 'عن التطبيق',
      'logout': 'تسجيل الخروج',
      'logout_confirm': 'هل أنت متأكد من تسجيل الخروج؟',
      'cancel': 'إلغاء',
      'exit': 'خروج',
      'verified': 'حساب موثّق ✓',
      'new_tag': 'جديد',
      'contact_us': 'تواصل معنا: support@teryaq.jo',

      // Login
      'welcome_back': 'مرحباً بعودتك',
      'login': 'تسجيل الدخول',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'continue_id': 'المتابعة برقم الهوية',
      'forgot_password': 'نسيت كلمة المرور؟',
      'national_id': 'رقم الهوية الوطنية',
      'id_login_title': 'الدخول برقم الهوية الوطنية',
      'id_hint': 'أدخل رقم الهوية الوطنية المكون من 10 أرقام',
      'back_to_email': 'العودة للبريد',
      'biometric_prompt': 'سجّل دخولك باستخدام البصمة أو الوجه',

      // AI
      'ai_title': 'وكيل ترياق الذكي',
      'connected': 'متصل الآن',
      'type_question': 'اكتب سؤالك...',
      'type_msg': 'اكتب رسالتك...',
      'speech_unavailable': 'خاصية التحدث غير متاحة',
      'chat_history': 'سجل المحادثات',
      'new_chat': 'جديد',
      'no_prev_chats': 'لا يوجد محادثات سابقة',
      'welcome_agent': 'مرحباً بك في وكيل ترياق',
      'ask_health': 'اسأل أي شيء عن صحتك...',
      'show_on_map': 'عرض على الخريطة',
      'booked_ok': 'تم الحجز بنجاح ✓',
      'book_apt_via_ai': 'احجز موعدك الآن عبر وكيل ترياق الذكي',
      'video_call': 'استشارة فيديو',
      'video_desc': 'استشارة طبية عن بُعد مع أفضل الأطباء',
      'view_results': 'عرض نتائجي',
      'med_reminder': 'تذكير أدويتي',
      'nearest_hospital': 'أقرب مستشفى',
      'open_map': 'افتح الخريطة',
      'emergency_mode': 'وضع الطوارئ',
      'lab_results_more': 'نتائج المختبر',

      // Missing keys
      'health': 'الخدمات الصحية',
      'devices': 'الأجهزة المتصلة',
      'wearables': 'الأجهزة الذكية',
      'payment_history': 'سجل المدفوعات',
      'theme_color': 'لون التطبيق',
      'change_theme': 'تغيير اللون',
      'dashboard': 'لوحة المتابعة',
      'quick_services': 'الخدمات السريعة',
      'next_appointment': 'الموعد القادم',
      'my_medications': 'أدويتي',
      'explore_more': 'استكشف المزيد',
      'emergency': 'طوارئ',
      'search_hint': 'ابحث عن طبيب، خدمة، أو دواء...',
      'ai_advisor': 'مستشار الذكاء الاصطناعي',
      'choose_color': 'اختر لون التطبيق',
    },
    'en': {
      // App
      'app_name': 'Teryaq',
      'app_subtitle': 'Smart Health',
      'app_full': 'Teryaq — Smart Health',

      // Nav
      'home': 'Home',
      'appointments': 'Appointments',
      'map': 'Map',
      'more': 'More',
      'teryaq': 'Teryaq',

      // Home
      'good_morning': 'Good Morning',
      'good_afternoon': 'Good Afternoon',
      'good_evening': 'Good Evening',
      'vitals': 'Vital Signs',
      'normal': 'Normal ✓',
      'heart_rate': 'Heart Rate',
      'blood_pressure': 'Blood Pressure',
      'oxygen': 'Oxygen',
      'temperature': 'Temp',
      'ai_agent': 'Teryaq AI Agent',
      'ai_desc': 'Ask anything... booking, tests, meds, emergency',
      'online_24': 'Online 24/7',
      'book_appointment': 'Book\nAppt',
      'lab_results': 'Lab\nResults',
      'my_meds': 'My Meds',
      'map_btn': 'Map',
      'upcoming_apt': 'Upcoming Appointment',
      'view_all': 'View All',
      'book_apt': 'Book Appointment',
      'no_upcoming': 'No upcoming appointments',
      'confirmed': 'Confirmed ✓',
      'med_tracker': 'Medication Tracker',
      'manage': 'Manage',
      'latest_labs': 'Latest Labs',
      'all': 'All',
      'ready': 'Ready',
      'health_insights': 'Health Insights',

      // More
      'account': 'Account',
      'medical_record': 'Medical Record',
      'health_wallet': 'Health Wallet',
      'profile': 'Profile',
      'family_sharing': 'Family Sharing',
      'notifications': 'Notifications',
      'payments': 'Payments',
      'payment_methods': 'Payment Methods',
      'invoices': 'Invoices',
      'health_devices': 'Health Devices',
      'connected_devices': 'Connected Devices',
      'fitness_data': 'Fitness Data',
      'health_services': 'Health Services',
      'home_services': 'Home Services',
      'care_programs': 'Care Programs',
      'settings': 'Settings',
      'language': 'Language',
      'language_value': 'English',
      'theme_mode': 'Theme',
      'theme_value': 'Light',
      'security': 'Security & Privacy',
      'help': 'Help & Support',
      'about': 'About',
      'logout': 'Logout',
      'logout_confirm': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'exit': 'Logout',
      'verified': 'Verified ✓',
      'new_tag': 'New',
      'contact_us': 'Contact us: support@teryaq.jo',

      // Login
      'welcome_back': 'Welcome Back',
      'login': 'Login',
      'email': 'Email',
      'password': 'Password',
      'continue_id': 'Continue with National ID',
      'forgot_password': 'Forgot Password?',
      'national_id': 'National ID',
      'id_login_title': 'Login with National ID',
      'id_hint': 'Enter your 10-digit National ID',
      'back_to_email': 'Back to Email',
      'biometric_prompt': 'Login with fingerprint or face',

      // AI
      'ai_title': 'Teryaq AI Agent',
      'connected': 'Online',
      'type_question': 'Type your question...',
      'type_msg': 'Type your message...',
      'speech_unavailable': 'Speech not available',
      'chat_history': 'Chat History',
      'new_chat': 'New',
      'no_prev_chats': 'No previous chats',
      'welcome_agent': 'Welcome to Teryaq Agent',
      'ask_health': 'Ask anything about your health...',
      'show_on_map': 'Show on Map',
      'booked_ok': 'Booked Successfully ✓',
      'book_apt_via_ai': 'Book now via Teryaq AI Agent',
      'video_call': 'Video Consultation',
      'video_desc': 'Remote medical consultation with the best doctors',
      'view_results': 'View Results',
      'med_reminder': 'Med Reminders',
      'nearest_hospital': 'Nearest Hospital',
      'open_map': 'Open Map',
      'emergency_mode': 'Emergency',
      'lab_results_more': 'Lab Results',

      // Missing keys
      'health': 'Health Services',
      'devices': 'Connected Devices',
      'wearables': 'Smart Devices',
      'payment_history': 'Payment History',
      'theme_color': 'App Color',
      'change_theme': 'Change Color',
      'dashboard': 'Dashboard',
      'quick_services': 'Quick Services',
      'next_appointment': 'Next Appointment',
      'my_medications': 'My Medications',
      'explore_more': 'Explore More',
      'emergency': 'Emergency',
      'search_hint': 'Search for a doctor, service, or medication...',
      'ai_advisor': 'AI Health Advisor',
      'choose_color': 'Choose App Color',
    },
  };
}
