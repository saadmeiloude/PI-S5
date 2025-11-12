import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => SupabaseConfig.client;
  static User? get currentUser => client.auth.currentUser;

  // Authentication methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  static Future<void> updatePassword(String newPassword) async {
    await client.auth.updateUser(UserAttributes(password: newPassword));
  }

  // Database operations - Users
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await client
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

  static Future<void> createUserProfile(Map<String, dynamic> userData) async {
    await client.from('users').insert(userData);
  }

  static Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await client.from('users').update(data).eq('id', userId);
  }

  // Database operations - Doctors
  static Future<List<Map<String, dynamic>>> getDoctors() async {
    final response = await client
        .from('doctors')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  static Future<Map<String, dynamic>?> getDoctorDetails(String doctorId) async {
    final response = await client
        .from('doctors')
        .select()
        .eq('id', doctorId)
        .single();
    return response;
  }

  // Database operations - Appointments
  static Future<List<Map<String, dynamic>>> getUserAppointments(
    String userId,
  ) async {
    final response = await client
        .from('appointments')
        .select()
        .eq('user_id', userId)
        .order('appointment_date', ascending: true);
    return List<Map<String, dynamic>>.from(response as List);
  }

  static Future<Map<String, dynamic>?> createAppointment(
    Map<String, dynamic> appointmentData,
  ) async {
    final response = await client
        .from('appointments')
        .insert(appointmentData)
        .select()
        .single();
    return response;
  }

  static Future<void> updateAppointment(
    String appointmentId,
    Map<String, dynamic> data,
  ) async {
    await client.from('appointments').update(data).eq('id', appointmentId);
  }

  static Future<void> cancelAppointment(String appointmentId) async {
    await client
        .from('appointments')
        .update({'status': 'cancelled'})
        .eq('id', appointmentId);
  }

  // Database operations - Consultations
  static Future<List<Map<String, dynamic>>> getUserConsultations(
    String userId,
  ) async {
    final response = await client
        .from('consultations')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  static Future<Map<String, dynamic>?> createConsultation(
    Map<String, dynamic> consultationData,
  ) async {
    final response = await client
        .from('consultations')
        .insert(consultationData)
        .select()
        .single();
    return response;
  }

  // Real-time subscriptions
  static Stream<List<Map<String, dynamic>>> subscribeToAppointments(
    String userId,
  ) {
    return client
        .from('appointments')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('appointment_date', ascending: true)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  static Stream<List<Map<String, dynamic>>> subscribeToConsultations(
    String userId,
  ) {
    return client
        .from('consultations')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }
}
