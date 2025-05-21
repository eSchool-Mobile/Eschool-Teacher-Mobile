import 'dart:ui';
import 'dart:math';
import 'package:eschool_saas_staff/cubits/academics/classesWithTeacherDetailsCubit.dart';
import 'package:eschool_saas_staff/data/models/subjectTeacher.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  static Widget getRouteInstance() {
    return BlocProvider(
      create: (context) => ClassesWithTeacherDetailsCubit(),
      child: const ClassesScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isSearchActive = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();

    _scrollController.addListener(_scrollListener);

    Future.delayed(Duration.zero, () {
      getClassesWithTeacherDetails();
    });
  }

  void _scrollListener() {
    if (_scrollController.offset > 10 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 10 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void getClassesWithTeacherDetails() async {
    context
        .read<ClassesWithTeacherDetailsCubit>()
        .getClassesWithTeacherDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColorPalette.primaryMaroon,
              secondary: AppColorPalette.secondaryMaroon,
              surface: Colors.white,
              background: Colors.white,
            ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Enhanced Animated Background Pattern
            AnimatedPositioned(
              duration: Duration(seconds: 1),
              curve: Curves.easeInOut,
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: AnimatedOpacity(
                duration: Duration(seconds: 1),
                opacity: 0.15,
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: BackgroundPatternPainter(
                        color: AppColorPalette.primaryMaroon,
                      ),
                    ),
                    // Decorative particles for modern look
                    ...List.generate(10, (index) {
                      return Positioned(
                        top: Random().nextDouble() *
                            MediaQuery.of(context).size.height,
                        left: Random().nextDouble() *
                            MediaQuery.of(context).size.width,
                        child: AnimatedContainer(
                          duration: Duration(seconds: 2 + index),
                          width: 4 + Random().nextDouble() * 8,
                          height: 4 + Random().nextDouble() * 8,
                          decoration: BoxDecoration(
                            color:
                                AppColorPalette.primaryMaroon.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Main Content with Enhanced Animation
            SafeArea(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _controller.value) * 30),
                    child: Opacity(
                      opacity: _controller.value,
                      child: BlocBuilder<ClassesWithTeacherDetailsCubit,
                          ClassesWithTeacherDetailsState>(
                        builder: (context, state) {
                          if (state is ClassesWithTeacherDetailsFetchSuccess) {
                            if (state.classes.isEmpty) {
                              return _buildEmptyState(context);
                            }
                            return _buildSuccessState(context, state);
                          }

                          if (state is ClassesWithTeacherDetailsFetchFailure) {
                            return _buildErrorState(context, state);
                          }

                          return _buildLoadingState(context);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Enhanced Search Bar
            _buildSearchBar(),

            // New Enhanced AppBar
            _buildAppBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isSearchActive ? 56 : 0,
        curve: Curves.easeInOut,
        child: _isSearchActive
            ? Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari kelas...',
                    prefixIcon: Icon(Icons.search,
                        color: AppColorPalette.secondaryMaroon),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.close,
                          color: AppColorPalette.secondaryMaroon),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = "";
                          _isSearchActive = false;
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              )
            : SizedBox.shrink(),
      ),
    );
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: MediaQuery.of(context).padding.top + 80,
        child: Stack(
          children: [
            // Fancy gradient background with animated particles
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF690013),
                          AppColorPalette.primaryMaroon,
                          Color(0xFFA12948),
                          AppColorPalette.secondaryMaroon,
                        ],
                        stops: [0.0, 0.3, 0.6, 1.0],
                        transform: GradientRotation(_controller.value * 0.02),
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF800020),
                            Color(0xFF9A1E3C),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Decorative design elements
            Positioned.fill(
              child: CustomPaint(
                painter: AppBarDecorationPainter(
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),

            // Animated glowing effect
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Positioned(
                  top: -100 + (_controller.value * 20),
                  right: -60 + (_controller.value * 10),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.0),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Main app bar content with frosted glass effect
            Positioned(
              bottom: 10,
              left: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Back button with ripple effect
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              highlightColor: Colors.white.withOpacity(0.1),
                              splashColor: Colors.white.withOpacity(0.2),
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                            .slideX(begin: -0.3, end: 0),

                        // Animated divider
                        Container(
                          height: 24,
                          width: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.4),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),

                        // Title with animated badge
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Main title
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Animated icon
                                    AnimatedBuilder(
                                      animation: _controller,
                                      builder: (context, child) {
                                        return Transform.rotate(
                                          angle: _controller.value * 0.05,
                                          child: Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.white.withOpacity(0.9),
                                                  Colors.white.withOpacity(0.4),
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.school,
                                              color:
                                                  AppColorPalette.primaryMaroon,
                                              size: 20,
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    SizedBox(width: 12),

                                    // Title text with glowing effect
                                    ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white,
                                            Colors.white.withOpacity(0.9),
                                          ],
                                        ).createShader(bounds);
                                      },
                                      blendMode: BlendMode.srcIn,
                                      child: Text(
                                        'Daftar Kelas',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 1),
                                              blurRadius: 3,
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

                        // Animated divider
                        Container(
                          height: 24,
                          width: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.4),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),

                        // Search button with interactive animation
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              highlightColor: Colors.white.withOpacity(0.1),
                              splashColor: Colors.white.withOpacity(0.2),
                              onTap: () {
                                setState(() {
                                  _isSearchActive = !_isSearchActive;
                                  if (!_isSearchActive) {
                                    _searchController.clear();
                                    _searchQuery = "";
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: _isSearchActive
                                      ? Border.all(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 1.5,
                                        )
                                      : null,
                                ),
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 400),
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    return RotationTransition(
                                      turns: Tween<double>(begin: 0.5, end: 1.0)
                                          .animate(animation),
                                      child: ScaleTransition(
                                        scale: animation,
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      ),
                                    );
                                  },
                                  child: _isSearchActive
                                      ? Icon(
                                          Icons.close_rounded,
                                          key: ValueKey<bool>(true),
                                          color: Colors.white,
                                          size: 22,
                                        )
                                      : Icon(
                                          Icons.search_rounded,
                                          key: ValueKey<bool>(false),
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                            .slideX(begin: 0.3, end: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Enhanced animated empty state icon
                TweenAnimationBuilder(
                    duration: Duration(seconds: 2),
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                AppColorPalette.primaryMaroon.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Transform.scale(
                              scale: 1 + sin(_controller.value * 2 * pi) * 0.05,
                              child: Icon(
                                Icons.school_outlined,
                                size: 100,
                                color: AppColorPalette.primaryMaroon
                                    .withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                const SizedBox(height: 32),

                // Enhanced no classes text
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppColorPalette.primaryMaroon,
                      AppColorPalette.secondaryMaroon,
                    ],
                  ).createShader(bounds),
                  child: CustomTextContainer(
                    textKey:
                        Utils.getTranslatedLabel(noClassSectionSelectedKey),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action button
                ElevatedButton.icon(
                  onPressed: () {
                    getClassesWithTeacherDetails();
                    HapticFeedback.mediumImpact();
                  },
                  icon: Icon(Icons.refresh_rounded),
                  label: Text(
                    "Refresh Classes",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorPalette.primaryMaroon,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessState(
      BuildContext context, ClassesWithTeacherDetailsFetchSuccess state) {
    // Filter classes based on search query if active
    final classes = _searchQuery.isEmpty
        ? state.classes
        : state.classes
            .where((classSection) => (classSection.fullName ?? "")
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    return AnimationLimiter(
      child: CustomScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: Utils.appContentTopScrollPadding(context: context) +
                    60, // Increased from 25 to 60
                bottom: 16,
                left: appContentHorizontalPadding,
                right: appContentHorizontalPadding,
              ),
              child: classes.isEmpty && _searchQuery.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Kelas tidak ditemukan',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms)
                  : _buildEnhancedHeaderCard(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      curve: Curves.easeOut,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildEnhancedClassCard(
                            context, classes[index], index),
                      ),
                    ),
                  ),
                ),
                childCount: classes.length,
              ),
            ),
          ),
          // Add some bottom padding for better scroll experience
          SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHeaderCard(BuildContext context) {
    return Hero(
      tag: 'class_list_title',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          children: [
            // Enhanced Main Card with Improved Frosted Glass Effect
            Card(
              elevation: 16,
              shadowColor: AppColorPalette.primaryMaroon.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColorPalette.primaryMaroon.withOpacity(0.9),
                          AppColorPalette.secondaryMaroon.withOpacity(0.9),
                        ],
                        stops: const [0.2, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColorPalette.primaryMaroon.withOpacity(0.2),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Enhanced Top Section with Title and Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CustomTextContainer(
                                        textKey: classListKey,
                                        style: GoogleFonts.poppins(
                                          fontSize:
                                              Utils.getScaledValue(context, 24),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.workspace_premium,
                                        color: Colors.white.withOpacity(0.9),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 60,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Enhanced Decorative Elements
            Positioned(
              right: -25,
              bottom: -15,
              child: Icon(
                Icons.school,
                size: 100,
                color: Colors.white.withOpacity(0.08),
              ),
            ),

            // Enhanced Decorative Elements
            ...List.generate(4, (index) {
              return Positioned(
                left: 15 + (index * 15),
                top: 15 + (index * 10),
                child: Container(
                  width: 30 - (index * 5),
                  height: 30 - (index * 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1 - (index * 0.02)),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedClassCard(
      BuildContext context, dynamic classSection, int index) {
    final bool isEven = index.isEven;
    final cardGradient = [
      Colors.white,
      Colors.white,
    ];

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0.96, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Utils.showBottomSheet(
                      child: _buildEnhancedBottomSheet(
                          classSection.subjectTeachers ?? []),
                      context: context);
                },
                borderRadius: BorderRadius.circular(24),
                splashColor: AppColorPalette.primaryMaroon.withOpacity(0.2),
                highlightColor: AppColorPalette.primaryMaroon.withOpacity(0.1),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: cardGradient,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorPalette.primaryMaroon.withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: AppColorPalette.primaryMaroon.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildEnhancedCardHeader(context, classSection, isEven),
                      _buildEnhancedCardBody(context, classSection, isEven),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedCardHeader(
      BuildContext context, dynamic details, bool isEven) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColorPalette.primaryMaroon.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        gradient: LinearGradient(
          begin: isEven ? Alignment.centerLeft : Alignment.centerRight,
          end: isEven ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            AppColorPalette.primaryMaroon.withOpacity(0.15),
            AppColorPalette.secondaryMaroon.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.fullName ?? 'Class Section',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColorPalette.primaryMaroon,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCardBody(
      BuildContext context, dynamic details, bool isEven) {
    // For class teacher names
    final classTeacherNames = details.getClassTeacherNames();

    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildEnhancedInfoRow(
              context, 'Guru Kelas', classTeacherNames, Icons.person_outline,
              gradient: [
                AppColorPalette.primaryMaroon.withOpacity(0.08),
                AppColorPalette.secondaryMaroon.withOpacity(0.02),
              ]),

          // Add spacing before button
          SizedBox(height: 20),

          // Smaller Selengkapnya button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Utils.showBottomSheet(
                    child: _buildEnhancedBottomSheet(
                        details.subjectTeachers ?? []),
                    context: context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorPalette.primaryMaroon,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Selengkapnya",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value,
      IconData icon, bool isAlt) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isAlt
            ? AppColorPalette.primaryMaroon.withOpacity(0.07)
            : AppColorPalette.secondaryMaroon.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAlt
              ? AppColorPalette.primaryMaroon.withOpacity(0.1)
              : AppColorPalette.secondaryMaroon.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isAlt
                ? AppColorPalette.primaryMaroon.withOpacity(0.7)
                : AppColorPalette.secondaryMaroon.withOpacity(0.7),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColorPalette.primaryMaroon.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColorPalette.primaryMaroon.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedInfoRow(
      BuildContext context, String label, String value, IconData icon,
      {required List<Color> gradient}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorPalette.primaryMaroon.withOpacity(0.12),
            AppColorPalette.secondaryMaroon.withOpacity(0.08),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColorPalette.primaryMaroon.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColorPalette.primaryMaroon.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColorPalette.primaryMaroon.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColorPalette.primaryMaroon.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColorPalette.secondaryMaroon,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColorPalette.primaryMaroon,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedBottomSheet(List<SubjectTeacher> subjectTeachers) {
    return ClassSubjectsBottomsheet(subjectTeachers: subjectTeachers);
  }

  Widget _buildErrorState(
      BuildContext context, ClassesWithTeacherDetailsFetchFailure state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error illustration or icon
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColorPalette.primaryMaroon.withOpacity(0.1),
            ),
            child: Center(
              child: Icon(
                Icons.error_outline_rounded,
                size: 70,
                color: AppColorPalette.primaryMaroon.withOpacity(0.7),
              ),
            ),
          ),
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Oops! Something went wrong',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColorPalette.primaryMaroon,
              ),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              state.errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColorPalette.secondaryMaroon.withOpacity(0.8),
              ),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => getClassesWithTeacherDetails(),
            icon: Icon(Icons.refresh_rounded),
            label: Text(
              "Try Again",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorPalette.primaryMaroon,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Enhanced loading animation
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 1500),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer circle
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColorPalette.primaryMaroon.withOpacity(0.2),
                        width: 4,
                      ),
                    ),
                  ),
                  // Animated progress circle
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: null,
                      strokeWidth: 4,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColorPalette.primaryMaroon,
                      ),
                    ),
                  ),
                  // Center icon
                  Icon(
                    Icons.school_rounded,
                    color: AppColorPalette.primaryMaroon,
                    size: 40,
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 32),
          Text(
            "Memuat Kelas...",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColorPalette.primaryMaroon,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Mohon tunggu selagi kami memuat data kelas",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColorPalette.secondaryMaroon.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class ClassSubjectsBottomsheet extends StatelessWidget {
  final List<SubjectTeacher> subjectTeachers;
  const ClassSubjectsBottomsheet({super.key, required this.subjectTeachers});

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
      titleLabelKey: classSubjectsKey,
      child: Column(
        children: [
          // Elegant header with subtle gradient
          Container(
            margin: EdgeInsets.only(bottom: 24, left: 12, right: 12),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 22, horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  AppColorPalette.primaryMaroon.withOpacity(0.9),
                  AppColorPalette.primaryMaroon.withOpacity(0.85),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColorPalette.shadowColor.withOpacity(0.25),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daftar Mata Pelajaran',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      height: 2,
                      width: 40,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${subjectTeachers.length} mata pelajaran',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Elegant subject list with minimalist design
          AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: subjectTeachers.length,
              itemBuilder: (context, index) {
                // Get subject name and teacher
                final subject =
                    subjectTeachers[index].subject?.getSybjectNameWithType() ??
                        '';
                final teacher = subjectTeachers[index].teacher?.fullName ?? '-';

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: Duration(milliseconds: 450),
                  child: SlideAnimation(
                    horizontalOffset: 50,
                    child: FadeInAnimation(
                      child: Container(
                        margin:
                            EdgeInsets.only(bottom: 16, left: 12, right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                AppColorPalette.primaryMaroon.withOpacity(0.15),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              spreadRadius: 1,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                              },
                              splashColor: AppColorPalette.primaryMaroon
                                  .withOpacity(0.1),
                              highlightColor: AppColorPalette.primaryMaroon
                                  .withOpacity(0.05),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Subject title
                                    CustomTextContainer(
                                      textKey: subject,
                                      style: GoogleFonts.poppins(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: AppColorPalette.primaryMaroon,
                                        height: 1.3,
                                      ),
                                    ),

                                    // Divider line
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      child: Container(
                                        height: 1,
                                        width: double.infinity,
                                        color: AppColorPalette.primaryMaroon
                                            .withOpacity(0.1),
                                      ),
                                    ),

                                    // Teacher info - elegant and simple
                                    Row(
                                      children: [
                                        // Profile avatar
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColorPalette.primaryMaroon
                                                .withOpacity(0.1),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.person_rounded,
                                              color:
                                                  AppColorPalette.primaryMaroon,
                                              size: 24,
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 14),

                                        // Teacher name and role
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                teacher,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                'Guru Pengajar',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black54,
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
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  final Color color;

  BackgroundPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Main wave
    final path = Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.05,
        size.width * 0.5,
        size.height * 0.15,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.25,
        size.width,
        size.height * 0.2,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);

    // Secondary decorative waves
    final path2 = Path()
      ..moveTo(0, size.height * 0.45)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.4,
        size.width * 0.6,
        size.height * 0.55,
        size.width,
        size.height * 0.47,
      )
      ..lineTo(size.width, size.height * 0.45)
      ..lineTo(0, size.height * 0.45)
      ..close();

    canvas.drawPath(
      path2,
      Paint()
        ..color = color.withOpacity(0.2)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EnhancedCurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    path.quadraticBezierTo(
      size.width * 0.1,
      size.height,
      size.width * 0.3,
      size.height - 25,
    );

    path.quadraticBezierTo(
      size.width * 0.5,
      size.height - 50,
      size.width * 0.7,
      size.height - 25,
    );

    path.quadraticBezierTo(
      size.width * 0.9,
      size.height,
      size.width,
      size.height - 40,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class AppColorPalette {
  static const Color primaryMaroon = Color(0xFF8B1F41);
  static const Color secondaryMaroon = Color(0xFFA84B5C);
  static const Color lightMaroon = Color(0xFFE7C8CD);
  static const Color accentPink = Color(0xFFF4D0D9);
  static const Color warmBeige = Color(0xFFF5E6E8);
  static const Color shadowColor = Color(0x298B1F41);
}

class AppBarDecorationPainter extends CustomPainter {
  final Color color;

  AppBarDecorationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.4,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.6,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
