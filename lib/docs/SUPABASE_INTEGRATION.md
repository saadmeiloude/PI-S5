# Supabase Integration Guide

## Overview
Your Flutter healthcare app has been successfully integrated with Supabase. This provides authentication, real-time database, storage, and other backend services.

## Configuration

### Supabase Credentials
- **URL**: `https://vsdxqgjzttpdabcxwxro.supabase.co`
- **Anon Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZzZHhxZ2p6dHRwZGFiY3h3eHJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzMjgxODgsImV4cCI6MjA3NzkwNDE4OH0.uOeXsOUNCYFQFKMyZnqQz6t6-flSfWjKiKcoxsZElr8`

### Files Created/Modified
1. **lib/config/supabase_config.dart** - Supabase configuration and initialization
2. **lib/services/supabase_service.dart** - All database operations and authentication methods
3. **lib/providers/user_provider.dart** - Updated to use Supabase authentication
4. **lib/main.dart** - Updated to initialize Supabase
5. **pubspec.yaml** - Added supabase_flutter dependency
6. **lib/docs/supabase_schema.sql** - Database schema for setup

## Database Setup

### 1. Create Tables
Go to your Supabase dashboard → SQL Editor and run the commands from `lib/docs/supabase_schema.sql`

### 2. Key Tables
- **users** - User profiles and information
- **doctors** - Doctor profiles and details
- **appointments** - Appointment scheduling
- **consultations** - Consultation tracking
- **reviews** - Doctor ratings and reviews
- **notifications** - Push notifications

### 3. Storage Buckets
Create these storage buckets:
- `avatars` - User profile images
- `doctor-images` - Doctor profile images
- `documents` - Medical documents
- `prescriptions` - Prescription images

## Authentication Features

### Available Methods
```dart
// User registration
await UserProvider().register(
  name: 'John Doe',
  email: 'john@example.com',
  phone: '+1234567890',
  password: 'securepassword',
  birthDate: DateTime(1990, 1, 1),
);

// User login
await UserProvider().login(
  email: 'john@example.com',
  password: 'securepassword',
);

// Password reset
await UserProvider().resetPassword('john@example.com');

// Change password
await UserProvider().changePassword('newpassword');

// Update profile
await UserProvider().updateProfile(
  name: 'John Smith',
  phone: '+0987654321',
);

// Logout
await UserProvider().logout();
```

### Authentication State
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isAuthenticated) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
```

## Database Operations

### User Profile
```dart
// Get user profile
final userData = await SupabaseService.getUserProfile(userId);

// Create user profile
await SupabaseService.createUserProfile({
  'id': userId,
  'name': 'John Doe',
  'email': 'john@example.com',
  'phone': '+1234567890',
});

// Update user profile
await SupabaseService.updateUserProfile(userId, {
  'name': 'John Smith',
  'phone': '+0987654321',
});
```

### Doctors
```dart
// Get all doctors
final doctors = await SupabaseService.getDoctors();

// Get doctor details
final doctor = await SupabaseService.getDoctorDetails(doctorId);
```

### Appointments
```dart
// Get user appointments
final appointments = await SupabaseService.getUserAppointments(userId);

// Create appointment
final appointment = await SupabaseService.createAppointment({
  'user_id': userId,
  'doctor_id': doctorId,
  'appointment_date': '2024-12-01',
  'appointment_time': '14:30',
  'status': 'scheduled',
});

// Update appointment
await SupabaseService.updateAppointment(appointmentId, {
  'status': 'confirmed',
});

// Cancel appointment
await SupabaseService.cancelAppointment(appointmentId);
```

### Real-time Subscriptions
```dart
// Subscribe to appointment updates
final appointmentStream = SupabaseService.subscribeToAppointments(userId);
appointmentStream.listen((appointments) {
  // Handle appointment updates
});

// Subscribe to consultation updates
final consultationStream = SupabaseService.subscribeToConsultations(userId);
consultationStream.listen((consultations) {
  // Handle consultation updates
});
```

## Current Implementation Status

### ✅ Completed
- Supabase configuration and initialization
- User authentication (signup, login, logout, password reset)
- User profile management
- Database service with CRUD operations
- Real-time subscriptions framework
- Updated providers to use Supabase

### 🔄 To Be Implemented
- Doctor profile management
- Appointment scheduling flow
- Consultation management
- Real-time notifications
- File upload (avatars, documents)
- Push notifications
- Advanced search and filtering

## Environment Setup

### Development
1. Ensure Supabase dependencies are installed: `flutter pub get`
2. Run the SQL schema from `lib/docs/supabase_schema.sql` in your Supabase dashboard
3. Create necessary storage buckets
4. Run the app: `flutter run`

### Production
1. Set up proper environment variables
2. Configure domain settings in Supabase
3. Set up proper RLS policies
4. Enable authentication providers (Google, etc.)

## Security Considerations

- Row Level Security (RLS) is enabled on all tables
- User can only access their own data
- Authentication is required for all operations
- API keys should be kept secure (using environment variables in production)

## Next Steps

1. **Set up the database schema** in your Supabase project
2. **Test authentication flow** with the existing screens
3. **Implement additional features** as needed
4. **Add real-time features** for live updates
5. **Set up push notifications** for appointment reminders
6. **Configure file upload** for profile images and documents

## Troubleshooting

### Common Issues
1. **Authentication not working**: Check if user exists in auth.users table
2. **Database operations failing**: Verify RLS policies and user permissions
3. **Real-time not updating**: Check if subscriptions are properly set up

### Debug Tools
- Use Supabase Dashboard → Table Editor to check data
- Monitor logs in Supabase Dashboard → Logs
- Use Flutter DevTools for app debugging

## Support

For Supabase-specific issues, refer to:
- [Supabase Flutter Documentation](https://supabase.com/docs/reference/dart/getting-started)
- [Supabase Discord Community](https://discord.supabase.com/)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)