// ═══════════════════════════════════════════════════════════════
//  TERYAQ SMART HEALTH — Dev API Server
//  Lightweight Express server with real Jordanian hospital data
//  Run: cd dev-server && npm install && node server.js
// ═══════════════════════════════════════════════════════════════

const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

const PORT = 3000;
const JWT_SECRET = 'teryaq-dev-secret-2026';

// ═══════════════════════════════════════════════════════════════
// IN-MEMORY DATABASE
// ═══════════════════════════════════════════════════════════════

const db = {
  users: [],
  hospitals: [],
  doctors: [],
  appointments: [],
  medications: [],
  labResults: [],
  notifications: [],
  healthRecords: [],
  // HMS
  patients: [],
  beds: [],
  triageQueue: [],
  alerts: [],
  feedback: [],
  emsIncoming: [],
  // MOH
  mohStats: {},
};

// ── Seed Real Jordanian Hospitals ──────────────────────────────
db.hospitals = [
  {
    id: 'h_001', name: 'مستشفى الأردن', nameEn: 'Jordan Hospital',
    type: 'private', phone: '06-5607071', email: 'info@jordanhospital.com',
    governorate: 'عمّان', city: 'الشميساني',
    address: 'شارع الملكة نور، الشميساني، عمّان',
    lat: 31.9580, lng: 35.8650,
    totalBeds: 350, availableBeds: 42, erCapacity: 40, currentErLoad: 18,
    specialties: ['طوارئ', 'قلب وشرايين', 'عظام', 'أطفال', 'نسائية وتوليد', 'باطنية', 'جراحة عامة', 'عيون', 'أنف وأذن وحنجرة', 'مسالك بولية'],
    operatingHours: { open: '00:00', close: '23:59', is24h: true },
    insurance: ['التأمين الصحي الحكومي', 'ميدنت', 'غلوب مد', 'الشرق العربي'],
    rating: 4.8, totalReviews: 2340, isActive: true,
    availability: 'open', waitTimeMinutes: 12,
  },
  {
    id: 'h_002', name: 'مستشفى الجامعة الأردنية', nameEn: 'Jordan University Hospital',
    type: 'university', phone: '06-5353444', email: 'info@juh.jo',
    governorate: 'عمّان', city: 'الجبيهة',
    address: 'الجامعة الأردنية، الجبيهة، عمّان',
    lat: 32.0194, lng: 35.8744,
    totalBeds: 600, availableBeds: 55, erCapacity: 60, currentErLoad: 35,
    specialties: ['طوارئ', 'جراحة', 'نسائية وتوليد', 'باطنية', 'أعصاب', 'أورام', 'قلب', 'عظام', 'أطفال', 'جلدية', 'نفسية'],
    operatingHours: { open: '00:00', close: '23:59', is24h: true },
    insurance: ['التأمين الصحي الحكومي', 'تأمين الجامعة', 'ميدنت'],
    rating: 4.7, totalReviews: 3100, isActive: true,
    availability: 'open', waitTimeMinutes: 25,
  },
  {
    id: 'h_003', name: 'مدينة الملك حسين الطبية', nameEn: 'King Hussein Medical City',
    type: 'military', phone: '06-5804804', email: 'info@khmc.jo',
    governorate: 'عمّان', city: 'الجبيهة',
    address: 'طريق الملكة رانيا، عمّان',
    lat: 31.9773, lng: 35.8639,
    totalBeds: 1200, availableBeds: 80, erCapacity: 100, currentErLoad: 72,
    specialties: ['طوارئ', 'أورام', 'أعصاب', 'مسالك بولية', 'جراحة قلب مفتوح', 'زراعة أعضاء', 'حروق', 'تأهيل'],
    operatingHours: { open: '00:00', close: '23:59', is24h: true },
    insurance: ['التأمين العسكري', 'التأمين الصحي الحكومي'],
    rating: 4.6, totalReviews: 4200, isActive: true,
    availability: 'busy', waitTimeMinutes: 45,
  },
  {
    id: 'h_004', name: 'مستشفى البشير', nameEn: 'Al-Bashir Hospital',
    type: 'public', phone: '06-4771511', email: 'info@bashir.gov.jo',
    governorate: 'عمّان', city: 'أشرفية',
    address: 'شارع الملك فيصل، الأشرفية، عمّان',
    lat: 31.9500, lng: 35.9350,
    totalBeds: 800, availableBeds: 35, erCapacity: 80, currentErLoad: 55,
    specialties: ['طوارئ', 'حروق', 'عيون', 'أنف وأذن وحنجرة', 'باطنية', 'جراحة', 'عظام', 'نسائية'],
    operatingHours: { open: '00:00', close: '23:59', is24h: true },
    insurance: ['التأمين الصحي الحكومي'],
    rating: 4.4, totalReviews: 5600, isActive: true,
    availability: 'open', waitTimeMinutes: 18,
  },
  {
    id: 'h_005', name: 'مستشفى الأمير حمزة', nameEn: 'Prince Hamzah Hospital',
    type: 'public', phone: '06-5039444', email: 'info@phh.gov.jo',
    governorate: 'عمّان', city: 'ماركا الشمالية',
    address: 'شارع الحرية، ماركا الشمالية، عمّان',
    lat: 31.9980, lng: 35.8700,
    totalBeds: 500, availableBeds: 60, erCapacity: 50, currentErLoad: 22,
    specialties: ['طوارئ', 'باطنية', 'جلدية', 'أطفال', 'نسائية', 'عظام'],
    operatingHours: { open: '00:00', close: '23:59', is24h: true },
    insurance: ['التأمين الصحي الحكومي', 'ميدنت'],
    rating: 4.5, totalReviews: 2800, isActive: true,
    availability: 'open', waitTimeMinutes: 15,
  },
  {
    id: 'h_006', name: 'المركز العربي الطبي', nameEn: 'Arab Medical Center',
    type: 'private', phone: '06-5921199', email: 'info@amc.jo',
    governorate: 'عمّان', city: 'جبل عمّان',
    address: 'شارع الملكة رانيا، جبل عمّان',
    lat: 31.9620, lng: 35.8570,
    totalBeds: 200, availableBeds: 28, erCapacity: 25, currentErLoad: 10,
    specialties: ['قلب وأوعية دموية', 'جراحة تجميل', 'باطنية', 'عظام', 'مسالك بولية'],
    operatingHours: { open: '00:00', close: '23:59', is24h: true },
    insurance: ['ميدنت', 'غلوب مد', 'الشرق العربي', 'MetLife'],
    rating: 4.7, totalReviews: 1900, isActive: true,
    availability: 'open', waitTimeMinutes: 8,
  },
  {
    id: 'h_007', name: 'مستشفى الخالدي', nameEn: 'Al-Khalidi Hospital',
    type: 'private', phone: '06-4644281', email: 'info@alkhaldi.jo',
    governorate: 'عمّان', city: 'جبل عمّان',
    address: 'شارع ابن خلدون، جبل عمّان',
    lat: 31.9530, lng: 35.8900,
    totalBeds: 250, availableBeds: 15, erCapacity: 30, currentErLoad: 22,
    specialties: ['طوارئ', 'عظام', 'نسائية وتوليد', 'أطفال', 'باطنية', 'جراحة عامة'],
    operatingHours: { open: '00:00', close: '23:59', is24h: true },
    insurance: ['ميدنت', 'غلوب مد', 'التأمين الصحي الحكومي'],
    rating: 4.5, totalReviews: 2100, isActive: true,
    availability: 'busy', waitTimeMinutes: 35,
  },
  {
    id: 'h_008', name: 'مستشفى الإسراء', nameEn: 'Al-Isra Hospital',
    type: 'private', phone: '06-5000222', email: 'info@israhospital.com',
    governorate: 'عمّان', city: 'طريق المطار',
    address: 'طريق المطار، عمّان',
    lat: 31.9420, lng: 35.8700,
    totalBeds: 180, availableBeds: 0, erCapacity: 20, currentErLoad: 20,
    specialties: ['باطنية', 'جراحة عامة', 'عظام'],
    operatingHours: { open: '08:00', close: '20:00', is24h: false },
    insurance: ['ميدنت', 'غلوب مد'],
    rating: 4.3, totalReviews: 950, isActive: true,
    availability: 'closed', waitTimeMinutes: 0,
  },
  {
    id: 'h_009', name: 'مستشفى ابن الهيثم', nameEn: 'Ibn Al-Haytham Hospital',
    type: 'private', phone: '06-5688888', email: 'info@ibnalhaytham.jo',
    governorate: 'عمّان', city: 'جبل الحسين',
    address: 'شارع خليل السالم، جبل الحسين',
    lat: 31.9630, lng: 35.9050,
    totalBeds: 150, availableBeds: 20, erCapacity: 15, currentErLoad: 5,
    specialties: ['عيون', 'ليزك', 'شبكية', 'ماء أبيض', 'ماء أزرق'],
    operatingHours: { open: '08:00', close: '20:00', is24h: false },
    insurance: ['ميدنت', 'غلوب مد', 'الشرق العربي'],
    rating: 4.4, totalReviews: 1500, isActive: true,
    availability: 'open', waitTimeMinutes: 10,
  },
  {
    id: 'h_010', name: 'مستشفى الاستقلال', nameEn: 'Al-Istiklal Hospital',
    type: 'military', phone: '06-4004040', email: 'info@istiklal.mil.jo',
    governorate: 'عمّان', city: 'أبو نصير',
    address: 'أبو نصير، عمّان',
    lat: 31.9700, lng: 35.9400,
    totalBeds: 400, availableBeds: 45, erCapacity: 40, currentErLoad: 15,
    specialties: ['طوارئ', 'أشعة', 'مختبر', 'باطنية', 'عظام', 'جراحة'],
    operatingHours: { open: '00:00', close: '23:59', is24h: true },
    insurance: ['التأمين العسكري', 'التأمين الصحي الحكومي'],
    rating: 4.2, totalReviews: 1800, isActive: true,
    availability: 'open', waitTimeMinutes: 20,
  },
  {
    id: 'h_011', name: 'مستشفى الملك المؤسس عبدالله', nameEn: 'King Abdullah University Hospital',
    type: 'university', phone: '02-7200600', email: 'info@kauh.jo',
    governorate: 'إربد', city: 'الرمثا',
    address: 'جامعة العلوم والتكنولوجيا، إربد',
    lat: 32.4957, lng: 35.9900,
    totalBeds: 680, availableBeds: 70, erCapacity: 50, currentErLoad: 25,
    specialties: ['طوارئ', 'قلب', 'أورام', 'أعصاب', 'جراحة', 'أطفال', 'نسائية', 'باطنية'],
    operatingHours: { open: '00:00', close: '23:59', is24h: true },
    insurance: ['التأمين الصحي الحكومي', 'تأمين الجامعة'],
    rating: 4.6, totalReviews: 2600, isActive: true,
    availability: 'open', waitTimeMinutes: 30,
  },
  {
    id: 'h_012', name: 'مستشفى الأمير هاشم العسكري', nameEn: 'Prince Hashem Military Hospital',
    type: 'military', phone: '05-3566566', email: 'info@phmh.mil.jo',
    governorate: 'الزرقاء', city: 'الزرقاء',
    address: 'الزرقاء، الأردن',
    lat: 32.0727, lng: 36.0880,
    totalBeds: 350, availableBeds: 40, erCapacity: 35, currentErLoad: 18,
    specialties: ['طوارئ', 'باطنية', 'جراحة', 'عظام', 'أطفال'],
    operatingHours: { open: '00:00', close: '23:59', is24h: true },
    insurance: ['التأمين العسكري'],
    rating: 4.3, totalReviews: 1200, isActive: true,
    availability: 'open', waitTimeMinutes: 22,
  },
];

