import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/BankOnlineQuestion.dart';
import 'package:eschool_saas_staff/cubits/questionOnlineExam/questionOnlineExamCubit.dart';
import 'package:eschool_saas_staff/ui/screens/onlineExam/PreviewQuestionBankSoal.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:get/get.dart' as getx;
import 'package:animate_do/animate_do.dart';

class BankSoalSelectionScreen extends StatefulWidget {
  final int examId;

  const BankSoalSelectionScreen({
    Key? key,
    required this.examId,
  }) : super(key: key);

  @override
  State<BankSoalSelectionScreen> createState() =>
      _BankSoalSelectionScreenState();
}

class _BankSoalSelectionScreenState extends State<BankSoalSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<BankSoalQuestion> _filteredBanks = [];
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    context.read<QuestionOnlineExamCubit>().getBankSoal(widget.examId);
  }

  @override
  void dispose() {
    _searchController.dispose();
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
              // Custom App Bar
              FadeInDown(
                duration: Duration(milliseconds: 600),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => getx.Get.back(),
                      ),
                      Expanded(
                        child: Text(
                          'Pilih Bank Soal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
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
                  child: BlocBuilder<QuestionOnlineExamCubit,
                      QuestionOnlineExamState>(
                    builder: (context, state) {
                      if (state is QuestionBanksLoading) {
                        return _buildLoadingView();
                      }

                      if (state is QuestionBanksLoaded) {
                        return _buildContent(state);
                      }

                      if (state is QuestionOnlineExamFailure) {
                        return _buildErrorView('Gagal memuat bank soal');
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
              color: Colors.red[400],
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
              Icons.source_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Tidak ada bank soal yang tersedia',
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

  Widget _buildBankList(List<BankSoalQuestion> banks) {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: banks.length,
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final bank = banks[index];
        return FadeInUp(
          duration: Duration(milliseconds: 600 + (index * 100)),
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () {
                // Debug print untuk memastikan data yang dikirim
                print('Selected Bank: ${bank.name}');
                print('Exam ID: ${widget.examId}');
                print('Class Section ID: ${bank.classSectionId}');
                print('Class Subject ID: ${bank.classSubjectId}');

                // Perbaiki navigasi menggunakan Get.toNamed
                getx.Get.toNamed(
                  Routes.previewQuestionBank,
                  arguments: {
                    'bank': bank,
                    'examId': widget.examId,
                    'classSectionId': bank.classSectionId,
                    'classSubjectId': bank.classSubjectId,
                  },
                );
              },
              child: Container(
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
                child: Stack(
                  children: [
                    Container(
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
                              Icons.quiz,
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
                                  bank.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Jumlah Soal: ${bank.soal.length}',
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
                            color: Colors.white.withOpacity(0.8),
                            size: 20,
                          ),
                        ],
                      ),
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

  void _filterBanks(String query, List<BankSoalQuestion> banks) {
    setState(() {
      if (query.isEmpty) {
        _filteredBanks = banks;
      } else {
        _filteredBanks = banks
            .where(
                (bank) => bank.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Widget _buildContent(QuestionBanksLoaded state) {
    _filteredBanks = state.banks;
    _showSearch = state.banks.length > 5;

    if (state.banks.isEmpty) {
      return _buildEmptyView();
    }

    return Column(
      children: [
        if (_showSearch)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (query) => _filterBanks(query, state.banks),
              decoration: InputDecoration(
                hintText: 'Cari bank soal...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        Expanded(
          child: _buildBankList(_filteredBanks),
        ),
      ],
    );
  }
}
