import 'package:eschool_saas_staff/cubits/payRoll/allowancesAndDeductionsCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/allowancesAndDeductionsContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customModernAppBar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eschool_saas_staff/ui/widgets/customErrorWidget.dart';
import 'package:eschool_saas_staff/utils/errorMessageUtils.dart';

class AllowancesAndDeductionsScreen extends StatefulWidget {
  const AllowancesAndDeductionsScreen({super.key});

  static Widget getRouteInstance() {
    return BlocProvider(
      create: (context) => AllowancesAndDeductionsCubit(),
      child: const AllowancesAndDeductionsScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<AllowancesAndDeductionsScreen> createState() =>
      _AllowancesAndDeductionsScreenState();
}

class _AllowancesAndDeductionsScreenState
    extends State<AllowancesAndDeductionsScreen> with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  final ScrollController _scrollController = ScrollController();
  final Color _maroonPrimary = const Color(0xFF800020);
  final Color _maroonLight = const Color(0xFFAA6976);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fabAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    context.read<AllowancesAndDeductionsCubit>().fetchAllowancesAndDeductions();
  }

  void _scrollListener() {
    if (_scrollController.offset > 50) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Informasi tunjangan dan potongan gaji staff',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.1, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildContent(AllowancesAndDeductionsFetchSuccess state) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<AllowancesAndDeductionsCubit>()
            .fetchAllowancesAndDeductions();
      },
      color: _maroonPrimary,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 120, top: 0),
        child: Column(
          children: [
            _buildHeader(),

            // Enhanced container with better spacing
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: AllowancesAndDeductionsContainer(
                allowances: state.allowances,
                deductions: state.deductions,
                baseSalary:
                    5000000.0, // Default base salary for calculation, you can get this from user context
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(
                  begin: 0.03,
                  end: 0,
                  curve: Curves.easeOutCubic,
                  duration: 600.ms,
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomModernAppBar(
        title: 'Tunjangan & Potongan',
        icon: Icons.account_balance_wallet,
        fabAnimationController: _fabAnimationController,
        primaryColor: _maroonPrimary,
        lightColor: _maroonLight,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: BlocBuilder<AllowancesAndDeductionsCubit,
          AllowancesAndDeductionsState>(
        builder: (context, state) {
          if (state is AllowancesAndDeductionsFetchSuccess) {
            return _buildContent(state);
          }
          if (state is AllowancesAndDeductionsFetchFailure) {
            return Center(
              child: CustomErrorWidget(
                message: ErrorMessageUtils.getReadableErrorMessage(
                    state.errorMessage),
                onRetry: () {
                  context
                      .read<AllowancesAndDeductionsCubit>()
                      .fetchAllowancesAndDeductions();
                },
                primaryColor: _maroonPrimary,
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomCircularProgressIndicator(
                  indicatorColor: _maroonPrimary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Memuat data tunjangan & potongan...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms);
        },
      ),
    );
  }
}