// ── Seed Real Doctors ──────────────────────────────────────────
db.doctors = [
  { id: 'd_001', name: 'د. أحمد الزعبي', nameEn: 'Dr. Ahmad Al-Zoubi', specialization: 'قلب وشرايين', hospitalId: 'h_001', hospitalName: 'مستشفى الأردن', phone: '0791234001', rating: 4.9, yearsExp: 18, fee: 40, available: true, schedule: { sun: ['09:00-14:00'], mon: ['09:00-14:00'], tue: ['09:00-14:00'], wed: ['09:00-14:00'], thu: ['09:00-12:00'] } },
  { id: 'd_002', name: 'د. سارة المعاني', nameEn: 'Dr. Sara Al-Maani', specialization: 'عيون', hospitalId: 'h_001', hospitalName: 'مستشفى الأردن', phone: '0791234002', rating: 4.8, yearsExp: 12, fee: 35, available: true, schedule: { sun: ['10:00-15:00'], mon: ['10:00-15:00'], wed: ['10:00-15:00'] } },
  { id: 'd_003', name: 'د. محمد الحوراني', nameEn: 'Dr. Mohammad Al-Hourani', specialization: 'عظام', hospitalId: 'h_001', hospitalName: 'مستشفى الأردن', phone: '0791234003', rating: 4.7, yearsExp: 15, fee: 45, available: true, schedule: { sun: ['08:00-13:00'], tue: ['08:00-13:00'], thu: ['08:00-13:00'] } },
  { id: 'd_004', name: 'د. لينا عبدالله', nameEn: 'Dr. Lina Abdullah', specialization: 'نسائية وتوليد', hospitalId: 'h_002', hospitalName: 'مستشفى الجامعة الأردنية', phone: '0791234004', rating: 4.9, yearsExp: 20, fee: 30, available: true, schedule: { sun: ['09:00-14:00'], mon: ['09:00-14:00'], tue: ['09:00-14:00'], wed: ['09:00-14:00'] } },
  { id: 'd_005', name: 'د. خالد النسور', nameEn: 'Dr. Khaled Al-Nsour', specialization: 'أعصاب', hospitalId: 'h_003', hospitalName: 'مدينة الملك حسين الطبية', phone: '0791234005', rating: 4.8, yearsExp: 22, fee: 50, available: true, schedule: { sun: ['08:00-12:00'], tue: ['08:00-12:00'], thu: ['08:00-12:00'] } },
  { id: 'd_006', name: 'د. رنا حداد', nameEn: 'Dr. Rana Haddad', specialization: 'أطفال', hospitalId: 'h_001', hospitalName: 'مستشفى الأردن', phone: '0791234006', rating: 4.7, yearsExp: 10, fee: 30, available: true, schedule: { sun: ['14:00-19:00'], mon: ['14:00-19:00'], wed: ['14:00-19:00'] } },
  { id: 'd_007', name: 'د. عمر المصري', nameEn: 'Dr. Omar Al-Masri', specialization: 'باطنية', hospitalId: 'h_004', hospitalName: 'مستشفى البشير', phone: '0791234007', rating: 4.5, yearsExp: 14, fee: 20, available: true, schedule: { sun: ['08:00-14:00'], mon: ['08:00-14:00'], tue: ['08:00-14:00'], wed: ['08:00-14:00'], thu: ['08:00-14:00'] } },
  { id: 'd_008', name: 'د. نور القاسم', nameEn: 'Dr. Nour Al-Qasem', specialization: 'جلدية', hospitalId: 'h_005', hospitalName: 'مستشفى الأمير حمزة', phone: '0791234008', rating: 4.6, yearsExp: 8, fee: 25, available: true, schedule: { sun: ['10:00-15:00'], tue: ['10:00-15:00'], thu: ['10:00-15:00'] } },
  { id: 'd_009', name: 'د. فراس الشوبكي', nameEn: 'Dr. Firas Al-Shobaki', specialization: 'جراحة تجميل', hospitalId: 'h_006', hospitalName: 'المركز العربي الطبي', phone: '0791234009', rating: 4.8, yearsExp: 16, fee: 60, available: true, schedule: { mon: ['09:00-13:00'], wed: ['09:00-13:00'] } },
  { id: 'd_010', name: 'د. هبة أبو عودة', nameEn: 'Dr. Heba Abu Oda', specialization: 'أورام', hospitalId: 'h_003', hospitalName: 'مدينة الملك حسين الطبية', phone: '0791234010', rating: 4.9, yearsExp: 25, fee: 55, available: true, schedule: { sun: ['08:00-13:00'], mon: ['08:00-13:00'], tue: ['08:00-13:00'] } },
  { id: 'd_011', name: 'د. ياسر الطراونة', nameEn: 'Dr. Yaser Al-Tarawneh', specialization: 'مسالك بولية', hospitalId: 'h_006', hospitalName: 'المركز العربي الطبي', phone: '0791234011', rating: 4.6, yearsExp: 13, fee: 40, available: true, schedule: { sun: ['14:00-18:00'], tue: ['14:00-18:00'], thu: ['14:00-18:00'] } },
  { id: 'd_012', name: 'د. دانا الكيلاني', nameEn: 'Dr. Dana Al-Kilani', specialization: 'أنف وأذن وحنجرة', hospitalId: 'h_004', hospitalName: 'مستشفى البشير', phone: '0791234012', rating: 4.5, yearsExp: 9, fee: 25, available: true, schedule: { sun: ['09:00-14:00'], mon: ['09:00-14:00'], wed: ['09:00-14:00'] } },
];

// ── Seed Users ─────────────────────────────────────────────────
// Citizen — ID: 123
db.users.push({
  id: 'usr_001',
  name: 'فاطمة أحمد الخالدي', nameEn: 'Fatima Ahmad Al-Khalidi',
  nationalId: '123', email: 'fatima@masar.jo', phone: '+962791234567',
  password: '123', gender: 'أنثى', birthDate: '1995-03-15',
  bloodType: 'A+', height: 165, weight: 58,
  insuranceProvider: 'التأمين الصحي الحكومي', insuranceId: 'INS-2024-78432',
  emergencyContact: 'أحمد الخالدي', emergencyPhone: '+962797654321',
  allergies: ['بنسلين', 'سلفا'],
  chronicConditions: ['حساسية موسمية'],
  role: 'citizen',
});
// Doctor — ID: 1234
db.users.push({
  id: 'usr_doc_001', name: 'د. أحمد الزعبي', nameEn: 'Dr. Ahmad Al-Zoubi',
  nationalId: '1234', email: 'ahmad@hospital.jo', phone: '+962791234001',
  password: '1234', gender: 'ذكر', birthDate: '1980-05-10',
  role: 'doctor', hospitalId: 'h_001', department: 'قلب وشرايين', doctorId: 'd_001',
});
// MOH — ID: 12345
db.users.push({
  id: 'usr_moh_001', name: 'وزارة الصحة', nameEn: 'Ministry of Health',
  nationalId: '12345', email: 'admin@moh.gov.jo', phone: '+96265001',
  password: '12345', gender: 'مؤسسة', birthDate: '1950-01-01',
  role: 'moh', department: 'إدارة',
});
// Nurse — ID: 123456
db.users.push({
  id: 'usr_nurse_001', name: 'نور الحسن', nameEn: 'Nour Al-Hasan',
  nationalId: '123456', email: 'nour@hospital.jo', phone: '+962791234020',
  password: '123456', gender: 'أنثى', birthDate: '1992-08-20',
  role: 'nurse', hospitalId: 'h_001', department: 'طوارئ',
});
// Reception — ID: 1234567
db.users.push({
  id: 'usr_rec_001', name: 'ليلى العمري', nameEn: 'Layla Al-Omari',
  nationalId: '1234567', email: 'layla@hospital.jo', phone: '+962791234030',
  password: '1234567', gender: 'أنثى', birthDate: '1990-03-12',
  role: 'reception', hospitalId: 'h_001',
});

// ── Seed Appointments ──────────────────────────────────────────
db.appointments.push(
  {
    id: 'apt_001', patientId: 'usr_001',
    hospital: 'مستشفى الأردن', hospitalId: 'h_001',
    department: 'عيون', doctor: 'د. سارة المعاني', doctorId: 'd_002',
    date: '2026-04-15', time: '10:30', status: 'confirmed',
    type: 'فحص دوري', reason: 'فحص نظر دوري',
  },
  {
    id: 'apt_002', patientId: 'usr_001',
    hospital: 'مستشفى البشير', hospitalId: 'h_004',
    department: 'باطنية', doctor: 'د. عمر المصري', doctorId: 'd_007',
    date: '2026-04-22', time: '09:00', status: 'pending',
    type: 'مراجعة', reason: 'متابعة فحوصات',
  },
  {
    id: 'apt_003', patientId: 'usr_001',
    hospital: 'مستشفى الأردن', hospitalId: 'h_001',
    department: 'قلب وشرايين', doctor: 'د. أحمد الزعبي', doctorId: 'd_001',
    date: '2026-03-10', time: '11:00', status: 'completed',
    type: 'فحص', reason: 'تخطيط قلب',
  },
);

// ── Seed Medications ───────────────────────────────────────────
db.medications.push(
  {
    id: 'med_001', patientId: 'usr_001',
    name: 'أموكسيسيلين', nameEn: 'Amoxicillin',
    dose: '500mg', frequency: 'مرتين يومياً', duration: '7 أيام',
    remaining: 5, total: 14, nextDose: '08:00 م',
    prescribedBy: 'د. عمر المصري', hospital: 'مستشفى البشير',
    startDate: '2026-04-05', endDate: '2026-04-12',
    instructions: 'بعد الأكل مع كوب ماء كامل',
    active: true, icon: 'capsule',
  },
  {
    id: 'med_002', patientId: 'usr_001',
    name: 'فيتامين D3', nameEn: 'Vitamin D3',
    dose: '2000 IU', frequency: 'مرة يومياً', duration: 'مستمر',
    remaining: 22, total: 30, nextDose: '09:00 ص',
    prescribedBy: 'د. عمر المصري', hospital: 'مستشفى البشير',
    startDate: '2026-03-01', endDate: null,
    instructions: 'مع وجبة تحتوي على دهون',
    active: true, icon: 'pill',
  },
  {
    id: 'med_003', patientId: 'usr_001',
    name: 'لوراتادين', nameEn: 'Loratadine',
    dose: '10mg', frequency: 'عند الحاجة', duration: 'حسب الحاجة',
    remaining: 8, total: 10, nextDose: null,
    prescribedBy: 'د. نور القاسم', hospital: 'مستشفى الأمير حمزة',
    startDate: '2026-02-15', endDate: null,
    instructions: 'عند ظهور أعراض الحساسية',
    active: true, icon: 'tablet',
  },
  {
    id: 'med_004', patientId: 'usr_001',
    name: 'أوميبرازول', nameEn: 'Omeprazole',
    dose: '20mg', frequency: 'مرة يومياً', duration: '30 يوم',
    remaining: 0, total: 30, nextDose: null,
    prescribedBy: 'د. عمر المصري', hospital: 'مستشفى البشير',
    startDate: '2026-02-01', endDate: '2026-03-02',
    instructions: 'قبل الفطور بنصف ساعة',
    active: false, icon: 'capsule',
  },
);

// ── Seed Lab Results ───────────────────────────────────────────
db.labResults.push(
  {
    id: 'lab_001', patientId: 'usr_001',
    name: 'فحص الدم الشامل CBC', date: '2026-03-28',
    status: 'ready', hospital: 'مستشفى الأردن',
    orderedBy: 'د. أحمد الزعبي',
    results: [
      { name: 'الهيموغلوبين', value: '13.2', unit: 'g/dL', normal: '12-16', status: 'normal' },
      { name: 'كريات الدم البيضاء', value: '7.8', unit: '10³/µL', normal: '4-11', status: 'normal' },
      { name: 'الصفائح الدموية', value: '245', unit: '10³/µL', normal: '150-400', status: 'normal' },
      { name: 'الهيماتوكريت', value: '39.5', unit: '%', normal: '36-46', status: 'normal' },
      { name: 'MCV', value: '88', unit: 'fL', normal: '80-100', status: 'normal' },
    ],
  },
  {
    id: 'lab_002', patientId: 'usr_001',
    name: 'فحص السكر التراكمي HbA1c', date: '2026-03-28',
    status: 'ready', hospital: 'مستشفى الأردن',
    orderedBy: 'د. أحمد الزعبي',
    results: [
      { name: 'HbA1c', value: '5.4', unit: '%', normal: '4-5.6', status: 'normal' },
      { name: 'سكر الصيام', value: '95', unit: 'mg/dL', normal: '70-100', status: 'normal' },
    ],
  },
  {
    id: 'lab_003', patientId: 'usr_001',
    name: 'وظائف الكلى', date: '2026-03-28',
    status: 'ready', hospital: 'مستشفى الأردن',
    orderedBy: 'د. أحمد الزعبي',
    results: [
      { name: 'الكرياتينين', value: '0.8', unit: 'mg/dL', normal: '0.6-1.2', status: 'normal' },
      { name: 'اليوريا BUN', value: '14', unit: 'mg/dL', normal: '7-20', status: 'normal' },
      { name: 'eGFR', value: '105', unit: 'mL/min', normal: '>90', status: 'normal' },
    ],
  },
  {
    id: 'lab_004', patientId: 'usr_001',
    name: 'وظائف الغدة الدرقية', date: '2026-02-15',
    status: 'ready', hospital: 'مستشفى البشير',
    orderedBy: 'د. عمر المصري',
    results: [
      { name: 'TSH', value: '2.1', unit: 'mIU/L', normal: '0.4-4.0', status: 'normal' },
      { name: 'T4 الحر', value: '1.2', unit: 'ng/dL', normal: '0.8-1.8', status: 'normal' },
    ],
  },
);

// ── Seed Notifications ─────────────────────────────────────────
db.notifications.push(
  { id: 'n_001', userId: 'usr_001', type: 'appointment', title: 'تذكير بموعد', body: 'لديك موعد مع د. سارة المعاني يوم 15/4 الساعة 10:30 ص في مستشفى الأردن', time: new Date(Date.now() - 3600000).toISOString(), read: false, severity: 'info' },
  { id: 'n_002', userId: 'usr_001', type: 'lab', title: 'نتائج فحص جاهزة', body: 'نتائج فحص الدم الشامل CBC جاهزة — اطلع عليها الآن', time: new Date(Date.now() - 10800000).toISOString(), read: false, severity: 'info' },
  { id: 'n_003', userId: 'usr_001', type: 'medication', title: 'تذكير بالدواء', body: 'حان وقت أموكسيسيلين 500mg — الجرعة المسائية', time: new Date(Date.now() - 18000000).toISOString(), read: true, severity: 'warning' },
  { id: 'n_004', userId: 'usr_001', type: 'system', title: 'تحديث معلومات التأمين', body: 'يرجى تحديث بيانات التأمين الصحي قبل نهاية الشهر', time: new Date(Date.now() - 86400000).toISOString(), read: true, severity: 'info' },
);

// ── Seed Health Record ─────────────────────────────────────────
db.healthRecords.push({
  userId: 'usr_001',
  bloodType: 'A+', height: 165, weight: 58, bmi: 21.3,
  allergies: ['بنسلين', 'سلفا'],
  chronicConditions: ['حساسية موسمية'],
  diagnoses: [
    { date: '2026-03-10', diagnosis: 'ارتفاع ضغط طفيف', doctor: 'د. أحمد الزعبي', hospital: 'مستشفى الأردن' },
    { date: '2025-06-15', diagnosis: 'التهاب الجيوب الأنفية', doctor: 'د. دانا الكيلاني', hospital: 'مستشفى البشير' },
    { date: '2025-03-20', diagnosis: 'نقص فيتامين D', doctor: 'د. عمر المصري', hospital: 'مستشفى البشير' },
  ],
  vitals: {
    heartRate: 72, bloodPressure: '120/78',
    temperature: 36.8, oxygenSaturation: 98,
    lastUpdated: '2026-04-08',
  },
});

