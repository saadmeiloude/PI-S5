import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/doctor_provider.dart';
import 'providers/chat_provider.dart';
import 'config/supabase_config.dart';
import 'screens/splash_screen.dart';
import 'screens/home.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cree-un-compt.dart';
import 'screens/chek-email.dart';
import 'screens/verification du-code.dart';
import 'screens/set_password.dart';
import 'screens/password_changed_screen.dart';
import 'screens/search_screen.dart';
import 'screens/doctor_details_screen.dart';
import 'screens/select_time_screen.dart';
import 'screens/consultations_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/restart-mot-de-passe.dart';
import 'screens/chat_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/video_call_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  await NotificationService.initialize();

  // Initialize user provider after Supabase is ready
  final userProvider = UserProvider();
  await userProvider.initializeUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'PI 2025',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00BFFF),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              elevation: 0,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Color(0xFF00BFFF),
                width: 2.0,
              ),
            ),
          ),
        ),
        initialRoute: '/welcome',
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/splash': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/create_account': (context) => const CreateAccountScreen(),
          '/check_email': (context) => const CheckEmailScreen(),
          '/verification': (context) => const VerificationScreen(),
          '/set_password': (context) => const SetPasswordScreen(),
          '/password_changed': (context) => const PasswordChangedScreen(),
          '/search': (context) => const SearchScreen(),
          '/doctor_details': (context) => const DoctorDetailsScreen(),
          '/select_time': (context) => const SelectTimeScreen(),
          '/consultations': (context) => const ConsultationsScreen(),
          '/appointments': (context) => const AppointmentsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/notification_settings': (context) =>
              const NotificationSettingsScreen(),
          '/forgot_password': (context) => const ForgotPasswordScreen(),
          '/chat': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, String>;
            return ChatScreen(
              chatRoomId: args['chatRoomId']!,
              doctorName: args['doctorName']!,
            );
          },
          '/chat_list': (context) => const ChatListScreen(),
          '/video_call': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
            return VideoCallScreen(
              channelName: args['channelName']!,
              doctorName: args['doctorName']!,
              isVideoCall: args['isVideoCall'] ?? true,
            );
          },
        },
      ),
    );
  }
}
