import 'package:eschool_saas_staff/cubits/leave/applyLeaveCubit.dart';
import 'package:eschool_saas_staff/cubits/leave/leaveSettingsCubit.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customFileContainer.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/textWithFadedBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/uploadImageOrFileButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// Define our theme colors
final Color maroonPrimary = Color(0xFF8B1F41);
final Color maroonLight = Color(0xFFAC3B5C);
final Color maroonDark = Color(0xFF6A0F2A);
final Color accentColor = Color(0xFFF5EBE0);
final Color bgColor = Color(0xFFFAF6F2);
final Color cardColor = Colors.white;
final Color textDarkColor = Color(0xFF2D2D2D);
final Color textMediumColor = Color(0xFF717171);
final Color borderColor = Color(0xFFE8E8E8);

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  static Widget getRouteInstance() => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ApplyLeaveCubit(),
          ),
          BlocProvider(
            create: (context) => LeaveSettingsAndSessionYearsCubit(),
          ),
        ],
        child: const ApplyLeaveScreen(),
      );

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _textEditingController =
      TextEditingController();
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;
  Map<DateTime, String> _leaveDays = {};
  List<PlatformFile> _uploadedFiles = [];
  bool _isExpanded = true;
  bool _isAttachmentExpanded = false;
  bool _isReasonExpanded = true;
  bool _showDateSelection = false;
  double _headerHeight = 200.0;

  @override
  void initState() {
    super.initState();

    // Primary animation controller for fade effects
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Pulse animation for interactive elements
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Slide animation for content entry
    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutQuint,
      ),
    );

    // Start animations
    _animationController.forward();
    _slideController.forward();

    // Scroll listener to create collapsing header effect
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && _headerHeight == 200.0) {
        setState(() {
          _headerHeight = 120.0;
        });
      } else if (_scrollController.offset <= 50 && _headerHeight == 120.0) {
        setState(() {
          _headerHeight = 200.0;
        });
      }
    });

    // Initialize data
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<LeaveSettingsAndSessionYearsCubit>()
            .getLeaveSettingsAndSessionYears();
      }
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addFiles() async {
    HapticFeedback.mediumImpact();
    final result = await Utils.openFilePicker(
      context: context,
    );
    if (result != null) {
      _uploadedFiles.addAll(result.files);
      setState(() {});

      // Show a subtle animation when files are added
      _pulseController.reset();
      _pulseController.forward();
    }
  }

  void generateLeaveDays() {
    List<int> holidayWeekdays =
        context.read<LeaveSettingsAndSessionYearsCubit>().getHolidayWeekDays();
    _leaveDays = {};
    int differenceInDays =
        _selectedToDate!.difference(_selectedFromDate!).inDays;
    _leaveDays.addAll({
      _selectedFromDate!: fullDayKey,
    });
    for (var i = 1; i < differenceInDays; i++) {
      final date = _selectedFromDate!.add(Duration(days: i));
      _leaveDays.addAll({date: fullDayKey});
    }

    _leaveDays.addAll({
      _selectedToDate!: fullDayKey,
    });

    _leaveDays
        .removeWhere((key, value) => holidayWeekdays.contains(key.weekday));
  }

  void onTapFromDate() async {
    HapticFeedback.lightImpact();
    setState(() {
      _showDateSelection = true;
    });

    final selectedDate = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: maroonPrimary,
                onPrimary: Colors.white,
                onSurface: textDarkColor,
                surface: cardColor,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: maroonPrimary,
                ),
              ),
              dialogBackgroundColor: cardColor,
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: child!,
            ),
          );
        },
        lastDate: DateTime.parse(context
            .read<LeaveSettingsAndSessionYearsCubit>()
            .getCurrentSessionYear()
            .end_date!));

    setState(() {
      _showDateSelection = false;
    });

    if (selectedDate != null) {
      setState(() {
        _selectedFromDate = selectedDate;
      });

      if (_selectedToDate != null) {
        if (_selectedFromDate!.isAfter(_selectedToDate!)) {
          setState(() {
            _selectedToDate = null;
            _leaveDays = {};
          });
        } else {
          generateLeaveDays();
        }
      }
    }
  }

  void onTapToDate() async {
    if (_selectedFromDate == null) {
      _showAnimatedSnackBar(message: pleaseSelectFromDateKey);
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _showDateSelection = true;
    });

    final selectedDate = await showDatePicker(
        context: context,
        firstDate: _selectedFromDate!,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: maroonPrimary,
                onPrimary: Colors.white,
                onSurface: textDarkColor,
                surface: cardColor,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: maroonPrimary,
                ),
              ),
              dialogBackgroundColor: cardColor,
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: child!,
            ),
          );
        },
        lastDate: DateTime.parse(context
            .read<LeaveSettingsAndSessionYearsCubit>()
            .getCurrentSessionYear()
            .end_date!));

    setState(() {
      _showDateSelection = false;
    });

    if (selectedDate != null) {
      setState(() {
        _selectedToDate = selectedDate;
      });
      generateLeaveDays();
    }
  }

  void _showAnimatedSnackBar({required String message}) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  message.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: maroonPrimary,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 6,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Widget _buildSubmitLeaveContainer() {
    return BlocConsumer<ApplyLeaveCubit, ApplyLeaveState>(
      listener: (context, state) {
        if (state is ApplyLeaveSuccess) {
          _leaveDays = {};
          _textEditingController.clear();
          _selectedFromDate = null;
          _selectedToDate = null;
          _uploadedFiles = [];
          setState(() {});
          Navigator.pop(context);

          // Show success animation with confetti effect
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Perizinan berhasil diajukan!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.green.shade600,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
            ),
          );
        } else if (state is ApplyLeaveFailure) {
          _showAnimatedSnackBar(message: state.errorMessage);
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: state is! ApplyLeaveInProgress,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
             

                  // Submit button with animation
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.95, end: 1.0),
                    duration: Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: CustomRoundedButton(
                          height: 56,
                          widthPercentage: 1.0,
                          backgroundColor: maroonPrimary,
                          buttonTitle: submitLeaveKey,
                          radius: 16,
                          textSize: 16,
                          fontWeight: FontWeight.w600,
                          showBorder: false,
                          child: state is ApplyLeaveInProgress
                              ? const CustomCircularProgressIndicator(
                                  indicatorColor: Colors.white)
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      submitLeaveKey.tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                          onTap: () {
                            if (state is ApplyLeaveInProgress) {
                              return;
                            }

                            if (_textEditingController.text.trim().isEmpty) {
                              _showAnimatedSnackBar(
                                  message: pleaseAddReasonKey);
                              return;
                            }

                            if (_selectedFromDate == null) {
                              _showAnimatedSnackBar(
                                  message: pleaseSelectFromDateKey);
                              return;
                            }

                            if (_selectedToDate == null) {
                              _showAnimatedSnackBar(
                                  message: pleaseSelectToDateKey);
                              return;
                            }

                            context.read<ApplyLeaveCubit>().applyLeave(
                                attachmentPaths: _uploadedFiles
                                    .map((file) => (file.path ?? ""))
                                    .toList(),
                                reason: _textEditingController.text.trim(),
                                leaveDays: _leaveDays);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelectionField({
    required String title,
    required String? selectedDate,
    required IconData icon,
    required VoidCallback onTap,
    required String hintText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOutQuint,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
          border: Border.all(
            color: selectedDate != null
                ? maroonPrimary.withOpacity(0.3)
                : borderColor,
            width: selectedDate != null ? 1.5 : 1,
          ),
        ),
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: maroonPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: maroonPrimary,
                size: 22,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: textMediumColor,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    selectedDate ?? hintText,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: selectedDate != null
                          ? textDarkColor
                          : textMediumColor.withOpacity(0.7),
                      fontWeight: selectedDate != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
              padding: EdgeInsets.all(selectedDate != null ? 8 : 0),
              decoration: BoxDecoration(
                color: selectedDate != null
                    ? maroonPrimary.withOpacity(0.1)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                selectedDate != null
                    ? Icons.check_rounded
                    : Icons.calendar_month_rounded,
                size: 20,
                color: selectedDate != null
                    ? maroonPrimary
                    : textMediumColor.withOpacity(0.5),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveDaysWithReasonContainer({required DateTime dateTime}) {
    final selectedLeaveTypeKey = _leaveDays[dateTime];
    final formattedDate =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dateTime);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(
            bottom: 12.0, // Reduced from 16.0
            left: appContentHorizontalPadding,
            right: appContentHorizontalPadding),
        padding: EdgeInsets.symmetric(
            horizontal: 16, vertical: 12), // Reduced padding
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: Offset(0, 5),
              spreadRadius: 0,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date header - Simplified design
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: maroonPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.event,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: textDarkColor,
                        ),
                      ),
                      Text(
                        "Pilih jenis izin",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          color: textMediumColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Leave type radio buttons in a row - Completely different approach
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  _buildLeaveTypeRadio(
                    dateTime: dateTime,
                    leaveTypeKey: fullDayKey,
                    label: "Penuh",
                    icon: Icons.event_available_rounded,
                    isSelected: selectedLeaveTypeKey == fullDayKey,
                  ),
                  SizedBox(width: 8),
                  _buildLeaveTypeRadio(
                    dateTime: dateTime,
                    leaveTypeKey: firstHalfKey,
                    label: "Pagi",
                    icon: Icons.wb_sunny_outlined,
                    isSelected: selectedLeaveTypeKey == firstHalfKey,
                  ),
                  SizedBox(width: 8),
                  _buildLeaveTypeRadio(
                    dateTime: dateTime,
                    leaveTypeKey: secondHalfKey,
                    label: "Siang",
                    icon: Icons.nights_stay_outlined,
                    isSelected: selectedLeaveTypeKey == secondHalfKey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveTypeRadio({
    required DateTime dateTime,
    required String leaveTypeKey,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _leaveDays[dateTime] = leaveTypeKey;
          setState(() {});
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? maroonPrimary.withOpacity(0.1)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? maroonPrimary : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? maroonPrimary : textMediumColor,
              ),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: isSelected ? maroonPrimary : textDarkColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratedLeaveDaysContainer() {
    List<DateTime> dateTimes = _leaveDays.keys.toList()..sort();
    if (dateTimes.isEmpty) {
      return const SizedBox();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: appContentHorizontalPadding,
              right: appContentHorizontalPadding,
              bottom: 16,
              top: 16,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: maroonPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: maroonPrimary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Detail Hari Cuti",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: textDarkColor,
                      ),
                    ),
                    Text(
                      "${dateTimes.length} hari yang perlu diatur",
                      style: TextStyle(
                        fontSize: 13,
                        color: textMediumColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: maroonPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: maroonPrimary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    "${dateTimes.length} Hari",
                    style: TextStyle(
                      color: maroonPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...dateTimes
              .map((dateTime) =>
                  _buildLeaveDaysWithReasonContainer(dateTime: dateTime))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: maroonPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: maroonPrimary,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: textDarkColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
    String? subtitle,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onToggle();
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: maroonPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: maroonPrimary,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: textDarkColor,
                          ),
                        ),
                        if (subtitle != null) SizedBox(height: 4),
                        if (subtitle != null)
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: textMediumColor,
                              fontFamily: 'Poppins',
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? maroonPrimary.withOpacity(0.1)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isExpanded ? maroonPrimary : textMediumColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              height: isExpanded ? null : 0,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: isExpanded ? 20 : 0,
              ),
              child: ClipRect(
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonTextFieldSection() {
    return _buildExpandableSection(
      title: "Alasan Cuti",
      icon: Icons.description_rounded,
      isExpanded: _isReasonExpanded,
      subtitle: "Jelaskan alasan pengajuan cuti Anda",
      onToggle: () {
        setState(() {
          _isReasonExpanded = !_isReasonExpanded;
        });
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _textEditingController,
              maxLines: 5,
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Poppins',
                color: textDarkColor,
              ),
              decoration: InputDecoration(
                hintText: "Jelaskan alasan pengajuan cuti Anda...",
                hintStyle: TextStyle(
                  color: textMediumColor.withOpacity(0.7),
                  fontFamily: 'Poppins',
                ),
                contentPadding: EdgeInsets.all(16),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Min. 10 karakter",
              style: TextStyle(
                fontSize: 12,
                color: textMediumColor,
                fontFamily: 'Poppins',
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return _buildExpandableSection(
      title: "Lampiran Dokumen",
      icon: Icons.attach_file_rounded,
      isExpanded: _isAttachmentExpanded,
      subtitle: _uploadedFiles.isEmpty
          ? "Tambahkan file pendukung (opsional)"
          : "${_uploadedFiles.length} file terlampir",
      onToggle: () {
        setState(() {
          _isAttachmentExpanded = !_isAttachmentExpanded;
        });
      },
      child: Column(
        children: [
          // Stylish upload button
          GestureDetector(
            onTap: _addFiles,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: maroonPrimary.withOpacity(0.3),
                  width: 1,
                ),
                // For dashed border, consider adding the dotted_border package
                // and wrapping this Container with a DottedBorder widget
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.file_upload_outlined,
                    color: maroonPrimary,
                    size: 36,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tambahkan File",
                    style: TextStyle(
                      color: maroonPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "PDF, JPG, PNG (maks. 5MB)",
                    style: TextStyle(
                      color: textMediumColor,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Uploaded files list with animation
          ..._uploadedFiles.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final file = entry.value;

              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: maroonPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getFileIcon(file.name),
                          color: maroonPrimary,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                                color: textDarkColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              _formatFileSize(file.size),
                              style: TextStyle(
                                fontSize: 12,
                                color: textMediumColor,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _uploadedFiles.removeAt(index);
                          });
                        },
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ).toList(),

          if (_uploadedFiles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Belum ada file yang diunggah",
                style: TextStyle(
                  fontSize: 14,
                  color: textMediumColor,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '${sizeInBytes} B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  Widget _buildHeaderSection() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOutQuint,
      height: _headerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [maroonPrimary, maroonDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: maroonPrimary.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button and title row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Title and subtitle in a column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pengajuan Cuti",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            // Only show subtitle when header is expanded
                            if (_headerHeight > 130)
                              AnimatedOpacity(
                                opacity: (_headerHeight - 130) /
                                    70, // Fade out as height decreases
                                duration: Duration(milliseconds: 200),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "Silakan isi formulir pengajuan cuti Anda",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // No Spacer needed - this was contributing to the overflow
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: appContentHorizontalPadding,
        vertical: 16,
      ),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        children: [
          _buildSectionTitle("Periode Cuti", Icons.date_range_rounded),
          _buildDateSelectionField(
            title: "Tanggal Mulai",
            selectedDate: _selectedFromDate != null
                ? Utils.formatDate(_selectedFromDate!)
                : null,
            hintText: "Pilih tanggal mulai",
            icon: Icons.calendar_today_rounded,
            onTap: onTapFromDate,
          ),
          _buildDateSelectionField(
            title: "Tanggal Selesai",
            selectedDate: _selectedToDate != null
                ? Utils.formatDate(_selectedToDate!)
                : null,
            hintText: "Pilih tanggal selesai",
            icon: Icons.event_rounded,
            onTap: onTapToDate,
          ),
          if (_selectedFromDate != null && _selectedToDate != null)
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: maroonPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: maroonPrimary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: maroonPrimary,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Total durasi cuti: ${_selectedToDate!.difference(_selectedFromDate!).inDays + 1} hari",
                      style: TextStyle(
                        color: maroonPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'Poppins',
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      primaryColor: maroonPrimary,
      scaffoldBackgroundColor: bgColor,
      textTheme: GoogleFonts.poppinsTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: maroonPrimary,
        primary: maroonPrimary,
        secondary: maroonLight,
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            BlocBuilder<LeaveSettingsAndSessionYearsCubit,
                LeaveSettingsAndSessionYearsState>(
              builder: (context, state) {
                if (state is LeaveSettingsAndSessionYearsFetchSuccess) {
                  return Column(
                    children: [
                      _buildHeaderSection(),
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.only(
                              bottom: 120,
                            ),
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Date selection section
                                    _buildDateRangeSection(),

                                    // Leave days details
                                    _buildGeneratedLeaveDaysContainer(),

                                    // Reason input section
                                    if (_leaveDays.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              appContentHorizontalPadding,
                                          vertical: 8,
                                        ),
                                        child: _buildReasonTextFieldSection(),
                                      ),

                                    // Attachment section
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: appContentHorizontalPadding,
                                      ),
                                      child: _buildAttachmentSection(),
                                    ),

                                    // Additional information or policies
                                    if (_leaveDays.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              appContentHorizontalPadding,
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.blue.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_rounded,
                                                color: Colors.blue.shade700,
                                                size: 24,
                                              ),
                                              SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Informasi Penting",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors
                                                            .blue.shade800,
                                                        fontSize: 14,
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      "Pengajuan cuti akan diproses dalam 1-2 hari kerja. Pastikan data yang diisi sudah benar.",
                                                      style: TextStyle(
                                                        color: Colors
                                                            .blue.shade800,
                                                        fontSize: 13,
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                if (state is LeaveSettingsAndSessionYearsFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      errorMessage: state.errorMessage,
                      onTapRetry: () {
                        context
                            .read<LeaveSettingsAndSessionYearsCubit>()
                            .getLeaveSettingsAndSessionYears();
                      },
                    ),
                  );
                }

                // Loading state with animation
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          color: maroonPrimary,
                          strokeWidth: 4,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        "Memuat data...",
                        style: TextStyle(
                          fontSize: 16,
                          color: textMediumColor,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: BlocBuilder<LeaveSettingsAndSessionYearsCubit,
                  LeaveSettingsAndSessionYearsState>(
                builder: (context, state) {
                  if (state is LeaveSettingsAndSessionYearsFetchSuccess) {
                    return _buildSubmitLeaveContainer();
                  }
                  return const SizedBox();
                },
              ),
            ),
            // Date selection overlay animation
            if (_showDateSelection)
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                color: Colors.black54,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(
                            color: maroonPrimary,
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Memuat...",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