// ── Seed HMS Patients (checked-in today) ───────────────────────
db.patients = [
  { id: 'p_001', name: 'عمر خالد', age: 45, gender: 'ذكر', nationalId: '9901234001', qrCode: 'QR-001', triageLevel: 'red', status: 'in-treatment', department: 'طوارئ', doctor: 'د. أحمد الزعبي', room: 'ER-3', bed: 'B-12', vitals: { hr: 110, bp: '90/60', temp: 39.2, o2: 92 }, checkinTime: '2026-04-09T07:30:00', complaint: 'ألم صدري حاد وضيق تنفس', notes: 'ECG abnormal, troponin pending' },
  { id: 'p_002', name: 'فاطمة سالم', age: 32, gender: 'أنثى', nationalId: '9901234002', qrCode: 'QR-002', triageLevel: 'yellow', status: 'waiting', department: 'باطنية', doctor: 'د. عمر المصري', room: null, bed: null, vitals: { hr: 88, bp: '130/85', temp: 37.8, o2: 97 }, checkinTime: '2026-04-09T08:15:00', complaint: 'صداع مزمن وغثيان', notes: '' },
  { id: 'p_003', name: 'محمد أنس', age: 28, gender: 'ذكر', nationalId: '9901234003', qrCode: 'QR-003', triageLevel: 'green', status: 'waiting', department: 'عظام', doctor: 'د. محمد الحوراني', room: null, bed: null, vitals: { hr: 72, bp: '120/78', temp: 36.8, o2: 99 }, checkinTime: '2026-04-09T08:45:00', complaint: 'ألم ركبة بعد رياضة', notes: '' },
  { id: 'p_004', name: 'سارة ياسين', age: 55, gender: 'أنثى', nationalId: '9901234004', qrCode: 'QR-004', triageLevel: 'red', status: 'in-surgery', department: 'جراحة', doctor: 'د. فراس الشوبكي', room: 'OR-2', bed: 'B-24', vitals: { hr: 95, bp: '140/90', temp: 37.1, o2: 96 }, checkinTime: '2026-04-09T06:00:00', complaint: 'التهاب زائدة حاد', notes: 'Emergency appendectomy in progress' },
  { id: 'p_005', name: 'ريم حسام', age: 8, gender: 'أنثى', nationalId: '9901234005', qrCode: 'QR-005', triageLevel: 'yellow', status: 'in-treatment', department: 'أطفال', doctor: 'د. رنا حداد', room: 'PED-1', bed: 'B-05', vitals: { hr: 100, bp: '100/65', temp: 38.5, o2: 97 }, checkinTime: '2026-04-09T09:00:00', complaint: 'حرارة مرتفعة 3 أيام', notes: 'Blood culture taken' },
  { id: 'p_006', name: 'أحمد نبيل', age: 67, gender: 'ذكر', nationalId: '9901234006', qrCode: 'QR-006', triageLevel: 'yellow', status: 'observation', department: 'قلب وشرايين', doctor: 'د. أحمد الزعبي', room: 'CCU-2', bed: 'B-30', vitals: { hr: 65, bp: '150/95', temp: 36.9, o2: 95 }, checkinTime: '2026-04-09T05:30:00', complaint: 'خفقان وارتفاع ضغط', notes: 'Under 24h monitoring' },
  { id: 'p_007', name: 'لمى فريد', age: 24, gender: 'أنثى', nationalId: '9901234007', qrCode: 'QR-007', triageLevel: 'green', status: 'discharged', department: 'عيون', doctor: 'د. سارة المعاني', room: null, bed: null, vitals: { hr: 70, bp: '115/72', temp: 36.6, o2: 99 }, checkinTime: '2026-04-09T07:00:00', complaint: 'فحص نظر دوري', notes: 'Completed, follow up in 6 months' },
  { id: 'p_008', name: 'يوسف عبدالرحمن', age: 40, gender: 'ذكر', nationalId: '9901234008', qrCode: 'QR-008', triageLevel: 'green', status: 'waiting', department: 'جلدية', doctor: 'د. نور القاسم', room: null, bed: null, vitals: { hr: 75, bp: '118/76', temp: 36.7, o2: 99 }, checkinTime: '2026-04-09T09:30:00', complaint: 'طفح جلدي', notes: '' },
];

// ── Seed Beds ──────────────────────────────────────────────────
db.beds = [
  { id: 'B-01', ward: 'طوارئ', room: 'ER-1', status: 'available', type: 'standard' },
  { id: 'B-02', ward: 'طوارئ', room: 'ER-1', status: 'available', type: 'standard' },
  { id: 'B-03', ward: 'طوارئ', room: 'ER-2', status: 'occupied', type: 'standard', patientId: 'p_009' },
  { id: 'B-05', ward: 'أطفال', room: 'PED-1', status: 'occupied', type: 'pediatric', patientId: 'p_005' },
  { id: 'B-06', ward: 'أطفال', room: 'PED-1', status: 'available', type: 'pediatric' },
  { id: 'B-10', ward: 'باطنية', room: 'MED-1', status: 'available', type: 'standard' },
  { id: 'B-11', ward: 'باطنية', room: 'MED-2', status: 'occupied', type: 'standard', patientId: 'p_010' },
  { id: 'B-12', ward: 'طوارئ', room: 'ER-3', status: 'occupied', type: 'monitored', patientId: 'p_001' },
  { id: 'B-20', ward: 'جراحة', room: 'SURG-1', status: 'available', type: 'post-op' },
  { id: 'B-21', ward: 'جراحة', room: 'SURG-1', status: 'cleaning', type: 'post-op' },
  { id: 'B-24', ward: 'جراحة', room: 'OR-2', status: 'occupied', type: 'operating', patientId: 'p_004' },
  { id: 'B-30', ward: 'قلب', room: 'CCU-2', status: 'occupied', type: 'ICU', patientId: 'p_006' },
  { id: 'B-31', ward: 'قلب', room: 'CCU-1', status: 'available', type: 'ICU' },
  { id: 'B-32', ward: 'قلب', room: 'CCU-1', status: 'reserved', type: 'ICU' },
  { id: 'B-40', ward: 'نسائية', room: 'OB-1', status: 'available', type: 'maternity' },
  { id: 'B-41', ward: 'نسائية', room: 'OB-1', status: 'available', type: 'maternity' },
];

// ── Seed Alerts ────────────────────────────────────────────────
db.alerts = [
  { id: 'alert_001', type: 'critical', title: 'مريض حرج — ER-3', body: 'عمر خالد: تروبونين مرتفع، احتمال MI', time: new Date(Date.now() - 1800000).toISOString(), acknowledged: false, patientId: 'p_001' },
  { id: 'alert_002', type: 'bed', title: 'سرير ICU شاغر', body: 'CCU-1 — B-31 متاح للحالات الحرجة', time: new Date(Date.now() - 3600000).toISOString(), acknowledged: true },
  { id: 'alert_003', type: 'ems', title: '🚑 إسعاف قادم', body: 'حادث سير — وصول خلال 8 دقائق — 2 مصابين', time: new Date(Date.now() - 300000).toISOString(), acknowledged: false },
];

// ── Seed EMS Incoming ──────────────────────────────────────────
db.emsIncoming = [
  { id: 'ems_001', ambulanceId: 'AMB-12', eta: 8, priority: 'red', patients: 2, description: 'حادث سير — كسور متعددة + إصابة رأس', vitals: { hr: 120, bp: '85/55', o2: 88 }, lat: 31.965, lng: 35.880, dispatchTime: new Date(Date.now() - 600000).toISOString() },
  { id: 'ems_002', ambulanceId: 'AMB-07', eta: 15, priority: 'yellow', patients: 1, description: 'سيدة حامل — تقلصات مبكرة', vitals: { hr: 95, bp: '130/85', o2: 97 }, lat: 31.950, lng: 35.900, dispatchTime: new Date(Date.now() - 900000).toISOString() },
];

// ── Seed Feedback ──────────────────────────────────────────────
db.feedback = [
  { id: 'fb_001', patientId: 'p_007', patientName: 'لمى فريد', doctor: 'د. سارة المعاني', department: 'عيون', rating: 3, comment: 'خدمة ممتازة', time: new Date(Date.now() - 7200000).toISOString() },
  { id: 'fb_002', patientId: 'p_003', patientName: 'محمد أنس', doctor: 'د. محمد الحوراني', department: 'عظام', rating: 2, comment: 'وقت انتظار طويل', time: new Date(Date.now() - 86400000).toISOString() },
];

// ═══════════════════════════════════════════════════════════════
// AUTH MIDDLEWARE
// ═══════════════════════════════════════════════════════════════

function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'No token' });
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch {
    return res.status(401).json({ error: 'Invalid token' });
  }
}

// ═══════════════════════════════════════════════════════════════
// AUTH ROUTES
// ═══════════════════════════════════════════════════════════════

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  const user = db.users.find(u => u.email === email) || db.users[0];
  const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '30d' });
  res.json({ success: true, token, user: sanitizeUser(user) });
});

app.post('/api/auth/national-id', (req, res) => {
  const { nationalId } = req.body;
  const user = db.users.find(u => u.nationalId === nationalId);
  if (!user) {
    return res.status(401).json({ success: false, error: 'رقم الهوية غير مسجل في النظام' });
  }
  const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, { expiresIn: '30d' });
  res.json({ success: true, token, user: sanitizeUser(user), role: user.role });
});

function sanitizeUser(u) {
  const { password, ...safe } = u;
  return { ...safe, avatarInitial: u.name[0], role: u.role || 'citizen' };
}

// ═══════════════════════════════════════════════════════════════
// USER ROUTES
// ═══════════════════════════════════════════════════════════════

app.get('/api/user/profile', authMiddleware, (req, res) => {
  const user = db.users.find(u => u.id === req.userId) || db.users[0];
  res.json(sanitizeUser(user));
});

// ═══════════════════════════════════════════════════════════════
// HOSPITAL ROUTES
// ═══════════════════════════════════════════════════════════════

app.get('/api/hospitals', (req, res) => {
  const { governorate, specialty, search } = req.query;
  let results = db.hospitals.filter(h => h.isActive);
  if (governorate) results = results.filter(h => h.governorate === governorate);
  if (specialty) results = results.filter(h => h.specialties.some(s => s.includes(specialty)));
  if (search) results = results.filter(h => h.name.includes(search) || h.nameEn.toLowerCase().includes(search.toLowerCase()));
  res.json(results);
});

app.get('/api/hospitals/:id', (req, res) => {
  const h = db.hospitals.find(h => h.id === req.params.id);
  if (!h) return res.status(404).json({ error: 'Hospital not found' });
  const doctors = db.doctors.filter(d => d.hospitalId === h.id);
  res.json({ ...h, doctors });
});

// ═══════════════════════════════════════════════════════════════
// DOCTOR ROUTES
// ═══════════════════════════════════════════════════════════════

app.get('/api/doctors', (req, res) => {
  const { specialization, hospitalId, search } = req.query;
  let results = db.doctors.filter(d => d.available);
  if (specialization) results = results.filter(d => d.specialization.includes(specialization));
  if (hospitalId) results = results.filter(d => d.hospitalId === hospitalId);
  if (search) results = results.filter(d => d.name.includes(search) || d.nameEn.toLowerCase().includes(search.toLowerCase()));
  res.json(results);
});

app.get('/api/doctors/:id', (req, res) => {
  const d = db.doctors.find(d => d.id === req.params.id);
  if (!d) return res.status(404).json({ error: 'Doctor not found' });
  res.json(d);
});

app.get('/api/doctors/:id/slots', (req, res) => {
  const doctor = db.doctors.find(d => d.id === req.params.id);
  if (!doctor) return res.status(404).json({ error: 'Doctor not found' });

  const { date } = req.query;
  const targetDate = date ? new Date(date) : new Date();
  const days = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
  const dayKey = days[targetDate.getDay()];
  const schedule = doctor.schedule[dayKey] || [];

  const slots = [];
  for (const range of schedule) {
    const [start, end] = range.split('-');
    let hour = parseInt(start.split(':')[0]);
    const endHour = parseInt(end.split(':')[0]);
    while (hour < endHour) {
      const timeStr = `${hour.toString().padStart(2, '0')}:00`;
      const booked = db.appointments.some(a =>
        a.doctorId === doctor.id &&
        a.date === targetDate.toISOString().split('T')[0] &&
        a.time === timeStr &&
        a.status !== 'cancelled'
      );
      slots.push({ time: timeStr, available: !booked });
      hour++;
    }
  }
  res.json({ doctor: doctor.name, date: targetDate.toISOString().split('T')[0], slots });
});

// ═══════════════════════════════════════════════════════════════
// APPOINTMENT ROUTES
// ═══════════════════════════════════════════════════════════════

app.get('/api/health/appointments', authMiddleware, (req, res) => {
  const apts = db.appointments.filter(a => a.patientId === req.userId);
  res.json(apts);
});

