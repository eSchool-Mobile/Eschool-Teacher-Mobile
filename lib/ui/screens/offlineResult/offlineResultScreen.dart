import 'package:eschool_saas_staff/cubits/exam/offlineExamStudentResultsCubit.dart';
import 'package:eschool_saas_staff/cubits/exam/offlineExamsWithClassesAndSessionYearsCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/offlineExam.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/ui/screens/offlineResult/widgets/studentOfflineResultContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customFilterModernAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';

class OfflineResultScreen extends StatefulWidget {
  const OfflineResultScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => OfflineExamsWithClassesAndSessionYearsCubit(),
        ),
        BlocProvider(
          create: (context) => OfflineExamStudentResultsCubit(),
        ),
      ],
      child: const OfflineResultScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<OfflineResultScreen> createState() => _OfflineResultScreenState();
}

class _OfflineResultScreenState extends State<OfflineResultScreen>
    with TickerProviderStateMixin {
  ClassSection? _selectedClassSection;
  SessionYear? _selectedSessionYear;
  OfflineExam? _selectedOfflineExam;

  // Animation controller for the app bar
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Define colors
  final Color maroonPrimary = const Color(0xFF8B1F41);
  final Color maroonLight = const Color(0xFFAC3B5C);
  final Color maroonDark = const Color(0xFF6A0F2A);
  final Color accentColor = const Color(0xFFF5EBE0);
  final Color bgColor = const Color(0xFFFAF6F2);
  final Color cardColor = Colors.white;
  final Color textDarkColor = const Color(0xFF2D2D2D);
  final Color textMediumColor = const Color(0xFF717171);
  final Color borderColor = const Color(0xFFE8E8E8);

  // Gradient colors for modern design
  final List<Color> gradientColors = [
    const Color(0xFF8B1F41),
    const Color(0xFFAC3B5C),
  ];

  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _animationController.forward();

    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<OfflineExamsWithClassesAndSessionYearsCubit>()
            .getOfflineExamsWithSessionYearsAndClasses(
                sesstionYearId: _selectedSessionYear?.id);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<OfflineExamStudentResultsCubit>().hasMore()) {
        getMoreStudentResults();
      }
    }
  }

  void changeSelectedSessionYear(SessionYear value) {
    _selectedSessionYear = value;
    setState(() {});
  }

  void changeSelectedClassSection(ClassSection value) {
    _selectedClassSection = value;
    setState(() {});
  }

  void changeSelectedOfflineExam(OfflineExam? value) {
    _selectedOfflineExam = value;
    setState(() {});
  }

  void getStudentResults() {
    context.read<OfflineExamStudentResultsCubit>().getStudentResults(
        sessionYearId: _selectedSessionYear?.id ?? 0,
        classSectionId: _selectedClassSection?.id ?? 0,
        examId: _selectedOfflineExam?.id ?? 0);
  }

  void getMoreStudentResults() {
    context.read<OfflineExamStudentResultsCubit>().fetchMore(
        sessionYearId: _selectedSessionYear?.id ?? 0,
        classSectionId: _selectedClassSection?.id ?? 0,
        examId: _selectedOfflineExam?.id ?? 0);
  }

  Widget _buildStudentResults() {
    return BlocBuilder<OfflineExamStudentResultsCubit,
        OfflineExamStudentResultsState>(
      builder: (context, state) {
        if (state is OfflineExamStudentResultsFetchSuccess) {
          if (state.studentResults.isEmpty) {
            return Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    top: Utils.appContentTopScrollPadding(context: context) +
                        100),
                child: Container(
                  margin: EdgeInsets.all(appContentHorizontalPadding),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 64,
                        color: maroonPrimary.withOpacity(0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak Ada Data',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textDarkColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tidak ada data siswa untuk ujian ini.\nSilakan pilih ujian yang berbeda atau periksa kembali pengaturan filter.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: textMediumColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.only(
                  top:
                      Utils.appContentTopScrollPadding(context: context) + 100),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(appContentHorizontalPadding),
                    color: Theme.of(context).colorScheme.surface,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: appContentHorizontalPadding),
                          height: 40,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context).colorScheme.tertiary),
                          child:
                              LayoutBuilder(builder: (context, boxConstraints) {
                            return Row(
                              children: [
                                SizedBox(
                                  width: boxConstraints.maxWidth * (0.15),
                                  child:
                                      const CustomTextContainer(textKey: "#"),
                                ),
                                SizedBox(
                                  width: boxConstraints.maxWidth * (0.85),
                                  child: const CustomTextContainer(
                                      textKey: nameKey),
                                ),
                              ],
                            );
                          }),
                        ),
                        Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary),
                                  left: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary)),
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(5),
                                  bottomRight: Radius.circular(5)),
                              color: Theme.of(context).colorScheme.surface),
                          child: Column(
                            children: List.generate(state.studentResults.length,
                                (index) {
                              if (context
                                  .read<OfflineExamStudentResultsCubit>()
                                  .hasMore()) {
                                //
                                if (index == state.studentResults.length - 1) {
                                  if (state
                                      is OfflineExamStudentResultsFetchFailure) {
                                    return Center(
                                      child: CustomTextButton(
                                          buttonTextKey: retryKey,
                                          onTapButton: () {
                                            getMoreStudentResults();
                                          }),
                                    );
                                  }

                                  return Center(
                                    child: CustomCircularProgressIndicator(
                                      indicatorColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  );
                                }
                              }
                              return StudentOfflineResultContainer(
                                  examName: _selectedOfflineExam?.name ?? "-",
                                  studentResult: state.studentResults[index],
                                  index: index);
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }

        if (state is OfflineExamStudentResultsFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: () {
                getStudentResults();
              },
            ),
          );
        }

        return Center(
          child: CustomCircularProgressIndicator(
            indicatorColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  // Build the new modern app bar with filter options
  PreferredSizeWidget _buildHeaderSection() {
    final state =
        context.read<OfflineExamsWithClassesAndSessionYearsCubit>().state;
    final bool hasSessionYears =
        state is OfflineExamsWithClassesAndSessionYearsFetchSuccess &&
            state.sessionYears.isNotEmpty;
    final bool hasOfflineExams =
        state is OfflineExamsWithClassesAndSessionYearsFetchSuccess &&
            state.offlineExams.isNotEmpty;
    final bool hasClasses =
        state is OfflineExamsWithClassesAndSessionYearsFetchSuccess &&
            context
                .read<OfflineExamsWithClassesAndSessionYearsCubit>()
                .getAllClasses()
                .isNotEmpty;

    return CustomFilterModernAppBar(
      title: Utils.getTranslatedLabel(offlineResultKey),
      titleIcon: Icons.assignment_outlined,
      primaryColor: maroonPrimary,
      secondaryColor: maroonLight,
      onBackPressed: () {
        Navigator.pop(context);
      },
      animationController: _animationController,
      enableAnimations: true,
      height: 240.0, // Increased height to accommodate filters below title
      firstFilterItem: FilterItemConfig(
        title: _selectedSessionYear?.name ?? Utils.getTranslatedLabel(yearKey),
        icon: Icons.calendar_today_rounded,
        onTap: () {
          if (hasSessionYears) {
            final successState =
                state as OfflineExamsWithClassesAndSessionYearsFetchSuccess;
            Utils.showBottomSheet(
                child: FilterSelectionBottomsheet<SessionYear>(
                  onSelection: (value) {
                    if (value != null) {
                      changeSelectedSessionYear(value);
                      context
                          .read<OfflineExamsWithClassesAndSessionYearsCubit>()
                          .getOfflineExamsWithSessionYearsAndClasses(
                              sesstionYearId: value.id);
                      Get.back();
                    }
                  },
                  selectedValue:
                      _selectedSessionYear ?? successState.sessionYears.first,
                  titleKey: sessionYearKey,
                  values: successState.sessionYears,
                ),
                context: context);
          }
        },
      ),
      secondFilterItem: FilterItemConfig(
        title: _selectedOfflineExam?.name ?? Utils.getTranslatedLabel(examKey),
        icon: Icons.ballot_outlined,
        onTap: () {
          if (hasOfflineExams) {
            final successState =
                state as OfflineExamsWithClassesAndSessionYearsFetchSuccess;
            Utils.showBottomSheet(
                child: FilterSelectionBottomsheet<OfflineExam>(
                    onSelection: (value) {
                      if (value != null) {
                        changeSelectedOfflineExam(value);
                        getStudentResults();
                        Get.back();
                      }
                    },
                    selectedValue:
                        _selectedOfflineExam ?? successState.offlineExams.first,
                    titleKey: examKey,
                    values: successState.offlineExams),
                context: context);
          }
        },
      ),
      thirdFilterItem: FilterItemConfig(
        title: _selectedClassSection?.fullName ??
            Utils.getTranslatedLabel(classKey),
        icon: Icons.class_outlined,
        onTap: () {
          if (hasClasses) {
            final classes = context
                .read<OfflineExamsWithClassesAndSessionYearsCubit>()
                .getAllClasses();
            Utils.showBottomSheet(
                child: FilterSelectionBottomsheet<ClassSection>(
                    onSelection: (value) {
                      if (value != null) {
                        changeSelectedClassSection(value);
                        getStudentResults();
                        Get.back();
                      }
                    },
                    selectedValue: _selectedClassSection ?? classes.first,
                    titleKey: classKey,
                    values: classes),
                context: context);
          }
        },
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
        appBar: _buildHeaderSection(),
        body: BlocConsumer<OfflineExamsWithClassesAndSessionYearsCubit,
            OfflineExamsWithClassesAndSessionYearsState>(
          listener: (context, state) {
            if (state is OfflineExamsWithClassesAndSessionYearsFetchSuccess) {
              if (state.offlineExams.isNotEmpty) {
                changeSelectedOfflineExam(state.offlineExams.first);
              } else {
                changeSelectedOfflineExam(null);
              }

              if (context
                      .read<OfflineExamsWithClassesAndSessionYearsCubit>()
                      .getAllClasses()
                      .isNotEmpty &&
                  state.sessionYears.isNotEmpty) {
                if (_selectedSessionYear?.id == null) {
                  changeSelectedSessionYear(state.sessionYears
                      .where((element) => element.isThisDefault())
                      .first);
                }

                if (_selectedClassSection?.id == null) {
                  changeSelectedClassSection(context
                      .read<OfflineExamsWithClassesAndSessionYearsCubit>()
                      .getAllClasses()
                      .first);
                }

                if (state.offlineExams.isNotEmpty) {
                  getStudentResults();
                }
              }
            }
          },
          builder: (context, state) {
            if (state is OfflineExamsWithClassesAndSessionYearsFetchSuccess) {
              if (state.offlineExams.isEmpty ||
                  context
                      .read<OfflineExamsWithClassesAndSessionYearsCubit>()
                      .getAllClasses()
                      .isEmpty) {
                return Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: EdgeInsets.all(appContentHorizontalPadding),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: maroonPrimary.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak Ada Ujian',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: textDarkColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.offlineExams.isEmpty
                              ? 'Tidak ada ujian offline tersedia untuk tahun ajaran yang dipilih.'
                              : 'Tidak ada kelas tersedia untuk ujian ini.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: textMediumColor,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return _buildStudentResults();
            }

            if (state is OfflineExamsWithClassesAndSessionYearsFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context
                        .read<OfflineExamsWithClassesAndSessionYearsCubit>()
                        .getOfflineExamsWithSessionYearsAndClasses(
                            sesstionYearId: _selectedSessionYear?.id);
                  },
                ),
              );
            }

            return Center(
              child: CustomCircularProgressIndicator(
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
      ),
    );
  }
}
