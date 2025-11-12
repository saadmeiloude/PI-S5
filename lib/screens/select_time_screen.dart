import 'package:flutter/material.dart';

class SelectTimeScreen extends StatefulWidget {
  const SelectTimeScreen({super.key});

  @override
  State<SelectTimeScreen> createState() => _SelectTimeScreenState();
}

class _SelectTimeScreenState extends State<SelectTimeScreen> {
  final Color _primaryColor = const Color(0xFF00BFFF); // Bright blue color
  int _selectedDate = 5; // Placeholder for selected date
  String? _selectedTime; // Placeholder for selected time

  // Helper widget for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  // Helper widget for a single date cell in the calendar
  Widget _buildDateCell(int date) {
    bool isSelected = date == _selectedDate;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Text(
          date.toString(),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Helper widget for a single time slot chip
  Widget _buildTimeChip(String time) {
    bool isSelected = time == _selectedTime;
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTime = time;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _primaryColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? _primaryColor : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            time,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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
      currentIndex: 1, // Assuming 'Appointments' is the selected tab
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
    // Days of the week in Arabic (reversed for RTL display)
    const List<String> daysOfWeek = ['س', 'ج', 'خ', 'أ', 'ث', 'م', 'ح'];
    // Dates for June 2024 (example)
    const List<int> dates = [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
      24,
      25,
      26,
      27,
      28,
      29,
      30,
    ];
    // Time slots
    const List<String> timeSlots = [
      '10:00 ص',
      '11:00 ص',
      '12:00 ص',
      '1:00 م',
      '2:00 م',
      '3:00 م',
    ];

    return Directionality(
      textDirection: TextDirection.rtl, // Set the entire screen to RTL
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'اختر الوقت',
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
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 1. Date Section Title
                    _buildSectionTitle('التاريخ'),

                    // 2. Month Navigation
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.arrow_back_ios,
                            size: 18,
                          ), // Left arrow (Next month in RTL)
                          const Text(
                            'يونيو 2024',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ), // Right arrow (Previous month in RTL)
                        ],
                      ),
                    ),

                    // 3. Days of the Week (Grid Header)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                        itemCount: daysOfWeek.length,
                        itemBuilder: (context, index) {
                          return Center(
                            child: Text(
                              daysOfWeek[index],
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // 4. Calendar Dates (Grid)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                      itemCount:
                          35, // 5 rows * 7 days (to simulate the calendar layout)
                      itemBuilder: (context, index) {
                        // Calculate the date index, assuming the month starts on the 1st
                        int dateIndex =
                            index -
                            3; // Adjust for the 3 empty cells before the 1st
                        if (dateIndex >= 0 && dateIndex < dates.length) {
                          return _buildDateCell(dates[dateIndex]);
                        }
                        return Container(); // Empty cell for padding
                      },
                    ),

                    // 5. Time Section Title
                    _buildSectionTitle('الوقت'),

                    // 6. Time Slots (Wrap for flow layout)
                    Wrap(
                      alignment: WrapAlignment.end, // Align chips to the right
                      children: timeSlots
                          .map((time) => _buildTimeChip(time))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 7. Confirm Button (Fixed at the bottom)
            Padding(
              padding: const EdgeInsets.only(
                left: 25.0,
                right: 25.0,
                bottom: 30.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _selectedTime != null
                      ? () {
                          // Action for Confirm Appointment
                          print(
                            'Confirm Appointment pressed for date $_selectedDate and time $_selectedTime',
                          );
                        }
                      : null, // Disable button if no time is selected
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'تأكيد الموعد',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // 8. Bottom Navigation Bar
            _buildBottomNavBar(context),
          ],
        ),
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
      title: 'Select Time Screen',
      debugShowCheckedModeBanner: false,
      home: SelectTimeScreen(),
    );
  }
}
*/
