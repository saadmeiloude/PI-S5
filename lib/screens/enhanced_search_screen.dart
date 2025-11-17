import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/doctor_provider.dart';
import '../models/user.dart';

class EnhancedSearchScreen extends StatefulWidget {
  const EnhancedSearchScreen({super.key});

  @override
  State<EnhancedSearchScreen> createState() => _EnhancedSearchScreenState();
}

class _EnhancedSearchScreenState extends State<EnhancedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'الكل';
  List<Doctor> _filteredDoctors = [];
  List<Doctor> _allDoctors = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDoctors() {
    setState(() {
      _isLoading = true;
    });

    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    _allDoctors = doctorProvider.doctors;
    _filteredDoctors = _allDoctors;

    setState(() {
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    _filterDoctors();
  }

  void _filterDoctors() {
    String query = _searchController.text.trim();
    List<Doctor> doctors = _allDoctors;

    // Filter by search query
    if (query.isNotEmpty) {
      doctors = doctors.where((doctor) {
        return doctor.name.toLowerCase().contains(query.toLowerCase()) ||
            doctor.specialty.toLowerCase().contains(query.toLowerCase()) ||
            doctor.location.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    // Apply category filters
    switch (_selectedFilter) {
      case 'التخصصات':
        doctors = doctors.where((doctor) {
          return doctor.specialty.toLowerCase().contains(query.toLowerCase());
        }).toList();
        break;
      case 'المواقع':
        doctors = doctors.where((doctor) {
          return doctor.location.toLowerCase().contains(query.toLowerCase());
        }).toList();
        break;
      case 'التقييمات':
        doctors = doctors.where((doctor) => doctor.rating >= 4.5).toList();
        break;
      case 'الطب العام':
        doctors = doctors.where((doctor) {
          return doctor.specialty.toLowerCase().contains('عام') ||
              doctor.specialty.toLowerCase().contains('طبيب عام');
        }).toList();
        break;
      case 'القلب':
        doctors = doctors.where((doctor) {
          return doctor.specialty.toLowerCase().contains('قلب') ||
              doctor.specialty.toLowerCase().contains('قلب و أوعية دموية');
        }).toList();
        break;
      case 'العظام':
        doctors = doctors.where((doctor) {
          return doctor.specialty.toLowerCase().contains('عظام') ||
              doctor.specialty.toLowerCase().contains('جراحة عظام');
        }).toList();
        break;
      case 'العيون':
        doctors = doctors.where((doctor) {
          return doctor.specialty.toLowerCase().contains('عيون') ||
              doctor.specialty.toLowerCase().contains('طب العيون');
        }).toList();
        break;
      case 'الأنف والأذن':
        doctors = doctors.where((doctor) {
          return doctor.specialty.toLowerCase().contains('أنف') ||
              doctor.specialty.toLowerCase().contains('أذن') ||
              doctor.specialty.toLowerCase().contains('أنف أذن حنجرة');
        }).toList();
        break;
    }

    setState(() {
      _filteredDoctors = doctors;
    });
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _filterDoctors();
  }

  // Helper widget for the search bar
  Widget _buildEnhancedSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: 'ابحث عن الأطباء أو التخصصات أو المواقع',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF00BFFF),
            size: 24,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: (value) {
          // Auto-clear when search is empty
          if (value.isEmpty) {
            _filterDoctors();
          }
        },
      ),
    );
  }

  // Helper widget for filter chips with enhanced design
  Widget _buildEnhancedFilterChip(String label, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF00BFFF), Color(0xFF0095CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : Colors.white,
          border: isActive
              ? null
              : Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF00BFFF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () => _onFilterSelected(isActive ? 'الكل' : label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced doctor item with better design
  Widget _buildEnhancedDoctorItem(Doctor doctor) {
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
          // Header with doctor info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Doctor avatar with gradient
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BFFF), Color(0xFF0095CC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00BFFF).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
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
                        doctor.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 6),
                      // Specialty badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          doctor.specialty,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF00BFFF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Location and rating
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              doctor.location,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Rating stars
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  doctor.rating.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // View profile button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/doctor_details',
                        arguments: doctor,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00BFFF)),
                      foregroundColor: const Color(0xFF00BFFF),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('عرض التفاصيل'),
                  ),
                ),
                const SizedBox(width: 12),
                // Book appointment button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/select_time',
                        arguments: doctor.id,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('حجز موعد'),
                  ),
                ),
              ],
            ),
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
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'البحث عن الأطباء',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list, color: Color(0xFF00BFFF)),
              onPressed: () {
                // Show filter options
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Search bar
                  const SizedBox(height: 20),
                  _buildEnhancedSearchBar(),

                  // Filter chips
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildEnhancedFilterChip(
                          'الكل',
                          isActive: _selectedFilter == 'الكل',
                        ),
                        _buildEnhancedFilterChip(
                          'التخصصات',
                          isActive: _selectedFilter == 'التخصصات',
                        ),
                        _buildEnhancedFilterChip(
                          'المواقع',
                          isActive: _selectedFilter == 'المواقع',
                        ),
                        _buildEnhancedFilterChip(
                          'التقييمات',
                          isActive: _selectedFilter == 'التقييمات',
                        ),
                        _buildEnhancedFilterChip(
                          'الطب العام',
                          isActive: _selectedFilter == 'الطب العام',
                        ),
                        _buildEnhancedFilterChip(
                          'القلب',
                          isActive: _selectedFilter == 'القلب',
                        ),
                        _buildEnhancedFilterChip(
                          'العظام',
                          isActive: _selectedFilter == 'العظام',
                        ),
                        _buildEnhancedFilterChip(
                          'العيون',
                          isActive: _selectedFilter == 'العيون',
                        ),
                        _buildEnhancedFilterChip(
                          'الأنف والأذن',
                          isActive: _selectedFilter == 'الأنف والأذن',
                        ),
                      ],
                    ),
                  ),

                  // Results
                  Expanded(
                    child: _filteredDoctors.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _filteredDoctors.length,
                            itemBuilder: (context, index) {
                              return _buildEnhancedDoctorItem(
                                _filteredDoctors[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  // Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.1),
            ),
            child: Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد نتائج',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب البحث بكلمات مختلفة أو تغيير الفلاتر',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
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
      currentIndex: 0,
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
