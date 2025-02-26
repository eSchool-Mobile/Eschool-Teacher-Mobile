import 'dart:convert';

import 'package:eschool_saas_staff/cubits/onlineExam/onlineExamCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

class OnlineExamResultScreen extends StatefulWidget {
  @override
  _OnlineExamResultScreenState createState() => _OnlineExamResultScreenState();
}

class _OnlineExamResultScreenState extends State<OnlineExamResultScreen> {
  late String _searchController = "";

  @override
  void initState() {
    super.initState();
    context.read<OnlineExamCubit>().getOnlineExams(getFull: false);
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
        // borderRadius: 0,
        // blur: 20,
        // alignment: Alignment.center,
        // border: 0,
        // linearGradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [
        //     Colors.white.withOpacity(0.1),
        //     Colors.white.withOpacity(0.05),
        //   ],
        // ),
        // borderGradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [
        //     Colors.white.withOpacity(0.5),
        //     Colors.white.withOpacity(0.2),
        //   ],
        // ),
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
                        'Hasil Ujian Online',
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
                        'Daftar Nilai Ujian',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.filter_list, color: Colors.white),
                onPressed: () {},
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
        await context
            .read<OnlineExamCubit>()
            .getOnlineExams(getFull: true, search: _searchController);
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
              context
                  .read<OnlineExamCubit>()
                  .getOnlineExams(getFull: true, search: value);
              _searchController = value;
            },
            decoration: InputDecoration(
              hintText: 'Cari hasil ujian...',
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

  Widget _buildExamCard() {
    return BlocBuilder<OnlineExamCubit, OnlineExamState>(
      builder: (context, state) {
        if (state is OnlineExamLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is OnlineExamFailure) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is OnlineExamSuccess) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.exams.length,
            itemBuilder: (context, index) {
              final exam = state.exams[index];
              return GestureDetector(
                  onTap: () {
                    if (exam.status == 2) {
                      Get.toNamed(
                          "/OnlineExamResultQuestionsScreen/${exam.id}/${base64.encode(utf8.encode(exam.title))}");
                    }
                  },
                  child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        exam.title ?? 'Tidak ada ujian',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF8B0000),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: exam.status == 0
                                              ? Colors.orange.withOpacity(0.1)
                                              : exam.status == 1
                                                  ? Colors.blue.withOpacity(0.1)
                                                  : Colors.green
                                                      .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          (exam.status == 0
                                              ? 'Belum Dimulai'
                                              : exam.status == 1
                                                  ? 'Sedang Berlangsung'
                                                  : 'Selesai'),
                                          style: TextStyle(
                                            color: exam.status == 0
                                                ? Colors.orange
                                                : exam.status == 1
                                                    ? Colors.blue
                                                    : Colors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    exam.title ?? 'Tidak ada judul',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildInfoRow(
                                          Icons.calendar_today,
                                          DateFormat('dd MMMM yyyy HH:mm',
                                                      'id_ID')
                                                  .format(exam.startDate) ??
                                              'No date'),
                                      SizedBox(width: 16),
                                      _buildInfoRow(Icons.timer,
                                          '${exam.duration} menit'),
                                      SizedBox(width: 16),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )));
            },
          );
        }
        return Center(child: Text('No data available'));
      },
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
}
