import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
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

  // Storage operations
  static Future<String?> uploadProfileImage(
    String userId,
    String imagePath,
  ) async {
    try {
      // For web platform, we'll use a placeholder or skip upload for now
      // In a real implementation, you would need to handle web file uploads
      if (kIsWeb) {
        debugPrint('Web platform detected - image upload not implemented yet');
        return null;
      }

      // Read the image file
      final file = File(imagePath);
      if (!await file.exists()) return null;

      // Create unique filename
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload to Supabase Storage
      await client.storage
          .from('profile-images') // Bucket name
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true, // Overwrite if exists
            ),
          );

      // Get public URL
      final publicUrl = client.storage
          .from('profile-images')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  static Future<void> deleteProfileImage(String imageUrl) async {
    try {
      // For web platform, skip deletion
      if (kIsWeb) {
        debugPrint('Web platform detected - image deletion skipped');
        return;
      }

      // Extract filename from URL
      final uri = Uri.parse(imageUrl);
      final fileName = uri.pathSegments.last;

      // Delete from storage
      await client.storage.from('profile-images').remove([fileName]);
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
    }
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

  // Database operations - Chat Rooms
  static Future<List<Map<String, dynamic>>> getUserChatRooms(
    String userId,
  ) async {
    // Get chat rooms where user is doctor
    final doctorRooms = await client
        .from('chat_rooms')
        .select()
        .eq('doctor_id', userId)
        .order('created_at', ascending: false);

    // Get chat rooms where user is patient
    final patientRooms = await client
        .from('chat_rooms')
        .select()
        .eq('patient_id', userId)
        .order('created_at', ascending: false);

    final allRooms = [...doctorRooms, ...patientRooms];
    return List<Map<String, dynamic>>.from(allRooms as List);
  }

  static Future<Map<String, dynamic>?> createChatRoom(
    Map<String, dynamic> chatRoomData,
  ) async {
    final response = await client
        .from('chat_rooms')
        .insert(chatRoomData)
        .select()
        .single();
    return response;
  }

  // Database operations - Messages
  static Future<List<Map<String, dynamic>>> getChatMessages(
    String chatRoomId,
  ) async {
    final response = await client
        .from('messages')
        .select()
        .eq('chat_room_id', chatRoomId)
        .order('timestamp', ascending: true);
    return List<Map<String, dynamic>>.from(response as List);
  }

  static Future<Map<String, dynamic>?> sendMessage(
    Map<String, dynamic> messageData,
  ) async {
    final response = await client
        .from('messages')
        .insert(messageData)
        .select()
        .single();
    return response;
  }

  static Future<void> deleteMessage(String messageId) async {
    await client.from('messages').delete().eq('id', messageId);
  }

  // Real-time subscriptions for chat - TODO: Implement when stream 'or' is fixed
  // static Stream<List<Map<String, dynamic>>> subscribeToMessages(
  //   String chatRoomId,
  // ) {
  //   return client
  //       .from('messages')
  //       .stream(primaryKey: ['id'])
  //       .eq('chat_room_id', chatRoomId)
  //       .order('timestamp', ascending: true)
  //       .map((data) => List<Map<String, dynamic>>.from(data));
  // }

  // static Stream<List<Map<String, dynamic>>> subscribeToChatRooms(
  //   String userId,
  // ) {
  //   return client
  //       .from('chat_rooms')
  //       .stream(primaryKey: ['id'])
  //       .or('doctor_id.eq.$userId,patient_id.eq.$userId')
  //       .order('created_at', ascending: false)
  //       .map((data) => List<Map<String, dynamic>>.from(data));
  // }
}
