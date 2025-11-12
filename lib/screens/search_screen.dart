import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  // Helper widget for the search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const TextField(
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: 'ابحث عن الأطباء أو التخصصات',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  // Helper widget for a filter chip
  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 14)),
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
    );
  }

  // Helper widget for a single Suggested Doctor item
  Widget _buildDoctorItem(String name, String specialty, String location) {
    // Placeholder for the doctor's image (rectangular with rounded corners)
    Widget doctorImage = Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1), // Light teal color
        borderRadius: BorderRadius.circular(10),
        // In a real app, replace with:
        // image: DecorationImage(image: AssetImage('assets/doctor_image.png'), fit: BoxFit.cover),
      ),
      child: Center(
        child: Icon(
          Icons.person_3_outlined,
          size: 40,
          color: Colors.teal.shade600,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Align to the right for RTL
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    'التخصص: $specialty',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    location,
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
      currentIndex: 0, // Assuming 'Search' is the selected tab
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
            Navigator.pushNamed(context, '/consultations');
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
            'البحث',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.black),
              onPressed: () {
                print('Filter pressed');
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),

              // 1. Search Bar
              _buildSearchBar(),
              const SizedBox(height: 15),

              // 2. Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true, // Scroll from right to left for RTL
                child: Row(
                  children: [
                    _buildFilterChip('التخصصات'),
                    _buildFilterChip('المواقع'),
                    _buildFilterChip('التقييمات'),
                    // Add more filters as needed
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 3. Suggested Doctors Section Title
              const Text(
                'الأطباء المقترحون',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 15),

              // 4. Suggested Doctors List
              _buildDoctorItem(
                'الدكتور عادل الرحمن',
                'أسنان',
                'المملكة العربية السعودية',
              ),
              _buildDoctorItem(
                'الدكتور عادل الرحمن',
                'أسنان',
                'المملكة العربية السعودية',
              ),
              _buildDoctorItem(
                'الدكتور عادل الرحمن',
                'أسنان',
                'المملكة العربية السعودية',
              ),
              // Add more doctors as needed
            ],
          ),
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
      title: 'Search Screen',
      debugShowCheckedModeBanner: false,
      home: SearchScreen(),
    );
  }
}
*/
