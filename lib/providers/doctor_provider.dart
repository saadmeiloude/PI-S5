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
        name: 'Mamadou Tourad  ',
        specialty: 'Medcin',
        location: 'Mauritania',
        rating: 4.8,
        reviewCount: 125,
        qualifications: 'Bac + 4',
        experienceYears: 10,
        workingHours: [
          WorkingHour(
            days: 'Lundi - Vendredi',
            hours: ' 9:00 matin -  5:00 Soir',
          ),
          WorkingHour(days: 'Samdi et vendredi ', hours: '', isClosed: true),
        ],
      ),
      Doctor(
        id: 'doc_002',
        name: '  Cheikh Dhib',
        specialty: ' Dentice',
        location: ' Mauritania ',
        rating: 4.5,
        reviewCount: 89,
        qualifications: 'Bac + 3',
        experienceYears: 8,
        workingHours: [
          WorkingHour(
            days: 'Lundi - Vendredi',
            hours: ' 8:00 matin -  4:00 Soir',
          ),
        ],
      ),
      Doctor(
        id: 'doc_003',
        name: 'Houtatou ',
        specialty: 'Docteure en yeux',
        location: '  Mauritania',
        rating: 4.9,
        reviewCount: 156,
        qualifications: 'Docteur de megebna ',
        experienceYears: 12,
        workingHours: [
          WorkingHour(
            days: 'Lundi - Dimanche ',
            hours: ' 8:00 matin -  4:00 Soir',
          ),
          WorkingHour(days: 'Vendredi', hours: 'matin 9:00 - Soir 1:00'),
        ],
      ),
      Doctor(
        id: 'doc_004',
        name: '  Moussa',
        specialty: 'Nez',
        location: '  Mauritania',
        rating: 4.3,
        reviewCount: 72,
        qualifications: 'Doctore Tercha',
        experienceYears: 6,
        workingHours: [
          WorkingHour(
            days: 'Lundi - Dimanche',
            hours: '8:00 matin -  4:00 Soir',
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
