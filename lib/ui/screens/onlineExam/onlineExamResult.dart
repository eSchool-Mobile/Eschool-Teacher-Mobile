import 'dart:convert';
import 'package:eschool_saas_staff/cubits/onlineExam/onlineExamCubit.dart';
import 'package:eschool_saas_staff/data/models/exam.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
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
  late final _searchController = TextEditingController(); // Diubah jadi TextEditingController
  bool _showSearchBar = false;
  bool _isSearching = false;
  String _selectedFilter = "Semua"; // Variabel untuk filter (default Semua)
  DateTime? _startDate; // State utama
  DateTime? _endDate;   // State utama

  @override
  void initState() {
    super.initState();
    context.read<OnlineExamCubit>().getOnlineExams();
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose controller
    super.dispose();
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
              _buildAnimatedHeader(context),
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

  Widget _buildAnimatedHeader(BuildContext context) {
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
                        'Daftar Ujian Online',
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
                onPressed: () {
                  _showFilterBottomSheet(context); // Panggil dengan context utama
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Judul
                  Text(
                    'Filter Status Ujian',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B0000),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Input Tanggal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: modalContext,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setModalState(() {
                                _startDate = picked;
                                parentContext.read<OnlineExamCubit>().getOnlineExams(
                                  search: _searchController.text,
                                  startDate: _startDate,
                                  endDate: _endDate,
                                );
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _startDate != null
                                  ? DateFormat('dd/MM/yyyy').format(_startDate!)
                                  : 'Dari',
                              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '-',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: modalContext,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setModalState(() {
                                _endDate = picked;
                                parentContext.read<OnlineExamCubit>().getOnlineExams(
                                  search: _searchController.text,
                                  startDate: _startDate,
                                  endDate: _endDate,
                                );
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _endDate != null
                                  ? DateFormat('dd/MM/yyyy').format(_endDate!)
                                  : 'Sampai',
                              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Filter Status
                  Column(
                    children: [
                      _buildFilterOption('Semua', setModalState, parentContext),
                      _buildFilterOption('Selesai', setModalState, parentContext),
                      _buildFilterOption('Belum Dimulai', setModalState, parentContext),
                      _buildFilterOption('Sedang Berlangsung', setModalState, parentContext),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(String label, StateSetter setModalState, BuildContext parentContext) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _selectedFilter = label;
              parentContext.read<OnlineExamCubit>().getOnlineExams(
                search: _searchController.text,
                startDate: _startDate,
                endDate: _endDate,
              );
            });
            setModalState(() {});
            Navigator.pop(context);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                Radio<String>(
                  value: label,
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value ?? 'Semua';
                      parentContext.read<OnlineExamCubit>().getOnlineExams(
                        search: _searchController.text,
                        startDate: _startDate,
                        endDate: _endDate,
                      );
                    });
                    setModalState(() {});
                    Navigator.pop(context);
                  },
                  activeColor: Color(0xFF8B0000),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isSearching = _searchController.text.isNotEmpty;
        });
        await context.read<OnlineExamCubit>().getOnlineExams(
          search: _searchController.text,
          startDate: _startDate,
          endDate: _endDate,
        );
      },
      child: Column(
        children: [
          if (_showSearchBar) _buildSearchBar(),
          if (!_showSearchBar) SizedBox(height: 20),
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
            controller: _searchController, // Gunakan controller
            onChanged: (value) {
              setState(() {
                _isSearching = value.isNotEmpty;
              });
              context.read<OnlineExamCubit>().getOnlineExams(
                search: value,
                startDate: _startDate,
                endDate: _endDate,
              );
            },
            decoration: InputDecoration(
              hintText: 'Cari hasil ujian...',
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
          return Center(child: CircularProgressIndicator());
        }
        if (state is OnlineExamFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage:
                  "Tidak dapat terhubung ke server, mohon periksa koneksi internet anda dan coba lagi",
              onTapRetry: () {
                context.read<OnlineExamCubit>().getOnlineExams();
              },
            ),
          );
        }
        if (state is OnlineExamSuccess) {
          if (state.exams.length > 5 && !_showSearchBar) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _showSearchBar = true;
              });
            });
          }

          final filteredExams = state.exams.where((exam) {
            if (_selectedFilter == "Semua") return true;
            if (_selectedFilter == "Belum Dimulai") return exam.status == 0;
            if (_selectedFilter == "Sedang Berlangsung") return exam.status == 1;
            if (_selectedFilter == "Selesai") return exam.status == 2;
            return false;
          }).toList()..sort((a, b) => b.startDate.compareTo(a.startDate));

          if (filteredExams.isEmpty) {
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
                        _isSearching
                            ? 'Tidak ada ujian yang cocok'
                            : 'Tidak ada ujian tersedia untuk filter ini',
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
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredExams.length,
            itemBuilder: (context, index) {
              final exam = filteredExams[index];
              return GestureDetector(
                onTap: () {
                  if (exam.status == 2) {
                    Get.toNamed(
                        "/OnlineExamResultQuestionsScreen/${exam.id}/${base64.encode(utf8.encode(exam.title))}");
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16), // Ganti 'custom' jadi 'bottom' kalau typo
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      exam.title ?? 'Tidak ada Judul',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8B0000),
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: exam.status == 0
                                          ? Colors.orange.withOpacity(0.1)
                                          : exam.status == 1
                                              ? Colors.blue.withOpacity(0.1)
                                              : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
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
                                exam.subjectName ?? 'Tidak ada Nama Mata Pelajaran',
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
                                      DateFormat('dd MMMM yyyy HH:mm', 'id_ID')
                                              .format(exam.startDate) ??
                                          'No date'),
                                  SizedBox(width: 16),
                                  _buildInfoRow(
                                      Icons.timer, '${exam.duration} menit'),
                                  SizedBox(width: 16),
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