app.post('/api/health/appointments', authMiddleware, (req, res) => {
  const { hospitalId, department, doctorId, date, time, reason, type } = req.body;

  const hospital = db.hospitals.find(h => h.id === hospitalId);
  const doctor = db.doctors.find(d => d.id === doctorId);

  // Check slot availability
  const conflict = db.appointments.some(a =>
    a.doctorId === doctorId && a.date === date && a.time === time && a.status !== 'cancelled'
  );
  if (conflict) {
    return res.status(409).json({ success: false, error: 'هذا الموعد محجوز مسبقاً. يرجى اختيار وقت آخر.' });
  }

  const apt = {
    id: `apt_${uuidv4().slice(0, 8)}`,
    patientId: req.userId,
    hospital: hospital?.name || department,
    hospitalId,
    department: department || doctor?.specialization,
    doctor: doctor?.name || 'غير محدد',
    doctorId: doctorId || null,
    date, time,
    status: 'confirmed',
    type: type || 'موعد جديد',
    reason: reason || '',
    createdAt: new Date().toISOString(),
  };
  db.appointments.push(apt);

  // Add notification
  db.notifications.push({
    id: `n_${uuidv4().slice(0, 8)}`,
    userId: req.userId, type: 'appointment',
    title: 'تم حجز موعد جديد ✅',
    body: `تم حجز موعدك مع ${apt.doctor} في ${apt.hospital} يوم ${date} الساعة ${time}`,
    time: new Date().toISOString(), read: false, severity: 'info',
  });

  res.status(201).json({ success: true, appointment: apt });
});

app.delete('/api/health/appointments/:id', authMiddleware, (req, res) => {
  const apt = db.appointments.find(a => a.id === req.params.id && a.patientId === req.userId);
  if (!apt) return res.status(404).json({ error: 'Appointment not found' });
  apt.status = 'cancelled';
  res.json({ success: true });
});

// ═══════════════════════════════════════════════════════════════
// HEALTH RECORDS, LAB RESULTS, MEDICATIONS
// ═══════════════════════════════════════════════════════════════

app.get('/api/health/records', authMiddleware, (req, res) => {
  const record = db.healthRecords.find(r => r.userId === req.userId);
  res.json(record || {});
});

app.get('/api/health/lab-results', authMiddleware, (req, res) => {
  const results = db.labResults.filter(r => r.patientId === req.userId);
  res.json(results);
});

app.get('/api/health/medications', authMiddleware, (req, res) => {
  const meds = db.medications.filter(m => m.patientId === req.userId);
  res.json(meds);
});

// ═══════════════════════════════════════════════════════════════
// NOTIFICATIONS
// ═══════════════════════════════════════════════════════════════

app.get('/api/notifications', authMiddleware, (req, res) => {
  const notes = db.notifications.filter(n => n.userId === req.userId);
  notes.sort((a, b) => new Date(b.time) - new Date(a.time));
  res.json(notes);
});

app.patch('/api/notifications/:id/read', authMiddleware, (req, res) => {
  const note = db.notifications.find(n => n.id === req.params.id);
  if (note) note.read = true;
  res.json({ success: true });
});

// ═══════════════════════════════════════════════════════════════
// EMERGENCY
// ═══════════════════════════════════════════════════════════════

app.post('/api/emergency/trigger', authMiddleware, (req, res) => {
  const { latitude, longitude } = req.body;
  // Find nearest hospital with ER
  let nearest = null;
  let minDist = Infinity;
  for (const h of db.hospitals) {
    if (h.availability === 'closed') continue;
    const dist = Math.sqrt(Math.pow(h.lat - latitude, 2) + Math.pow(h.lng - longitude, 2));
    if (dist < minDist) { minDist = dist; nearest = h; }
  }
  res.json({
    success: true,
    nearestHospital: nearest?.name || 'مستشفى الأردن',
    distance: (minDist * 111).toFixed(1) + ' كم',
    responseTime: `${Math.round(minDist * 111 / 30 * 60)} دقائق`,
    emergencyPhone: '911',
  });
});

// ═══════════════════════════════════════════════════════════════
// AI AGENT — Smart Booking & Context-Aware
// ═══════════════════════════════════════════════════════════════

app.post('/api/ai/chat', authMiddleware, async (req, res) => {
  const { messages, userLocation } = req.body;
  const user = db.users.find(u => u.id === req.userId) || db.users[0];
  const userAppointments = db.appointments.filter(a => a.patientId === user.id && a.status !== 'cancelled');
  const userMeds = db.medications.filter(m => m.patientId === user.id && m.active);

  // Build context for AI
  const hospitalsContext = db.hospitals.map(h =>
    `${h.name} (${h.id}): ${h.specialties.join('، ')} — ${h.availability === 'open' ? 'مفتوح' : h.availability === 'busy' ? 'مزدحم' : 'مغلق'} — وقت الانتظار: ${h.waitTimeMinutes} دقيقة — التقييم: ${h.rating}`
  ).join('\n');

  const doctorsContext = db.doctors.map(d =>
    `${d.name} (${d.id}): ${d.specialization} — ${d.hospitalName} — رسوم: ${d.fee} دينار — تقييم: ${d.rating}`
  ).join('\n');

  const appointmentsContext = userAppointments.map(a =>
    `${a.hospital} — ${a.department} — ${a.doctor} — ${a.date} ${a.time} — ${a.status}`
  ).join('\n');

  const medsContext = userMeds.map(m =>
    `${m.name} ${m.dose} — ${m.frequency} — متبقي: ${m.remaining}/${m.total}`
  ).join('\n');

  const systemPrompt = `أنت "وكيل ترياق الذكي" — المساعد الصحي الذكي في تطبيق ترياق للصحة الذكية (Teryaq Smart Health) في الأردن.

═══ هويتك ═══
اسمك: وكيل ترياق الذكي
أنت تعمل داخل تطبيق صحي أردني حكومي
أنت تعمل 24/7 بدون توقف — مساعد ذكي ذاتي متكامل
تجيب دائماً بالعربية بلهجة أردنية مهنية ولبقة
تفهم اللهجة الأردنية: "بدي"، "شو"، "كيفك"، "وين"، "هاد"، "ليش"، "إنشالله"
ترد باللهجة الأردنية: "إن شاء الله"، "تكرم عينك"، "على راسي"، "ما تقلق"، "الحمد لله"

═══ بيانات المستخدم الحالي ═══
الاسم: ${user.name}
فصيلة الدم: ${user.bloodType}
الحساسية: ${user.allergies.join('، ')}
الأمراض المزمنة: ${user.chronicConditions.join('، ') || 'لا يوجد'}
التأمين: ${user.insuranceProvider}

═══ المواعيد الحالية ═══
${appointmentsContext || 'لا يوجد مواعيد'}

═══ الأدوية الحالية ═══
${medsContext || 'لا يوجد أدوية'}

═══ المستشفيات المتوفرة ═══
${hospitalsContext}

═══ الأطباء المتوفرون ═══
${doctorsContext}

═══ قدراتك (مهم جداً) ═══

1. **حجز المواعيد**: عندما يطلب المستخدم حجز موعد (بأي صياغة: "بدي أحجز"، "سجلّي موعد"، "عندكم دكتور.."، "بدي أراجع.."):
   - اسأله عن التخصص إذا لم يحدد
   - اقترح المستشفيات والأطباء المتوفرين
   - اقترح أوقات متاحة
   - عندما يوافق، أرسل JSON بالشكل التالي في نهاية ردك (في سطر لوحده):
   <<<BOOK_APPOINTMENT:{"hospitalId":"h_xxx","doctorId":"d_xxx","department":"...","date":"YYYY-MM-DD","time":"HH:00","reason":"...","type":"موعد جديد"}>>>

2. **إعادة جدولة المواعيد**: إذا طلب تغيير موعد:
   <<<RESCHEDULE_APPOINTMENT:{"appointmentId":"apt_xxx","newDate":"YYYY-MM-DD","newTime":"HH:00"}>>>

3. **إلغاء المواعيد**: إذا طلب إلغاء موعد:
   <<<CANCEL_APPOINTMENT:{"appointmentId":"apt_xxx"}>>>

4. **عرض المواعيد**: اعرض مواعيده الحالية من البيانات أعلاه

5. **الأدوية والتذكيرات**: ذكّره بأدويته ومواعيدها وتحقق من التزامه

6. **المستشفيات**: ساعده بإيجاد مستشفى مناسب حسب التخصص

7. **كشف الأنماط الصحية (Pattern Detection)**: 
   - راقب الأعراض المتكررة وحذّر المستخدم
   - إذا ذكر ألم متكرر أو أعراض مشابهة → اقترح فحص شامل
   - حلّل تاريخ المواعيد وأنماط الأمراض

8. **تصنيف مبدئي (Pre-Triage)**:
   - إذا وصف أعراض طوارئ (ألم صدر، ضيق تنفس، نزيف) → وجّهه فوراً للطوارئ
   - إذا وصف أعراض عادية → اقترح القسم المناسب

═══ أسلوبك ═══
- كن مختصراً ومفيداً وودوداً بلهجة أردنية
- اقترح الحجز بدون ما يطلب إذا كان السياق مناسب (مثلاً: سأل عن دكتور → اقترح "بدك أحجزلك؟")
- لا تنس تنوّه على مراجعة الطبيب للأمور الحرجة
- استخدم إيموجي بشكل معتدل
- عند الحالات الحرجة كن حازماً وسريعاً: "رجاءً روح الطوارئ فوراً! 🚨"
- قدّم نصائح وقائية بشكل طبيعي في المحادثة`;

  try {
    const aiMessages = [
      { role: 'system', content: systemPrompt },
      ...messages,
    ];

    const aiRes = await fetch('https://api.x.ai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.GROK_API_KEY || 'xai-efHzSTNn1olwhZlZ37LjwpCtZyeAxGpOeiLGsczkagHQLPzOT6kbpbhu3z7ArYKF4YUr3A1eZZ8yHLfe'}`,
      },
      body: JSON.stringify({
        model: 'grok-3-latest',
        messages: aiMessages,
        max_tokens: 800,
        temperature: 0.7,
      }),
    });

    const aiData = await aiRes.json();
    let reply = aiData.choices?.[0]?.message?.content || 'عذراً، حدث خطأ تقني.';

    // ── Process AI booking commands ──
    const actions = [];

    const bookMatch = reply.match(/<<<BOOK_APPOINTMENT:(.*?)>>>/s);
    if (bookMatch) {
      try {
        const bookData = JSON.parse(bookMatch[1]);
        const hospital = db.hospitals.find(h => h.id === bookData.hospitalId);
        const doctor = db.doctors.find(d => d.id === bookData.doctorId);

        const conflict = db.appointments.some(a =>
          a.doctorId === bookData.doctorId && a.date === bookData.date &&
          a.time === bookData.time && a.status !== 'cancelled'
        );

        if (!conflict && hospital && doctor) {
          const newApt = {
            id: `apt_${uuidv4().slice(0, 8)}`,
            patientId: user.id,
            hospital: hospital.name, hospitalId: bookData.hospitalId,
            department: bookData.department || doctor.specialization,
            doctor: doctor.name, doctorId: bookData.doctorId,
            date: bookData.date, time: bookData.time,
            status: 'confirmed',
            type: bookData.type || 'موعد جديد',
            reason: bookData.reason || '',
            createdAt: new Date().toISOString(),
          };
          db.appointments.push(newApt);

          db.notifications.push({
            id: `n_${uuidv4().slice(0, 8)}`,
            userId: user.id, type: 'appointment',
            title: 'تم حجز موعد جديد ✅',
            body: `تم حجز موعدك مع ${doctor.name} في ${hospital.name} يوم ${bookData.date} الساعة ${bookData.time}`,
            time: new Date().toISOString(), read: false, severity: 'info',
          });

          actions.push({ type: 'appointment_booked', appointment: newApt });
        } else if (conflict) {
          reply = reply.replace(bookMatch[0], '') + '\n\n⚠️ عذراً، هذا الموعد محجوز مسبقاً. هل تريد وقت آخر؟';
        }
      } catch (e) {
        console.error('Failed to parse booking:', e);
      }
      reply = reply.replace(bookMatch[0], '');
    }

    const cancelMatch = reply.match(/<<<CANCEL_APPOINTMENT:(.*?)>>>/s);
    if (cancelMatch) {
      try {
        const cancelData = JSON.parse(cancelMatch[1]);
        const apt = db.appointments.find(a => a.id === cancelData.appointmentId);
        if (apt) {
          apt.status = 'cancelled';
          actions.push({ type: 'appointment_cancelled', appointmentId: apt.id });
        }
      } catch (e) {
        console.error('Failed to parse cancel:', e);
      }
      reply = reply.replace(cancelMatch[0], '');
    }

    res.json({ reply: reply.trim(), actions });

  } catch (err) {
    console.error('AI error:', err);
    res.status(500).json({ reply: 'عذراً، حدث خطأ في الاتصال. حاول مرة أخرى.', actions: [] });
  }
});

// ═══════════════════════════════════════════════════════════════
// HMS — Hospital Management System API
// ═══════════════════════════════════════════════════════════════

// Patients
app.get('/api/hms/patients', authMiddleware, (req, res) => {
  const { status, triage, department } = req.query;
  let results = [...db.patients];
  if (status) results = results.filter(p => p.status === status);
  if (triage) results = results.filter(p => p.triageLevel === triage);
  if (department) results = results.filter(p => p.department === department);
  results.sort((a, b) => {
    const order = { red: 0, yellow: 1, green: 2 };
    return (order[a.triageLevel] ?? 3) - (order[b.triageLevel] ?? 3);
  });
  res.json(results);
});

app.get('/api/hms/patients/:id', authMiddleware, (req, res) => {
  const p = db.patients.find(p => p.id === req.params.id);
  if (!p) return res.status(404).json({ error: 'Patient not found' });
  res.json(p);
});

app.post('/api/hms/patients/checkin', authMiddleware, (req, res) => {
  const { name, age, gender, nationalId, complaint } = req.body;
  const patient = {
    id: `p_${uuidv4().slice(0, 6)}`,
    name, age, gender, nationalId,
    qrCode: `QR-${uuidv4().slice(0, 6).toUpperCase()}`,
    triageLevel: 'green', status: 'waiting',
    department: null, doctor: null, room: null, bed: null,
    vitals: { hr: 0, bp: '0/0', temp: 0, o2: 0 },
    checkinTime: new Date().toISOString(),
    complaint: complaint || '', notes: '',
  };
  db.patients.push(patient);
  res.status(201).json({ success: true, patient });
});

