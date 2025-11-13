import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailsScreen({super.key, required this.doctor});

  final Color _primaryColor = const Color(0xFF00BFFF); // Bright blue color

  // Helper widget for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  // Helper widget for the rating bar (e.g., 5-star rating)
  Widget _buildRatingBar(int star, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '${(percentage * 100).toInt()}%',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$star',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Helper widget for a single review item
  Widget _buildReviewItem(
    String reviewer,
    String time,
    int rating,
    String reviewText,
    int likes,
    int dislikes,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Reviewer Info
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    reviewer,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    time,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              // Placeholder for reviewer image
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 18,
              );
            }).reversed.toList(), // Reverse to display stars from right to left
          ),
          const SizedBox(height: 5),

          // Review Text
          Text(
            reviewText,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),

          // Likes/Dislikes
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('$dislikes', style: const TextStyle(color: Colors.grey)),
              const Icon(
                Icons.thumb_down_alt_outlined,
                color: Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 15),
              Text('$likes', style: const TextStyle(color: Colors.grey)),
              const Icon(
                Icons.thumb_up_alt_outlined,
                color: Colors.grey,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for available working hours
  Widget _buildWorkingHourItem(
    String days,
    String hours, {
    bool isClosed = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            isClosed ? 'مغلق' : hours,
            style: TextStyle(
              fontSize: 15,
              color: isClosed ? Colors.red : Colors.black,
              fontWeight: isClosed ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.right,
          ),
          const Spacer(),
          Text(
            days,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.calendar_today_outlined,
            color: Colors.grey,
            size: 20,
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
      currentIndex: 0, // Placeholder
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
            'تفاصيل الطبيب',
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
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. Doctor Info Section
                  Center(
                    child: Column(
                      children: [
                        // Doctor Image Placeholder
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal.shade600,
                            border: Border.all(
                              color: Colors.teal.shade100,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'التخصص: ${doctor.specialty}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'خبرة ${doctor.experienceYears} سنوات',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Qualifications Section
                  _buildSectionTitle('المؤهلات'),
                  Text(
                    doctor.qualifications,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),

                  // 3. Reviews Section
                  _buildSectionTitle('التقييمات'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating Bars (Left side in LTR, Right side in RTL)
                      Expanded(
                        child: Column(
                          children: [
                            _buildRatingBar(5, 0.75), // 75%
                            _buildRatingBar(4, 0.15), // 15%
                            _buildRatingBar(3, 0.05), // 5%
                            _buildRatingBar(2, 0.03), // 3%
                            _buildRatingBar(1, 0.02), // 2%
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Overall Rating (Right side in LTR, Left side in RTL)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            doctor.rating.toString(),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children:
                                List.generate(5, (index) {
                                      return Icon(
                                        index < doctor.rating.floor()
                                            ? Icons.star
                                            : (index < doctor.rating
                                                  ? Icons.star_half
                                                  : Icons.star_border),
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    }).reversed
                                    .toList(), // Reverse to display stars from right to left
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'تقييم ${doctor.reviewCount}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Individual Reviews
                  _buildReviewItem(
                    'محمد عبد الرحمن',
                    'قبل شهر',
                    5,
                    'تجربة ممتازة والدكتور مهني ومحترف',
                    50,
                    2,
                  ),
                  _buildReviewItem(
                    'ليلى أحمد',
                    'قبل شهرين',
                    3,
                    'الدكتور ممتاز ولكن المواعيد مزدحمة قليلاً',
                    5,
                    1,
                  ),
                  // Add more reviews here

                  // 4. Working Hours Section
                  _buildSectionTitle('ساعات العمل المتاحة'),
                  ...doctor.workingHours.map(
                    (hour) => _buildWorkingHourItem(
                      hour.days,
                      hour.hours,
                      isClosed: hour.isClosed,
                    ),
                  ),

                  // Padding for the fixed button at the bottom
                  const SizedBox(height: 100),
                ],
              ),
            ),

            // 5. Fixed Booking Button at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      final userProvider = Provider.of<UserProvider>(
                        context,
                        listen: false,
                      );
                      final chatProvider = Provider.of<ChatProvider>(
                        context,
                        listen: false,
                      );

                      if (userProvider.currentUser != null) {
                        // Create or get existing chat room
                        final chatRoomId = await chatProvider.createChatRoom(
                          doctorId: doctor.id,
                          patientId: userProvider.currentUser!.id,
                          doctorName: doctor.name,
                          patientName: userProvider.currentUser!.name,
                        );

                        if (chatRoomId != null) {
                          // Navigate to chat
                          Navigator.pushNamed(
                            context,
                            '/chat',
                            arguments: {
                              'chatRoomId': chatRoomId,
                              'doctorName': doctor.name,
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('فشل في إنشاء المحادثة'),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يجب تسجيل الدخول أولاً'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'حجز موعد',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
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
      title: 'Doctor Details Screen',
      debugShowCheckedModeBanner: false,
      home: DoctorDetailsScreen(),
    );
  }
}
*/
