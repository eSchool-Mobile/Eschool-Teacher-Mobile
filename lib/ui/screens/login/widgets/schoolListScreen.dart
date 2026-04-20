import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eschool_saas_staff/data/repositories/authRepository.dart';
import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SchoolListScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const SchoolListScreen({Key? key, required this.userData}) : super(key: key);
  @override
  State<SchoolListScreen> createState() => _SchoolListScreenState();
}

class _SchoolListScreenState extends State<SchoolListScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> schools = [];
  List<Map<String, dynamic>> filteredSchools = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  late final AnimationController _animationController;
  late final AnimationController _floatingElementsController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _float1;
  late final Animation<double> _float2;
  late final Animation<double> _float3;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSchools();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _floatingElementsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Floating animations with different speeds and ranges
    _float1 = Tween<double>(begin: -15.0, end: 15.0).animate(
      CurvedAnimation(
        parent: _floatingElementsController,
        curve: Curves.easeInOut,
      ),
    );

    _float2 = Tween<double>(begin: -20.0, end: 20.0).animate(
      CurvedAnimation(
        parent: _floatingElementsController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    _float3 = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _floatingElementsController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();
  }

  void _loadSchools() {
    print('=== DEBUG LOAD SCHOOLS ===');
    print('userData received: ${widget.userData}');
    print('userData keys: ${widget.userData.keys}');
    print('userData[data]: ${widget.userData['data']}');
    if (widget.userData['data'] != null) {
      print('userData[data] keys: ${widget.userData['data'].keys}');
      print('schools in userData: ${widget.userData['data']?['schools']}');
      print('schools type: ${widget.userData['data']?['schools'].runtimeType}');
    }

    if (widget.userData['data']?['schools'] != null) {
      setState(() {
        // Properly cast each map to ensure type safety
        schools = (widget.userData['data']['schools'] as List<dynamic>)
            .map((item) =>
                Map<String, dynamic>.from(item as Map<dynamic, dynamic>))
            .toList();
        filteredSchools = List.from(schools); // Initialize filtered list
      });
      print('Loaded schools: $schools');
      print('Number of schools loaded: ${schools.length}');
      for (int i = 0; i < schools.length; i++) {
        print(
            'School $i: ${schools[i]['school_name']} - ${schools[i]['school_code']}');
      }
    } else {
      print('No schools found in userData');
    }
  }

  void _filterSchools(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSchools = List.from(schools);
        isSearching = false;
      } else {
        isSearching = true;
        filteredSchools = schools.where((school) {
          final schoolName = (school['school_name'] ?? '').toLowerCase();
          final searchQuery = query.toLowerCase();

          return schoolName.contains(searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _selectSchool(Map<String, dynamic> school) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authRepository = AuthRepository();

      // Get the school token and verify it exists
      final String schoolToken = school['token'] ?? '';
      if (schoolToken.isEmpty) {
        throw Exception('School token is missing');
      }

      // First update the auth token in repository
      await authRepository.setAuthToken(schoolToken);

      // Save all necessary data in SharedPreferences
      await Future.wait([
        prefs.setString('school_token', schoolToken),
        prefs.setString('selected_school_code', school['school_code'] ?? ""),
        prefs.setString('selected_school_name', school['school_name'] ?? ""),
        prefs.setString('selected_school_db', school['database_name'] ?? ""),
        // Save token without Bearer prefix (will be added in headers)
        prefs.setString('auth_token', '$schoolToken'),
      ]);

      // Get the school data from the user object - safely check nested structure
      final userMap = school['user'] != null && school['user'] is Map
          ? Map<String, dynamic>.from(school['user'] as Map)
          : <String, dynamic>{};
      final schoolData = userMap['school'] != null && userMap['school'] is Map
          ? Map<String, dynamic>.from(userMap['school'] as Map)
          : <String, dynamic>{};
      final userDataFromResponse =
          widget.userData['data'] != null && widget.userData['data'] is Map
              ? Map<String, dynamic>.from(widget.userData['data'] as Map)
              : <String, dynamic>{};

      // Global user object from the initial login response
      final globalUser = userDataFromResponse['user'] != null &&
              userDataFromResponse['user'] is Map
          ? Map<String, dynamic>.from(userDataFromResponse['user'] as Map)
          : <String, dynamic>{};

      // Create a complete user details map with all necessary data
      final Map<String, dynamic> completeUserDetails = {
        ...globalUser, // Global user fields (id, name, email, etc.)
        ...userMap, // Branch-specific user fields (overwrites global if present)
        'school': {
          ...schoolData,
          'name': schoolData['name'] ??
              school['school_name'] ??
              school['name'], // Fallback name
          'id': schoolData['id'] ??
              school['id'] ??
              userMap['school_id'], // Fallback ID
          'school_code': school['school_code'],
        },
        'school_id': schoolData['id'] ?? school['id'] ?? userMap['school_id'],
        'token': schoolToken,
        'schools': userDataFromResponse['schools'],
        // IMPORTANT: Preserve teacher/staff data from selected school's user object
        'teacher': userMap['teacher'],
        'staff': userMap['staff'],
      };

      // Set login state before creating user details
      await authRepository.setIsLogIn(true);

      // Debug logging untuk memastikan data teacher tidak hilang
      print('=== DEBUG TEACHER DATA PRESERVATION ===');
      print('Original globalUser teacher: ${globalUser['teacher']}');
      print('Selected school user teacher: ${school['user']['teacher']}');
      print('Complete user details teacher: ${completeUserDetails['teacher']}');
      print('Complete user details staff: ${completeUserDetails['staff']}');
      print('========================================');

      // Create and save UserDetails instance with complete data
      final userDetailsInstance = UserDetails.fromJson(completeUserDetails);
      await authRepository.setUserDetails(userDetailsInstance);

      // Additional debug untuk UserDetails instance
      print('=== DEBUG USERDETAILS INSTANCE ===');
      print('UserDetails teacher ID: ${userDetailsInstance.teacher?.id}');
      print('UserDetails staff ID: ${userDetailsInstance.staff?.id}');
      print('UserDetails school ID: ${userDetailsInstance.schoolId}');
      print('==================================');

      // Save teacher ID if available (dari sekolah yang dipilih, bukan global)
      if (userMap['teacher'] != null) {
        await prefs.setInt('teacher_id', userMap['teacher']['id']);
        print(
            'Saved teacher ID from selected school: ${userMap['teacher']['id']}');
      } else if (globalUser['teacher'] != null) {
        // Fallback ke teacher global jika tidak ada teacher untuk sekolah ini
        await prefs.setInt('teacher_id', globalUser['teacher']['id']);
        print(
            'Saved teacher ID from global data: ${globalUser['teacher']['id']}');
      } // Update Auth state in BLoC with proper token format
      if (!context.mounted) return;

      final schoolsToStore = List<Map<String, dynamic>>.from(
          userDataFromResponse['schools'] ?? []);
      print('DEBUG SCHOOL SELECTION: Schools to store: $schoolsToStore');
      print('DEBUG SCHOOL SELECTION: Schools length: ${schoolsToStore.length}');

      await context.read<AuthCubit>().authenticateUser(
            authToken: '$schoolToken', // Token without Bearer prefix
            userDetails: userDetailsInstance,
            schoolCode: school['school_code'] ?? '',
            schools: schoolsToStore,
          );

      print('DEBUG SCHOOL SELECTION: Authentication completed');
      print('Final UserDetails verification:');
      print('- Teacher ID: ${userDetailsInstance.teacher?.id}');
      print('- Staff ID: ${userDetailsInstance.staff?.id}');
      print('- School ID: ${userDetailsInstance.schoolId}');
      print('- School Name: ${userDetailsInstance.school?.name}');

      // Debug logging
      print('Full auth token set: $schoolToken');
      print('School selected: ${school['school_name']}');
      print('School ID: ${schoolData['id']}');
      print('Database name: ${school['database_name']}');
      print('Auth state updated with complete user details');
      print('User school_id: ${completeUserDetails['school_id']}');

      // Add small delay to ensure auth state is properly set
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to main application
      Get.offAllNamed(Routes.homeScreen);
    } catch (e) {
      print('Error during school selection: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select school: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingElementsController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Modern elegant maroon color palette
    final Color primaryMaroon =
        Color(0xFF800020); // Primary maroon (main brand color)
    final Color softMaroon =
        Color(0xFFE8D5DA); // Very soft maroon pink for backgrounds
    final Color deepMaroon =
        Color(0xFF5C0016); // Deeper maroon for contrast and depth
    final Color accentColor = Color(0xFF4A0012); // Dark maroon accent for text
    final Color goldAccent =
        Color.fromARGB(255, 161, 88, 120); // Elegant gold for highlights
    final Color shimmerColor = Color(0xFFFBF8F9); // Softest pink shimmer
    final Color creamWhite = Color(0xFFFFFCFD); // Pure cream white background

    return Scaffold(
      backgroundColor: creamWhite,
      body: Stack(
        children: [
          // Beautiful animated background
          _buildElegantBackground(),
          // Main Scrollable Content using CustomScrollView
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header Section as Sliver - Clean Modern Design
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 32),
                        child: Column(
                          children: [
                            // Clean Modern Header
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                children: [
                                  // Simple Icon
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: primaryMaroon,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryMaroon.withOpacity(0.2),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.school_rounded,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Clean Title
                                  Text(
                                    'Pilih Sekolah Anda',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: primaryMaroon,
                                      letterSpacing: -0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  // Simple Subtitle
                                  Text(
                                    'Silakan pilih institusi pendidikan Anda\nuntuk melanjutkan ke sistem akademik',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[600],
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            // Search Bar Section
                            _buildSearchBar(
                                primaryMaroon, softMaroon, goldAccent),
                            // Search Results Counter
                            if (isSearching)
                              _buildSearchResultsCounter(
                                  primaryMaroon, goldAccent),
                          ],
                        ),
                      ),
                    ),
                    // Schools List Section as Sliver
                    filteredSchools.isEmpty && isSearching
                        ? SliverToBoxAdapter(
                            child: _buildNoSearchResults(
                                primaryMaroon, softMaroon, goldAccent),
                          )
                        : filteredSchools.isEmpty
                            ? SliverToBoxAdapter(
                                child: _buildEmptyState(
                                    primaryMaroon, softMaroon, goldAccent),
                              )
                            : _buildSchoolsListSliver(
                                context,
                                primaryMaroon,
                                softMaroon,
                                accentColor,
                                goldAccent,
                                shimmerColor,
                                deepMaroon,
                              ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(
      String label, IconData icon, Color iconColor, Color bgColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor.withOpacity(0.2),
            bgColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bgColor.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      Color primaryMaroon, Color softMaroon, Color goldAccent) {
    final Color deepMaroon =
        Color(0xFF5C0016); // Deeper maroon for contrast and depth
    final Color shimmerColor = Color(0xFFFBF8F9); // Softest pink shimmer
    final Color creamWhite = Color(0xFFFFFCFD); // Pure cream white background

    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              creamWhite,
              shimmerColor.withOpacity(0.8),
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: softMaroon.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryMaroon.withOpacity(0.15),
              blurRadius: 40,
              spreadRadius: 0,
              offset: Offset(0, 20),
            ),
            BoxShadow(
              color: goldAccent.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: creamWhite.withOpacity(0.9),
              blurRadius: 15,
              spreadRadius: -5,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enhanced Modern Icon Container
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow effect
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        goldAccent.withOpacity(0.3),
                        goldAccent.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Main icon container
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        softMaroon.withOpacity(0.2),
                        primaryMaroon.withOpacity(0.1),
                        deepMaroon.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: softMaroon.withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: softMaroon.withOpacity(0.3),
                        blurRadius: 25,
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: primaryMaroon.withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    size: 88,
                    color: primaryMaroon,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Enhanced Modern Title with better gradient
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryMaroon,
                  deepMaroon,
                  softMaroon,
                ],
                stops: [0.0, 0.6, 1.0],
              ).createShader(bounds),
              child: Text(
                'Tidak Ada Sekolah',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.8,
                  shadows: [
                    Shadow(
                      color: primaryMaroon.withOpacity(0.3),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Enhanced decorative divider
            Container(
              height: 5,
              width: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    goldAccent.withOpacity(0.3),
                    goldAccent,
                    primaryMaroon,
                    deepMaroon,
                    primaryMaroon,
                    goldAccent,
                    goldAccent.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: goldAccent.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Enhanced subtitle
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: primaryMaroon.withOpacity(0.7),
                  letterSpacing: 0.3,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Saat ini ',
                  ),
                  TextSpan(
                    text: 'tidak ada sekolah',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: primaryMaroon,
                    ),
                  ),
                  TextSpan(
                    text: ' yang tersedia\nuntuk ',
                  ),
                  TextSpan(
                    text: 'akun Anda',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: deepMaroon,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Enhanced premium contact button
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 18,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    goldAccent.withOpacity(0.2),
                    goldAccent.withOpacity(0.12),
                    goldAccent.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: goldAccent.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: goldAccent.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: primaryMaroon.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryMaroon,
                          deepMaroon,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryMaroon.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Hubungi Admin',
                    style: TextStyle(
                      color: primaryMaroon,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolsList(
    BuildContext context,
    Color primaryMaroon,
    Color softMaroon,
    Color accentColor,
    Color goldAccent,
    Color shimmerColor,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: schools.length,
      itemBuilder: (context, index) {
        final school = schools[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            child: InkWell(
              onTap: () => _selectSchool(school),
              borderRadius: BorderRadius.circular(28),
              splashColor: primaryMaroon.withOpacity(0.1),
              highlightColor: goldAccent.withOpacity(0.05),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: primaryMaroon.withOpacity(0.08),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryMaroon.withOpacity(0.15),
                      blurRadius: 32,
                      spreadRadius: 0,
                      offset: Offset(0, 16),
                    ),
                    BoxShadow(
                      color: goldAccent.withOpacity(0.1),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.9),
                      blurRadius: 8,
                      spreadRadius: -4,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Modern School Header with improved design
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryMaroon,
                            primaryMaroon.withOpacity(0.9),
                            softMaroon.withOpacity(0.8),
                          ],
                          stops: [0.0, 0.6, 1.0],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Enhanced Logo Container
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Colors.grey.shade50,
                                ],
                              ),
                              border: Border.all(
                                color: goldAccent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: goldAccent.withOpacity(0.5),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  blurRadius: 8,
                                  spreadRadius: -2,
                                  offset: Offset(0, -4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(44),
                              child: Image.network(
                                school['user']['school']?['logo'] ??
                                    school['user']['image'] ??
                                    '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading image: $error');
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          softMaroon.withOpacity(0.1),
                                          primaryMaroon.withOpacity(0.05),
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.school_rounded,
                                      color: primaryMaroon,
                                      size: 44,
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          softMaroon.withOpacity(0.1),
                                          primaryMaroon.withOpacity(0.05),
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.school_rounded,
                                      color: primaryMaroon,
                                      size: 44,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // School Info Section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // School Name with better typography
                                Text(
                                  school['school_name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                // School Code Badge with improved design
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.25),
                                        Colors.white.withOpacity(0.15),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.tag_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        school['school_code'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Enhanced School Details Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Address Section with better design
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  softMaroon.withOpacity(0.08),
                                  softMaroon.withOpacity(0.04),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: softMaroon.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        primaryMaroon.withOpacity(0.1),
                                        softMaroon.withOpacity(0.05),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primaryMaroon.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    color: primaryMaroon,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Alamat Sekolah',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: primaryMaroon.withOpacity(0.8),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        school['user']['school']['address'] ??
                                            'Alamat tidak tersedia',
                                        style: TextStyle(
                                          color: accentColor.withOpacity(0.85),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.2,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Enhanced Action Button
                          Container(
                            width: double.infinity,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    goldAccent.withOpacity(0.15),
                                    goldAccent.withOpacity(0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: goldAccent.withOpacity(0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: goldAccent.withOpacity(0.2),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: primaryMaroon,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryMaroon.withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Pilih Sekolah Ini',
                                    style: TextStyle(
                                      color: primaryMaroon,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSchoolsListSliver(
    BuildContext context,
    Color primaryMaroon,
    Color softMaroon,
    Color accentColor,
    Color goldAccent,
    Color shimmerColor,
    Color deepMaroon,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final school = filteredSchools[index];
            print(
                'Image URL for school ${school['school_name']}: ${school['user']['school']?['logo'] ?? school['user']['image'] ?? ''}');
            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                elevation: 0,
                child: InkWell(
                  onTap: () => _selectSchool(school),
                  borderRadius: BorderRadius.circular(20),
                  splashColor: primaryMaroon.withOpacity(0.1),
                  highlightColor: goldAccent.withOpacity(0.05),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          softMaroon.withOpacity(0.02),
                          Colors.grey.shade50.withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryMaroon.withOpacity(0.08),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryMaroon.withOpacity(0.06),
                          blurRadius: 16,
                          spreadRadius: 0,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: goldAccent.withOpacity(0.04),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 8,
                          spreadRadius: -2,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header dengan Logo dan Info Utama (Kompak tapi menarik)
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primaryMaroon.withOpacity(0.92),
                                primaryMaroon.withOpacity(0.85),
                                deepMaroon.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Logo Container yang lebih kompak
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      Colors.grey.shade50,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: goldAccent.withOpacity(0.7),
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(
                                      color: goldAccent.withOpacity(0.3),
                                      blurRadius: 6,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Image.network(
                                    school['user']['school']?['logo'] ??
                                        school['user']['image'] ??
                                        '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading image: $error');
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              softMaroon.withOpacity(0.1),
                                              primaryMaroon.withOpacity(0.05),
                                            ],
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.school_rounded,
                                          color: primaryMaroon,
                                          size: 26,
                                        ),
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              softMaroon.withOpacity(0.1),
                                              primaryMaroon.withOpacity(0.05),
                                            ],
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.school_rounded,
                                          color: primaryMaroon,
                                          size: 26,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // School Info yang kompak
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // School Name tanpa ellipsis
                                    Text(
                                      school['school_name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.2,
                                        height: 1.2,
                                      ),
                                      // Hilangkan maxLines untuk tampilkan semua
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Content Section yang kompak
                        Container(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Address Section yang ringkas tapi lengkap
                              if (school['user']['school']['address'] != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        softMaroon.withOpacity(0.04),
                                        primaryMaroon.withOpacity(0.02),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: softMaroon.withOpacity(0.12),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              primaryMaroon.withOpacity(0.08),
                                              softMaroon.withOpacity(0.04),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.location_on_rounded,
                                          color: primaryMaroon,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Alamat',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: primaryMaroon
                                                    .withOpacity(0.7),
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            // Tampilkan alamat lengkap tanpa ellipsis
                                            Text(
                                              school['user']['school']
                                                  ['address'],
                                              style: TextStyle(
                                                color: accentColor
                                                    .withOpacity(0.8),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.1,
                                                height: 1.3,
                                              ),
                                              // Hilangkan maxLines untuk tampilkan alamat lengkap
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 16),

                              // Action Button yang menarik tapi tidak besar
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      primaryMaroon.withOpacity(0.06),
                                      goldAccent.withOpacity(0.04),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: primaryMaroon.withOpacity(0.15),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryMaroon.withOpacity(0.08),
                                      blurRadius: 8,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              primaryMaroon,
                                              deepMaroon,
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryMaroon
                                                  .withOpacity(0.25),
                                              blurRadius: 6,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Pilih Sekolah Ini',
                                        style: TextStyle(
                                          color: primaryMaroon,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: filteredSchools.length,
        ),
      ),
    );
  }

  Widget _buildFloatingElement({
    required double top,
    required double left,
    required double size,
    required Color color,
    required Animation<double> animation,
    double? angle,
    Widget? child,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: AnimatedBuilder(
        animation: _floatingElementsController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, animation.value),
            child: Transform.rotate(
              angle: angle ?? 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(size / 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientDecorativeElement({
    required double top,
    required double left,
    required double size,
    required List<Color> colors,
    required Animation<double> animation,
    required double angle,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: AnimatedBuilder(
        animation: _floatingElementsController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, animation.value),
            child: Transform.rotate(
              angle: angle,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(size / 3),
                    boxShadow: [
                      BoxShadow(
                        color: colors.first.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildElegantBackground() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final Color primaryMaroon =
        Color(0xFF800020); // Primary maroon (main brand color)
    final Color softMaroon =
        Color(0xFFE8D5DA); // Very soft maroon pink for backgrounds
    final Color deepMaroon =
        Color(0xFF5C0016); // Deeper maroon for contrast and depth
    final Color goldAccent = Color(0xFFD4AF37); // Elegant gold for highlights

    return Stack(
      children: [
        // Enhanced background gradient with more sophistication
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFCFD), // Pure cream white background
                Color(0xFFFBF8F9), // Softest pink shimmer
                Colors.white, // Pure white
                Color(0xFFE8D5DA), // Very soft maroon pink for backgrounds
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),

        // Large premium decorative floating elements
        _buildFloatingElement(
          top: -60,
          left: -50,
          size: screenWidth * 0.5,
          color: primaryMaroon.withOpacity(0.08),
          animation: _float1,
        ),

        _buildGradientDecorativeElement(
          top: screenHeight * 0.08,
          left: screenWidth * 0.65,
          size: screenWidth * 0.35,
          colors: [
            softMaroon.withOpacity(0.15),
            primaryMaroon.withOpacity(0.08),
            deepMaroon.withOpacity(0.06),
          ],
          animation: _float2,
          angle: -math.pi / 8,
        ),

        _buildFloatingElement(
          top: screenHeight * 0.45,
          left: -screenWidth * 0.2,
          size: screenWidth * 0.4,
          color: goldAccent.withOpacity(0.12),
          animation: _float3,
          angle: math.pi / 6,
        ),

        _buildGradientDecorativeElement(
          top: screenHeight * 0.7,
          left: screenWidth * 0.55,
          size: screenWidth * 0.45,
          colors: [
            primaryMaroon.withOpacity(0.12),
            deepMaroon.withOpacity(0.08),
            softMaroon.withOpacity(0.06)
          ],
          animation: _float1,
          angle: math.pi / 12,
        ),

        // Premium floating geometric shapes
        for (int i = 0; i < 12; i++)
          _buildFloatingElement(
            top: screenHeight * (0.15 + i * 0.08) % screenHeight,
            left: screenWidth * (0.08 + i * 0.11) % screenWidth,
            size: 6 + (i % 5) * 4,
            color: i % 4 == 0
                ? primaryMaroon.withOpacity(0.15)
                : i % 4 == 1
                    ? goldAccent.withOpacity(0.2)
                    : i % 4 == 2
                        ? deepMaroon.withOpacity(0.15)
                        : softMaroon.withOpacity(0.18),
            animation: i % 3 == 0
                ? _float1
                : i % 3 == 1
                    ? _float2
                    : _float3,
          ),

        // Sophisticated curved overlay shapes
        Positioned(
          top: screenHeight * 0.25,
          right: -80,
          child: AnimatedBuilder(
            animation: _floatingElementsController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_float2.value * 0.5, _float1.value * 0.3),
                child: Container(
                  width: 160,
                  height: 240,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        softMaroon.withOpacity(0.12),
                        primaryMaroon.withOpacity(0.06),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(120),
                      bottomLeft: Radius.circular(120),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        Positioned(
          bottom: screenHeight * 0.08,
          left: -90,
          child: AnimatedBuilder(
            animation: _floatingElementsController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_float3.value * 0.4, _float2.value * 0.2),
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        goldAccent.withOpacity(0.15),
                        deepMaroon.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(90),
                      bottomRight: Radius.circular(90),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Additional premium decorative elements
        Positioned(
          top: screenHeight * 0.6,
          left: screenWidth * 0.1,
          child: AnimatedBuilder(
            animation: _floatingElementsController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_float1.value * 0.6, 0),
                child: Transform.rotate(
                  angle: _float2.value * 0.02,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryMaroon.withOpacity(0.1),
                          deepMaroon.withOpacity(0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: softMaroon.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Elegant diamond shapes
        for (int i = 0; i < 6; i++)
          Positioned(
            top: screenHeight * (0.2 + i * 0.15) % screenHeight,
            left: screenWidth * (0.15 + i * 0.18) % screenWidth,
            child: AnimatedBuilder(
              animation: _floatingElementsController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    (i % 3 == 0
                            ? _float1.value
                            : i % 3 == 1
                                ? _float2.value
                                : _float3.value) *
                        0.3,
                    (i % 3 == 0
                            ? _float3.value
                            : i % 3 == 1
                                ? _float1.value
                                : _float2.value) *
                        0.2,
                  ),
                  child: Transform.rotate(
                    angle: math.pi / 4 + (_float1.value * 0.01),
                    child: Container(
                      width: 12 + (i % 3) * 4,
                      height: 12 + (i % 3) * 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: i % 4 == 0
                              ? [
                                  primaryMaroon.withOpacity(0.2),
                                  deepMaroon.withOpacity(0.1)
                                ]
                              : i % 4 == 1
                                  ? [
                                      goldAccent.withOpacity(0.25),
                                      softMaroon.withOpacity(0.1)
                                    ]
                                  : i % 4 == 2
                                      ? [
                                          deepMaroon.withOpacity(0.2),
                                          primaryMaroon.withOpacity(0.1)
                                        ]
                                      : [
                                          softMaroon.withOpacity(0.2),
                                          goldAccent.withOpacity(0.1)
                                        ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar(
      Color primaryMaroon, Color softMaroon, Color goldAccent) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              softMaroon.withOpacity(0.03),
              Colors.grey.shade50.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primaryMaroon.withOpacity(0.12),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryMaroon.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: goldAccent.withOpacity(0.05),
              blurRadius: 16,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 8,
              spreadRadius: -2,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          onChanged: _filterSchools,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: primaryMaroon,
            letterSpacing: 0.2,
          ),
          decoration: InputDecoration(
            hintText: 'Cari nama sekolah...',
            hintStyle: TextStyle(
              color: primaryMaroon.withOpacity(0.5),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryMaroon.withOpacity(0.1),
                      softMaroon.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: primaryMaroon,
                  size: 20,
                ),
              ),
            ),
            suffixIcon: isSearching
                ? Container(
                    padding: const EdgeInsets.all(12),
                    child: GestureDetector(
                      onTap: () {
                        searchController.clear();
                        _filterSchools('');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryMaroon.withOpacity(0.1),
                              softMaroon.withOpacity(0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.clear_rounded,
                          color: primaryMaroon,
                          size: 16,
                        ),
                      ),
                    ),
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoSearchResults(
      Color primaryMaroon, Color softMaroon, Color goldAccent) {
    final Color shimmerColor = Color(0xFFFBF8F9);
    final Color creamWhite = Color(0xFFFFFCFD);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              creamWhite,
              shimmerColor.withOpacity(0.8),
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: softMaroon.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryMaroon.withOpacity(0.12),
              blurRadius: 32,
              spreadRadius: 0,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: goldAccent.withOpacity(0.15),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Icon Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    softMaroon.withOpacity(0.15),
                    primaryMaroon.withOpacity(0.08),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: softMaroon.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: softMaroon.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: primaryMaroon,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              'Sekolah Tidak Ditemukan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: primaryMaroon,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Subtitle
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: primaryMaroon.withOpacity(0.7),
                  letterSpacing: 0.2,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: 'Tidak ada hasil untuk pencarian ',
                  ),
                  TextSpan(
                    text: '"${searchController.text}"',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: primaryMaroon,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Search suggestions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    goldAccent.withOpacity(0.08),
                    goldAccent.withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: goldAccent.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Tips Pencarian:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: primaryMaroon,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Coba gunakan kata kunci yang berbeda\n• Periksa ejaan nama sekolah\n• Gunakan nama lengkap atau sebagian nama\n• Pastikan nama sekolah sudah benar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: primaryMaroon.withOpacity(0.8),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsCounter(Color primaryMaroon, Color goldAccent) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  goldAccent.withOpacity(0.15),
                  goldAccent.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: goldAccent.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 16,
                  color: primaryMaroon,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ditemukan ${filteredSchools.length} sekolah',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryMaroon,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