app.patch('/api/hms/patients/:id/triage', authMiddleware, (req, res) => {
  const p = db.patients.find(p => p.id === req.params.id);
  if (!p) return res.status(404).json({ error: 'Patient not found' });
  const { triageLevel, department, doctor, vitals, notes } = req.body;
  if (triageLevel) p.triageLevel = triageLevel;
  if (department) p.department = department;
  if (doctor) p.doctor = doctor;
  if (vitals) p.vitals = { ...p.vitals, ...vitals };
  if (notes) p.notes = notes;
  res.json({ success: true, patient: p });
});

app.patch('/api/hms/patients/:id/status', authMiddleware, (req, res) => {
  const p = db.patients.find(p => p.id === req.params.id);
  if (!p) return res.status(404).json({ error: 'Patient not found' });
  p.status = req.body.status;
  if (req.body.room) p.room = req.body.room;
  if (req.body.bed) p.bed = req.body.bed;
  res.json({ success: true, patient: p });
});

// Beds
app.get('/api/hms/beds', authMiddleware, (req, res) => {
  const { ward } = req.query;
  let results = [...db.beds];
  if (ward) results = results.filter(b => b.ward === ward);
  const summary = {
    total: results.length,
    available: results.filter(b => b.status === 'available').length,
    occupied: results.filter(b => b.status === 'occupied').length,
    reserved: results.filter(b => b.status === 'reserved').length,
    cleaning: results.filter(b => b.status === 'cleaning').length,
  };
  res.json({ beds: results, summary });
});

app.patch('/api/hms/beds/:id', authMiddleware, (req, res) => {
  const bed = db.beds.find(b => b.id === req.params.id);
  if (!bed) return res.status(404).json({ error: 'Bed not found' });
  Object.assign(bed, req.body);
  res.json({ success: true, bed });
});

// Alerts
app.get('/api/hms/alerts', authMiddleware, (req, res) => {
  const sorted = [...db.alerts].sort((a, b) => new Date(b.time) - new Date(a.time));
  res.json(sorted);
});

app.patch('/api/hms/alerts/:id/acknowledge', authMiddleware, (req, res) => {
  const alert = db.alerts.find(a => a.id === req.params.id);
  if (alert) alert.acknowledged = true;
  res.json({ success: true });
});

// EMS
app.get('/api/hms/ems', authMiddleware, (req, res) => {
  res.json(db.emsIncoming);
});

// Feedback
app.get('/api/hms/feedback', authMiddleware, (req, res) => {
  res.json(db.feedback);
});

app.post('/api/hms/feedback', (req, res) => {
  const { patientId, patientName, doctor, department, rating, comment } = req.body;
  const fb = {
    id: `fb_${uuidv4().slice(0, 6)}`,
    patientId, patientName, doctor, department,
    rating: Math.min(3, Math.max(1, rating)),
    comment: comment || '', time: new Date().toISOString(),
  };
  db.feedback.push(fb);
  res.status(201).json({ success: true, feedback: fb });
});

// HMS Dashboard Stats
app.get('/api/hms/dashboard', authMiddleware, (req, res) => {
  const today = db.patients;
  const beds = db.beds;
  res.json({
    patientsToday: today.length,
    criticalPatients: today.filter(p => p.triageLevel === 'red').length,
    waitingPatients: today.filter(p => p.status === 'waiting').length,
    inTreatment: today.filter(p => p.status === 'in-treatment').length,
    inSurgery: today.filter(p => p.status === 'in-surgery').length,
    discharged: today.filter(p => p.status === 'discharged').length,
    totalBeds: beds.length,
    availableBeds: beds.filter(b => b.status === 'available').length,
    occupiedBeds: beds.filter(b => b.status === 'occupied').length,
    pendingAlerts: db.alerts.filter(a => !a.acknowledged).length,
    emsIncoming: db.emsIncoming.length,
    avgWaitTime: 18,
    avgRating: db.feedback.length > 0 ? (db.feedback.reduce((s, f) => s + f.rating, 0) / db.feedback.length).toFixed(1) : '0',
    triageBreakdown: {
      red: today.filter(p => p.triageLevel === 'red').length,
      yellow: today.filter(p => p.triageLevel === 'yellow').length,
      green: today.filter(p => p.triageLevel === 'green').length,
    },
    departmentLoad: [...new Set(today.map(p => p.department))].map(dept => ({
      name: dept,
      count: today.filter(p => p.department === dept).length,
    })),
  });
});

// ═══════════════════════════════════════════════════════════════
// MOH — Ministry of Health Dashboard API
// ═══════════════════════════════════════════════════════════════

app.get('/api/moh/dashboard', authMiddleware, (req, res) => {
  const hospitals = db.hospitals;
  const totalBeds = hospitals.reduce((s, h) => s + h.totalBeds, 0);
  const availableBeds = hospitals.reduce((s, h) => s + h.availableBeds, 0);
  const totalAppts = db.appointments.length;
  const governorates = [...new Set(hospitals.map(h => h.governorate))];

  res.json({
    totalHospitals: hospitals.length,
    totalBeds,
    availableBeds,
    occupancyRate: ((1 - availableBeds / totalBeds) * 100).toFixed(1),
    totalAppointments: totalAppts,
    totalDoctors: db.doctors.length,
    totalPatients: db.patients.length,
    communityHealthIndex: 78.5,
    epidemicRisk: 'low',
    governorates: governorates.map(g => ({
      name: g,
      hospitals: hospitals.filter(h => h.governorate === g).length,
      beds: hospitals.filter(h => h.governorate === g).reduce((s, h) => s + h.totalBeds, 0),
      available: hospitals.filter(h => h.governorate === g).reduce((s, h) => s + h.availableBeds, 0),
    })),
    hospitalStats: hospitals.map(h => ({
      id: h.id, name: h.name, nameEn: h.nameEn,
      governorate: h.governorate, type: h.type,
      lat: h.lat, lng: h.lng,
      totalBeds: h.totalBeds, availableBeds: h.availableBeds,
      occupancyRate: ((1 - h.availableBeds / h.totalBeds) * 100).toFixed(1),
      erLoad: h.currentErLoad, erCapacity: h.erCapacity,
      rating: h.rating, waitTime: h.waitTimeMinutes,
      availability: h.availability,
    })),
    demandPrediction: [
      { hour: '08:00', predicted: 45 }, { hour: '09:00', predicted: 62 },
      { hour: '10:00', predicted: 78 }, { hour: '11:00', predicted: 85 },
      { hour: '12:00', predicted: 72 }, { hour: '13:00', predicted: 58 },
      { hour: '14:00', predicted: 65 }, { hour: '15:00', predicted: 70 },
      { hour: '16:00', predicted: 55 }, { hour: '17:00', predicted: 40 },
    ],
    costSavings: { monthly: 125000, yearly: 1500000, currency: 'JOD' },
    efficiencyMetrics: {
      avgWaitTime: 22, avgTreatmentTime: 45,
      bedTurnoverRate: 3.2, readmissionRate: 4.5,
      patientSatisfaction: 82,
    },
    dataSources: {
      hospitals: hospitals.length,
      pharmacies: 234,
      schools: 1870,
      governmentSystems: 12,
    },
  });
});

app.get('/api/moh/hospitals', authMiddleware, (req, res) => {
  res.json(db.hospitals.map(h => ({
    ...h,
    doctors: db.doctors.filter(d => d.hospitalId === h.id).length,
    todayPatients: db.patients.filter(p => true).length,
  })));
});

app.get('/api/moh/analytics', authMiddleware, (req, res) => {
  res.json({
    healthIndex: {
      overall: 78.5,
      byGovernorate: [
        { name: 'عمّان', score: 82.3 }, { name: 'إربد', score: 75.1 },
        { name: 'الزرقاء', score: 71.8 }, { name: 'العقبة', score: 69.5 },
        { name: 'المفرق', score: 65.2 }, { name: 'الكرك', score: 68.7 },
      ],
    },
    epidemicDetection: {
      currentRisk: 'low',
      alerts: [
        { disease: 'إنفلونزا موسمية', region: 'عمّان', level: 'moderate', cases: 342 },
        { disease: 'حساسية ربيعية', region: 'إربد', level: 'high', cases: 567 },
      ],
    },
    bookingFairness: {
      score: 87,
      underservedAreas: ['المفرق', 'الطفيلة', 'معان'],
    },
    doctorDistribution: {
      ratio: '1:450',
      suggestions: [
        { area: 'المفرق', needed: 'باطنية', count: 3 },
        { area: 'معان', needed: 'أطفال', count: 2 },
        { area: 'الطفيلة', needed: 'نسائية', count: 2 },
      ],
    },
  });
});

// MOH Reports
app.get('/api/moh/reports', authMiddleware, (req, res) => {
  res.json([
    { id: 'r1', title: 'تقرير أداء المستشفيات الشهري', date: '2026-04-01', type: 'performance', status: 'published' },
    { id: 'r2', title: 'إحصائيات الطوارئ — الربع الأول', date: '2026-03-31', type: 'emergency', status: 'published' },
    { id: 'r3', title: 'تقرير توزيع الأطباء', date: '2026-03-15', type: 'distribution', status: 'published' },
    { id: 'r4', title: 'مؤشرات جودة الخدمة', date: '2026-02-28', type: 'quality', status: 'published' },
    { id: 'r5', title: 'تقرير الأوبئة السنوي', date: '2026-01-15', type: 'epidemic', status: 'draft' },
    { id: 'r6', title: 'تقرير العدالة الصحية', date: '2025-12-30', type: 'equity', status: 'published' },
  ]);
});

// MOH Epidemic overview
app.get('/api/moh/epidemic', authMiddleware, (req, res) => {
  res.json({
    activeCases: 1247,
    recoveredToday: 89,
    monitoredAreas: 5,
    riskLevel: 'moderate',
    diseases: [
      { name: 'إنفلونزا موسمية', cases: 892, trend: 'decreasing', region: 'عمّان' },
      { name: 'حساسية ربيعية', cases: 234, trend: 'increasing', region: 'إربد' },
      { name: 'التهاب رئوي', cases: 89, trend: 'stable', region: 'الزرقاء' },
      { name: 'حمى مالطية', cases: 32, trend: 'decreasing', region: 'المفرق' },
    ],
    timeline: [
      { month: 'يناير', cases: 1500 }, { month: 'فبراير', cases: 1320 },
      { month: 'مارس', cases: 1100 }, { month: 'أبريل', cases: 1247 },
    ],
  });
});

// MOH Alerts (POST)
app.post('/api/moh/alerts', authMiddleware, (req, res) => {
  res.json({ success: true, message: 'تم إرسال التنبيه بنجاح' });
});

// ═══════════════════════════════════════════════════════════════
// OTP AUTHENTICATION (Feature 1)
// ═══════════════════════════════════════════════════════════════

const otpStore = {}; // phone -> { code, expires, userId }

app.post('/api/auth/otp/send', (req, res) => {
  const { phone } = req.body;
  if (!phone) return res.status(400).json({ error: 'رقم الهاتف مطلوب' });
  const user = db.users.find(u => u.phone === phone || u.phone?.replace('+962', '0') === phone);
  const code = Math.floor(100000 + Math.random() * 900000).toString();
  otpStore[phone] = { code, expires: Date.now() + 300000, userId: user?.id };
  console.log(`📱 OTP for ${phone}: ${code}`);
  res.json({ success: true, message: 'تم إرسال رمز التحقق', expiresIn: 300, demo_code: code });
});

app.post('/api/auth/otp/verify', (req, res) => {
  const { phone, code } = req.body;
  const stored = otpStore[phone];
  if (!stored || stored.expires < Date.now()) return res.status(400).json({ error: 'رمز التحقق منتهي الصلاحية' });
  if (stored.code !== code) return res.status(401).json({ error: 'رمز التحقق غير صحيح' });
  delete otpStore[phone];
  let user = db.users.find(u => u.id === stored.userId);
  if (!user) {
    user = { id: `usr_${uuidv4().slice(0,8)}`, name: '', phone, role: 'citizen', nationalId: '', email: '', password: '', gender: '', birthDate: '', bloodType: '', allergies: [], chronicConditions: [], insuranceProvider: '' };
    db.users.push(user);
  }
  const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, { expiresIn: '365d' });
  res.json({ success: true, token, user: sanitizeUser(user), role: user.role, isNewUser: !user.name });
});

// ═══════════════════════════════════════════════════════════════
// RESIDENT REGISTRATION — No National ID (Feature 16)
// ═══════════════════════════════════════════════════════════════

app.post('/api/auth/register/resident', (req, res) => {
  const { name, phone, passportNumber, nationality, birthDate, gender } = req.body;
  if (!name || !phone) return res.status(400).json({ error: 'الاسم ورقم الهاتف مطلوبان' });
  const user = {
    id: `usr_${uuidv4().slice(0,8)}`, name, phone,
    nationalId: passportNumber || `RES-${uuidv4().slice(0,6)}`,
    email: '', password: '', gender: gender || '', birthDate: birthDate || '',
    bloodType: '', allergies: [], chronicConditions: [],
    insuranceProvider: '', role: 'citizen', isResident: true, nationality: nationality || '',
  };
  db.users.push(user);
  const token = jwt.sign({ userId: user.id, role: 'citizen' }, JWT_SECRET, { expiresIn: '365d' });
  res.json({ success: true, token, user: sanitizeUser(user) });
});

// ═══════════════════════════════════════════════════════════════
// AUTO PROFILE CREATION (Feature 19)
// ═══════════════════════════════════════════════════════════════

