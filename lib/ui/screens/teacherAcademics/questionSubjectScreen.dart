import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import '../../../cubits/teacherAcademics/assignment/questionBankCubit.dart';
import '../../../data/models/question.dart';

class QuestionSubjectScreen extends StatefulWidget {
  @override
  State<QuestionSubjectScreen> createState() => _QuestionSubjectScreenState();
}

class _QuestionSubjectScreenState extends State<QuestionSubjectScreen> {

  @override
  void initState() {
    super.initState();
    // Add delay to ensure proper initialization
    Future.delayed(Duration.zero, () {
      context.read<QuestionBankCubit>().fetchTeacherSubjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B0000).withOpacity(0.9),
              Color(0xFF6B0000),
              Color(0xFF4B0000),
              Theme.of(context).colorScheme.secondary,
            ],
            stops: [0.2, 0.4, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              FadeInDown(
                duration: Duration(milliseconds: 600),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      Text(
                        'Bank Soal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: BlocBuilder<QuestionBankCubit, QuestionBankState>(
                    builder: (context, state) {
                      if (state is QuestionBankLoading) {
                        return _buildLoadingView();
                      }

                      if (state is SubjectsFetchSuccess) {
                        if (state.subjects.isEmpty) {
                          return _buildEmptyView();
                        }
                        return _buildSubjectsList(state.subjects);
                      }

                      if (state is QuestionBankError) {
                        return _buildErrorView(state.message);
                      }

                      return SizedBox();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Memuat data...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return FadeInUp(
      duration: Duration(milliseconds: 800),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.subject_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Tidak ada mata pelajaran',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return FadeInUp(
      duration: Duration(milliseconds: 800),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<QuestionBankCubit>().fetchTeacherSubjects();
              },
              icon: Icon(Icons.refresh),
              label: Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsList(List<dynamic> subjects) {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      physics: BouncingScrollPhysics(),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return FadeInUp(
          duration: Duration(milliseconds: 600 + (index * 100)),
          child: GestureDetector(
            onTap: () {
              if (subject.subject.id != 0) {
                Get.toNamed(Routes.questionBankScreen, arguments: subject);
              }
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getSubjectIcon(subject.subjectWithName),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.subjectWithName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Jumlah Bank Soal: ${subject.bankSoalCount}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
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

  IconData _getSubjectIcon(String subjectName) {
    final name = subjectName.toLowerCase();
    if (name.contains('matematika')) return Icons.functions;
    if (name.contains('bahasa')) return Icons.language;
    if (name.contains('ipa') || name.contains('sains')) return Icons.science;
    if (name.contains('ips') || name.contains('sosial')) return Icons.public;
    if (name.contains('komputer') || name.contains('informatika')) return Icons.computer;
    if (name.contains('olahraga')) return Icons.sports;
    if (name.contains('seni')) return Icons.palette;
    return Icons.subject;
  }
}