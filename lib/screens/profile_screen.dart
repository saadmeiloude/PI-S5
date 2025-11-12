import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_widgets.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Helper widget for profile information item
  Widget _buildProfileInfoItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            if (onTap != null) ...[
              Icon(Icons.chevron_left, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(icon, color: Colors.grey.shade600, size: 20),
          ],
        ),
      ),
    );
  }

  // Helper widget for settings option
  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool hasSwitch = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              if (hasSwitch) ...[
                Switch(
                  value: switchValue,
                  onChanged: onSwitchChanged,
                  activeColor: const Color(0xFF00BFFF),
                  inactiveThumbColor: Colors.grey.shade300,
                  inactiveTrackColor: Colors.grey.shade200,
                ),
                const SizedBox(width: 12),
              ],
              if (!hasSwitch) ...[
                Icon(Icons.chevron_left, color: Colors.grey.shade400, size: 16),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(icon, color: const Color(0xFF00BFFF), size: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Profile image widget with edit capability
  Widget _buildProfileImage({
    required String name,
    required String? profileImage,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF00BFFF).withOpacity(0.1),
              backgroundImage: profileImage != null && profileImage.isNotEmpty
                  ? NetworkImage(profileImage)
                  : null,
              child: profileImage == null || profileImage.isEmpty
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '؟',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00BFFF),
                      ),
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF00BFFF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the Bottom Navigation Bar
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
      currentIndex: 3,
      elevation: 0,
      onTap: (index) {
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
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'الملف الشخصي',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF00BFFF)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.currentUser;

            if (user == null) {
              return const Center(child: Text('لا يوجد مستخدم مسجل دخول'));
            }

            // Check if profile is temporary (database not set up)
            final isTemporaryProfile =
                user.id.startsWith('temp_') ||
                user.name == 'مستخدم جديد' ||
                user.email.isEmpty;

            return SingleChildScrollView(
              child: Column(
                children: [
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
                                  'قاعدة البيانات غير مُعدة. يرجى تشغيل سكريبت الإعداد في Supabase للحصول على جميع الميزات.',
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

                  // Profile Header Section
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildProfileImage(
                          name: user.name,
                          profileImage: user.profileImage,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'تعديل الملف الشخصي',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                          },
                          backgroundColor: const Color(0xFF00BFFF),
                          width: 200,
                          height: 40,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Profile Information Section
                  CustomCard(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'معلومات الملف الشخصي',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildProfileInfoItem(
                          icon: Icons.person_outline,
                          title: 'الاسم',
                          value: user.name,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildProfileInfoItem(
                          icon: Icons.email_outlined,
                          title: 'البريد الإلكتروني',
                          value: user.email,
                        ),
                        const Divider(height: 1),
                        _buildProfileInfoItem(
                          icon: Icons.phone_outlined,
                          title: 'رقم الهاتف',
                          value: user.phone,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                        if (user.birthDate != null) ...[
                          const Divider(height: 1),
                          _buildProfileInfoItem(
                            icon: Icons.calendar_today_outlined,
                            title: 'تاريخ الميلاد',
                            value:
                                '${user.birthDate!.day}/${user.birthDate!.month}/${user.birthDate!.year}',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Settings Section
                  CustomCard(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الإعدادات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSettingsOption(
                          icon: Icons.notifications_outlined,
                          title: 'إدارة الإشعارات',
                          subtitle: 'تخصيص إشعارات التطبيق',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/notification_settings',
                            );
                          },
                        ),
                        _buildSettingsOption(
                          icon: Icons.lock_outline,
                          title: 'تغيير كلمة المرور',
                          subtitle: 'تحديث كلمة المرور الخاصة بك',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Scaffold(
                                  body: Center(
                                    child: Text('Password Change Screen'),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        _buildSettingsOption(
                          icon: Icons.security_outlined,
                          title: 'الخصوصية والأمان',
                          subtitle: 'إعدادات الأمان وحماية البيانات',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Scaffold(
                                  body: Center(
                                    child: Text('Privacy Settings Screen'),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        _buildSettingsOption(
                          icon: Icons.language_outlined,
                          title: 'اللغة',
                          subtitle: 'العربية (AR)',
                          onTap: () {
                            // Language settings
                          },
                        ),
                        _buildSettingsOption(
                          icon: Icons.help_outline,
                          title: 'المساعدة والدعم',
                          subtitle: 'الأسئلة الشائعة والدعم الفني',
                          onTap: () {
                            // Help & Support
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Account Section
                  CustomCard(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الحساب',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSettingsOption(
                          icon: Icons.analytics_outlined,
                          title: 'إحصائيات الحساب',
                          subtitle: 'عرض تفاصيل الاستخدام',
                          onTap: () {
                            // Account statistics
                          },
                        ),
                        _buildSettingsOption(
                          icon: Icons.delete_outline,
                          title: 'حذف الحساب',
                          subtitle: 'إزالة الحساب نهائياً',
                          onTap: () {
                            _showDeleteAccountDialog(context, userProvider);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CustomButton(
                      text: 'تسجيل الخروج',
                      onPressed: () {
                        _showLogoutDialog(context, userProvider);
                      },
                      backgroundColor: Colors.red.shade50,
                      textColor: Colors.red,
                      // borderRadius: 12.0, // Removed as CustomButton doesn't support this parameter
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                userProvider.logout();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    UserProvider userProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف الحساب'),
          content: const Text(
            'هل أنت متأكد من رغبتك في حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle account deletion
                userProvider.logout();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text(
                'حذف الحساب',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
