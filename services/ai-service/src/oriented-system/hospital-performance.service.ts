import { Injectable, Logger } from '@nestjs/common';
import { EventBusService, HealthcareEvent } from './event-bus.service';

export interface HospitalScore {
  hospitalName: string;
  hospitalNameAr: string;
  overallScore: number; // 0–100
  metrics: {
    waitTime: number;        // avg minutes
    patientSatisfaction: number; // 0–100
    successRate: number;     // 0–100
    emergencyResponse: number; // 0–100
    staffRating: number;     // 0–100
    facilityRating: number;  // 0–100
  };
  specializations: string[];
  governorate: string;
  lastUpdated: Date;
}

@Injectable()
export class HospitalPerformanceService {
  private readonly logger = new Logger(HospitalPerformanceService.name);
  private readonly scores = new Map<string, HospitalScore>();

  constructor(private readonly eventBus: EventBusService) {
    this.initializeHospitalScores();
    this.registerEventListeners();
  }

  private registerEventListeners() {
    // Update scores when visits complete — real performance tracking
    this.eventBus.on(HealthcareEvent.VISIT_COMPLETED, (payload) => {
      const hospital = payload.data.hospitalName;
      if (hospital && this.scores.has(hospital)) {
        const score = this.scores.get(hospital)!;
        // Rolling average update
        if (payload.data.satisfaction) {
          score.metrics.patientSatisfaction = Math.round(
            score.metrics.patientSatisfaction * 0.95 + payload.data.satisfaction * 0.05,
          );
        }
        if (payload.data.waitMinutes) {
          score.metrics.waitTime = Math.round(
            score.metrics.waitTime * 0.9 + payload.data.waitMinutes * 0.1,
          );
        }
        score.overallScore = this.calculateOverallScore(score.metrics);
        score.lastUpdated = new Date();

        this.eventBus.emit(HealthcareEvent.PERFORMANCE_SCORE_UPDATED, payload.userId, {
          hospitalName: hospital,
          overallScore: score.overallScore,
        });
      }
    });
  }

  private calculateOverallScore(metrics: HospitalScore['metrics']): number {
    // Weighted average — wait time inversely scored
    const waitScore = Math.max(0, 100 - metrics.waitTime);
    return Math.round(
      waitScore * 0.15 +
      metrics.patientSatisfaction * 0.25 +
      metrics.successRate * 0.25 +
      metrics.emergencyResponse * 0.15 +
      metrics.staffRating * 0.10 +
      metrics.facilityRating * 0.10,
    );
  }

