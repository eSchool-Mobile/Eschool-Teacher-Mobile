import 'dart:convert';

import 'package:eschool_saas_staff/cubits/onlineExam/onlineExamCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

class OnlineExamResultAnswerScreen extends StatefulWidget {
  final int examId;
  final int questionId;
  final String examName;
  final String questionType;

  const OnlineExamResultAnswerScreen(
      {Key? key,
      required this.examId,
      required this.questionId,
      required this.examName,
      required this.questionType})
      : super(key: key);

  @override
  _OnlineExamResultAnswerScreenState createState() =>
      _OnlineExamResultAnswerScreenState();
}

class _OnlineExamResultAnswerScreenState
    extends State<OnlineExamResultAnswerScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OnlineExamCubit>().getOnlineExamResultAnswer(
        examId: widget.examId,
        questionId: widget.questionId,
        search: _searchController.text);
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
              _buildAnimatedHeader(),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: _buildBody(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return FadeInDown(
      duration: Duration(milliseconds: 800),
      child: Container(
        width: double.infinity,
        height: 100,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lihat Jawaban Siswa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${widget.examName}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<OnlineExamCubit>().getOnlineExamResultAnswer(
            examId: widget.examId,
            questionId: widget.questionId,
            search: _searchController.text);
      },
      child: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildExamCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return FadeInDown(
      delay: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              context.read<OnlineExamCubit>().getOnlineExamResultAnswer(
                  examId: widget.examId,
                  questionId: widget.questionId,
                  search: value);
            },
            decoration: InputDecoration(
              hintText: 'Cari jawaban spesifik...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExamCard() {
    return BlocBuilder<OnlineExamCubit, OnlineExamState>(
      builder: (context, state) {
        if (state is OnlineExamLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is OnlineExamFailure) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is OnlineExamAnswersSuccess) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.answers.length,
            itemBuilder: (context, index) {
              final answer = state.answers[index];
              bool localIsCorrect = answer.isCorrect ?? false;

              return FadeInUp(
                delay: Duration(milliseconds: index * 100),
                child: StatefulBuilder(
                  // Added StatefulBuilder
                  builder: (context, setState) => Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with student name and status
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: localIsCorrect
                                    ? [
                                        Colors.green.shade400,
                                        Colors.green.shade300
                                      ]
                                    : [
                                        Colors.red.shade400,
                                        Colors.red.shade300
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  answer.studentName ?? 'Unknown',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      localIsCorrect
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      localIsCorrect ? 'Benar' : 'Salah',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding:
                                EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: 50,
                                maxHeight: 200,
                              ),
                              child: SingleChildScrollView(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: Colors.grey[200]!),
                                    ),
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      answer.answer,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    (widget.questionType != 'multiple_choice' &&
                                            widget.questionType != 'true_false')
                                        ? 16
                                        : 8),
                            margin: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: widget.questionType != 'multiple_choice' &&
                                    widget.questionType != 'true_false'
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            final result = await context
                                                .read<OnlineExamCubit>()
                                                .updateOnlineExamAnswerCorrection(
                                                    examId: widget.examId,
                                                    studentId: answer.studentId,
                                                    questionId:
                                                        widget.questionId,
                                                    answerId: answer.id,
                                                    isAnswer: 1);
                                            if (result) {
                                              setState(() {
                                                answer.isCorrect = true;
                                                localIsCorrect = true;
                                              });
                                            }
                                          },
                                          child: Container(
                                            height: 48,
                                            margin: EdgeInsets.only(
                                                left: 16, right: 8),
                                            decoration: BoxDecoration(
                                              color: localIsCorrect
                                                  ? Colors.green.shade50
                                                  : Colors.white,
                                              border: Border.all(
                                                color: localIsCorrect
                                                    ? Colors.green
                                                    : Colors.grey[300]!,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: localIsCorrect
                                                      ? Colors.green
                                                      : Colors.grey[600],
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Benar',
                                                  style: TextStyle(
                                                    color: localIsCorrect
                                                        ? Colors.green
                                                        : Colors.grey[600],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            final result = await context
                                                .read<OnlineExamCubit>()
                                                .updateOnlineExamAnswerCorrection(
                                                    examId: widget.examId,
                                                    studentId: answer.studentId,
                                                    questionId:
                                                        widget.questionId,
                                                    answerId: answer.id,
                                                    isAnswer: 0);
                                            if (result) {
                                              setState(() {
                                                answer.isCorrect = false;
                                                localIsCorrect = false;
                                              });
                                            }
                                          },
                                          child: Container(
                                            height: 48,
                                            margin: EdgeInsets.only(
                                                left: 8, right: 16),
                                            decoration: BoxDecoration(
                                              color: !localIsCorrect
                                                  ? Colors.red.shade50
                                                  : Colors.white,
                                              border: Border.all(
                                                color: !localIsCorrect
                                                    ? Colors.red
                                                    : Colors.grey[300]!,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.cancel,
                                                  color: !localIsCorrect
                                                      ? Colors.red
                                                      : Colors.grey[600],
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Salah',
                                                  style: TextStyle(
                                                    color: !localIsCorrect
                                                        ? Colors.red
                                                        : Colors.grey[600],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
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
        return Center(child: Text('Tidak ada data'));
      },
    );
  }
}
