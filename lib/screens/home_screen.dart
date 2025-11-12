import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Helper widget for the search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const TextField(
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: 'ابحث عن الأطباء أو التخصصات',
          hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Color(0xFF00BFFF), size: 24),
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // Helper widget for the Upcoming Appointment card
  Widget _buildAppointmentCard(BuildContext context) {
    // Placeholder for the image
    Widget imagePlaceholder = Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3F2FD), Color(0xFFB3E5FC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.local_hospital,
          size: 48,
          color: const Color(0xFF00BFFF).withOpacity(0.7),
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imagePlaceholder,
          const SizedBox(height: 12),
          const Text(
            'موعد الدكتور عامر السليمان',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                'الأحد، 15 يوليو في 10:00 صباحاً',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for a single Suggested Doctor item
  Widget _buildDoctorItem(
    String name,
    String specialty,
    bool isFemale, {
    double rating = 0.0,
    String experience = '',
  }) {
    // Placeholder for the doctor's image (circular)
    Widget doctorImage = Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00BFFF).withOpacity(0.1),
            const Color(0xFF00BFFF).withOpacity(0.2),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00BFFF).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isFemale ? Icons.person_4_outlined : Icons.person_3_outlined,
          size: 36,
          color: const Color(0xFF00BFFF),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.end, // Align to the right for RTL
          children: [
            // Text content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end, // Align text to the right
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          specialty,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        if (rating > 0) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          Text(
                            rating.toString(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (experience.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        experience,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Image
            doctorImage,
          ],
        ),
      ),
    );
  }

  // Helper widget for quick actions
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF00BFFF), size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Emergency dialog
  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('طوارئ طبية', textAlign: TextAlign.center),
          content: const Text(
            'هل تحتاج إلى مساعدة طبية فورية؟',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                // Call emergency services
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جاري الاتصال بخدمات الطوارئ...'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('اتصل بالطوارئ'),
            ),
          ],
        );
      },
    );
  }

  // Helper widget for the Bottom Navigation Bar
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00BFFF),
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        currentIndex: 0, // Assuming 'Search' is the first tab
        elevation: 0,
        onTap: (index) {
          // Handle navigation
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/search');
              break;
            case 1:
              Navigator.pushNamed(context, '/appointments');
              break;
            case 2:
              Navigator.pushNamed(context, '/chat_list');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 24),
            label: 'البحث',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined, size: 24),
            label: 'المواعيد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 24),
            label: 'الاستشارات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24),
            label: 'الملف الشخصي',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Set the entire screen to RTL
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'الرئيسية',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00BFFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: Color(0xFF00BFFF),
                  size: 24,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/notification_settings');
                },
              ),
            ),
          ],
        ),
        body: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.currentUser;
            final isTemporaryProfile =
                user != null &&
                (user.id.startsWith('temp_') ||
                    user.name == 'مستخدم جديد' ||
                    user.email.isEmpty);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Database setup warning
                  if (isTemporaryProfile)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تحتاج إعداد قاعدة البيانات',
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'قاعدة البيانات غير مُعدة. يرجى تشغيل سكريبت الإعداد في Supabase.',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Welcome message
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF00BFFF), Color(0xFF87CEEB)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00BFFF).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.health_and_safety,
                          color: Colors.white,
                          size: 40,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'مرحباً بك في تطبيقنا',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'احجز موعدك مع أفضل الأطباء',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Quick Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickAction(
                        icon: Icons.search,
                        label: 'البحث عن طبيب',
                        onTap: () => Navigator.pushNamed(context, '/search'),
                      ),
                      _buildQuickAction(
                        icon: Icons.calendar_today,
                        label: 'المواعيد',
                        onTap: () =>
                            Navigator.pushNamed(context, '/appointments'),
                      ),
                      _buildQuickAction(
                        icon: Icons.chat,
                        label: 'الاستشارات',
                        onTap: () => Navigator.pushNamed(context, '/chat_list'),
                      ),
                      _buildQuickAction(
                        icon: Icons.medical_services,
                        label: 'الطوارئ',
                        onTap: () => _showEmergencyDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 1. Search Bar
                  _buildSearchBar(),
                  const SizedBox(height: 32),

                  // 2. Upcoming Appointments Section Title
                  const Text(
                    'المواعيد القادمة',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 16),

                  // 3. Appointment Card
                  _buildAppointmentCard(context),
                  const SizedBox(height: 32),

                  // 4. Suggested Doctors Section Title
                  const Text(
                    'الأطباء المقترحون',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 16),

                  // 5. Suggested Doctors List
                  _buildDoctorItem(
                    'الدكتورة لينا الراشد',
                    'أطباء الأسرة والأسنان',
                    true,
                    rating: 4.9,
                    experience: '15 سنة',
                  ),
                  _buildDoctorItem(
                    'الدكتور عامر السليمان',
                    'أطباء الأسرة والأسنان',
                    false,
                    rating: 4.7,
                    experience: '12 سنة',
                  ),
                  _buildDoctorItem(
                    'الدكتورة سارة محمد',
                    'طب الأطفال',
                    true,
                    rating: 4.8,
                    experience: '10 سنوات',
                  ),
                  // Add more doctors as needed
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }
}

// Example of how to use this screen in main.dart
/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Home Screen',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
*/
