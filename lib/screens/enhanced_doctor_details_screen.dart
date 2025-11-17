import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';

class EnhancedDoctorDetailsScreen extends StatelessWidget {
  final Doctor doctor;

  const EnhancedDoctorDetailsScreen({super.key, required this.doctor});

  final Color _primaryColor = const Color(0xFF00BFFF);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isPortrait = screenSize.height > screenSize.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: CustomScrollView(
          slivers: [
            // App Bar with doctor's image and basic info
            SliverAppBar(
              expandedHeight: isPortrait ? 300 : 200,
              pinned: true,
              backgroundColor: _primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  doctor.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00BFFF), Color(0xFF0095CC)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: isPortrait ? 120 : 80,
                          height: isPortrait ? 120 : 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Icon(
                            Icons.person,
                            size: isPortrait ? 60 : 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          doctor.specialty,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${doctor.rating} (${doctor.reviewCount} تقييم)',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('مشاركة تفاصيل الطبيب')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت إضافته للمفضلة')),
                    );
                  },
                ),
              ],
            ),

            // Main content
            SliverToBoxAdapter(
              child: isTablet && !isPortrait
                  ? _buildTabletLayout(context)
                  : _buildMobileLayout(context),
            ),
          ],
        ),
        floatingActionButton: isPortrait
            ? _buildFloatingActionButton(context)
            : null,
      ),
    );
  }

  // Mobile layout
  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick stats cards
          _buildQuickStatsCard(),
          const SizedBox(height: 20),

          // About section
          _buildAboutSection(),
          const SizedBox(height: 20),

          // Specialties section
          _buildSpecialtiesSection(),
          const SizedBox(height: 20),

          // Experience & qualifications
          _buildExperienceSection(),
          const SizedBox(height: 20),

          // Reviews section
          _buildReviewsSection(),
          const SizedBox(height: 20),

          // Working hours
          _buildWorkingHoursSection(),
          const SizedBox(height: 100), // Space for floating action button
        ],
      ),
    );
  }

  // Tablet layout
  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          // Top row with quick info and about
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick stats and about
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildQuickStatsCard(),
                    const SizedBox(height: 20),
                    _buildAboutSection(),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Specialties
              Expanded(flex: 1, child: _buildSpecialtiesSection()),
            ],
          ),
          const SizedBox(height: 20),

          // Experience and reviews
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _buildExperienceSection()),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: _buildReviewsSection()),
            ],
          ),
          const SizedBox(height: 20),

          // Working hours
          _buildWorkingHoursSection(),
        ],
      ),
    );
  }

  // Quick stats card
  Widget _buildQuickStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('التقييم', '${doctor.rating}', Icons.star),
              _buildStatItem(
                'التقييمات',
                '${doctor.reviewCount}',
                Icons.rate_review,
              ),
              _buildStatItem(
                'سنوات الخبرة',
                '${doctor.experienceYears}',
                Icons.work,
              ),
              _buildStatItem('المواقع', 'متعدد', Icons.location_on),
            ],
          ),
          const SizedBox(height: 20),
          // Rating distribution
          Row(
            children: [
              Expanded(child: _buildRatingBar(5, 0.8)),
              const SizedBox(width: 12),
              Expanded(child: _buildRatingBar(4, 0.15)),
              const SizedBox(width: 12),
              Expanded(child: _buildRatingBar(3, 0.03)),
              const SizedBox(width: 12),
              Expanded(child: _buildRatingBar(2, 0.02)),
              const SizedBox(width: 12),
              Expanded(child: _buildRatingBar(1, 0.0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _primaryColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Column(
      children: [
        Text(
          '$stars★',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00BFFF)),
          minHeight: 4,
        ),
      ],
    );
  }

  // About section
  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نبذة عن الطبيب',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'دكتور ${doctor.name} هو أخصائي في مجال ${doctor.specialty}، حاصل على ${doctor.qualifications} وله خبرة تزيد عن ${doctor.experienceYears} سنة في تقديم أفضل الخدمات الطبية للمرضى.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.medical_services,
                  color: Color(0xFF00BFFF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'متخصص في علاج وتشخيص الأمراض المتعلقة بـ ${doctor.specialty}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF00BFFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Specialties section
  Widget _buildSpecialtiesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'التخصصات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSpecialtyChip(doctor.specialty),
          const SizedBox(height: 8),
          // Add more specialties as needed
          _buildSpecialtyChip('استشارات طبية'),
          const SizedBox(height: 8),
          _buildSpecialtyChip('متابعة الحالات'),
          const SizedBox(height: 16),
          const Text(
            'الحالات التي يعالجها:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• علاج الأمراض المتعلقة بـ ${doctor.specialty}\n'
            '• استشارات طبية متخصصة\n'
            '• متابعة حالات المرضى\n'
            '• تقديم النصائح الطبية الوقائية\n'
            '• تقييم الحالة الصحية',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyChip(String specialty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Text(
        specialty,
        style: const TextStyle(
          color: Color(0xFF00BFFF),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  // Experience section
  Widget _buildExperienceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الخبرة والمؤهلات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.work,
                  color: Color(0xFF00BFFF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${doctor.experienceYears} سنة خبرة',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'خبرة مهنية متراكمة',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            doctor.qualifications,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.school, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'حاصل على شهادة الدكتوراه في التخصص',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Reviews section
  Widget _buildReviewsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تقييمات المرضى',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // This will be implemented later
                  print('عرض جميع التقييمات');
                },
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sample reviews
          _buildReviewItem(
            'أحمد محمد',
            'قبل شهر',
            5,
            'دكتور ممتاز ومتفهم، ساعدني كثيراً في تشخيص حالتي',
            15,
            1,
          ),
          const SizedBox(height: 12),
          _buildReviewItem(
            'فاطمة علي',
            'قبل شهرين',
            5,
            'خدمة طبية ممتازة وتعامل راقي',
            23,
            0,
          ),
          const SizedBox(height: 12),
          _buildReviewItem(
            'محمد السعيد',
            'قبل 3 أشهر',
            4,
            'طبيب ماهر وخبرة عالية في المجال',
            8,
            2,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(
    String reviewer,
    String time,
    int rating,
    String reviewText,
    int likes,
    int dislikes,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primaryColor,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewer,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reviewText,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('$likes'),
              const SizedBox(width: 4),
              Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 16),
              Text('$dislikes'),
              const SizedBox(width: 4),
              Icon(Icons.thumb_down, size: 16, color: Colors.grey[600]),
            ],
          ),
        ],
      ),
    );
  }

  // Working hours section
  Widget _buildWorkingHoursSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ساعات العمل',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...doctor.workingHours.map(
            (hour) => _buildWorkingHourItem(
              hour.days,
              hour.hours,
              isClosed: hour.isClosed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHourItem(
    String days,
    String hours, {
    bool isClosed = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isClosed ? Icons.close : Icons.access_time,
            color: isClosed ? Colors.red : _primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              days,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            isClosed ? 'مغلق' : hours,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isClosed ? Colors.red : _primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Floating action button for booking
  Widget _buildFloatingActionButton(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 56,
      child: FloatingActionButton.extended(
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
                  'doctorId': doctor.id,
                },
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('فشل في إنشاء المحادثة')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
            );
          }
        },
        backgroundColor: _primaryColor,
        icon: const Icon(Icons.chat, color: Colors.white),
        label: const Text(
          'احجز موعد',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
