import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/examStatus/examStatusCubit.dart';
import 'package:eschool_saas_staff/cubits/onlineExam/onlineExamCubit.dart';
import 'package:eschool_saas_staff/data/models/onlineExam.dart';
import 'package:eschool_saas_staff/data/models/studentExamStatus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ExamStatusScreen extends StatefulWidget {
  const ExamStatusScreen({Key? key}) : super(key: key);

  static Route<dynamic> route() {
    return MaterialPageRoute(builder: (_) => const ExamStatusScreen());
  }

  static Widget getRouteInstance() {
    return const ExamStatusScreen();
  }

  @override
  State<ExamStatusScreen> createState() => _ExamStatusScreenState();
}

class _ExamStatusScreenState extends State<ExamStatusScreen> {
  OnlineExam? selectedExam;

  @override
  void initState() {
    super.initState();
    context.read<OnlineExamCubit>().getOnlineExams();
  }

  void _refreshExamStatus() {
    if (selectedExam != null) {
      context.read<ExamStatusCubit>().getStudentExamStatus(selectedExam!.id);
    }
  }

  Widget _buildStatusIndicator(int status) {
    final bool isActive = status == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.blue.withOpacity(0.2)
            : Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.hourglass_top : Icons.check_circle,
            size: 16,
            color: isActive ? Colors.blue : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? "Sedang Mengerjakan" : "Selesai",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.blue : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamDropdown(List<OnlineExam> exams) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<OnlineExam>(
          isExpanded: true,
          hint: const Text("Pilih Ujian"),
          value: selectedExam,
          items: exams.map((exam) {
            return DropdownMenuItem<OnlineExam>(
              value: exam,
              child: Text(exam.title),
            );
          }).toList(),
          onChanged: (exam) {
            if (exam != null) {
              setState(() {
                selectedExam = exam;
              });
              context.read<ExamStatusCubit>().getStudentExamStatus(exam.id);
            }
          },
        ),
      ),
    );
  }

  Widget _buildStudentStatusList(List<StudentExamStatus> statuses) {
    if (statuses.isEmpty) {
      return _NoDataContainer(
        title: "Tidak ada data status ujian",
        message: "Belum ada siswa yang mengerjakan ujian ini",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: statuses.length,
      itemBuilder: (context, index) {
        final status = statuses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            status.className,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusIndicator(status.status),
                  ],
                ),
                const Divider(height: 24),
                if (status.startTime != null) ...[
                  _buildTimeInfo(
                    "Waktu Mulai",
                    status.startTime ?? "-",
                    Icons.play_circle_outline,
                    Colors.blue,
                  ),
                  const SizedBox(height: 8),
                ],
                if (status.status == 2 && status.endTime != null) ...[
                  _buildTimeInfo(
                    "Waktu Selesai",
                    status.endTime ?? "-",
                    Icons.stop_circle_outlined,
                    Colors.red,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: const Text(
          "Status Siswa Ujian",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _CustomRefreshIndicator(
        onRefresh: () async {
          if (selectedExam != null) {
            context
                .read<ExamStatusCubit>()
                .getStudentExamStatus(selectedExam!.id);
          } else {
            context.read<OnlineExamCubit>().getOnlineExams();
          }
        },
        child: BlocBuilder<OnlineExamCubit, OnlineExamState>(
          builder: (context, state) {
            if (state is OnlineExamSuccess) {
              if (state.exams.isEmpty) {
                return _NoDataContainer(
                  title: "Tidak ada ujian",
                  message: "Belum ada ujian yang dibuat",
                );
              }

              return Column(
                children: [
                  _buildExamDropdown(state.exams),
                  Expanded(
                    child: BlocBuilder<ExamStatusCubit, ExamStatusState>(
                      builder: (context, statusState) {
                        if (selectedExam == null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/images/exam_icon.svg",
                                  height: 100,
                                  width: 100,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Pilih ujian untuk melihat status siswa",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (statusState is ExamStatusLoading) {
                          return const Center(
                            child: _CustomCircularProgressIndicator(),
                          );
                        }

                        if (statusState is ExamStatusFailure) {
                          return _ErrorContainer(
                            errorMessage: statusState.errorMessage,
                            onTapRetry: _refreshExamStatus,
                          );
                        }

                        if (statusState is ExamStatusSuccess) {
                          return _buildStudentStatusList(
                            statusState.studentExamStatuses,
                          );
                        }

                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              );
            }

            if (state is OnlineExamFailure) {
              return _ErrorContainer(
                errorMessage: state.message,
                onTapRetry: () {
                  context.read<OnlineExamCubit>().getOnlineExams();
                },
              );
            }

            return const Center(
              child: _CustomCircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

// Internal custom widgets implementations

class _CustomCircularProgressIndicator extends StatelessWidget {
  const _CustomCircularProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      color: Colors.deepPurple,
      strokeWidth: 3,
    );
  }
}

class _CustomRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const _CustomRefreshIndicator(
      {Key? key, required this.onRefresh, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Colors.deepPurple,
      backgroundColor: Colors.white,
      displacement: 40,
      strokeWidth: 3,
      child: child,
    );
  }
}

class _ErrorContainer extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onTapRetry;

  const _ErrorContainer(
      {Key? key, required this.errorMessage, required this.onTapRetry})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            "Terjadi kesalahan",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onTapRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Coba Lagi",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoDataContainer extends StatelessWidget {
  final String title;
  final String message;

  const _NoDataContainer({Key? key, required this.title, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 70,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
