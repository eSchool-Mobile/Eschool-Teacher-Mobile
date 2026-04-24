import 'dart:math';
import 'package:eschool_saas_staff/cubits/fee/downloadStudentFeeReceiptCubit.dart';
import 'package:eschool_saas_staff/cubits/fee/sessionYearAndFeesCubit.dart';
import 'package:eschool_saas_staff/cubits/fee/studentsFeeStatusCubit.dart';
import 'package:eschool_saas_staff/data/models/staffTeacher/fee.dart';
import 'package:eschool_saas_staff/data/models/staffTeacher/payment.dart';
import 'package:eschool_saas_staff/data/models/academic/sessionYear.dart';
import 'package:eschool_saas_staff/data/models/staff/studentDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customFilterModernAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/no_search_results_widget.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class PaidFeesScreen extends StatefulWidget {
  const PaidFeesScreen({super.key});

  static Widget getRouteInstance() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SessionYearAndFeesCubit(),
        ),
        BlocProvider(
          create: (context) => StudentsFeeStatusCubit(),
        ),
      ],
      child: const PaidFeesScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<PaidFeesScreen> createState() => _PaidFeesScreenState();
}

// Add missing key constant
const String totalFeeKey = "totalFee";

class _PaidFeesScreenState extends State<PaidFeesScreen>
    with TickerProviderStateMixin {
  String _selectedFeeStatus = "";
  Fee? _selectedFee;
  SessionYear? _selectedSessionYear;

  // Color scheme for maroon theme
  final Color _maroonPrimary = const Color(0xFF800020);
  final Color _maroonLight = const Color(0xFFAA6976);

  // Search functionality
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Animation controller for scroll-based animations
  late AnimationController _fabAnimationController;
  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  String formatRupiah(double amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    debugPrint('=================== SCREEN INITIALIZED ===================');
    debugPrint('Initial Session Year: ${_selectedSessionYear?.name ?? "Not set"}');
    debugPrint('Initial Fee Status: $_selectedFeeStatus');
    debugPrint('Initial Fee: ${_selectedFee?.name ?? "Not set"}');
    debugPrint('Initial Search Query: "$_searchQuery"');
    debugPrint('Initial Search Active: $_isSearchActive');
    debugPrint('=========================================================');

    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<SessionYearAndFeesCubit>().getSessionYearsAndFees();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void scrollListener() {
    // Animate based on scroll position
    if (_scrollController.offset > 50) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }

    // Load more data if at the bottom of the list
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<StudentsFeeStatusCubit>().hasMore()) {
        getMoreStudentFees();
      }
    }
  }

  void getStudentFees() {
    // Print parameter values for debugging
    debugPrint('===================== PARAMETER VALUES =====================');
    debugPrint('Session Year ID: ${_selectedSessionYear?.id ?? 0}');
    debugPrint('Session Year Name: ${_selectedSessionYear?.name ?? "Not selected"}');
    debugPrint(
        'Fee Status: $_selectedFeeStatus (${_selectedFeeStatus == paidKey ? 1 : 0})');
    debugPrint('Fee ID: ${_selectedFee?.id ?? 0}');
    debugPrint('Fee Name: ${_selectedFee?.name ?? "Not selected"}');
    debugPrint('Search Query: $_searchQuery');
    debugPrint('==========================================================');

    context.read<StudentsFeeStatusCubit>().getStudentFeePaymentStatus(
        sessionYearId: _selectedSessionYear?.id ?? 0,
        status: _selectedFeeStatus == paidKey ? 1 : 0,
        feeId: _selectedFee?.id ?? 0,
        search: _searchQuery);
  }

  void getMoreStudentFees() {
    // Print parameter values for pagination
    debugPrint('================ PAGINATION PARAMETER VALUES ================');
    debugPrint('Session Year ID: ${_selectedSessionYear?.id ?? 0}');
    debugPrint('Session Year Name: ${_selectedSessionYear?.name ?? "Not selected"}');
    debugPrint(
        'Fee Status: $_selectedFeeStatus (${_selectedFeeStatus == paidKey ? 1 : 0})');
    debugPrint('Fee ID: ${_selectedFee?.id ?? 0}');
    debugPrint('Fee Name: ${_selectedFee?.name ?? "Not selected"}');
    debugPrint('Search Query: $_searchQuery');
    debugPrint('============================================================');

    context.read<StudentsFeeStatusCubit>().fetchMore(
        sessionYearId: _selectedSessionYear?.id ?? 0,
        status: _selectedFeeStatus == paidKey ? 1 : 0,
        feeId: _selectedFee?.id ?? 0);
  }

  void changeSelectedSessionYear(SessionYear value) {
    setState(() {
      _selectedSessionYear = value;
    });
    debugPrint('Session Year changed to: ${value.name} (ID: ${value.id})');
  }

  void changeSelectedFeeStatus(String value) {
    setState(() {
      _selectedFeeStatus = value;
    });
    debugPrint('Fee Status changed to: $value (${value == paidKey ? 1 : 0})');
  }

  void changeSelectedFee(Fee value) {
    setState(() {
      _selectedFee = value;
    });
    debugPrint('Fee Type changed to: ${value.name} (ID: ${value.id})');
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
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
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari siswa...',
                  prefixIcon: Icon(Icons.search, color: _maroonLight),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close, color: _maroonLight),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = "";
                        _isSearchActive = false;
                      });
                      // Trigger search with empty query when clearing
                      getStudentFees();
                      debugPrint('Search cleared and deactivated');
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  // Use debounce technique for search
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchQuery == value) {
                      getStudentFees();
                    }
                  });
                  debugPrint('Search Query changed to: "$value"');
                },
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildAppBar() {
    return BlocConsumer<SessionYearAndFeesCubit, SessionYearAndFeesState>(
      listener: (context, state) {
        if (state is SessionYearAndFeesFetchSuccess) {
          if (state.fees.isNotEmpty && state.sessionYears.isNotEmpty) {
            changeSelectedFee(state.fees.first);
            changeSelectedSessionYear(state.sessionYears
                .where((element) => element.isThisDefault())
                .toList()
                .first);
            changeSelectedFeeStatus(paidKey);
            getStudentFees();
          }
        }
      },
      builder: (context, state) {
        if (state is SessionYearAndFeesFetchSuccess) {
          return CustomFilterModernAppBar(
            title: 'Biaya yang Dibayar',
            titleIcon: Icons.payments_rounded,
            primaryColor: _maroonPrimary,
            secondaryColor: _maroonLight,
            onBackPressed: () => Navigator.of(context).pop(),
            animationController: _fabAnimationController,
            enableAnimations: true,
            height: MediaQuery.of(context).padding.top + 200,
            showFiltersRow: true,
            showSearchButton: true,
            isSearchActive: _isSearchActive,
            onSearchPressed: () {
              setState(() {
                _isSearchActive = !_isSearchActive;
                if (!_isSearchActive) {
                  _searchController.clear();
                  _searchQuery = "";
                  getStudentFees(); // Reload data when search is cleared
                }
              });
              debugPrint(
                  'Search toggled: ${_isSearchActive ? "activated" : "deactivated"}');
            },

            // First filter - Session Year
            firstFilterItem: FilterItemConfig(
              title: _selectedSessionYear?.name ?? 'Tahun Ajaran',
              icon: Icons.calendar_today_rounded,
              onTap: () {
                if (state.sessionYears.isNotEmpty) {
                  Utils.showBottomSheet(
                    child: FilterSelectionBottomsheet<SessionYear>(
                      onSelection: (value) {
                        changeSelectedSessionYear(value!);
                        getStudentFees();
                        Get.back();
                      },
                      selectedValue: _selectedSessionYear!,
                      titleKey: sessionYearKey,
                      values: state.sessionYears,
                    ),
                    context: context,
                  );
                }
              },
            ),

            // Second filter - Status
            secondFilterItem: FilterItemConfig(
              title: _selectedFeeStatus.isEmpty
                  ? 'Status'
                  : Utils.getTranslatedLabel(_selectedFeeStatus),
              icon: Icons.payment_rounded,
              onTap: () {
                Utils.showBottomSheet(
                  child: FilterSelectionBottomsheet<String>(
                    onSelection: (value) {
                      changeSelectedFeeStatus(value!);
                      getStudentFees();
                      Get.back();
                    },
                    selectedValue: _selectedFeeStatus,
                    titleKey: statusKey,
                    values: const [paidKey, unpaidKey],
                  ),
                  context: context,
                );
              },
            ),

            // Third filter - Fee
            thirdFilterItem: FilterItemConfig(
              title: _selectedFee?.name ?? 'Biaya',
              icon: Icons.monetization_on_rounded,
              onTap: () {
                if (state.fees.isNotEmpty) {
                  Utils.showBottomSheet(
                    child: FilterSelectionBottomsheet<Fee>(
                      onSelection: (value) {
                        changeSelectedFee(value!);
                        getStudentFees();
                        Get.back();
                      },
                      selectedValue: _selectedFee!,
                      titleKey: feeKey,
                      values: state.fees,
                    ),
                    context: context,
                  );
                }
              },
            ),
          );
        }

        // Return a simple modern AppBar when data is loading
        return CustomFilterModernAppBar(
          title: 'Biaya yang Dibayar',
          titleIcon: Icons.payments_rounded,
          primaryColor: _maroonPrimary,
          secondaryColor: _maroonLight,
          onBackPressed: () => Navigator.of(context).pop(),
          animationController: _fabAnimationController,
          enableAnimations: true,
          height: MediaQuery.of(context).padding.top + 200,
          showFiltersRow: false,
          showSearchButton: true,
          isSearchActive: _isSearchActive,
          onSearchPressed: () {
            setState(() {
              _isSearchActive = !_isSearchActive;
              if (!_isSearchActive) {
                _searchController.clear();
                _searchQuery = "";
              }
            });
            debugPrint(
                'Search toggled: ${_isSearchActive ? "activated" : "deactivated"}');
          },
        );
      },
    );
  }

  Widget _buildStudentFeeItemSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with student info
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Index number skeleton
                  Container(
                    width: 30,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Student details
                  Expanded(
                    child: Row(
                      children: [
                        // Student avatar skeleton
                        Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),

                        // Name and class skeleton
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name skeleton
                              Container(
                                height: 14,
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              // Class skeleton
                              Container(
                                height: 12,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Toggle indicator skeleton
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),

            // Expanded details skeleton (shown as collapsed)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title skeleton
                  Container(
                    width: 120,
                    height: 16,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  // Info rows skeleton
                  ...List.generate(
                      4,
                      (index) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left side - label
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      // Icon skeleton
                                      Container(
                                        width: 26,
                                        height: 26,
                                        margin: const EdgeInsets.only(right: 6),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      // Label skeleton
                                      Container(
                                        height: 13,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Divider
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: const Text(
                                    ":",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),

                                // Right side - value
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    height: 14,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),

                  // Payment history section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 12, top: 16),
                    margin: const EdgeInsets.only(bottom: 12, top: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon skeleton
                        Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        // Title skeleton
                        Container(
                          height: 14,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        // Count badge skeleton
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          width: 30,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Payment history items skeleton
                  ...List.generate(
                      2,
                      (index) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with date and method
                                Row(
                                  children: [
                                    // Date section
                                    Expanded(
                                      child: Row(
                                        children: [
                                          // Icon skeleton
                                          Container(
                                            width: 24,
                                            height: 24,
                                            margin:
                                                const EdgeInsets.only(right: 6),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          // Date skeleton
                                          Container(
                                            height: 12,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Method badge skeleton
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      width: 60,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Amount row skeleton
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 13,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    Container(
                                      height: 14,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),

                  // Download button skeleton
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon skeleton
                        Container(
                          width: 34,
                          height: 34,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Text skeleton
                        Container(
                          height: 14,
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
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
    );
  }

  Widget _buildPaidFeesSkeleton() {
    return Align(
      alignment: Alignment.topCenter,
      child: RefreshIndicator(
        onRefresh: () async {},
        color: _maroonPrimary,
        displacement: 100,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: 100,
            top: MediaQuery.of(context).padding.top + 210,
          ),
          child: Column(
            children: [
              // Title and subtitle section
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),

              _buildSearchBar(),

              // Students list container skeleton
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header skeleton
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Row(
                          children: [
                            // Icon skeleton
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Title and count skeleton
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 16,
                                    width: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 12,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Counter badge skeleton
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Table header skeleton
                    Container(
                      margin: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Container(
                                height: 14,
                                width: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                height: 14,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Student items skeleton
                    Container(
                      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          children: List.generate(
                            5,
                            (index) => Column(
                              children: [
                                _buildStudentFeeItemSkeleton(),
                                if (index < 4)
                                  Divider(
                                    color: Colors.grey[100],
                                    thickness: 1,
                                    height: 1,
                                  ),
                              ],
                            ),
                          ),
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
    );
  }

  Widget _buildStudents() {
    return BlocBuilder<StudentsFeeStatusCubit, StudentsFeeStatusState>(
      builder: (context, state) {
        if (state is StudentsFeeStatusFetchSuccess) {
          // Debug output
          debugPrint('=================== STUDENT DATA DEBUG ===================');
          debugPrint('Total students in state: ${state.students.length}');

          if (state.students.isNotEmpty) {
            final firstStudent = state.students.first;
            debugPrint(
                'First student: ${firstStudent.fullName ?? "No name"} (ID: ${firstStudent.id})');
            debugPrint(
                'First student roll number: ${firstStudent.rollNumber ?? "No roll number"}');
            debugPrint('Has payment_status: ${firstStudent.paymentStatus != null}');
            if (firstStudent.paymentStatus != null) {
              debugPrint('Payment status details:');
              debugPrint(
                  '  isFullyPaid: ${firstStudent.paymentStatus!.isFullyPaid}');
              debugPrint(
                  '  totalAmount: ${firstStudent.paymentStatus!.totalAmount}');
              debugPrint('  paidAmount: ${firstStudent.paymentStatus!.paidAmount}');
            }

            debugPrint(
                'Has payment_history: ${firstStudent.paymentHistory?.length ?? 0} items');
            if (firstStudent.paymentHistory != null &&
                firstStudent.paymentHistory!.isNotEmpty) {
              debugPrint('First payment history item:');
              debugPrint('  ID: ${firstStudent.paymentHistory!.first.id}');
              debugPrint('  Amount: ${firstStudent.paymentHistory!.first.amount}');
              debugPrint(
                  '  Date: ${firstStudent.paymentHistory!.first.paymentDate}');
              debugPrint(
                  '  Method: ${firstStudent.paymentHistory!.first.paymentMethod}');
            }
          } else {
            debugPrint('No students in state!');
          }
          debugPrint('=========================================================');

          // Filter students by search query when search is active
          final studentsList = _searchQuery.isEmpty
              ? state.students
              : state.students
                  .where((student) => ((student.fullName ?? "")
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase())))
                  .toList();

          if (studentsList.isEmpty && _searchQuery.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top +
                    170, // Added top padding to avoid app bar
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: NoSearchResultsWidget(
                searchQuery: _searchQuery,
                onClearSearch: () {
                  setState(() {
                    _searchQuery = "";
                    _searchController.clear();
                    _isSearchActive = false;
                  });
                },
                primaryColor: _maroonPrimary,
                accentColor: _maroonLight,
                title: 'Siswa Tidak Ditemukan',
                description:
                    'Tidak ditemukan siswa yang sesuai dengan pencarian Anda. Coba gunakan kata kunci yang berbeda.',
                icon: Icons.person_search_outlined,
              ).animate().fadeIn(delay: 300.ms),
            );
          }

          if (studentsList.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data pembayaran',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Data pembayaran akan ditampilkan di sini',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms),
            );
          }

          return Align(
            alignment: Alignment.topCenter,
            child: RefreshIndicator(
              onRefresh: () async {
                getStudentFees();
              },
              color: _maroonPrimary,
              displacement: 100,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(
                  bottom: 100,
                  // Increasing top padding to ensure title appears below app bar
                  top: MediaQuery.of(context).padding.top + 210,
                ),
                child: Column(
                  children: [
                    // Title and subtitle section
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Biaya yang Dibayar',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _maroonPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Data pembayaran biaya sekolah siswa',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.1, end: 0, curve: Curves.easeOutQuad),

                    // Search bar
                    _buildSearchBar(),

                    // Students list with container styling
                    Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Elegant header with animated gradient
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _maroonPrimary.withValues(alpha: 0.9),
                                  _maroonPrimary,
                                  _maroonLight,
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16)),
                              boxShadow: [
                                BoxShadow(
                                  color: _maroonPrimary.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Animated icon
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(duration: 300.ms)
                                    .slideX(begin: -0.2, end: 0),

                                const SizedBox(width: 16),

                                // Title text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Daftar Pembayaran Siswa',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        '${studentsList.length} siswa',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.white.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Counter badge with animation
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      studentsList.length.toString(),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn(duration: 400.ms).scale(
                                    begin: const Offset(0.8, 0.8),
                                    end: const Offset(1.0, 1.0),
                                    duration: 400.ms),
                              ],
                            ),
                          ),

                          // Table header with modern design
                          Container(
                            margin: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    "No",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: _maroonPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    Utils.getTranslatedLabel(nameKey),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: _maroonPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

                          // Students list items
                          Container(
                            margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: studentsList.length,
                                itemBuilder: (context, index) {
                                  final student = studentsList[index];

                                  return StudentPaidFeeDetailsContainer(
                                    index: index,
                                    compolsoryFeeAmount:
                                        state.compolsoryFeeAmount,
                                    optionalFeeAmount: state.optionalFeeAmount,
                                    studentDetails: student,
                                    maroonPrimary: _maroonPrimary,
                                    maroonLight: _maroonLight,
                                  );
                                },
                              ),
                            ),
                          ),

                          // Load more button if needed
                          if (context.read<StudentsFeeStatusCubit>().hasMore())
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: state.fetchMoreError
                                  ? TextButton(
                                      onPressed: () => getMoreStudentFees(),
                                      child: Text(
                                        Utils.getTranslatedLabel(retryKey),
                                        style: GoogleFonts.poppins(
                                          color: _maroonPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: _buildStudentFeeItemSkeleton(),
                                    ),
                            ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is StudentsFeeStatusFetchFailure) {
          return Center(
            child: CustomErrorWidget(
              message: state.errorMessage,
              onRetry: () {
                getStudentFees();
              },
              primaryColor: _maroonPrimary,
            ),
          );
        }

        return _buildPaidFeesSkeleton();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<SessionYearAndFeesCubit, SessionYearAndFeesState>(
            builder: (context, state) {
              if (state is SessionYearAndFeesFetchSuccess) {
                if (state.sessionYears.isEmpty || state.fees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 64,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Data tidak tersedia',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[800],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada data tahun ajaran atau biaya',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ).animate().fadeIn().scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          duration: 400.ms,
                        ),
                  );
                }
                return _buildStudents();
              }
              if (state is SessionYearAndFeesFetchFailure) {
                return Center(
                  child: CustomErrorWidget(
                    message: state.errorMessage,
                    onRetry: () {
                      context
                          .read<SessionYearAndFeesCubit>()
                          .getSessionYearsAndFees();
                    },
                    primaryColor: _maroonPrimary,
                  ),
                );
              }

              return _buildPaidFeesSkeleton();},
          ),

          // Modern app bar
          _buildAppBar(),
        ],
      ),
    );
  }
}

class StudentPaidFeeDetailsContainer extends StatefulWidget {
  final StudentDetails studentDetails;
  final double compolsoryFeeAmount;
  final double optionalFeeAmount;
  final int index;
  final Color maroonPrimary;
  final Color maroonLight;

  const StudentPaidFeeDetailsContainer({
    super.key,
    required this.studentDetails,
    required this.compolsoryFeeAmount,
    required this.optionalFeeAmount,
    required this.index,
    required this.maroonPrimary,
    required this.maroonLight,
  });

  @override
  State<StudentPaidFeeDetailsContainer> createState() =>
      _StudentPaidFeeDetailsContainerState();
}

class _StudentPaidFeeDetailsContainerState
    extends State<StudentPaidFeeDetailsContainer>
    with TickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: tileCollapsedDuration);

  // We only need these two animations
  late final Animation<double> _opacityAnimation =
      Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
          parent: _animationController, curve: const Interval(0.5, 1.0)));

  late final Animation<double> _iconAngleAnimation =
      Tween<double>(begin: 0, end: 180).animate(CurvedAnimation(
          parent: _animationController, curve: Curves.easeInOut));

  String formatRupiah(double amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _downloadFeeReceipt() {
    // Get all payment history records
    final List<PaymentHistory> paymentHistory =
        widget.studentDetails.paymentHistory ??
            widget.studentDetails.paidFeeDetails?.paymentHistory ??
            [];

    // Validate that we have payment records
    if (paymentHistory.isEmpty) {
      Utils.showSnackBar(
        message: "No payment records found for this student",
        context: context,
      );
      return;
    }

    // Extract payment history IDs
    final List<int> paymentHistoryIds = paymentHistory
        .map((payment) => payment.id)
        .toList();

    if (paymentHistoryIds.isEmpty) {
      Utils.showSnackBar(
        message: "Invalid payment records found",
        context: context,
      );
      return;
    }

    Get.dialog(
      BlocProvider(
        create: (context) => DownloadStudentFeeReceiptCubit(),
        child: _downloadFeesReceiptDialog(paymentHistoryIds),
      ),
    );
  }

  Widget _downloadFeesReceiptDialog(List<int> paymentHistoryIds) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 8.0,
      backgroundColor: Colors.white,
      child: BlocConsumer<DownloadStudentFeeReceiptCubit,
          DownloadStudentFeeReceiptState>(
        listener: (context, state) {
          if (state is DownloadStudentFeeReceiptSuccess) {
            OpenFilex.open(state.downloadedFilePath);
            Get.back();
          }
        },
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: widget.maroonPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: widget.maroonPrimary,
                    size: 32,
                  ),
                ).animate().fadeIn().scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                    ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Download Struk Pembayaran',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Memproses struk pembayaran siswa',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Loading indicator or status
                if (state is DownloadStudentFeeReceiptInProgress)
                  Column(
                    children: [
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(
                          color: widget.maroonPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Memproses dokumen...',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  )
                else if (state is DownloadStudentFeeReceiptFailure)
                  Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 50,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.red[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<DownloadStudentFeeReceiptCubit>()
                              .downloadStudentFeeReceipt(
                                  paymentHistoryIds: paymentHistoryIds,
                                  studentName: widget.studentDetails.fullName ??
                                      "Student");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.maroonPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          Utils.getTranslatedLabel(retryKey),
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<DownloadStudentFeeReceiptCubit>()
                          .downloadStudentFeeReceipt(
                              paymentHistoryIds: paymentHistoryIds,
                              studentName:
                                  widget.studentDetails.fullName ?? "Student");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.maroonPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.download_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Download Sekarang',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                // Cancel button
                if (state is DownloadStudentFeeReceiptInProgress)
                  const SizedBox(height: 16)
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    IconData? icon,
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - label with icon
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null)
                  Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: widget.maroonPrimary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 14,
                      color: widget.maroonPrimary,
                    ),
                  ),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              ":",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ),

          // Right side - value with better constraints
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? widget.maroonPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Build a payment history item
  Widget _buildPaymentHistoryItem(PaymentHistory payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and method
          Row(
            children: [
              // Date with icon
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: widget.maroonPrimary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: widget.maroonPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        payment.paymentDate,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Method with colored badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.maroonPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  payment.paymentMethod,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: widget.maroonPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Nominal",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                formatRupiah(payment.amount),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.maroonPrimary,
                ),
              ),
            ],
          ),

          // View proof image if available
          if (payment.proofImage != null && payment.proofImage!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: InkWell(
                onTap: () {
                  // Open image in dialog with improved UI
                  Get.dialog(
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header with gradient
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.maroonPrimary,
                                  const Color(0xFF9A1E3C),
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.receipt_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Bukti Pembayaran",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Close button as overlay
                          Stack(
                            children: [
                              // Image container
                              Container(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(Get.context!).size.height *
                                          0.6,
                                  maxWidth:
                                      MediaQuery.of(Get.context!).size.width *
                                          0.8,
                                ),
                                // ClipRRect kept for rounded corners while
                                // InteractiveViewer enables pinch-zoom & pan
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(16),
                                  ),
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    scaleEnabled: true,
                                    minScale: 1.0,
                                    maxScale: 4.0,
                                    child: Image.network(
                                      payment.proofImage!,
                                      fit: BoxFit.contain,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return SizedBox(
                                          height: 300,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                              color: widget.maroonPrimary,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              SizedBox(
                                        height: 300,
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.error_outline,
                                                  color: Colors.red, size: 48),
                                              const SizedBox(height: 16),
                                              Text(
                                                "Gagal memuat gambar",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Close button overlay
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => Get.back(),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_rounded,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Lihat Bukti Pembayaran",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[700],
                        ),
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

  @override
  Widget build(BuildContext context) {
    // Determine if we have payment data in either the old or new format
    final bool hasFeeDetails = widget.studentDetails.paidFeeDetails != null;
    final bool hasPaymentStatus = widget.studentDetails.paymentStatus != null;

    // Get the payment history
    final List<PaymentHistory> paymentHistory =
        widget.studentDetails.paymentHistory ??
            widget.studentDetails.paidFeeDetails?.paymentHistory ??
            [];

    // Debug info
    debugPrint('=================== PAYMENT DETAILS DEBUG ===================');
    debugPrint('Student ID: ${widget.studentDetails.id}');
    debugPrint('Student Name: ${widget.studentDetails.fullName}');
    debugPrint('Has paymentStatus: $hasPaymentStatus');
    debugPrint(
        'Has direct payment_history: ${widget.studentDetails.paymentHistory != null}');
    debugPrint(
        'Has paidFeeDetails: ${widget.studentDetails.paidFeeDetails != null}');
    debugPrint(
        'Has paidFeeDetails.paymentHistory: ${widget.studentDetails.paidFeeDetails?.paymentHistory != null}');
    debugPrint('Total payment history items: ${paymentHistory.length}');
    if (paymentHistory.isNotEmpty) {
      debugPrint(
          'First payment: ${paymentHistory.first.amount} on ${paymentHistory.first.paymentDate}');
    }
    debugPrint('=========================================================');

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (_animationController.isAnimating) {
              return;
            }

            if (_animationController.isCompleted) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with student info
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Index number
                      SizedBox(
                        width: 30,
                        child: Text(
                          "${widget.index + 1}",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),

                      // Student details
                      Expanded(
                        child: Row(
                          children: [
                            // Student avatar or icon
                            Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: widget.maroonPrimary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  widget.studentDetails.fullName?.isNotEmpty ==
                                          true
                                      ? widget.studentDetails.fullName![0]
                                          .toUpperCase()
                                      : "S",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: widget.maroonPrimary,
                                  ),
                                ),
                              ),
                            ),

                            // Name and class with proper constraints
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.studentDetails.fullName ?? "-",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    // Use class section from new API structure if available
                                    widget.studentDetails.classSection
                                            ?.fullName ??
                                        widget.studentDetails.student
                                            ?.classSection?.fullName ??
                                        widget.studentDetails.rollNumber ??
                                        "-",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Toggle indicator
                      Transform.rotate(
                        angle: (pi * _iconAngleAnimation.value) / 180,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: widget.maroonPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Expanded details
                AnimatedOpacity(
                  opacity: _opacityAnimation.value,
                  duration: const Duration(milliseconds: 300),
                  child: _animationController.value > 0.5
                      ? Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section title
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(bottom: 12),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.payments_rounded,
                                      size: 16,
                                      color: widget.maroonPrimary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Detail Pembayaran',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: widget.maroonPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Fee details - prioritize new API format if available
                              _buildInfoRow(
                                label: Utils.getTranslatedLabel(totalFeeKey),
                                value: formatRupiah(hasPaymentStatus
                                    ? widget.studentDetails.paymentStatus!
                                        .totalAmount
                                    : (widget.compolsoryFeeAmount +
                                        widget.optionalFeeAmount)),
                                icon: Icons.monetization_on_outlined,
                              ),

                              _buildInfoRow(
                                label: 'ID Siswa',
                                value: '${widget.studentDetails.id ?? "N/A"}',
                                icon: Icons.person_pin,
                                valueColor: Colors.indigo[700],
                              ),

                              _buildInfoRow(
                                label: 'Jumlah Dibayar',
                                value: formatRupiah(hasPaymentStatus
                                    ? widget.studentDetails.paymentStatus!
                                        .paidAmount
                                    : (widget.studentDetails.paidFeeDetails
                                            ?.paidAmount ??
                                        0.0)),
                                icon: Icons.payments,
                                valueColor: Colors.green[700],
                              ),

                              if (hasPaymentStatus ||
                                  (hasFeeDetails &&
                                      widget.studentDetails.paidFeeDetails!
                                              .remainingAmount >
                                          0))
                                _buildInfoRow(
                                  label: 'Sisa Pembayaran',
                                  value: formatRupiah(hasPaymentStatus
                                      ? widget.studentDetails.paymentStatus!
                                          .remainingAmount
                                      : (widget.studentDetails.paidFeeDetails
                                              ?.remainingAmount ??
                                          0.0)),
                                  icon: widget.studentDetails.paymentStatus
                                                  ?.isFullyPaid ==
                                              true ||
                                          widget.studentDetails.paidFeeDetails
                                                  ?.isFullyPaid ==
                                              true
                                      ? Icons.check_circle_outline
                                      : Icons.warning_amber_rounded,
                                  valueColor: widget.studentDetails
                                                  .paymentStatus?.isFullyPaid ==
                                              true ||
                                          widget.studentDetails.paidFeeDetails
                                                  ?.isFullyPaid ==
                                              true
                                      ? Colors.green[700]
                                      : Colors.orange[700],
                                ),

                              _buildInfoRow(
                                label: 'Status',
                                value: widget.studentDetails.paymentStatus
                                                ?.isFullyPaid ==
                                            true ||
                                        widget.studentDetails.paidFeeDetails
                                                ?.isFullyPaid ==
                                            true
                                    ? "Lunas"
                                    : "Belum Lunas",
                                icon: Icons.info_outline,
                                valueColor: widget.studentDetails.paymentStatus
                                                ?.isFullyPaid ==
                                            true ||
                                        widget.studentDetails.paidFeeDetails
                                                ?.isFullyPaid ==
                                            true
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                              ),

                              if (paymentHistory.isNotEmpty) ...[
                                // Payment history section title with improved design
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                      bottom: 12, top: 16),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: widget.maroonPrimary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.history_rounded,
                                          size: 16,
                                          color: widget.maroonPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Riwayat Pembayaran',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: widget.maroonPrimary,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Payment count badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: widget.maroonPrimary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${paymentHistory.length}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: widget.maroonPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Payment history list
                                ...paymentHistory
                                    .map((payment) =>
                                        _buildPaymentHistoryItem(payment))
                                    ,
                              ],

                              // Payment receipt section with improved design
                              if (hasFeeDetails || hasPaymentStatus)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(top: 16),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () =>
                                          _downloadFeeReceipt(), // This calls our updated method
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              widget.maroonPrimary,
                                              const Color(0xFF9A1E3C),
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: widget.maroonPrimary
                                                  .withValues(alpha: 0.3),
                                              offset: const Offset(0, 3),
                                              blurRadius: 6,
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Animated icon
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withValues(alpha: 0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.download_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Text
                                            Text(
                                              'Unduh Struk Pembayaran',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 300.ms, duration: 500.ms)
                                    .slideY(begin: 0.2, end: 0),
                            ],
                          ),
                        )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad)
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
