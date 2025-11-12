import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../models/user.dart';
import '../widgets/custom_widgets.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _showUpcomingOnly = false;

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

  // Helper method to format date in Arabic
  String _formatDate(DateTime date) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }

  // Helper method to get time until appointment
  String _getTimeUntilAppointment(DateTime appointmentDate) {
    final now = DateTime.now();
    final difference = appointmentDate.difference(now);

    if (difference.isNegative) {
      return 'انتهت';
    }

    if (difference.inDays > 0) {
      return 'خلال ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'خلال ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'خلال ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  // Show confirmation dialog for cancel
  Future<void> _showCancelDialog(Appointment appointment) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('إلغاء الموعد'),
            content: const Text('هل أنت متأكد من إلغاء هذا الموعد؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _cancelAppointment(appointment);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('تأكيد الإلغاء'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Cancel appointment
  Future<void> _cancelAppointment(Appointment appointment) async {
    try {
      final success = await context
          .read<AppointmentProvider>()
          .cancelAppointment(appointment.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إلغاء الموعد بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في إلغاء الموعد'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Show reschedule options
  Future<void> _showRescheduleOptions(Appointment appointment) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RescheduleBottomSheet(appointment: appointment),
    );
  }

  // Build appointment card
  Widget _buildAppointmentCard(Appointment appointment, bool isUpcoming) {
    final isCancelled = appointment.status == AppointmentStatus.cancelled;
    final isCompleted = appointment.status == AppointmentStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge and time until appointment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isUpcoming && !isCancelled && !isCompleted
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isUpcoming && !isCancelled && !isCompleted
                        ? _getTimeUntilAppointment(appointment.date)
                        : _getStatusText(appointment.status),
                    style: TextStyle(
                      color: isUpcoming && !isCancelled && !isCompleted
                          ? Colors.blue
                          : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isUpcoming && !isCancelled && !isCompleted)
                  Text(
                    appointment.time,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Doctor info
            Row(
              children: [
                // Doctor avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue[400]!, Colors.blue[600]!],
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 16),

                // Doctor details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.specialty,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(appointment.date),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isUpcoming && !isCancelled && !isCompleted) ...[
                  // Cancel button
                  TextButton(
                    onPressed: () => _showCancelDialog(appointment),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('إلغاء'),
                  ),

                  const SizedBox(width: 8),

                  // Reschedule button
                  ElevatedButton(
                    onPressed: () => _showRescheduleOptions(appointment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('إعادة الجدولة'),
                  ),
                ] else if (isCompleted) ...[
                  // Reschedule button for completed appointments
                  ElevatedButton(
                    onPressed: () => _showRescheduleOptions(appointment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('حجز موعد جديد'),
                  ),
                ],
              ],
            ),

            // Notes section if available
            if (appointment.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.notes!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Get status text in Arabic
  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'مجدول';
      case AppointmentStatus.completed:
        return 'مكتمل';
      case AppointmentStatus.cancelled:
        return 'ملغي';
      case AppointmentStatus.rescheduled:
        return 'مؤجل';
    }
  }

  // Build search bar
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'البحث عن طبيب أو تخصص...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  // Filter appointments based on search query
  List<Appointment> _filterAppointments(List<Appointment> appointments) {
    if (_searchQuery.isEmpty) return appointments;

    return appointments
        .where(
          (appointment) =>
              appointment.doctorName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              appointment.specialty.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  // Build empty state
  Widget _buildEmptyState(bool isUpcoming) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUpcoming ? Icons.calendar_today : Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isUpcoming ? 'لا توجد مواعيد قادمة' : 'لا توجد مواعيد سابقة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isUpcoming
                ? 'احجز موعداً جديداً مع طبيب'
                : 'سيتم عرض مواعيدك السابقة هنا',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'المواعيد',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(text: 'المواعيد القادمة'),
              Tab(text: 'المواعيد السابقة'),
            ],
          ),
        ),
        body: Consumer<AppointmentProvider>(
          builder: (context, appointmentProvider, child) {
            final upcomingAppointments = _filterAppointments(
              appointmentProvider.upcomingAppointments,
            );
            final pastAppointments = _filterAppointments(
              appointmentProvider.pastAppointments,
            );

            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildSearchBar(),
                ),

                // Tab views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Upcoming appointments
                      upcomingAppointments.isEmpty
                          ? _buildEmptyState(true)
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: upcomingAppointments.length,
                              itemBuilder: (context, index) {
                                final appointment = upcomingAppointments[index];
                                return _buildAppointmentCard(appointment, true);
                              },
                            ),

                      // Past appointments
                      pastAppointments.isEmpty
                          ? _buildEmptyState(false)
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: pastAppointments.length,
                              itemBuilder: (context, index) {
                                final appointment = pastAppointments[index];
                                return _buildAppointmentCard(
                                  appointment,
                                  false,
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  // Bottom Navigation Bar (same as before)
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
      currentIndex: 1,
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
          icon: Icon(Icons.person_outline, size: 24),
          label: 'الملف الشخصي',
        ),
      ],
    );
  }
}

// Reschedule bottom sheet widget
class RescheduleBottomSheet extends StatefulWidget {
  final Appointment appointment;

  const RescheduleBottomSheet({super.key, required this.appointment});

  @override
  State<RescheduleBottomSheet> createState() => _RescheduleBottomSheetState();
}

class _RescheduleBottomSheetState extends State<RescheduleBottomSheet> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            const Text(
              'إعادة جدولة الموعد',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // Date picker
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'اختر التاريخ',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: widget.appointment.date,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),

            // Time picker
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'اختر الوقت',
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(widget.appointment.date),
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            // Confirm button
            ElevatedButton(
              onPressed: _selectedDate != null && _selectedTime != null
                  ? () => _rescheduleAppointment()
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('تأكيد الجدولة'),
            ),
          ],
        ),
      ),
    );
  }

  void _rescheduleAppointment() async {
    try {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final success = await context
          .read<AppointmentProvider>()
          .rescheduleAppointment(
            appointmentId: widget.appointment.id,
            newDate: dateTime,
            newTime: _selectedTime!.format(context),
          );

      if (mounted) {
        Navigator.of(context).pop();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إعادة جدولة الموعد بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في إعادة جدولة الموعد'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
