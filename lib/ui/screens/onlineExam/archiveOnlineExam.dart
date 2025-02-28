import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/onlineExam/onlineExamCubit.dart';
import 'package:eschool_saas_staff/data/models/onlineExam.dart';
import 'package:get/get.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

class ArchiveOnlineExam extends StatefulWidget {
  @override
  State<ArchiveOnlineExam> createState() => _ArchiveOnlineExamState();
}

class _ArchiveOnlineExamState extends State<ArchiveOnlineExam> {
  late String _searchController = "";

  @override
  void initState() {
    super.initState();
    _loadArchivedExams();
  }

  Future<void> _loadArchivedExams() async {
    await Future.delayed(Duration(milliseconds: 500));
    if (mounted) {
      context.read<OnlineExamCubit>().getArchivedExams();
    }
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
                        'Arsip Ujian',
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
                        'Daftar ujian yang diarsipkan',
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

  Widget _buildSearchBar() {
    return FadeInDown(
      delay: Duration(milliseconds: 200),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchController = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari ujian arsip...',
              prefixIcon: Icon(Icons.search, color: Color(0xFF8B0000)),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
      ),
    );
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
                    child: Column(
                      children: [
                        _buildSearchBar(),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadArchivedExams,
                            child:
                                BlocBuilder<OnlineExamCubit, OnlineExamState>(
                              builder: (context, state) {
                                if (state is OnlineExamLoading) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (state is OnlineExamSuccess) {
                                  if (state.archivedExams.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.archive_outlined,
                                              size: 80, color: Colors.grey),
                                          SizedBox(height: 16),
                                          Text(
                                            'Tidak ada ujian yang diarsipkan',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  var filteredExams = state.archivedExams
                                      .where((exam) =>
                                          exam.title.toLowerCase().contains(
                                              _searchController
                                                  .toLowerCase()) ||
                                          exam.subjectName
                                              .toLowerCase()
                                              .contains(_searchController
                                                  .toLowerCase()))
                                      .toList();

                                  return ListView.builder(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: filteredExams.length,
                                    itemBuilder: (context, index) {
                                      final exam = filteredExams[index];
                                      return FadeInUp(
                                        duration: Duration(
                                            milliseconds: 600 + (index * 100)),
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(16),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              exam.title,
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0xFF8B0000),
                                                              ),
                                                            ),
                                                          ),
                                                          PopupMenuButton(
                                                            icon: Icon(
                                                              Icons.more_vert,
                                                              color: Colors
                                                                  .grey[600],
                                                            ),
                                                            itemBuilder:
                                                                (context) => [
                                                              PopupMenuItem(
                                                                child: ListTile(
                                                                  leading: Icon(
                                                                      Icons
                                                                          .restore),
                                                                  title: Text(
                                                                      'Pulihkan'),
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                ),
                                                                value:
                                                                    'restore',
                                                              ),
                                                              PopupMenuItem(
                                                                child: ListTile(
                                                                  leading: Icon(
                                                                      Icons
                                                                          .delete_forever,
                                                                      color: Colors
                                                                          .red),
                                                                  title: Text(
                                                                      'Hapus Permanen',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.red)),
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                ),
                                                                value: 'delete',
                                                              ),
                                                            ],
                                                            onSelected:
                                                                (value) async {
                                                              if (value ==
                                                                  'restore') {
                                                                _showRestoreConfirmation(
                                                                    exam);
                                                              } else if (value ==
                                                                  'delete') {
                                                                _showDeleteConfirmation(
                                                                    context,
                                                                    exam);
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        exam.subjectName,
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      SizedBox(height: 12),
                                                      Row(
                                                        children: [
                                                          _buildInfoRow(
                                                            Icons
                                                                .calendar_today,
                                                            DateFormat(
                                                                    'dd MMMM yyyy HH:mm',
                                                                    'id_ID')
                                                                .format(exam
                                                                    .startDate),
                                                          ),
                                                          SizedBox(width: 16),
                                                          _buildInfoRow(
                                                            Icons.timer,
                                                            '${exam.duration} menit',
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                                return Center(
                                  child: Text('Terjadi kesalahan'),
                                );
                              },
                            ),
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
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, OnlineExam exam) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red[600],
                  size: 32,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Hapus Permanen',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Apakah Anda yakin ingin menghapus ujian ini secara permanen? Tindakan ini tidak dapat dibatalkan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Batal'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        try {
                          // Show loading
                          Get.dialog(
                            Dialog(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.red),
                                  ),
                                ),
                              ),
                            ),
                            barrierDismissible: false,
                          );

                          await context
                              .read<OnlineExamCubit>()
                              .deleteOnlineExam(
                                examId: exam.id,
                                mode: 'permanent',
                              );

                          Get.back(); // Close loading

                          Get.snackbar(
                            'Berhasil',
                            'Ujian berhasil dihapus permanen',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                        } catch (e) {
                          Get.back(); // Close loading
                          Get.snackbar(
                            'Gagal',
                            'Gagal menghapus ujian',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                      child: Text(
                        'Hapus',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showRestoreConfirmation(OnlineExam exam) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restore_rounded,
                  color: Colors.blue[600],
                  size: 32,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Pulihkan Ujian',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Apakah Anda yakin ingin memulihkan ujian ini?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Batal'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        try {
                          // Show loading
                          Get.dialog(
                            Dialog(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              child: Container(
                                padding: EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Memulihkan ujian...',
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            barrierDismissible: false,
                          );

                          await context
                              .read<OnlineExamCubit>()
                              .restoreOnlineExam(exam.id);

                          Get.back(); // Close loading

                          Get.snackbar(
                            'Berhasil',
                            'Ujian berhasil dipulihkan',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                            duration: Duration(seconds: 2),
                          );

                          await Future.delayed(Duration(milliseconds: 500));
                          Get.offAllNamed(Routes.onlineExamScreen);
                        } catch (e) {
                          Get.back(); // Close loading
                          Get.snackbar(
                            'Gagal',
                            'Gagal memulihkan ujian: ${e.toString()}',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                            duration: Duration(seconds: 3),
                          );
                        }
                      },
                      child: Text(
                        'Pulihkan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
