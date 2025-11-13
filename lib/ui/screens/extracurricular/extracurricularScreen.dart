import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/extracurricular/extracurricularCubit.dart';
import 'package:eschool_saas_staff/data/repositories/extracurricularRepository.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';
import 'package:eschool_saas_staff/data/models/extracurricular.dart';
import '../../../app/routes.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/no_search_results_widget.dart';
import 'package:eschool_saas_staff/ui/widgets/skeleton/skeleton_widgets.dart';

class ExtracurricularScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    return BlocProvider(
      create: (context) => ExtracurricularCubit(ExtracurricularRepository()),
      child: ExtracurricularScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<ExtracurricularScreen> createState() => _ExtracurricularScreenState();
}

class _ExtracurricularScreenState extends State<ExtracurricularScreen>
    with TickerProviderStateMixin {
  String searchQuery = "";
  String? _restoredExtracurricularId;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _appBarAnimationController;
  final ScrollController _scrollController = ScrollController();

  // Theme colors - Soft Maroon palette
  final Color _primaryColor = Color(0xFF7A1E23);
  final Color _highlightColor = Color(0xFFB84D4D);

  @override
  void initState() {
    super.initState();
    print('🎯 [EXTRACURRICULAR SCREEN] Initialized');
    _refreshExtracurriculars();

    // Listen for state changes
    context.read<ExtracurricularCubit>().stream.listen((state) {
      if (state is ExtracurricularSuccess) {
        print(
            '✅ [EXTRACURRICULAR SCREEN] UI Updated: ${state.extracurriculars.length} extracurriculars');
        setState(() {});
      } else if (state is ExtracurricularFailure) {
        print('❌ [EXTRACURRICULAR SCREEN] UI Error: ${state.errorMessage}');
        setState(() {});
      } else if (state is ExtracurricularLoading) {
        print('⏳ [EXTRACURRICULAR SCREEN] Loading...');
      }
    });

    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _appBarAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.stop();
    _pulseController.stop();
    _appBarAnimationController.stop();
    _animationController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    _appBarAnimationController.dispose();
    super.dispose();
  }

  void _refreshExtracurriculars() {
    print('🔄 [EXTRACURRICULAR SCREEN] Refreshing data...');
    if (mounted) {
      context.read<ExtracurricularCubit>().getExtracurriculars();
    } else {
      print('⚠️ [EXTRACURRICULAR SCREEN] Widget not mounted, skipping refresh');
    }
  }

  void _forceRefreshAfterRestore() {
    if (mounted) {
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          context.read<ExtracurricularCubit>().getExtracurriculars();
        }
      });
      Future.delayed(Duration(milliseconds: 800), () {
        if (mounted) {
          context.read<ExtracurricularCubit>().getExtracurriculars();
        }
      });
      Future.delayed(Duration(milliseconds: 1500), () {
        if (mounted) {
          context.read<ExtracurricularCubit>().getExtracurriculars();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshExtracurriculars();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomModernAppBar(
          title: 'kurikuler',
          icon: Icons.sports_soccer,
          fabAnimationController: _appBarAnimationController,
          primaryColor: _primaryColor,
          lightColor: _highlightColor,
          onBackPressed: () => Navigator.of(context).pop(),
          showAddButton: true,
          onAddPressed: () async {
            final result = await Get.toNamed(Routes.createExtracurricular);
            if (result == true) {
              _refreshExtracurriculars();
            }
          },
          showArchiveButton: true,
          onArchivePressed: () async {
            final result = await Get.toNamed(Routes.archiveExtracurricular);
            if (result != null && result is String) {
              setState(() {
                _restoredExtracurricularId = result;
              });
              _forceRefreshAfterRestore();
              Future.delayed(Duration(seconds: 3), () {
                if (mounted) {
                  setState(() {
                    _restoredExtracurricularId = null;
                  });
                }
              });
            }
          },
        ),
        body: _buildAnimatedBody(),
      ),
    );
  }

  Widget _buildAnimatedBody() {
    return AnimationLimiter(
      child: CustomScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        slivers: [
          _buildSearchBar(),
          BlocBuilder<ExtracurricularCubit, ExtracurricularState>(
            builder: (context, state) {
              if (state is ExtracurricularLoading) {
                print('🎨 [EXTRACURRICULAR SCREEN] Building loading UI');
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildShimmerCard(),
                      childCount: 6,
                    ),
                  ),
                );
              }

              if (state is ExtracurricularFailure) {
                print('🎨 [EXTRACURRICULAR SCREEN] Building error UI');
                return SliverFillRemaining(
                  child: Center(
                    child: CustomErrorWidget(
                      message: state.errorMessage,
                      onRetry: _refreshExtracurriculars,
                    ),
                  ),
                );
              }

              if (state is ExtracurricularSuccess) {
                print('🎨 [EXTRACURRICULAR SCREEN] Building success UI');
                return _buildExtracurricularGrid(state);
              }

              print('🎨 [EXTRACURRICULAR SCREEN] Building default UI');
              return SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: FadeInDown(
        delay: Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari ekstrakurikuler...',
                prefixIcon: Icon(Icons.search, color: _primaryColor),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExtracurricularGrid(ExtracurricularSuccess state) {
    var filteredExtracurriculars = searchQuery.isEmpty
        ? state.extracurriculars
        : state.extracurriculars
            .where((e) =>
                e.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                e.description
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                e.coachName.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    // Sort to prioritize restored extracurricular if exists
    if (_restoredExtracurricularId != null) {
      filteredExtracurriculars.sort((a, b) {
        if (a.id.toString() == _restoredExtracurricularId) return -1;
        if (b.id.toString() == _restoredExtracurricularId) return 1;
        return b.id.compareTo(a.id);
      });
    } else {
      filteredExtracurriculars.sort((a, b) => b.id.compareTo(a.id));
    }

    if (filteredExtracurriculars.isEmpty && searchQuery.isNotEmpty) {
      return SliverFillRemaining(
        child: NoSearchResultsWidget(
          searchQuery: searchQuery,
          onClearSearch: () {
            setState(() {
              searchQuery = "";
            });
          },
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildExtracurricularCard(
                      context, filteredExtracurriculars[index]),
                ),
              ),
            );
          },
          childCount: filteredExtracurriculars.length,
        ),
      ),
    );
  }

  Widget _buildExtracurricularCard(
      BuildContext context, Extracurricular extracurricular) {
    final bool isRecentlyRestored =
        _restoredExtracurricularId == extracurricular.id.toString();

    final colorScheme = {
      'primary': _primaryColor,
      'light': Color(0xFFF5E6E8),
      'accent': Color(0xFF8B4513),
    };

    final double screenWidth = MediaQuery.of(context).size.width;
    final double availableWidth = screenWidth - 48;
    final double titleFontSize = 24.0;
    final double lineHeight = 1.4;

    final int estimatedCharactersPerLine =
        (availableWidth / (titleFontSize * 0.6)).floor();
    final int estimatedLines = math.max(
        1, (extracurricular.name.length / estimatedCharactersPerLine).ceil());
    final double estimatedTextHeight =
        estimatedLines * titleFontSize * lineHeight;

    final double minHeight = 260.0;
    final double maxHeight = 450.0;

    final double headerHeight = math.min(
      maxHeight,
      math.max(minHeight, 200 + estimatedTextHeight),
    );

    return FadeInUp(
      duration: Duration(milliseconds: 500),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isRecentlyRestored
                  ? Colors.green.withOpacity(0.3)
                  : colorScheme['primary']!.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
          border: isRecentlyRestored
              ? Border.all(color: Colors.green, width: 2)
              : null,
        ),
        child: Column(
          children: [
            // Header with gradient and pattern
            Container(
              height: headerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme['primary']!,
                    colorScheme['primary']!.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  // Pattern overlay
                  Positioned.fill(
                    child: CustomPaint(
                      painter: Modern2025PatternPainter(
                        primaryColor: Colors.white.withOpacity(0.1),
                        secondaryColor: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with glow effect
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.sports_soccer,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(height: 16),
                        // Title with auto-wrap
                        Text(
                          extracurricular.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            height: lineHeight,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        // Coach info
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  extracurricular.coachName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
            // Content section
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme['primary'],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    extracurricular.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernActionButton(
                          onTap: () async {
                            final result = await Get.toNamed(
                              Routes.editExtracurricular,
                              arguments: extracurricular,
                            );
                            if (result == true) {
                              _refreshExtracurriculars();
                            }
                          },
                          icon: Icons.edit,
                          label: 'Edit',
                          gradient: LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                          ),
                          shadowColor: Color(0xFF4CAF50),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildModernActionButton(
                          onTap: () => _showDeleteConfirmation(extracurricular),
                          icon: Icons.archive,
                          label: 'Arsip',
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFFF8C00)],
                          ),
                          shadowColor: Color(0xFFFF9800),
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
    );
  }

  Widget _buildModernActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required Color shadowColor,
  }) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: SkeletonCard(
        height: 300,
      ),
    );
  }

  void _showDeleteConfirmation(Extracurricular extracurricular) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.archive, color: Colors.orange),
            SizedBox(width: 10),
            Text('Arsipkan Ekstrakurikuler?'),
          ],
        ),
        content: Text(
          'Ekstrakurikuler "${extracurricular.name}" akan dipindahkan ke arsip. Anda dapat memulihkannya nanti.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context
                    .read<ExtracurricularCubit>()
                    .deleteExtracurricular(extracurricular.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ekstrakurikuler berhasil diarsipkan'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal mengarsipkan ekstrakurikuler'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Arsipkan'),
          ),
        ],
      ),
    );
  }
}

class Modern2025PatternPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  Modern2025PatternPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dotPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    final double spacing = 40;

    // Draw curved lines
    for (double i = -size.width / 2; i < size.width * 1.5; i += spacing) {
      final path = Path();
      path.moveTo(i, 0);
      path.quadraticBezierTo(
          i + spacing / 2, size.height / 2, i + spacing, size.height);
      canvas.drawPath(path, paint);
    }

    // Add decorative dots
    for (int i = 0; i < 12; i++) {
      final x = (size.width * 0.1) + (i * size.width * 0.08);
      final y = size.height * 0.2 + (i % 3) * size.height * 0.3;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