app.put('/api/user/profile', authMiddleware, (req, res) => {
  const user = db.users.find(u => u.id === req.userId);
  if (!user) return res.status(404).json({ error: 'User not found' });
  const { name, phone, email, birthDate, gender, bloodType, height, weight, allergies, chronicConditions, emergencyContact, emergencyPhone, insuranceProvider, insuranceId } = req.body;
  if (name) user.name = name;
  if (phone) user.phone = phone;
  if (email) user.email = email;
  if (birthDate) user.birthDate = birthDate;
  if (gender) user.gender = gender;
  if (bloodType) user.bloodType = bloodType;
  if (height) user.height = height;
  if (weight) user.weight = weight;
  if (allergies) user.allergies = allergies;
  if (chronicConditions) user.chronicConditions = chronicConditions;
  if (emergencyContact) user.emergencyContact = emergencyContact;
  if (emergencyPhone) user.emergencyPhone = emergencyPhone;
  if (insuranceProvider) user.insuranceProvider = insuranceProvider;
  if (insuranceId) user.insuranceId = insuranceId;
  // Auto-create health record if missing
  if (!db.healthRecords.find(r => r.userId === user.id)) {
    db.healthRecords.push({ userId: user.id, bloodType: user.bloodType || '', height: user.height || 0, weight: user.weight || 0, bmi: user.height && user.weight ? (user.weight / Math.pow(user.height/100, 2)).toFixed(1) : 0, allergies: user.allergies || [], chronicConditions: user.chronicConditions || [], diagnoses: [], vitals: { heartRate: 0, bloodPressure: '0/0', temperature: 0, oxygenSaturation: 0, lastUpdated: new Date().toISOString() } });
  }
  res.json({ success: true, user: sanitizeUser(user) });
});

// ═══════════════════════════════════════════════════════════════
// FAMILY LINK (Feature 11)
// ═══════════════════════════════════════════════════════════════

app.get('/api/family/members', authMiddleware, (req, res) => {
  const members = db.familyMembers?.filter(m => m.ownerId === req.userId) || [];
  res.json(members);
});

app.post('/api/family/members', authMiddleware, (req, res) => {
  if (!db.familyMembers) db.familyMembers = [];
  const { name, relation, nationalId, birthDate, gender, bloodType, allergies, chronicConditions } = req.body;
  const member = {
    id: `fam_${uuidv4().slice(0,6)}`, ownerId: req.userId,
    name, relation, nationalId: nationalId || '', birthDate: birthDate || '',
    gender: gender || '', bloodType: bloodType || '',
    allergies: allergies || [], chronicConditions: chronicConditions || [],
    createdAt: new Date().toISOString(),
  };
  db.familyMembers.push(member);
  res.status(201).json({ success: true, member });
});

app.delete('/api/family/members/:id', authMiddleware, (req, res) => {
  if (!db.familyMembers) return res.json({ success: true });
  const idx = db.familyMembers.findIndex(m => m.id === req.params.id && m.ownerId === req.userId);
  if (idx >= 0) db.familyMembers.splice(idx, 1);
  res.json({ success: true });
});

// ═══════════════════════════════════════════════════════════════
// SMART BOOKING — Cross-Hospital (Feature 4, 6, 20)
// ═══════════════════════════════════════════════════════════════

app.get('/api/booking/smart-search', authMiddleware, (req, res) => {
  const { specialty, governorate, urgency } = req.query;
  let doctors = [...db.doctors];
  if (specialty) doctors = doctors.filter(d => d.specialization.includes(specialty));
  if (governorate) {
    const hospIds = db.hospitals.filter(h => h.governorate === governorate).map(h => h.id);
    doctors = doctors.filter(d => hospIds.includes(d.hospitalId));
  }
  // Smart priority: sort by wait time + rating
  const results = doctors.map(d => {
    const h = db.hospitals.find(h => h.id === d.hospitalId);
    return { ...d, hospital: h?.name, waitTime: h?.waitTimeMinutes || 999, hospitalRating: h?.rating || 0, availableBeds: h?.availableBeds || 0, governorate: h?.governorate };
  });
  if (urgency === 'critical') {
    results.sort((a, b) => a.waitTime - b.waitTime);
  } else {
    results.sort((a, b) => (b.rating + b.hospitalRating) / 2 - (a.rating + a.hospitalRating) / 2);
  }
  res.json(results);
});

app.post('/api/booking/reschedule', authMiddleware, (req, res) => {
  const { appointmentId, newDate, newTime } = req.body;
  const apt = db.appointments.find(a => a.id === appointmentId && a.patientId === req.userId);
  if (!apt) return res.status(404).json({ error: 'الموعد غير موجود' });
  const conflict = db.appointments.some(a => a.doctorId === apt.doctorId && a.date === newDate && a.time === newTime && a.status !== 'cancelled' && a.id !== apt.id);
  if (conflict) return res.status(409).json({ error: 'الوقت الجديد محجوز' });
  apt.date = newDate; apt.time = newTime; apt.status = 'confirmed';
  db.notifications.push({ id: `n_${uuidv4().slice(0,8)}`, userId: req.userId, type: 'appointment', title: 'تم تعديل الموعد ✅', body: `تم تغيير موعدك إلى ${newDate} الساعة ${newTime}`, time: new Date().toISOString(), read: false, severity: 'info' });
  res.json({ success: true, appointment: apt });
});

// ═══════════════════════════════════════════════════════════════
// MEDICATION DELIVERY & REFILL (Feature 8, 9)
// ═══════════════════════════════════════════════════════════════

app.post('/api/medications/refill', authMiddleware, (req, res) => {
  const { medicationId } = req.body;
  const med = db.medications.find(m => m.id === medicationId);
  if (!med) return res.status(404).json({ error: 'الدواء غير موجود' });
  med.remaining = med.total; med.startDate = new Date().toISOString().split('T')[0];
  db.notifications.push({ id: `n_${uuidv4().slice(0,8)}`, userId: req.userId, type: 'medication', title: 'تم إعادة تعبئة الدواء ✅', body: `تم إعادة تعبئة ${med.name} ${med.dose}`, time: new Date().toISOString(), read: false, severity: 'info' });
  res.json({ success: true, medication: med });
});

app.post('/api/medications/deliver', authMiddleware, (req, res) => {
  if (!db.deliveryOrders) db.deliveryOrders = [];
  const { medicationIds, address, phone, notes } = req.body;
  const meds = medicationIds.map(id => db.medications.find(m => m.id === id)).filter(Boolean);
  const order = {
    id: `del_${uuidv4().slice(0,6)}`, userId: req.userId,
    medications: meds.map(m => ({ id: m.id, name: m.name, dose: m.dose })),
    address: address || 'العنوان المسجل', phone: phone || '',
    status: 'confirmed', estimatedDelivery: '45-60 دقيقة',
    totalCost: meds.length * 3.5, currency: 'JOD',
    createdAt: new Date().toISOString(), notes: notes || '',
  };
  db.deliveryOrders.push(order);
  db.notifications.push({ id: `n_${uuidv4().slice(0,8)}`, userId: req.userId, type: 'medication', title: 'طلب توصيل أدوية 🚚', body: `تم تأكيد طلب توصيل ${meds.length} أدوية — الوصول خلال ${order.estimatedDelivery}`, time: new Date().toISOString(), read: false, severity: 'info' });
  res.json({ success: true, order });
});

app.get('/api/medications/delivery-orders', authMiddleware, (req, res) => {
  const orders = (db.deliveryOrders || []).filter(o => o.userId === req.userId);
  res.json(orders);
});

// ═══════════════════════════════════════════════════════════════
// APPOINTMENT NOTIFICATIONS (Feature 5) & GEOFENCING (Feature 13)
// ═══════════════════════════════════════════════════════════════

app.get('/api/notifications/settings', authMiddleware, (req, res) => {
  if (!db.notificationSettings) db.notificationSettings = {};
  const settings = db.notificationSettings[req.userId] || { appointmentReminders: ['1_week', '1_day', '2_hours'], medicationAlerts: true, labResultsReady: true, geofencingEnabled: true, geofenceRadiusMeters: 500 };
  res.json(settings);
});

app.put('/api/notifications/settings', authMiddleware, (req, res) => {
  if (!db.notificationSettings) db.notificationSettings = {};
  db.notificationSettings[req.userId] = { ...db.notificationSettings[req.userId], ...req.body };
  res.json({ success: true, settings: db.notificationSettings[req.userId] });
});

app.post('/api/geofence/checkin', authMiddleware, (req, res) => {
  const { lat, lng, hospitalId } = req.body;
  const hospital = db.hospitals.find(h => h.id === hospitalId);
  if (!hospital) return res.status(404).json({ error: 'Hospital not found' });
  const dist = Math.sqrt(Math.pow(hospital.lat - lat, 2) + Math.pow(hospital.lng - lng, 2)) * 111000;
  const userApts = db.appointments.filter(a => a.patientId === req.userId && a.hospitalId === hospitalId && a.status === 'confirmed');
  res.json({ success: true, withinRange: dist < 500, distanceMeters: Math.round(dist), nearbyAppointments: userApts, parkingDirections: 'الموقف الرئيسي — البوابة الشرقية', hospitalMessage: `مرحباً بك في ${hospital.name}! تم تفعيل دورك.` });
});

// ═══════════════════════════════════════════════════════════════
// HOME NURSING SERVICE (Feature 12)
// ═══════════════════════════════════════════════════════════════

app.get('/api/nursing/services', (req, res) => {
  res.json([
    { id: 'ns_1', name: 'تمريض منزلي', price: 25, unit: 'ساعة', icon: 'medical_services' },
    { id: 'ns_2', name: 'سحب عينات دم', price: 15, unit: 'زيارة', icon: 'bloodtype' },
    { id: 'ns_3', name: 'علاج طبيعي', price: 35, unit: 'جلسة', icon: 'accessibility_new' },
    { id: 'ns_4', name: 'رعاية مسنين', price: 20, unit: 'ساعة', icon: 'elderly' },
    { id: 'ns_5', name: 'تضميد جروح', price: 12, unit: 'زيارة', icon: 'healing' },
    { id: 'ns_6', name: 'حقن وريدية', price: 18, unit: 'زيارة', icon: 'vaccines' },
  ]);
});

app.post('/api/nursing/book', authMiddleware, (req, res) => {
  if (!db.nursingOrders) db.nursingOrders = [];
  const { serviceId, date, time, address, notes, patientName } = req.body;
  const order = {
    id: `nrs_${uuidv4().slice(0,6)}`, userId: req.userId, serviceId,
    date, time, address: address || 'العنوان المسجل',
    patientName: patientName || '', notes: notes || '',
    status: 'confirmed', nurseName: 'نور الحسن — ممرضة معتمدة',
    estimatedArrival: '30-45 دقيقة', createdAt: new Date().toISOString(),
  };
  db.nursingOrders.push(order);
  res.status(201).json({ success: true, order });
});

// ═══════════════════════════════════════════════════════════════
// WEARABLE DEVICES (Feature 14)
// ═══════════════════════════════════════════════════════════════

app.post('/api/devices/sync', authMiddleware, (req, res) => {
  const { deviceType, readings } = req.body;
  if (!db.deviceReadings) db.deviceReadings = [];
  const reading = { id: `dev_${uuidv4().slice(0,6)}`, userId: req.userId, deviceType, readings, syncedAt: new Date().toISOString() };
  db.deviceReadings.push(reading);
  // Update user vitals in health record
  const record = db.healthRecords.find(r => r.userId === req.userId);
  if (record && readings) {
    if (readings.heartRate) record.vitals.heartRate = readings.heartRate;
    if (readings.bloodPressure) record.vitals.bloodPressure = readings.bloodPressure;
    if (readings.oxygenSaturation) record.vitals.oxygenSaturation = readings.oxygenSaturation;
    if (readings.temperature) record.vitals.temperature = readings.temperature;
    record.vitals.lastUpdated = new Date().toISOString();
  }
  res.json({ success: true, reading });
});

app.get('/api/devices/readings', authMiddleware, (req, res) => {
  const readings = (db.deviceReadings || []).filter(r => r.userId === req.userId);
  res.json(readings);
});

// ═══════════════════════════════════════════════════════════════
// PAYMENTS (Feature 15)
// ═══════════════════════════════════════════════════════════════

app.get('/api/payments/bills', authMiddleware, (req, res) => {
  res.json([
    { id: 'bill_001', type: 'appointment', description: 'مراجعة د. سارة المعاني — عيون', amount: 35, currency: 'JOD', status: 'pending', date: '2026-04-15', hospitalId: 'h_001' },
    { id: 'bill_002', type: 'lab', description: 'فحص دم شامل CBC', amount: 25, currency: 'JOD', status: 'paid', date: '2026-03-28', hospitalId: 'h_001' },
    { id: 'bill_003', type: 'medication', description: 'أموكسيسيلين 500mg — 14 حبة', amount: 8.5, currency: 'JOD', status: 'pending', date: '2026-04-05', hospitalId: 'h_004' },
  ]);
});

app.post('/api/payments/pay', authMiddleware, (req, res) => {
  const { billId, method } = req.body;
  db.notifications.push({ id: `n_${uuidv4().slice(0,8)}`, userId: req.userId, type: 'payment', title: 'تم الدفع بنجاح ✅', body: `تم دفع الفاتورة عبر ${method || 'البطاقة'}`, time: new Date().toISOString(), read: false, severity: 'info' });
  res.json({ success: true, transactionId: `txn_${uuidv4().slice(0,8)}`, message: 'تم الدفع بنجاح' });
});

// ═══════════════════════════════════════════════════════════════
// DAILY HEALTH TIPS (Feature 18)
// ═══════════════════════════════════════════════════════════════