  private initializeHospitalScores() {
    const hospitals: HospitalScore[] = [
      {
        hospitalName: 'jordan_university_hospital',
        hospitalNameAr: 'مستشفى الجامعة الأردنية',
        overallScore: 88,
        metrics: { waitTime: 25, patientSatisfaction: 90, successRate: 92, emergencyResponse: 85, staffRating: 88, facilityRating: 90 },
        specializations: ['internal_medicine', 'cardiology', 'neurology', 'oncology', 'surgery'],
        governorate: 'عمان',
        lastUpdated: new Date(),
      },
      {
        hospitalName: 'king_hussein_medical',
        hospitalNameAr: 'مستشفى الملك حسين الطبي',
        overallScore: 91,
        metrics: { waitTime: 20, patientSatisfaction: 93, successRate: 95, emergencyResponse: 92, staffRating: 90, facilityRating: 92 },
        specializations: ['military_medicine', 'surgery', 'orthopedics', 'cardiology', 'emergency'],
        governorate: 'عمان',
        lastUpdated: new Date(),
      },
      {
        hospitalName: 'al_bashir',
        hospitalNameAr: 'مستشفى البشير',
        overallScore: 78,
        metrics: { waitTime: 45, patientSatisfaction: 75, successRate: 82, emergencyResponse: 80, staffRating: 76, facilityRating: 72 },
        specializations: ['emergency', 'internal_medicine', 'surgery', 'pediatrics', 'obstetrics'],
        governorate: 'عمان',
        lastUpdated: new Date(),
      },
      {
        hospitalName: 'prince_hamza',
        hospitalNameAr: 'مستشفى الأمير حمزة',
        overallScore: 82,
        metrics: { waitTime: 30, patientSatisfaction: 82, successRate: 85, emergencyResponse: 83, staffRating: 80, facilityRating: 78 },
        specializations: ['internal_medicine', 'surgery', 'pediatrics', 'dermatology'],
        governorate: 'عمان',
        lastUpdated: new Date(),
      },
      {
        hospitalName: 'arab_medical_center',
        hospitalNameAr: 'المركز العربي الطبي',
        overallScore: 86,
        metrics: { waitTime: 15, patientSatisfaction: 88, successRate: 90, emergencyResponse: 82, staffRating: 87, facilityRating: 92 },
        specializations: ['cardiology', 'orthopedics', 'neurology', 'urology', 'ivf'],
        governorate: 'عمان',
        lastUpdated: new Date(),
      },
      {
        hospitalName: 'al_khalidi',
        hospitalNameAr: 'مستشفى الخالدي',
        overallScore: 85,
        metrics: { waitTime: 18, patientSatisfaction: 87, successRate: 88, emergencyResponse: 80, staffRating: 86, facilityRating: 90 },
        specializations: ['general_surgery', 'internal_medicine', 'pediatrics', 'ent'],
        governorate: 'عمان',
        lastUpdated: new Date(),
      },
      {
        hospitalName: 'istiklal',
        hospitalNameAr: 'مستشفى الاستقلال',
        overallScore: 76,
        metrics: { waitTime: 40, patientSatisfaction: 74, successRate: 80, emergencyResponse: 78, staffRating: 75, facilityRating: 70 },
        specializations: ['emergency', 'internal_medicine', 'orthopedics'],
        governorate: 'عمان',
        lastUpdated: new Date(),
      },
      {
        hospitalName: 'ibn_al_haytham',
        hospitalNameAr: 'مستشفى ابن الهيثم',
        overallScore: 83,
        metrics: { waitTime: 22, patientSatisfaction: 85, successRate: 86, emergencyResponse: 79, staffRating: 82, facilityRating: 84 },
        specializations: ['ophthalmology', 'internal_medicine', 'dermatology'],
        governorate: 'عمان',
        lastUpdated: new Date(),
      },
      {
        hospitalName: 'al_isra',
        hospitalNameAr: 'مستشفى الإسراء',
        overallScore: 80,
        metrics: { waitTime: 28, patientSatisfaction: 82, successRate: 84, emergencyResponse: 76, staffRating: 80, facilityRating: 80 },
        specializations: ['obstetrics', 'gynecology', 'pediatrics', 'internal_medicine'],
        governorate: 'عمان',
        lastUpdated: new Date(),
      },
      {
        hospitalName: 'jordan_hospital',
        hospitalNameAr: 'مستشفى الأردن',
        overallScore: 87,
        metrics: { waitTime: 16, patientSatisfaction: 89, successRate: 91, emergencyResponse: 84, staffRating: 88, facilityRating: 91 },
        specializations: ['cardiology', 'oncology', 'surgery', 'neurology', 'ivf'],
        governorate: 'عمان',
        lastUpdated: new Date(),
      },
    ];

    for (const h of hospitals) {
      this.scores.set(h.hospitalName, h);
    }

    this.logger.log(`Initialized ${hospitals.length} hospital performance scores`);
  }

  getScore(hospitalName: string): HospitalScore | undefined {
    return this.scores.get(hospitalName);
  }

  getAllScores(): HospitalScore[] {
    return Array.from(this.scores.values());
  }

  getTopHospitals(count = 5, specialization?: string): HospitalScore[] {
    let hospitals = this.getAllScores();
    if (specialization) {
      hospitals = hospitals.filter((h) => h.specializations.includes(specialization));
    }
    return hospitals
      .sort((a, b) => b.overallScore - a.overallScore)
      .slice(0, count);
  }

  getByGovernorate(governorate: string): HospitalScore[] {
    return this.getAllScores().filter((h) => h.governorate === governorate);
  }

  getRanking(): { rank: number; hospitalName: string; hospitalNameAr: string; score: number }[] {
    return this.getAllScores()
      .sort((a, b) => b.overallScore - a.overallScore)
      .map((h, i) => ({
        rank: i + 1,
        hospitalName: h.hospitalName,
        hospitalNameAr: h.hospitalNameAr,
        score: h.overallScore,
      }));
  }
}
