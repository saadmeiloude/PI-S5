import 'package:flutter/material.dart';

class ConsultationsScreen extends StatefulWidget {
  const ConsultationsScreen({super.key});

  @override
  State<ConsultationsScreen> createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper widget for a single consultation item
  Widget _buildConsultationItem(String type, String date, bool isMale) {
    // Placeholder for the doctor's image (circular)
    Widget doctorImage = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.teal.shade600,
        border: Border.all(color: Colors.teal.shade100, width: 2),
      ),
      child: Center(
        child: Icon(
          isMale ? Icons.person_3_outlined : Icons.person_4_outlined,
          size: 30,
          color: Colors.white,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Align to the right for RTL
        children: [
          // Text content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end, // Align text to the right
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    date,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
          // Image
          doctorImage,
        ],
      ),
    );
  }

  // Helper widget for the Bottom Navigation Bar (reused from home_screen)
  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
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
      currentIndex: 2, // Assuming 'Consultations' is the selected tab
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
            'الاستشارات',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop(); // Navigate back
            },
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
            indicatorWeight: 3.0,
            tabs: const [
              Tab(text: 'الاستشارات الحالية'),
              Tab(text: 'الاستشارات السابقة'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Current Consultations Tab
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Column(
                children: [
                  _buildConsultationItem(
                    'استشارة فيديو',
                    'الأحد، 15 مايو',
                    true,
                  ),
                  _buildConsultationItem(
                    'استشارة نصية',
                    'الأحد، 15 مايو',
                    false,
                  ),
                  // Add more current consultations here
                ],
              ),
            ),

            // Previous Consultations Tab (Placeholder)
            const Center(
              child: Text(
                'لا توجد استشارات سابقة',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
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
      title: 'Consultations Screen',
      debugShowCheckedModeBanner: false,
      home: ConsultationsScreen(),
    );
  }
}
*/
