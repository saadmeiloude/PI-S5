import 'package:flutter/foundation.dart';
import '../models/user.dart';

class DoctorProvider with ChangeNotifier {
  final List<Doctor> _doctors = [];

  List<Doctor> get doctors => List.unmodifiable(_doctors);

  // Initialize with sample data
  DoctorProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    _doctors.addAll([
      Doctor(
        id: 'doc_001',
        name: 'الدكتور محمد توراد',
        specialty: 'طب عام',
        location: 'موريتانيا',
        rating: 4.8,
        reviewCount: 125,
        qualifications: 'بكالوريوس + 4',
        experienceYears: 10,
        workingHours: [
          WorkingHour(
            days: 'الاثنين - الجمعة',
            hours: '9:00 صباحاً - 5:00 مساءً',
          ),
          WorkingHour(days: 'السبت والجمعة', hours: '', isClosed: true),
        ],
      ),
      Doctor(
        id: 'doc_002',
        name: 'الدكتور الشيخ ذيب',
        specialty: 'أسنان',
        location: 'موريتانيا',
        rating: 4.5,
        reviewCount: 89,
        qualifications: 'بكالوريوس + 3',
        experienceYears: 8,
        workingHours: [
          WorkingHour(
            days: 'الاثنين - الجمعة',
            hours: '8:00 صباحاً - 4:00 مساءً',
          ),
        ],
      ),
      Doctor(
        id: 'doc_003',
        name: 'الدكتورة هوتاتو',
        specialty: 'عيون',
        location: 'موريتانيا',
        rating: 4.9,
        reviewCount: 156,
        qualifications: 'دكتور في الطب',
        experienceYears: 12,
        workingHours: [
          WorkingHour(
            days: 'الاثنين - الأحد',
            hours: '8:00 صباحاً - 4:00 مساءً',
          ),
          WorkingHour(days: 'الجمعة', hours: '9:00 صباحاً - 1:00 مساءً'),
        ],
      ),
      Doctor(
        id: 'doc_004',
        name: 'الدكتور موسى',
        specialty: 'أنف وأذن وحنجرة',
        location: 'موريتانيا',
        rating: 4.3,
        reviewCount: 72,
        qualifications: 'دكتور في الطب',
        experienceYears: 6,
        workingHours: [
          WorkingHour(
            days: 'الاثنين - الأحد',
            hours: '8:00 صباحاً - 4:00 مساءً',
          ),
        ],
      ),
    ]);
  }

  // Search doctors by specialty or name
  List<Doctor> searchDoctors(String query) {
    if (query.isEmpty) return _doctors;

    return _doctors
        .where(
          (doctor) =>
              doctor.name.toLowerCase().contains(query.toLowerCase()) ||
              doctor.specialty.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Get doctor by ID
  Doctor? getDoctorById(String id) {
    try {
      return _doctors.firstWhere((doctor) => doctor.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get doctors by specialty
  List<Doctor> getDoctorsBySpecialty(String specialty) {
    return _doctors
        .where(
          (doctor) =>
              doctor.specialty.toLowerCase().contains(specialty.toLowerCase()),
        )
        .toList();
  }

  // Get top rated doctors
  List<Doctor> getTopRatedDoctors() {
    return _doctors.where((doctor) => doctor.rating >= 4.5).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  // Add a review to a doctor
  Future<bool> addReview({
    required String doctorId,
    required String reviewer,
    required int rating,
    required String reviewText,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would update the doctor's rating and reviews
    // For demo purposes, just return true
    return true;
  }
}
