import 'package:flutter_test/flutter_test.dart';
import 'package:pi_2025/models/user.dart';
import 'package:pi_2025/providers/user_provider.dart';
import 'package:pi_2025/providers/appointment_provider.dart';
import 'package:pi_2025/providers/doctor_provider.dart';

void main() {
  group('User Model Tests', () {
    test('should create user from JSON', () {
      final json = {
        'id': 'test_id',
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': '0501234567',
        'birthDate': '1990-01-01T00:00:00.000',
      };

      final user = User.fromJson(json);

      expect(user.id, 'test_id');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.phone, '0501234567');
      expect(user.birthDate, DateTime(1990, 1, 1));
    });

    test('should convert user to JSON', () {
      final user = User(
        id: 'test_id',
        name: 'Test User',
        email: 'test@example.com',
        phone: '0501234567',
        birthDate: DateTime(1990, 1, 1),
      );

      final json = user.toJson();

      expect(json['id'], 'test_id');
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['phone'], '0501234567');
      expect(json['birthDate'], '1990-01-01T00:00:00.000Z');
    });

    test('should copy user with new values', () {
      final originalUser = User(
        id: 'test_id',
        name: 'Test User',
        email: 'test@example.com',
        phone: '0501234567',
      );

      final updatedUser = originalUser.copyWith(
        name: 'Updated User',
        email: 'updated@example.com',
      );

      expect(updatedUser.id, originalUser.id); // Should remain the same
      expect(updatedUser.name, 'Updated User'); // Should be updated
      expect(updatedUser.email, 'updated@example.com'); // Should be updated
      expect(updatedUser.phone, originalUser.phone); // Should remain the same
    });
  });

  group('UserProvider Tests', () {
    test('should login successfully with valid credentials', () async {
      final userProvider = UserProvider();

      final result = await userProvider.login(
        'test@example.com',
        'password123',
      );

      expect(result, true);
      expect(userProvider.isAuthenticated, true);
      expect(userProvider.currentUser, isNotNull);
    });

    test('should fail login with empty credentials', () async {
      final userProvider = UserProvider();

      final result = await userProvider.login('', '');

      expect(result, false);
      expect(userProvider.isAuthenticated, false);
      expect(userProvider.currentUser, isNull);
    });

    test('should register new user successfully', () async {
      final userProvider = UserProvider();

      final result = await userProvider.register(
        name: 'Test User',
        email: 'test@example.com',
        phone: '0501234567',
        password: 'password123',
      );

      expect(result, true);
      expect(userProvider.isAuthenticated, true);
      expect(userProvider.currentUser, isNotNull);
      expect(userProvider.currentUser!.name, 'Test User');
      expect(userProvider.currentUser!.email, 'test@example.com');
    });

    test('should logout user successfully', () async {
      final userProvider = UserProvider();

      // First login
      await userProvider.login('test@example.com', 'password123');
      expect(userProvider.isAuthenticated, true);

      // Then logout
      userProvider.logout();
      expect(userProvider.isAuthenticated, false);
      expect(userProvider.currentUser, isNull);
    });
  });

  group('AppointmentProvider Tests', () {
    test('should initialize with sample appointments', () {
      final appointmentProvider = AppointmentProvider();

      expect(appointmentProvider.appointments.length, greaterThan(0));
      expect(appointmentProvider.upcomingAppointments.length, greaterThan(0));
    });

    test('should book new appointment', () async {
      final appointmentProvider = AppointmentProvider();
      final initialCount = appointmentProvider.appointments.length;

      final result = await appointmentProvider.bookAppointment(
        doctorId: 'doc_123',
        doctorName: 'Test Doctor',
        specialty: 'Test Specialty',
        date: DateTime.now().add(const Duration(days: 1)),
        time: '10:00 AM',
      );

      expect(result, true);
      expect(appointmentProvider.appointments.length, initialCount + 1);
    });

    test('should cancel appointment', () async {
      final appointmentProvider = AppointmentProvider();

      // Find first appointment to cancel
      final firstAppointment = appointmentProvider.appointments.first;
      final result = await appointmentProvider.cancelAppointment(
        firstAppointment.id,
      );

      expect(result, true);
      // Note: In real implementation, you'd check the status change
    });
  });

  group('DoctorProvider Tests', () {
    test('should initialize with sample doctors', () {
      final doctorProvider = DoctorProvider();

      expect(doctorProvider.doctors.length, greaterThan(0));
    });

    test('should search doctors by name or specialty', () {
      final doctorProvider = DoctorProvider();

      final results = doctorProvider.searchDoctors('عامر');

      expect(results.length, greaterThan(0));
      expect(results.first.name, contains('عامر'));
    });

    test('should get doctors by specialty', () {
      final doctorProvider = DoctorProvider();

      final results = doctorProvider.getDoctorsBySpecialty('أسنان');

      expect(results.length, greaterThan(0));
      expect(results.first.specialty, contains('أسنان'));
    });

    test('should get top rated doctors', () {
      final doctorProvider = DoctorProvider();

      final results = doctorProvider.getTopRatedDoctors();

      expect(results.length, greaterThan(0));
      expect(results.first.rating, greaterThanOrEqualTo(4.5));
    });
  });
}
