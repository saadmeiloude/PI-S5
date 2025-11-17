import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AppointmentProvider with ChangeNotifier {
  final List<Appointment> _appointments = [];

  List<Appointment> get appointments => List.unmodifiable(_appointments);
  List<Appointment> get upcomingAppointments => _appointments
      .where(
        (apt) =>
            apt.date.isAfter(DateTime.now()) &&
            apt.status == AppointmentStatus.scheduled,
      )
      .toList();
  List<Appointment> get pastAppointments => _appointments
      .where(
        (apt) =>
            apt.date.isBefore(DateTime.now()) ||
            apt.status == AppointmentStatus.completed,
      )
      .toList();

  // Initialize with sample data
  AppointmentProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final now = DateTime.now();
    _appointments.addAll([
      Appointment(
        id: 'apt_001',
        doctorId: 'doc_001',
        doctorName: 'الدكتور عامر السليمان',
        specialty: 'جراحة العظام',
        date: now.add(Duration(days: 2, hours: 10)),
        time: '10:00 صباحاً',
        status: AppointmentStatus.scheduled,
      ),
      Appointment(
        id: 'apt_002',
        doctorId: 'doc_002',
        doctorName: 'الدكتور ماجد العلي',
        specialty: 'أطباء الأسرة والأسنان',
        date: now.add(Duration(days: 5, hours: 14)),
        time: '2:00 عصراً',
        status: AppointmentStatus.scheduled,
      ),
      Appointment(
        id: 'apt_003',
        doctorId: 'doc_003',
        doctorName: 'الدكتورة سارة أحمد',
        specialty: 'طب الأطفال',
        date: now.subtract(Duration(days: 7, hours: 9)),
        time: '9:00 صباحاً',
        status: AppointmentStatus.completed,
      ),
      Appointment(
        id: 'apt_004',
        doctorId: 'doc_004',
        doctorName: 'الدكتور محمد حسن',
        specialty: 'أمراض القلب',
        date: now.add(Duration(days: 1, hours: 16)),
        time: '4:00 عصراً',
        status: AppointmentStatus.scheduled,
      ),
    ]);
  }

  // Book a new appointment
  Future<bool> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String specialty,
    required DateTime date,
    required String time,
    String? notes,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final appointment = Appointment(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
      doctorId: doctorId,
      doctorName: doctorName,
      specialty: specialty,
      date: date,
      time: time,
      status: AppointmentStatus.scheduled,
      notes: notes,
    );

    _appointments.add(appointment);
    notifyListeners();
    return true;
  }

  // Cancel an appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        status: AppointmentStatus.cancelled,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  // Reschedule an appointment
  Future<bool> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDate,
    required String newTime,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        date: newDate,
        time: newTime,
        status: AppointmentStatus.rescheduled,
      );
      notifyListeners();
      return true;
    }
    return false;
  }
}

// Extension to add copyWith method to Appointment
extension AppointmentCopyWith on Appointment {
  Appointment copyWith({
    DateTime? date,
    String? time,
    AppointmentStatus? status,
    String? notes,
  }) {
    return Appointment(
      id: id,
      doctorId: doctorId,
      doctorName: doctorName,
      specialty: specialty,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