app.get('/api/health/tips', authMiddleware, (req, res) => {
  const user = db.users.find(u => u.id === req.userId) || {};
  const allTips = [
    { id: 't1', category: 'عام', title: 'شرب الماء', body: 'اشرب 8 أكواب ماء يومياً للحفاظ على ترطيب الجسم 💧', icon: 'water_drop', forConditions: [] },
    { id: 't2', category: 'عام', title: 'المشي اليومي', body: 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب بنسبة 35% 🚶', icon: 'directions_walk', forConditions: [] },
    { id: 't3', category: 'سكري', title: 'مراقبة السكر', body: 'حافظ على مستوى السكر الصائم بين 80-130 mg/dL. قس السكر قبل وبعد الوجبات', icon: 'bloodtype', forConditions: ['سكري'] },
    { id: 't4', category: 'قلب', title: 'صحة القلب', body: 'قلل الملح إلى أقل من 2 غرام يومياً وتجنب الأطعمة المقلية 🫀', icon: 'favorite', forConditions: ['قلب', 'ارتفاع ضغط'] },
    { id: 't5', category: 'عام', title: 'النوم الصحي', body: 'النوم 7-8 ساعات يعزز المناعة وصحة الدماغ 🌙', icon: 'bedtime', forConditions: [] },
    { id: 't6', category: 'تغذية', title: 'الفواكه والخضروات', body: 'تناول 5 حصص من الفواكه والخضروات يومياً لتعزيز مناعتك 🥗', icon: 'restaurant', forConditions: [] },
    { id: 't7', category: 'حساسية', title: 'إدارة الحساسية', body: 'تجنب الأماكن المغبرة وارتدِ كمامة خلال فترة التلقيح الربيعي 🤧', icon: 'air', forConditions: ['حساسية'] },
    { id: 't8', category: 'عام', title: 'فيتامين D', body: 'تعرّض للشمس 15 دقيقة صباحاً أو تناول مكملات فيتامين D ☀️', icon: 'wb_sunny', forConditions: [] },
    { id: 't9', category: 'توتر', title: 'إدارة التوتر', body: 'مارس تمارين التنفس العميق 5 دقائق يومياً لتقليل التوتر 🧘', icon: 'self_improvement', forConditions: [] },
    { id: 't10', category: 'عام', title: 'الفحص الدوري', body: 'قم بفحص دم شامل كل 6 أشهر للاكتشاف المبكر لأي مشكلة صحية 🔬', icon: 'science', forConditions: [] },
  ];
  // Personalize based on user conditions
  const conditions = user.chronicConditions || [];
  const personalized = allTips.filter(t => t.forConditions.length === 0 || t.forConditions.some(c => conditions.some(uc => uc.includes(c))));
  // Pick 3 tips for today (rotate daily)
  const dayOfYear = Math.floor((Date.now() - new Date(new Date().getFullYear(), 0, 0)) / 86400000);
  const start = (dayOfYear * 3) % personalized.length;
  const todayTips = [];
  for (let i = 0; i < 3 && i < personalized.length; i++) {
    todayTips.push(personalized[(start + i) % personalized.length]);
  }
  res.json({ tips: todayTips, totalAvailable: allTips.length });
});

// ═══════════════════════════════════════════════════════════════
// CHRONIC CARE PATHS (Feature 17)
// ═══════════════════════════════════════════════════════════════

app.get('/api/chronic/plans', authMiddleware, (req, res) => {
  res.json([
    { id: 'cp_diabetes', name: 'متابعة السكري', condition: 'سكري', progress: 0.65, nextStep: 'فحص HbA1c — 2026-06-01', totalSteps: 5, completedSteps: 3, monthlyChecklist: ['قياس السكر يومياً', 'فحص القدمين أسبوعياً', 'تمارين 150 دقيقة/أسبوع'] },
    { id: 'cp_heart', name: 'متابعة القلب', condition: 'قلب', progress: 0.45, nextStep: 'إيكو القلب — 2026-08-01', totalSteps: 5, completedSteps: 2, monthlyChecklist: ['قياس الضغط يومياً', 'تقليل الملح', 'أدوية بانتظام'] },
    { id: 'cp_cancer', name: 'متابعة الأورام', condition: 'أورام', progress: 0.30, nextStep: 'أشعة مقطعية — 2026-06-15', totalSteps: 4, completedSteps: 1, monthlyChecklist: ['فحص دم شهري', 'تغذية عالية البروتين', 'تقييم نفسي'] },
  ]);
});

// ═══════════════════════════════════════════════════════════════
// OFFLINE WALLET DATA (Feature 2, 3)
// ═══════════════════════════════════════════════════════════════

app.get('/api/wallet/offline-data', authMiddleware, (req, res) => {
  const user = db.users.find(u => u.id === req.userId) || {};
  const record = db.healthRecords.find(r => r.userId === req.userId) || {};
  const meds = db.medications.filter(m => m.patientId === req.userId && m.active);
  const latestLabs = db.labResults.filter(r => r.patientId === req.userId).slice(0, 3);
  res.json({
    name: user.name, nationalId: user.nationalId,
    bloodType: record.bloodType || user.bloodType || '',
    allergies: record.allergies || user.allergies || [],
    chronicConditions: record.chronicConditions || user.chronicConditions || [],
    currentMedications: meds.map(m => ({ name: m.name, dose: m.dose, frequency: m.frequency })),
    emergencyContact: user.emergencyContact || '', emergencyPhone: user.emergencyPhone || '',
    insurance: user.insuranceProvider || '', insuranceId: user.insuranceId || '',
    latestLabs: latestLabs.map(l => ({ name: l.name, date: l.date, status: l.status })),
    vitals: record.vitals || {},
    qrData: JSON.stringify({ id: user.nationalId, name: user.name, blood: record.bloodType || user.bloodType, allergies: record.allergies || user.allergies, chronic: record.chronicConditions || user.chronicConditions, emergency: user.emergencyPhone }),
    lastUpdated: new Date().toISOString(),
  });
});

// ═══════════════════════════════════════════════════════════════
// HMS: LAB RESULT READY NOTIFICATION (Feature 31)
// ═══════════════════════════════════════════════════════════════

app.post('/api/hms/lab-ready', authMiddleware, (req, res) => {
  const { patientId, labName } = req.body;
  const patient = db.patients.find(p => p.id === patientId);
  if (!patient) return res.status(404).json({ error: 'Patient not found' });
  db.alerts.push({ id: `alert_${uuidv4().slice(0,6)}`, type: 'lab', title: `نتائج جاهزة — ${patient.name}`, body: `نتائج ${labName || 'التحليل'} جاهزة للمريض ${patient.name}`, time: new Date().toISOString(), acknowledged: false, patientId });
  // Also push to citizen notifications if user exists
  const citizenUser = db.users.find(u => u.nationalId === patient.nationalId);
  if (citizenUser) {
    db.notifications.push({ id: `n_${uuidv4().slice(0,8)}`, userId: citizenUser.id, type: 'lab', title: 'نتائج فحصك جاهزة! 🔬', body: `نتائج ${labName || 'التحليل'} جاهزة. افتح التطبيق للاطلاع عليها.`, time: new Date().toISOString(), read: false, severity: 'info' });
  }
  res.json({ success: true });
});

// ═══════════════════════════════════════════════════════════════
// HMS: ER CASE REGISTRATION (Feature 32)
// ═══════════════════════════════════════════════════════════════

app.post('/api/hms/er/register', authMiddleware, (req, res) => {
  const { name, age, gender, complaint, vitals, severity } = req.body;
  const patient = {
    id: `p_${uuidv4().slice(0,6)}`, name, age, gender,
    nationalId: '', qrCode: `QR-ER-${uuidv4().slice(0,4).toUpperCase()}`,
    triageLevel: severity || 'red', status: 'in-treatment',
    department: 'طوارئ', doctor: null, room: 'ER-TRIAGE', bed: null,
    vitals: vitals || { hr: 0, bp: '0/0', temp: 0, o2: 0 },
    checkinTime: new Date().toISOString(), complaint: complaint || '', notes: 'حالة طوارئ — تسجيل سريع',
  };
  db.patients.push(patient);
  db.alerts.push({ id: `alert_${uuidv4().slice(0,6)}`, type: 'critical', title: `🚨 حالة طوارئ — ${name}`, body: `${complaint} — مستوى الخطورة: ${severity === 'red' ? 'حرج' : 'متوسط'}`, time: new Date().toISOString(), acknowledged: false, patientId: patient.id });
  res.status(201).json({ success: true, patient });
});

// ═══════════════════════════════════════════════════════════════
// HMS: DYNAMIC APPOINTMENT REDISTRIBUTION (Feature 24)
// ═══════════════════════════════════════════════════════════════

app.post('/api/hms/redistribute', authMiddleware, (req, res) => {
  const { doctorId, reason } = req.body;
  const affected = db.appointments.filter(a => a.doctorId === doctorId && a.status === 'confirmed' && new Date(a.date) >= new Date());
  const alternativeDoctors = db.doctors.filter(d => d.id !== doctorId && d.available);
  const redistributed = [];
  for (const apt of affected) {
    const altDoc = alternativeDoctors.find(d => d.specialization === db.doctors.find(od => od.id === doctorId)?.specialization);
    if (altDoc) {
      apt.doctor = altDoc.name; apt.doctorId = altDoc.id;
      apt.hospital = altDoc.hospitalName; apt.hospitalId = altDoc.hospitalId;
      redistributed.push(apt);
      const user = db.users.find(u => u.id === apt.patientId);
      if (user) {
        db.notifications.push({ id: `n_${uuidv4().slice(0,8)}`, userId: user.id, type: 'appointment', title: '⚠️ تم تغيير موعدك', body: `تم تحويل موعدك إلى ${altDoc.name} في ${altDoc.hospitalName} بسبب: ${reason || 'حالة طوارئ'}`, time: new Date().toISOString(), read: false, severity: 'warning' });
      }
    }
  }
  res.json({ success: true, affected: affected.length, redistributed: redistributed.length, details: redistributed });
});

// ═══════════════════════════════════════════════════════════════
// MOH: MULTI-SOURCE DATA INTEGRATION (Feature 40)
// ═══════════════════════════════════════════════════════════════

app.get('/api/moh/data-sources', authMiddleware, (req, res) => {
  res.json({
    pharmacies: { count: 234, lastSync: new Date(Date.now() - 3600000).toISOString(), topMedications: [{ name: 'أموكسيسيلين', prescriptions: 1240 }, { name: 'ميتفورمين', prescriptions: 890 }, { name: 'أملوديبين', prescriptions: 780 }], alerts: [{ type: 'shortage', medication: 'أنسولين ليسبرو', severity: 'high' }] },
    schools: { count: 1870, healthScreenings: 45320, alerts: [{ type: 'outbreak', disease: 'جدري الماء', school: 'مدرسة عمّان الأساسية', cases: 12 }], vaccinationRate: 94.5 },
    municipalities: { count: 12, waterQualityTests: 890, foodSafetyInspections: 2340, alerts: [{ type: 'water', area: 'جنوب عمّان', issue: 'ارتفاع نسبة الكلور' }] },
    civilDefense: { activeCases: 3, ambulancesDeployed: 12, avgResponseTime: '8.5 دقائق' },
    hakeem: { connected: true, lastSync: new Date(Date.now() - 1800000).toISOString(), totalRecords: 2450000, dailyTransactions: 15600 },
  });
});

// ═══════════════════════════════════════════════════════════════
// HAKEEM INTEGRATION (Feature 43)
// ═══════════════════════════════════════════════════════════════

app.get('/api/hakeem/patient/:nationalId', authMiddleware, (req, res) => {
  const user = db.users.find(u => u.nationalId === req.params.nationalId);
  const record = db.healthRecords.find(r => r.userId === user?.id);
  const labs = db.labResults.filter(r => r.patientId === user?.id);
  const meds = db.medications.filter(m => m.patientId === user?.id);
  res.json({
    source: 'Hakeem National Health System',
    nationalId: req.params.nationalId,
    name: user?.name || 'غير مسجل',
    bloodType: record?.bloodType || user?.bloodType || '',
    allergies: record?.allergies || user?.allergies || [],
    chronicConditions: record?.chronicConditions || user?.chronicConditions || [],
    labHistory: labs.map(l => ({ name: l.name, date: l.date, hospital: l.hospital })),
    medicationHistory: meds.map(m => ({ name: m.name, dose: m.dose, prescribedBy: m.prescribedBy })),
    lastVisit: '2026-04-05',
    registeredHospitals: ['مستشفى الأردن', 'مستشفى البشير'],
  });
});

// ═══════════════════════════════════════════════════════════════
// HEALTH CHECK
// ═══════════════════════════════════════════════════════════════

app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'Masar Smart Health - Dev Server',
    version: '2.0.0',
    features: 47,
    timestamp: new Date().toISOString(),
    data: {
      hospitals: db.hospitals.length,
      doctors: db.doctors.length,
      appointments: db.appointments.length,
      users: db.users.length,
    },
  });
});

// ═══════════════════════════════════════════════════════════════
// START
// ═══════════════════════════════════════════════════════════════


// ─── OTP Auth ─────────────────────────────────────────────
const _otpStore = {};
app.post('/api/auth/otp/request', (req, res) => {
  const { phone } = req.body || {};
  if (!phone || phone.length < 8) return res.status(400).json({ error: '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641 \u063a\u064a\u0631 \u0635\u062d\u064a\u062d' });
  const otp = String(100000 + Math.floor(Math.random() * 900000));
  _otpStore[phone] = { otp, expiresAt: Date.now() + 300000 };
  console.log('OTP', phone, otp);
  res.json({ success: true, debug_otp: otp });
});
app.post('/api/auth/otp/verify', (req, res) => {
  const { phone, otp } = req.body || {};
  const r = _otpStore[phone];
  if (!r || r.otp !== otp || Date.now() > r.expiresAt) return res.status(401).json({ error: '\u0631\u0645\u0632 \u063a\u064a\u0631 \u0635\u062d\u064a\u062d' });
  delete _otpStore[phone];
  const token = 'otp-' + require('crypto').randomBytes(16).toString('hex');
  res.json({ success: true, token, role: 'citizen', name: '\u0645\u0633\u062a\u062e\u062f\u0645 \u0645\u0633\u0627\u0631' });
});
app.post('/api/auth/resident', (req, res) => {
  const { documentNumber } = req.body || {};
  if (!documentNumber || documentNumber.length < 5) return res.status(400).json({ error: '\u0631\u0642\u0645 \u063a\u064a\u0631 \u0635\u062d\u064a\u062d' });
  const token = 'resident-' + require('crypto').randomBytes(16).toString('hex');
  res.json({ success: true, token, role: 'citizen', name: '\u0645\u0642\u064a\u0645 / \u0632\u0627\u0626\u0631' });
});

