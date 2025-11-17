import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../models/user.dart';
import '../widgets/custom_widgets.dart';

class EnhancedAppointmentsScreen extends StatefulWidget {
  const EnhancedAppointmentsScreen({super.key});

  @override
  State<EnhancedAppointmentsScreen> createState() =>
      _EnhancedAppointmentsScreenState();
}

class _EnhancedAppointmentsScreenState extends State<EnhancedAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedFilter = 'الكل';
  bool _showUpcomingOnly = false;
  List<Appointment> _filteredAppointments = [];

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

  // Enhanced appointment card with better design
  Widget _buildEnhancedAppointmentCard(
    Appointment appointment,
    bool isUpcoming,
  ) {
    final isCancelled = appointment.status == AppointmentStatus.cancelled;
    final isCompleted = appointment.status == AppointmentStatus.completed;
    final isToday = appointment.date.isToday();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header with date and status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isUpcoming && !isCancelled && !isCompleted
                      ? const Color(0xFF00BFFF)
                      : Colors.grey.shade400,
                  isUpcoming && !isCancelled && !isCompleted
                      ? const Color(0xFF0095CC)
                      : Colors.grey.shade500,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isUpcoming && !isCancelled && !isCompleted
                        ? Icons.calendar_today
                        : Icons.history,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(appointment.date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isUpcoming && !isCancelled && !isCompleted
                            ? _getTimeUntilAppointment(appointment.date)
                            : _getStatusText(appointment.status),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'اليوم',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Doctor info with enhanced design
                Row(
                  children: [
                    // Doctor avatar with gradient
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00BFFF),
                            const Color(0xFF0095CC),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00BFFF).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 35,
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              appointment.specialty,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF00BFFF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                appointment.time,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Notes section if available
                if (appointment.notes?.isNotEmpty == true) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ملاحظات',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appointment.notes!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action buttons
                Row(
                  children: [
                    if (isUpcoming && !isCancelled && !isCompleted) ...[
                      // Cancel button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showCancelDialog(appointment),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Reschedule button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showRescheduleOptions(appointment),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('إعادة جدولة'),
                        ),
                      ),
                    ] else if (isCompleted) ...[
                      // Reschedule button for completed appointments
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showRescheduleOptions(appointment),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('حجز موعد جديد'),
                        ),
                      ),
                    ] else if (isCancelled) ...[
                      // Book new appointment for cancelled ones
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _bookNewAppointment(appointment),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('حجز موعد جديد'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
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

  // Enhanced search bar
  Widget _buildEnhancedSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'البحث عن طبيب أو تخصص...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00BFFF)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
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

  // Show reschedule options
  Future<void> _showRescheduleOptions(Appointment appointment) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          EnhancedRescheduleBottomSheet(appointment: appointment),
    );
  }

  // Book new appointment
  void _bookNewAppointment(Appointment appointment) {
    Navigator.pushNamed(
      context,
      '/select_time',
      arguments: appointment.doctorId,
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
            labelColor: const Color(0xFF00BFFF),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF00BFFF),
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'المواعيد القادمة'),
              Tab(text: 'المواعيد السابقة'),
            ],
          ),
        ),
        body: Consumer<AppointmentProvider>(
          builder: (context, appointmentProvider, child) {
            final upcomingAppointments =
                appointmentProvider.upcomingAppointments;
            final pastAppointments = appointmentProvider.pastAppointments;

            return Column(
              children: [
                // Search bar
                const SizedBox(height: 20),
                _buildEnhancedSearchBar(),

                // Tab views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Upcoming appointments
                      upcomingAppointments.isEmpty
                          ? _buildEmptyState(true)
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: upcomingAppointments.length,
                              itemBuilder: (context, index) {
                                final appointment = upcomingAppointments[index];
                                return _buildEnhancedAppointmentCard(
                                  appointment,
                                  true,
                                );
                              },
                            ),

                      // Past appointments
                      pastAppointments.isEmpty
                          ? _buildEmptyState(false)
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: pastAppointments.length,
                              itemBuilder: (context, index) {
                                final appointment = pastAppointments[index];
                                return _buildEnhancedAppointmentCard(
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

  // Bottom Navigation Bar
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

  // Build empty state
  Widget _buildEmptyState(bool isUpcoming) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUpcoming
                  ? const Color(0xFF00BFFF).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
            ),
            child: Icon(
              isUpcoming ? Icons.calendar_today : Icons.history,
              size: 60,
              color: isUpcoming ? const Color(0xFF00BFFF) : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isUpcoming ? 'لا توجد مواعيد قادمة' : 'لا توجد مواعيد سابقة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isUpcoming
                ? 'احجز موعداً جديداً مع طبيب'
                : 'سيتم عرض مواعيدك السابقة هنا',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          if (isUpcoming) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('احجز موعد جديد'),
            ),
          ],
        ],
      ),
    );
  }
}

// Enhanced reschedule bottom sheet
class EnhancedRescheduleBottomSheet extends StatefulWidget {
  final Appointment appointment;

  const EnhancedRescheduleBottomSheet({super.key, required this.appointment});

  @override
  State<EnhancedRescheduleBottomSheet> createState() =>
      _EnhancedRescheduleBottomSheetState();
}

class _EnhancedRescheduleBottomSheetState
    extends State<EnhancedRescheduleBottomSheet> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            const Text(
              'إعادة جدولة الموعد',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 32),

            // Date picker
            _buildEnhancedDatePicker(),

            const SizedBox(height: 20),

            // Time picker
            _buildEnhancedTimePicker(),

            const SizedBox(height: 32),

            // Confirm button
            ElevatedButton(
              onPressed: _selectedDate != null && _selectedTime != null
                  ? () => _rescheduleAppointment()
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: const Color(0xFF00BFFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'تأكيد الجدولة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedDatePicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00BFFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.calendar_today, color: Color(0xFF00BFFF)),
        ),
        title: Text(
          _selectedDate != null
              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
              : 'اختر التاريخ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _selectedDate != null ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: const Text('انقر لاختيار التاريخ'),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: widget.appointment.date.isAfter(DateTime.now())
                ? widget.appointment.date
                : DateTime.now(),
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
    );
  }

  Widget _buildEnhancedTimePicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00BFFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.access_time, color: Color(0xFF00BFFF)),
        ),
        title: Text(
          _selectedTime != null ? _selectedTime!.format(context) : 'اختر الوقت',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _selectedTime != null ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: const Text('انقر لاختيار الوقت'),
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

// Extension for DateTime
extension DateTimeExtension on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
