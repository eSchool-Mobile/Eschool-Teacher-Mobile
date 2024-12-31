import 'dart:math';

import 'package:eschool_saas_staff/cubits/academics/sessionYearsCubit.dart';
import 'package:eschool_saas_staff/cubits/payRoll/downloadPayRollSlipCubit.dart';
import 'package:eschool_saas_staff/cubits/payRoll/myPayRollCubit.dart';
import 'package:eschool_saas_staff/data/models/payRoll.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/downloadPayRollSlipDialog.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/textWithFadedBackgroundContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';

class MyPayrollScreen extends StatefulWidget {
  const MyPayrollScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SessionYearsCubit(),
        ),
        BlocProvider(create: (context) => MyPayRollCubit())
      ],
      child: const MyPayrollScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<MyPayrollScreen> createState() => _MyPayrollScreenState();
}

class _MyPayrollScreenState extends State<MyPayrollScreen> {
  SessionYear? _selectedSessionYear;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<SessionYearsCubit>().getSessionYears();
      }
    });
  }

  void changeSelectedSessionYear(SessionYear value) {
    _selectedSessionYear = value;
    setState(() {});
    getPayRoll();
  }

  void getPayRoll() {
    context
        .read<MyPayRollCubit>()
        .getMyPayRoll(sessionYearId: _selectedSessionYear?.id ?? 0);
  }

  Widget _buildPayRolls() {
    return BlocBuilder<MyPayRollCubit, MyPayRollState>(
      builder: (context, state) {
        if (state is MyPayRollFetchSuccess) {
          if (state.payrolls.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: Utils.appContentTopScrollPadding(context: context) + 110,
                ),
                child: CustomTextContainer(
                  textKey: Utils.getTranslatedLabel('Gaji Belum Turun'),
                ),
              ),
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: 25,
                  top: Utils.appContentTopScrollPadding(context: context) + 90),
              child: Container(
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
                      child: LayoutBuilder(builder: (context, boxConstraints) {
                        return Row(
                          children: [
                            SizedBox(
                              width: boxConstraints.maxWidth * (0.125),
                              child: CustomTextContainer(
                                textKey: "No",
                                style: TextStyle(
                                    fontSize: Utils.getScaledValue(context, 15),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(
                              width: boxConstraints.maxWidth * (0.525),
                              child: CustomTextContainer(
                                textKey: monthKey,
                                style: TextStyle(
                                    fontSize: Utils.getScaledValue(context, 15),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(
                              width: boxConstraints.maxWidth * (0.3),
                              child: CustomTextContainer(
                                textKey: statusKey,
                                style: TextStyle(
                                    fontSize: Utils.getScaledValue(context, 15),
                                    fontWeight: FontWeight.w500),
                              ),
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
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                              left: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.tertiary)),
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5)),
                          color: Theme.of(context).colorScheme.surface),
                      child: Column(
                        children: List.generate(
                            state.payrolls.length,
                            (index) => MyPayrollDetailsContainer(
                                payRoll: state.payrolls[index], index: index)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }

        if (state is MyPayRollFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: () {
                getPayRoll();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        BlocBuilder<SessionYearsCubit, SessionYearsState>(
          builder: (context, state) {
            if (state is SessionYearsFetchSuccess) {
              if (state.sessionYears.isNotEmpty) {
                return _buildPayRolls();
              }
              return const SizedBox();
            }

            if (state is SessionYearsFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context.read<SessionYearsCubit>().getSessionYears();
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
        Align(
          alignment: Alignment.topCenter,
          child: BlocConsumer<SessionYearsCubit, SessionYearsState>(
            listener: (context, state) {
              if (state is SessionYearsFetchSuccess &&
                  state.sessionYears.isNotEmpty) {
                changeSelectedSessionYear(state.sessionYears
                    .where((element) => element.isThisDefault())
                    .toList()
                    .first);
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  const CustomAppbar(titleKey: myPayRollKey),
                  AppbarFilterBackgroundContainer(
                      child: LayoutBuilder(builder: (context, boxConstraints) {
                    return FilterButton(
                        onTap: () {
                          if (state is SessionYearsFetchSuccess &&
                              state.sessionYears.isNotEmpty) {
                            Utils.showBottomSheet(
                                child: FilterSelectionBottomsheet<SessionYear>(
                                    onSelection: (value) {
                                      changeSelectedSessionYear(value!);
                                      Get.back();
                                    },
                                    selectedValue: _selectedSessionYear!,
                                    titleKey: sessionYearKey,
                                    values: state.sessionYears),
                                context: context);
                          }
                        },
                        titleKey: _selectedSessionYear?.id == null
                            ? sessionYearKey
                            : _selectedSessionYear!.name ?? "-",
                        width: boxConstraints.maxWidth);
                  }))
                ],
              );
            },
          ),
        )
      ],
    ));
  }
}

class MyPayrollDetailsContainer extends StatefulWidget {
  final int index;
  final PayRoll payRoll;
  const MyPayrollDetailsContainer(
      {super.key, required this.index, required this.payRoll});

  @override
  State<MyPayrollDetailsContainer> createState() =>
      _MyPayrollDetailsContainerState();
}

class _MyPayrollDetailsContainerState extends State<MyPayrollDetailsContainer>
    with TickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: tileCollapsedDuration);

  //
  late final Animation<double> _heightAnimation = Tween<double>(
          begin: Utils().getResponsiveHeight(context, 175),
          end: Utils().getResponsiveHeight(context, 340))
      .animate(CurvedAnimation(
          parent: _animationController, curve: const Interval(0.0, 0.5)));

  late final Animation<double> _opacityAnimation =
      Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
          parent: _animationController, curve: const Interval(0.5, 1.0)));

  late final Animation<double> _iconAngleAnimation =
      Tween<double>(begin: 0, end: 180).animate(CurvedAnimation(
          parent: _animationController, curve: Curves.easeInOut));

  String _formatToRupiah(double? value) {
    if (value == null) return "Rp -";
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  String getIndonesianMonth(int monthNumber) {
    const List<String> indonesianMonths = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    if (monthNumber >= 1 && monthNumber <= 12) {
      return indonesianMonths[monthNumber - 1];
    }
    return 'Bulan tidak valid';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  ///[To display days, start and to date for the applied leave]
  Widget _buildLeaveDaysAndDateContainer(
      {required String title, required String value}) {
    final titleStyle = TextStyle(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.76),
        fontSize: Utils.getScaledValue(context, 15));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return Row(
          children: [
            SizedBox(
              width: boxConstraints.maxWidth * (0.4),
              child: CustomTextContainer(
                textKey: title,
                style: titleStyle,
              ),
            ),
            CustomTextContainer(
              textKey: ":",
              style: titleStyle,
            ),
            const Spacer(),
            CustomTextContainer(
              textKey: value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: Utils.getScaledValue(context, 15),
              ),
            )
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              height: _heightAnimation.value,
              padding: EdgeInsets.symmetric(
                  vertical: appContentHorizontalPadding,
                  horizontal: appContentHorizontalPadding),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary))),
              child: LayoutBuilder(builder: (context, boxConstraints) {
                return Column(
                  children: [
                    Row(
                      children: [
                        CustomTextContainer(
                            textKey: (widget.index + 1).toString()),
                        const Spacer(),
                        SizedBox(
                          width: boxConstraints.maxWidth * (0.475),
                          child: CustomTextContainer(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textKey:
                                "${getIndonesianMonth(widget.payRoll.month ?? 1)} - ${widget.payRoll.year ?? ''}",
                            style: TextStyle(
                              fontSize: Utils.getScaledValue(context, 13.5),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: boxConstraints.maxWidth * (0.475),
                          child: Row(
                            children: [
                              TextWithFadedBackgroundContainer(
                                  backgroundColor: Theme.of(context)
                                      .extension<CustomColors>()!
                                      .totalStaffOverviewBackgroundColor!
                                      .withOpacity(0.1),
                                  textColor: Theme.of(context)
                                      .extension<CustomColors>()!
                                      .totalStaffOverviewBackgroundColor!,
                                  titleKey: paidKey),
                              const Spacer(),
                              Transform.rotate(
                                angle: (pi * _iconAngleAnimation.value) / 180,
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4.0,
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: boxConstraints.maxWidth * (0.48),
                              child: CustomTextContainer(
                                textKey: basicSalaryKey,
                                style: TextStyle(
                                    fontSize: Utils.getScaledValue(context, 14),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.76)),
                              )),
                          SizedBox(
                              width: boxConstraints.maxWidth * (0.48),
                              child: CustomTextContainer(
                                textKey: netSalaryKey,
                                style: TextStyle(
                                    fontSize: Utils.getScaledValue(context, 14),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.76)),
                              )),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ///[Basic salary]
                        SizedBox(
                            width: boxConstraints.maxWidth * (0.48),
                            child: CustomTextFieldContainer(
                                enabled: false,
                                height:
                                    Utils().getResponsiveHeight(context, 50),
                                hintTextKey: _formatToRupiah(
                                    widget.payRoll.basicSalary))),

                        ///[Net salary]
                        SizedBox(
                            width: boxConstraints.maxWidth * (0.48),
                            child: CustomTextFieldContainer(
                                enabled: false,
                                height:
                                    Utils().getResponsiveHeight(context, 50),
                                hintTextKey:
                                    _formatToRupiah(widget.payRoll.amount)))
                      ],
                    ),
                    _animationController.value > 0.5
                        ? Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(top: 10.0),
                              padding: const EdgeInsets.all(15),
                              width: boxConstraints.maxWidth,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                              child: Opacity(
                                opacity: _opacityAnimation.value,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLeaveDaysAndDateContainer(
                                        title: monthlyAllowedPaidLeavesKey,
                                        value: widget.payRoll.paidLeaves
                                                ?.toStringAsFixed(0) ??
                                            "-"),
                                    _buildLeaveDaysAndDateContainer(
                                        title: monthlyTakenLeavesKey,
                                        value: widget.payRoll.takenLeaves
                                                ?.toStringAsFixed(0) ??
                                            "-"),
                                    Center(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 20),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            borderRadius:
                                                BorderRadius.circular(6.0)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: CustomTextButton(
                                            buttonTextKey:
                                                downloadSalarySlipKey,
                                            icon: const Icon(
                                                Icons.download_rounded,
                                                color: Colors.white),
                                            textStyle: TextStyle(
                                                fontSize: Utils.getScaledValue(
                                                    context, 14),
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white),
                                            onTapButton: () {
                                              Get.dialog(BlocProvider(
                                                create: (context) =>
                                                    DownloadPayRollSlipCubit(),
                                                child:
                                                    DownloadPayRollSlipDialog(
                                                        payRoll:
                                                            widget.payRoll),
                                              ));
                                            }),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                );
              }),
            ),
          );
        });
  }
}