// ─── Pharmacy ─────────────────────────────────────────────
const _phItems = [
  { id: 'm1', name: '\u0645\u064a\u062a\u0641\u0648\u0631\u0645\u064a\u0646 500mg', category: '\u0633\u0643\u0631\u064a', price: 3.5, requiresPrescription: true },
  { id: 'm2', name: '\u0628\u0627\u0631\u0627\u0633\u064a\u062a\u0627\u0645\u0648\u0644 500mg', category: '\u0645\u0633\u0643\u0646\u0627\u062a', price: 1.0, requiresPrescription: false },
  { id: 'm3', name: '\u0641\u064a\u062a\u0627\u0645\u064a\u0646 \u062f3 1000IU', category: '\u0641\u064a\u062a\u0627\u0645\u064a\u0646\u0627\u062a', price: 6.0, requiresPrescription: false },
  { id: 'm4', name: '\u0623\u0648\u0645\u0628\u0631\u0627\u0632\u0648\u0644 20mg', category: '\u0645\u0639\u062f\u0629', price: 4.5, requiresPrescription: false },
  { id: 'm5', name: '\u0633\u0627\u0644\u0628\u0648\u062a\u0627\u0645\u0648\u0644 \u0628\u062e\u0627\u062e', category: '\u0631\u0628\u0648', price: 15.0, requiresPrescription: true },
];
const _phOrders = [];
app.get('/api/pharmacy/medications', (req, res) => res.json({ items: _phItems }));
app.post('/api/pharmacy/orders', authMiddleware, (req, res) => {
  const { items, address } = req.body || {};
  if (!items || !items.length) return res.status(400).json({ error: '\u0644\u0627 \u062a\u0648\u062c\u062f \u0623\u0635\u0646\u0627\u0641' });
  const order = { id: 'ORD-' + Date.now(), userId: req.user && req.user.id, items, address, status: 'pending', estimatedDelivery: '30-45 \u062f\u0642\u064a\u0642\u0629', createdAt: new Date().toISOString() };
  _phOrders.push(order);
  res.json({ success: true, order });
});
app.get('/api/pharmacy/orders', authMiddleware, (req, res) => res.json({ orders: _phOrders.filter(o => o.userId === (req.user && req.user.id)) }));

// ─── Health Tips ──────────────────────────────────────────
const _tipsData = [
  { id: 1, category: '\u062a\u063a\u0630\u064a\u0629', title: '\u0627\u0634\u0631\u0628 8 \u0623\u0643\u0648\u0627\u0628 \u0645\u0627\u0621 \u064a\u0648\u0645\u064a\u0627\u064b', icon: '\ud83d\udca7' },
  { id: 2, category: '\u0646\u0634\u0627\u0637', title: '\u0627\u0644\u0645\u0634\u064a 30 \u062f\u0642\u064a\u0642\u0629 \u064a\u0648\u0645\u064a\u0627\u064b', icon: '\ud83d\udeb6' },
  { id: 3, category: '\u0646\u0648\u0645', title: '\u0646\u0645 7-8 \u0633\u0627\u0639\u0627\u062a \u064a\u0648\u0645\u064a\u0627\u064b', icon: '\ud83d\ude34' },
  { id: 4, category: '\u0648\u0642\u0627\u064a\u0629', title: '\u0627\u0641\u062d\u0635 \u0636\u063a\u0637\u0643 \u0634\u0647\u0631\u064a\u0627\u064b', icon: '\ud83e\ude7a' },
  { id: 5, category: '\u0641\u064a\u062a\u0627\u0645\u064a\u0646\u0627\u062a', title: '\u0639\u0631\u0651\u0636 \u0646\u0641\u0633\u0643 \u0644\u0644\u0634\u0645\u0633', icon: '\u2600\ufe0f' },
];
app.get('/api/health-tips', (req, res) => res.json({ tips: _tipsData }));

// ─── MoH Epidemic / CHI / Equity / Forecast ─────────────
app.get('/api/moh/epidemic-alerts', authMiddleware, (req, res) => {
  res.json({ alerts: [
    { id: 1, disease: '\u0625\u0646\u0641\u0644\u0648\u0646\u0632\u0627 \u0645\u0648\u0633\u0645\u064a\u0629', governorate: '\u0639\u0645\u0627\u0646', level: '\u0645\u062a\u0648\u0633\u0637', cases7Days: 1240, trend: 'rising' },
    { id: 2, disease: '\u062d\u0645\u0649 \u0627\u0644\u0636\u0646\u0643', governorate: '\u0627\u0644\u0639\u0642\u0628\u0629', level: '\u0645\u0631\u062a\u0641\u0639', cases7Days: 87, trend: 'stable' },
    { id: 3, disease: '\u062c\u062f\u0631\u064a \u0627\u0644\u0645\u0627\u0621', governorate: '\u0627\u0644\u0632\u0631\u0642\u0627\u0621', level: '\u0645\u062a\u0648\u0633\u0637', cases7Days: 340, trend: 'rising' },
  ], updatedAt: new Date().toISOString() });
});
app.get('/api/moh/chi', authMiddleware, (req, res) => {
  res.json({ nationalChi: 62, governorates: [
    { name: '\u0639\u0645\u0627\u0646', chiScore: 78, doctorsPer10k: 32 },
    { name: '\u0627\u0644\u0632\u0631\u0642\u0627\u0621', chiScore: 61, doctorsPer10k: 18 },
    { name: '\u0625\u0631\u0628\u062f', chiScore: 70, doctorsPer10k: 24 },
    { name: '\u0627\u0644\u0645\u0641\u0631\u0642', chiScore: 48, doctorsPer10k: 10 },
    { name: '\u0639\u062c\u0644\u0648\u0646', chiScore: 50, doctorsPer10k: 9 },
  ], updatedAt: new Date().toISOString() });
});
app.get('/api/moh/equity', authMiddleware, (req, res) => {
  res.json({ governorates: [
    { name: '\u0639\u0645\u0627\u0646', populationPct: 40, appointmentsPer100k: 820, equityIndex: 0.92 },
    { name: '\u0627\u0644\u0632\u0631\u0642\u0627\u0621', populationPct: 13, appointmentsPer100k: 510, equityIndex: 0.71 },
    { name: '\u0639\u062c\u0644\u0648\u0646', populationPct: 2, appointmentsPer100k: 270, equityIndex: 0.46 },
  ], recommendations: [
    { priority: '\u0639\u0627\u0644\u064a\u0629', text: '\u062a\u0648\u0632\u064a\u0639 15 \u0637\u0628\u064a\u0628\u0627\u064b \u0639\u0644\u0649 \u0639\u062c\u0644\u0648\u0646 \u0648\u062c\u0631\u0634', icon: '\ud83e\ude7a' },
    { priority: '\u0639\u0627\u0644\u064a\u0629', text: '\u0641\u062a\u062d \u0639\u064a\u0627\u062f\u0629 \u0645\u062a\u0646\u0642\u0644\u0629 \u0641\u064a \u0627\u0644\u0645\u0641\u0631\u0642', icon: '\ud83d\ude91' },
  ], updatedAt: new Date().toISOString() });
});
app.get('/api/moh/demand-forecast', authMiddleware, (req, res) => {
  res.json({ forecast: Array.from({ length: 10 }, (_, i) => ({
    date: new Date(Date.now() + i * 86400000).toISOString().split('T')[0],
    predicted: Math.floor(3000 + Math.random() * 1500),
    capacity: 4000,
    risk: i > 6 ? 'high' : i > 3 ? 'medium' : 'low',
  })) });
});

// ═══════════════════════════════════════════════════════════════
// BLOOD DONATION API
// ═══════════════════════════════════════════════════════════════

// Blood bank data
const bloodBank = {
  donors: [],
  requests: [
    { id: 'bd_001', bloodType: 'O-', hospital: 'مستشفى الأردن', hospitalId: 'h_001', units: 3, urgent: true, patient: 'حالة طوارئ — جراحة', createdAt: new Date().toISOString() },
    { id: 'bd_002', bloodType: 'A+', hospital: 'مستشفى الجامعة الأردنية', hospitalId: 'h_002', units: 2, urgent: true, patient: 'حالة ولادة قيصرية', createdAt: new Date().toISOString() },
    { id: 'bd_003', bloodType: 'B+', hospital: 'مستشفى البشير', hospitalId: 'h_004', units: 5, urgent: false, patient: 'مخزون منخفض', createdAt: new Date().toISOString() },
    { id: 'bd_004', bloodType: 'AB-', hospital: 'مدينة الملك حسين الطبية', hospitalId: 'h_003', units: 1, urgent: true, patient: 'حالة أورام', createdAt: new Date().toISOString() },
    { id: 'bd_005', bloodType: 'O+', hospital: 'مستشفى الأمير حمزة', hospitalId: 'h_005', units: 4, urgent: false, patient: 'مخزون احتياطي', createdAt: new Date().toISOString() },
  ],
  centers: [
    { id: 'bc_001', name: 'بنك الدم الوطني', address: 'الشميساني، عمّان', hours: '8:00 ص - 4:00 م', phone: '06-5603060', lat: 31.958, lng: 35.865 },
    { id: 'bc_002', name: 'مركز التبرع — مستشفى الأردن', address: 'الشميساني، عمّان', hours: '9:00 ص - 3:00 م', phone: '06-5607071', lat: 31.958, lng: 35.865 },
    { id: 'bc_003', name: 'بنك دم مستشفى الجامعة', address: 'الجبيهة، عمّان', hours: '8:00 ص - 2:00 م', phone: '06-5353444', lat: 32.019, lng: 35.874 },
    { id: 'bc_004', name: 'مركز الهلال الأحمر', address: 'جبل الحسين، عمّان', hours: '8:30 ص - 3:30 م', phone: '06-4636196', lat: 31.963, lng: 35.905 },
  ],
};

app.get('/api/blood/requests', authMiddleware, (req, res) => {
  res.json(bloodBank.requests);
});

app.get('/api/blood/centers', authMiddleware, (req, res) => {
  res.json(bloodBank.centers);
});

app.post('/api/blood/register-donor', authMiddleware, (req, res) => {
  const { name, phone, bloodType } = req.body;
  if (!name || !phone || !bloodType) {
    return res.status(400).json({ success: false, error: 'جميع الحقول مطلوبة' });
  }
  const donor = {
    id: `donor_${uuidv4().slice(0, 8)}`,
    userId: req.userId,
    name, phone, bloodType,
    registeredAt: new Date().toISOString(),
    lastDonation: null,
    active: true,
  };
  bloodBank.donors.push(donor);
  db.notifications.push({
    id: `n_${uuidv4().slice(0, 8)}`,
    userId: req.userId, type: 'blood_donation',
    title: 'تم تسجيلك كمتبرع دم ✅',
    body: `شكراً ${name}! فصيلة دمك: ${bloodType}. سيتم إشعارك عند الحاجة.`,
    time: new Date().toISOString(), read: false, severity: 'info',
  });
  res.json({ success: true, donor });
});

app.post('/api/blood/donate', authMiddleware, (req, res) => {
  const { requestId } = req.body;
  const request = bloodBank.requests.find(r => r.id === requestId);
  if (!request) {
    return res.status(404).json({ success: false, error: 'الطلب غير موجود' });
  }
  request.units = Math.max(0, request.units - 1);
  if (request.units === 0) {
    request.urgent = false;
    request.patient = 'تم التبرع — شكراً!';
  }
  res.json({ success: true, message: `شكراً! تم تسجيل رغبتك بالتبرع في ${request.hospital}` });
});

// ═══ GROK AI PROXY (CORS bypass for Flutter web) ═══════════
const GROK_API_KEY = 'xai-lSoC8T03HMR5ySPsvTQcLzzjKzzTvZld6qR0qsFwMREzdpt863J4byUFiNp8FLj0IRJWUQv7xXhusq7b';
const GROK_BASE = 'https://api.x.ai/v1';

app.post('/api/grok/chat', async (req, res) => {
  try {
    const response = await fetch(`${GROK_BASE}/chat/completions`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${GROK_API_KEY}` },
      body: JSON.stringify(req.body),
    });
    const data = await response.json();
    res.json(data);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/grok/images', async (req, res) => {
  try {
    const response = await fetch(`${GROK_BASE}/images/generations`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${GROK_API_KEY}` },
      body: JSON.stringify(req.body),
    });
    const data = await response.json();
    res.json(data);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.listen(PORT, () => {
  console.log(`\n═══════════════════════════════════════════════`);
  console.log(`  🏥 Masar Smart Health — Dev Server`);
  console.log(`  📡 http://localhost:${PORT}`);
  console.log(`  🏥 ${db.hospitals.length} مستشفى حقيقي`);
  console.log(`  👨‍⚕️ ${db.doctors.length} طبيب`);
  console.log(`  📅 ${db.appointments.length} مواعيد`);
  console.log(`  💊 ${db.medications.length} أدوية`);
  console.log(`═══════════════════════════════════════════════\n`);
});
