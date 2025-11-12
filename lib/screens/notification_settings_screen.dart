import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // State variables for the switches
  bool _appointmentNotifications = true;
  bool _appointmentReminders = true;
  bool _newOffers = false;
  bool _appUpdates = true;

  // Helper widget for a single notification setting item
  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Switch (on the left in RTL)
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors
                .black, // Assuming the active color is black or a dark color
            inactiveThumbColor: Colors.grey.shade300,
            inactiveTrackColor: Colors.grey.shade200,
          ),
          const SizedBox(width: 10),
          // Text content (on the right in RTL)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.right,
                  softWrap: true,
                ),
              ],
            ),
          ),
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
      currentIndex:
          3, // Assuming 'Profile' is the selected tab where this screen is accessed from
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
          icon: Icon(Icons.person, size: 24),
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
            'الإشعارات',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop(); // Navigate back
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
                child: Text(
                  'إعدادات الإشعارات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),

              // 1. Appointment Notifications
              _buildNotificationItem(
                title: 'إشعارات المواعيد',
                subtitle: 'تلقي إشعارات بخصوص المواعيد الخاصة بك.',
                value: _appointmentNotifications,
                onChanged: (bool newValue) {
                  setState(() {
                    _appointmentNotifications = newValue;
                  });
                },
              ),
              const Divider(height: 1, color: Colors.grey),

              // 2. Appointment Reminders
              _buildNotificationItem(
                title: 'تذكيرات المواعيد',
                subtitle: 'تلقي تنبيهات بخصوص التذكيرات المهمة لمواعيدك.',
                value: _appointmentReminders,
                onChanged: (bool newValue) {
                  setState(() {
                    _appointmentReminders = newValue;
                  });
                },
              ),
              const Divider(height: 1, color: Colors.grey),

              // 3. New Offers
              _buildNotificationItem(
                title: 'العروض الجديدة',
                subtitle:
                    'تلقي إشعارات بخصوص العروض الجديدة والخصومات المتاحة.',
                value: _newOffers,
                onChanged: (bool newValue) {
                  setState(() {
                    _newOffers = newValue;
                  });
                },
              ),
              const Divider(height: 1, color: Colors.grey),

              // 4. App Updates
              _buildNotificationItem(
                title: 'تحديثات التطبيق',
                subtitle:
                    'تلقي إشعارات بخصوص تحديثات التطبيق والميزات الجديدة.',
                value: _appUpdates,
                onChanged: (bool newValue) {
                  setState(() {
                    _appUpdates = newValue;
                  });
                },
              ),
              const Divider(height: 1, color: Colors.grey),
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
      title: 'Notification Settings Screen',
      debugShowCheckedModeBanner: false,
      home: NotificationSettingsScreen(),
    );
  }
}
*/
