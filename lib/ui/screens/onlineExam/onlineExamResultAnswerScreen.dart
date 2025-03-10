import 'dart:convert';

import 'package:eschool_saas_staff/cubits/onlineExam/onlineExamCubit.dart';
import 'package:flutter/services.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
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
  List<dynamic> _allAnswers = []; // Store all answers locally
  List<dynamic> _filteredAnswers = []; // Store filtered answers
  Map<String, TextEditingController> marksControllers = {};
  bool _isSearching = false;
  bool showSearchBar = false;

  @override
  void initState() {
    super.initState();
    // Initial load of all answers
    context.read<OnlineExamCubit>().getOnlineExamResultAnswer(
        examId: widget.examId, questionId: widget.questionId, search: '');
  }

  // Filter answers locally based on search text
  void _filterAnswers(String query) {
    setState(() {
      _isSearching = true;
      if (query.isEmpty) {
        _filteredAnswers = List.from(_allAnswers);
      } else {
        _filteredAnswers = _allAnswers
            .where((answer) =>
                (answer.studentName?.toLowerCase() ?? '')
                    .contains(query.toLowerCase()) ||
                (answer.answer.toLowerCase()).contains(query.toLowerCase()))
            .toList();
      }
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
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _buildExamCard(),
        ),
        _buildBottomSheet(context),
      ],
    );
  }

  Widget _buildSearchBar() {
    return BlocListener<OnlineExamCubit, OnlineExamState>(
      listener: (context, state) {
        if (state is OnlineExamAnswersSuccess) {
          setState(() {
            _allAnswers = state.answers;
            showSearchBar = state.answers.length >= 5;
            if (!_isSearching) {
              _filteredAnswers = List.from(_allAnswers);
            } else {
              _filterAnswers(_searchController.text);
            }
          });
        }
      },
      child: showSearchBar ?
          Padding(
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
                  _filterAnswers(value);
                },
                decoration: InputDecoration(
                  hintText: 'Cari jawaban spesifik...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[400]),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _filterAnswers('');
                              _isSearching = false;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ) : SizedBox(height: 10)
    );
  }

  Widget _buildExamCard() {
  return BlocBuilder<OnlineExamCubit, OnlineExamState>(
    builder: (context, state) {
      if (state is OnlineExamLoading && _allAnswers.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (state is OnlineExamFailure && _allAnswers.isEmpty) {
        return Center(
          child: ErrorContainer(
            errorMessage:
                "Tidak dapat terhubung ke server, mohon periksa koneksi internet anda dan coba lagi",
            onTapRetry: () {
              context.read<OnlineExamCubit>().getOnlineExamResultAnswer(
                  examId: widget.examId,
                  questionId: widget.questionId,
                  search: '');
            },
          ),
        );
      }

      if (_isSearching || _allAnswers.isNotEmpty) {
        if (_filteredAnswers.isEmpty) {
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada jawaban tersedia',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _filteredAnswers.length,
          itemBuilder: (context, index) {
            final answer = _filteredAnswers[index];
            final controller = marksControllers.putIfAbsent(
                "${answer.studentId}:${answer.id}",
                () => TextEditingController(text: answer.marks.toString()));

            return StatefulBuilder(
              builder: (context, setState) {
                bool localIsCorrect = double.parse(controller.text.isNotEmpty
                        ? controller.text
                        : '0') >=
                    (answer.totalMarks / 2);

                return FadeInUp(
                  delay: Duration(milliseconds: index * 100),
                  child: Container(
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
                          // Header dengan status nilai
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
                            child: Text(
                              answer.studentName ?? 'Unknown',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Nilai jawaban berkisar antara 0 hingga ${answer.totalMarks}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          height: 40,
                                          child: TextField(
                                            controller: controller,
                                            onChanged: (value) {
                                              setState(() {}); // Memperbarui UI lokal
                                            },
  onEditingComplete: () {
    if (controller.text.isEmpty) {
      controller.text = '0';
    }
  },

                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                              height: 1.5,
                                            ),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.grey[50],
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                    color: Colors.grey[200]!),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                            ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              TextInputFormatter.withFunction(
                                                  (oldValue, newValue) {
                                                if (newValue.text.isEmpty)
                                                  return newValue;
                                                final intValue =
                                                    int.tryParse(
                                                            newValue.text) ??
                                                        0;
                                                if (intValue < 0)
                                                  return TextEditingValue(
                                                      text: '0');
                                                if (intValue >
                                                    answer.totalMarks)
                                                  return TextEditingValue(
                                                      text: answer.totalMarks
                                                          .toString());
                                                return newValue;
                                              }),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada jawaban tersedia',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildBottomSheet(BuildContext context) {
  return Container(
    width: double.infinity, // Lebar penuh
    decoration: BoxDecoration(
      color: Colors.white, // Latar belakang tetap putih
      border: Border(
        top: BorderSide(color: Colors.grey.shade400, width: 2), // Border garis atas
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 2,
          offset: Offset(0, -2), // Bayangan ke atas
        ),
      ],
    ),
    padding: EdgeInsets.all(16),
    child: SizedBox(
      width: double.infinity, // Lebar penuh
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF8B0000), // Warna maroon
          foregroundColor: Colors.white, // Warna teks putih
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          context.read<OnlineExamCubit>().updateOnlineExamAnswerCorrection(examId: widget.examId, data: marksControllers.entries.map((entry) {
            return {
              'student_id': int.tryParse(entry.key.split(":")[0]) ?? 0,
              'marks': int.tryParse(entry.value.text) ?? 0,
              "question_id": widget.questionId ?? 0,
              "answer_id": int.tryParse(entry.key.split(":")[1]) ?? 0,
              "is_answer": (int.tryParse(entry.value.text) ?? 0) > 0 ? 1 : 0
            };
          }).toList());
        },
        child: Text(
          "Simpan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
}
